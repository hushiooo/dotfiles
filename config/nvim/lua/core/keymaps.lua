local map = vim.keymap.set

vim.g.mapleader = " "

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- File ops
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

-- Buffers
map("n", "<leader>b", "<C-^>")

-- Undo / Redo
map("n", "U", "<C-r>")
map("n", "<leader>u", "u")
map("n", "<leader>U", "U")

-- Clipboard
map("v", "<leader>y", '"+y')
map("n", "<leader>y", '"+y')
map("n", "<leader>p", '"+p')

-- Search highlights
map("n", "<leader>h", ":noh<CR>")

-- Soft wrapped lines navigation
map("n", "k", "gk")
map("n", "j", "gj")
map("n", "°", "(")
