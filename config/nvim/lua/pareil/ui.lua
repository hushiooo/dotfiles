local M = {}

---@param lines string[]
---@param opts { max_width: integer, title: string }
function M.show_popup(lines, opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "diff"

    -- Width and height exclude the border, which comes from vim.o.winborder.
    local width = math.max(1, math.min(opts.max_width, vim.o.columns - 2))
    local height = math.max(1, math.min(#lines, math.floor(vim.o.lines * 0.9) - 2))

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.floor((vim.o.lines - height - 2) / 2),
        col = math.floor((vim.o.columns - width - 2) / 2),
        width = width,
        height = height,
        style = "minimal",
        title = opts.title,
        title_pos = "center",
    })

    vim.keymap.set("n", "q", "<cmd>close<CR>", {
        buffer = buf,
        nowait = true,
        silent = true,
        desc = "Close diff popup",
    })
end

return M
