local M = {}

--- Show diff in a floating popup window
---@param lines string[]
---@param config table
function M.show_popup(lines, config)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "diff"
    vim.bo[buf].bufhidden = "wipe"

    local width = config.delta_width or math.floor(vim.o.columns * 0.9)
    local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.9))
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = "pareil.nvim diff",
        title_pos = "center",
    })

    vim.keymap.set("n", "q", "<cmd>close<CR>", {
        buffer = buf,
        nowait = true,
        silent = true,
        desc = "Close pareil diff popup",
    })
end

return M
