local M = {}

---@param lines string[]
---@param config table
function M.show_popup(lines, config)
    lines = lines or {}
    config = config or {}
    local popup_cfg = config.popup or {}

    local function resolve_value(value, fallback)
        if type(value) == "function" then
            local ok, computed = pcall(value, lines)
            if ok and computed ~= nil then return computed end
        elseif value ~= nil then
            return value
        end
        return fallback
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    vim.bo[buf].filetype = popup_cfg.filetype or "diff"

    local max_width = popup_cfg.max_width or math.floor(vim.o.columns * 0.9)
    local width = resolve_value(popup_cfg.width, max_width)
    if type(width) ~= "number" then width = max_width end
    width = math.max(1, math.floor(math.min(width, vim.o.columns - 2)))

    local default_height = math.min(#lines + 2, math.floor(vim.o.lines * 0.9))
    local height = resolve_value(popup_cfg.height, default_height)
    if type(height) ~= "number" then height = default_height end
    height = math.max(1, math.floor(math.min(height, vim.o.lines - 2)))

    local row = resolve_value(popup_cfg.row, math.floor((vim.o.lines - height) / 2))
    local col = resolve_value(popup_cfg.col, math.floor((vim.o.columns - width) / 2))

    local win_opts = {
        relative = popup_cfg.relative or "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = popup_cfg.style or "minimal",
        border = popup_cfg.border or "rounded",
        title = popup_cfg.title or "pareil.nvim diff",
        title_pos = popup_cfg.title_pos or "center",
    }

    for _, key in ipairs({ "zindex", "noautocmd", "focusable", "footer", "footer_pos" }) do
        if popup_cfg[key] ~= nil then win_opts[key] = popup_cfg[key] end
    end

    if type(popup_cfg.win_opts) == "table" then
        win_opts = vim.tbl_extend("force", win_opts, popup_cfg.win_opts)
    end

    local enter = popup_cfg.enter ~= false
    local win = vim.api.nvim_open_win(buf, enter, win_opts)

    if popup_cfg.winblend ~= nil then
        vim.wo[win].winblend = popup_cfg.winblend
    end

    local close_mappings = popup_cfg.close_mappings or { "q" }
    if type(close_mappings) == "string" then
        close_mappings = { close_mappings }
    end

    for _, key in ipairs(close_mappings) do
        vim.keymap.set("n", key, popup_cfg.close_command or "<cmd>close<CR>", {
            buffer = buf,
            nowait = true,
            silent = true,
            desc = "Close diff popup",
        })
    end

    if type(popup_cfg.on_open) == "function" then
        pcall(popup_cfg.on_open, buf, win)
    end
end

return M
