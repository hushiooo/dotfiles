-- Helper function for keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- File operations
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Go back to previous buffer
map("n", "<leader>b", "<C-^>", { desc = "Previous buffer" })

-- Undo/Redo
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<leader>u", "u", { desc = "Undo" })
map("n", "<leader>U", "U", { desc = "Undo line" })

-- Clipboard operations
map("v", "<leader>y", "\"+y", { desc = "Copy to clipboard" })
map("n", "<leader>y", "\"+y", { desc = "Copy to clipboard" })
map("n", "<leader>p", "\"+p", { desc = "Paste from clipboard" })

-- Miscellaneous
map("n", "<leader>h", ":noh<CR>", { desc = "Clear highlights" })
map("n", "k", "gk", { desc = "Move up by visual line" })
map("n", "j", "gj", { desc = "Move down by visual line" })
map("n", "°", "(", { desc = "Jump to previous sentence" })

-- Note: Plugin-specific keymaps are defined in their respective plugin configurations
