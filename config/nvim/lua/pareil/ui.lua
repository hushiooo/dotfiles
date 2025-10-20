local M = {}

--- Show diff in a floating popup window
---@param lines string[]
---@param config table
function M.show_popup(lines, config)
    lines = lines or {}
    config = config or {}
    local popup_cfg = config.popup or {}

    local function resolve_value(value, fallback)
        if type(value) == "function" then
            local ok, computed = pcall(value, lines)
            if ok and computed ~= nil then
                return computed
            end
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

    local max_width = popup_cfg.max_width or config.delta_width or math.floor(vim.o.columns * 0.9)
    local width = resolve_value(popup_cfg.width, max_width)
    if type(width) ~= "number" then
        width = max_width
    end
    width = math.max(1, math.floor(math.min(width, math.max(1, vim.o.columns - 2))))

    local default_height = math.min(#lines + 2, math.floor(vim.o.lines * 0.9))
    local height = resolve_value(popup_cfg.height, default_height)
    if type(height) ~= "number" then
        height = default_height
    end
    height = math.max(1, math.floor(math.min(height, math.max(1, vim.o.lines - 2))))

    local default_row = math.floor((vim.o.lines - height) / 2)
    local row = resolve_value(popup_cfg.row, default_row)
    if type(row) ~= "number" then
        row = default_row
    end

    local default_col = math.floor((vim.o.columns - width) / 2)
    local col = resolve_value(popup_cfg.col, default_col)
    if type(col) ~= "number" then
        col = default_col
    end

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

    if popup_cfg.zindex ~= nil then
        win_opts.zindex = popup_cfg.zindex
    end
    if popup_cfg.noautocmd ~= nil then
        win_opts.noautocmd = popup_cfg.noautocmd
    end
    if popup_cfg.focusable ~= nil then
        win_opts.focusable = popup_cfg.focusable
    end
    if popup_cfg.footer ~= nil then
        win_opts.footer = popup_cfg.footer
    end
    if popup_cfg.footer_pos ~= nil then
        win_opts.footer_pos = popup_cfg.footer_pos
    end

    if type(popup_cfg.win_opts) == "table" then
        for key, value in pairs(popup_cfg.win_opts) do
            win_opts[key] = value
        end
    end

    local enter = popup_cfg.enter
    if enter == nil then
        enter = true
    end

    local win = vim.api.nvim_open_win(buf, enter, win_opts)

    if popup_cfg.winblend ~= nil then
        vim.api.nvim_win_set_option(win, "winblend", popup_cfg.winblend)
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
            desc = popup_cfg.close_desc or "Close pareil diff popup",
        })
    end

    if type(popup_cfg.on_open) == "function" then
        pcall(popup_cfg.on_open, buf, win)
    end
end

return M
