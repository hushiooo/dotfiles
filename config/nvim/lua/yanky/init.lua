local M = {}

local config = {
    max_items = 200,
    history_path = vim.fn.stdpath("data") .. "/yanky_history.json",
    paste_mode = "p",
    auto_paste_on_select = true,
    save_debounce_ms = 500,
}

local yank_history = {}
local save_timer = nil

local function truncate(str, max)
    return #str > max and str:sub(1, max) .. "…" or str
end

local function deduplicate(text)
    for i = #yank_history, 1, -1 do
        if yank_history[i].text == text then
            table.remove(yank_history, i)
        end
    end
end

local function cap_history()
    while #yank_history > config.max_items do
        yank_history[#yank_history] = nil
    end
end

local function load_history()
    local f = io.open(config.history_path, "r")
    if not f then return end
    local raw = f:read("*a")
    f:close()
    if not raw or raw == "" then return end
    local ok, decoded = pcall(vim.json.decode, raw)
    if ok and type(decoded) == "table" then
        for _, entry in ipairs(decoded) do
            if type(entry.text) == "string" and entry.text ~= "" then
                table.insert(yank_history, entry)
            end
        end
        cap_history()
    end
end

local function save_history_now()
    local ok, encoded = pcall(vim.json.encode, yank_history)
    if not ok then return end
    local f = io.open(config.history_path, "w")
    if not f then return end
    f:write(encoded)
    f:close()
end

local function save_history()
    if save_timer then
        save_timer:stop()
    end
    save_timer = vim.defer_fn(save_history_now, config.save_debounce_ms)
end

function M.store_yank()
    local event = vim.v.event
    local text

    if type(event.regcontents) == "table" then
        text = table.concat(event.regcontents, "\n")
    else
        local regname = event.regname or '"'
        local fallback = vim.fn.getreg(regname)
        if type(fallback) == "string" and fallback ~= "" then
            text = fallback
        else
            return
        end
    end

    if text == "" then return end

    deduplicate(text)

    table.insert(yank_history, 1, {
        text = text,
        time = os.date("%H:%M:%S"),
        file = vim.fn.expand("%:p"),
        line = vim.fn.line("."),
    })

    cap_history()
    save_history()
end

function M.yank_history_picker()
    if #yank_history == 0 then
        vim.notify("Yank history is empty", vim.log.levels.INFO)
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local previewers = require("telescope.previewers")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local function make_finder()
        return finders.new_table({
            results = yank_history,
            entry_maker = function(entry)
                local oneliner = entry.text:gsub("\n", "\\n")
                return {
                    value = entry,
                    display = string.format("[%s] %s:%d | %s",
                        entry.time,
                        vim.fn.fnamemodify(entry.file or "", ":t"),
                        entry.line or 0,
                        truncate(oneliner, 60)
                    ),
                    ordinal = entry.text,
                }
            end,
        })
    end

    pickers.new({}, {
        prompt_title = string.format("Yank History (%d)", #yank_history),
        finder = make_finder(),
        previewer = previewers.new_buffer_previewer({
            define_preview = function(self, entry)
                local lines = vim.split(entry.value.text, "\n")
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
            actions.select_default:replace(function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if not entry then return end
                local text = entry.value.text

                deduplicate(text)
                table.insert(yank_history, 1, {
                    text = text,
                    time = os.date("%H:%M:%S"),
                    file = vim.fn.expand("%:p"),
                    line = vim.fn.line("."),
                })
                cap_history()
                save_history()

                actions.close(prompt_bufnr)

                vim.schedule(function()
                    vim.fn.setreg('"', text)
                    vim.fn.setreg('0', text)
                    vim.fn.setreg('+', text)

                    if config.auto_paste_on_select then
                        vim.cmd("normal! \"\"" .. config.paste_mode)
                    end
                end)
            end)

            map({ "i", "n" }, "<C-d>", function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if not entry then return end

                for i, h in ipairs(yank_history) do
                    if h == entry.value then
                        table.remove(yank_history, i)
                        break
                    end
                end
                save_history()

                local picker = action_state.get_current_picker(prompt_bufnr)
                picker:refresh(make_finder(), { reset_prompt = false })
            end)

            return true
        end,
    }):find()
end

function M.clear()
    yank_history = {}
    save_history_now()
    vim.notify("Yank history cleared", vim.log.levels.INFO)
end

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
    load_history()

    vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("YankyAutoGroup", { clear = true }),
        callback = M.store_yank,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("YankySave", { clear = true }),
        callback = save_history_now,
    })
end

return M
