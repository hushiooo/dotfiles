local M = {}

---@param lines string[]
---@param config table
function M.show_popup(lines, config)
    lines = lines or {}
    local popup = (config or {}).popup or {}

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    vim.bo[buf].filetype = "diff"

    local width = math.max(1, math.min(popup.max_width or 120, vim.o.columns - 2))
    local height = math.max(1, math.min(#lines + 2, math.floor(vim.o.lines * 0.9), vim.o.lines - 2))

    -- Border comes from vim.o.winborder.
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        title = popup.title or "pareil diff",
        title_pos = "center",
    })

    vim.keymap.set("n", "q", "<cmd>close<CR>", {
        buffer = buf,
        nowait = true,
        silent = true,
        desc = "Close diff popup",
    })

    return win
end

return M
