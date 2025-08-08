-- Set <leader> key
vim.g.mapleader = " "

-- Aliases
local opt = vim.opt
local map = vim.keymap.set

-- ========================
-- General Options
-- ========================

-- Display
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cmdheight = 0
opt.laststatus = 3
opt.pumheight = 12
opt.fillchars:append({ eob = " " })

-- Interaction
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300

-- Scrolling
opt.scrolloff = 10
opt.sidescrolloff = 10

-- File handling
opt.swapfile = false
opt.undofile = true
opt.undolevels = 1000

-- Completion
opt.completeopt = { "menuone", "noselect" }

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4

-- JSON: 2-space indentation override
vim.api.nvim_create_autocmd("FileType", {
    pattern = "json",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- ========================
-- Keymaps
-- ========================

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- File operations
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")

-- Buffers
map("n", "<leader>b", "<C-^>")

-- Clear search highlights
map("n", "<leader>h", "<cmd>noh<CR>")

-- Word wrap navigation
map("n", "j", "gj")
map("n", "k", "gk")

-- Paragraph navigation (° on AZERTY)
map("n", "°", "(")

-- Redo
map("n", "U", "<C-r>")

-- Prevent yanked text from being replaced during visual paste
map("v", "p", '"_dP', { noremap = true, silent = true })
