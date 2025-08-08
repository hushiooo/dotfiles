local M = {}

local config = {
    max_items = 200,
    history_path = vim.fn.stdpath("data") .. "/yanky_history.json",
    paste_mode = "p", -- can be "p", "P", "gp", etc.
    auto_paste_on_select = true,
}

local yank_history = {}

-- Truncate long strings for display
local function truncate(str, max)
    return #str > max and str:sub(1, max) .. "…" or str
end

-- Load yank history from disk
local function load_history()
    local f = io.open(config.history_path, "r")
    if not f then return end
    local ok, decoded = pcall(vim.fn.json_decode, f:read("*a"))
    f:close()
    if ok and type(decoded) == "table" then
        for _, entry in ipairs(decoded) do
            if type(entry.text) == "string" then
                table.insert(yank_history, entry)
            end
        end
    end
end

-- Save yank history to disk
local function save_history()
    local f = io.open(config.history_path, "w")
    if not f then return end
    f:write(vim.fn.json_encode(yank_history))
    f:close()
end

-- Add most recent yank to history
function M.store_yank()
    local event = vim.v.event
    local regname = event.regname or '"'
    local text

    if type(event.regcontents) == "table" then
        text = table.concat(event.regcontents, "\n")
    else
        local fallback = vim.fn.getreg(regname)
        if type(fallback) == "string" and fallback ~= "" then
            text = fallback
        else
            return
        end
    end

    if text == "" then return end

    table.insert(yank_history, 1, {
        text = text,
        time = os.date("%H:%M:%S"),
        file = vim.fn.expand("%:p"),
        line = vim.fn.line("."),
    })

    if #yank_history > config.max_items then
        yank_history[#yank_history] = nil
    end

    save_history()
end

-- Register the TextYankPost autocommand
function M.setup_autocmd()
    pcall(function()
        vim.api.nvim_create_autocmd("TextYankPost", {
            group = vim.api.nvim_create_augroup("YankyAutoGroup", { clear = true }),
            callback = M.store_yank,
        })
    end)
end

-- Open yank history picker using Telescope
function M.yank_history_picker()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local previewers = require("telescope.previewers")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = "Yank History",
        finder = finders.new_table {
            results = yank_history,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format("[%s] %s:%d | %s",
                        entry.time,
                        vim.fn.fnamemodify(entry.file or "", ":t"),
                        entry.line or 0,
                        truncate(entry.text:gsub("\n", "\\n"), 60)
                    ),
                    ordinal = entry.text,
                }
            end,
        },
        previewer = previewers.new_buffer_previewer {
            define_preview = function(self, entry)
                local lines = vim.split(entry.value.text, "\n")
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                vim.bo[self.state.bufnr].filetype = "text"
            end,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, _)
            actions.select_default:replace(function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                local text = entry.value.text

                -- Save to history again
                table.insert(yank_history, 1, {
                    text = text,
                    time = os.date("%H:%M:%S"),
                    file = vim.fn.expand("%:p"),
                    line = vim.fn.line("."),
                })

                if #yank_history > config.max_items then
                    yank_history[#yank_history] = nil
                end

                save_history()
                actions.close(prompt_bufnr)

                vim.schedule(function()
                    vim.fn.setreg('"', text)
                    vim.fn.setreg('0', text)
                    vim.fn.setreg('*', text)
                    vim.fn.setreg('+', text)

                    if config.auto_paste_on_select then
                        vim.cmd("normal! \"\"" .. config.paste_mode)
                    end
                end)
            end)
            return true
        end,
    }):find()
end

-- Plugin setup function
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
    load_history()
    M.setup_autocmd()
end

return M
