-- Set <leader> keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Aliases
local opt = vim.opt
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ========================
-- General Options
-- ========================

-- Display
opt.number = true
opt.relativenumber = false
opt.numberwidth = 2
opt.cursorline = true
opt.cursorlineopt = "both"
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cmdheight = 0
opt.laststatus = 3
opt.pumheight = 12
opt.showmode = false
opt.showcmd = false
opt.ruler = false
opt.title = true
opt.winminwidth = 5
opt.fillchars:append({
    eob = " ",
    fold = " ",
    foldopen = "",
    foldclose = "",
    foldsep = " ",
    diff = "╱",
})

-- Interaction
opt.mouse = "a"
opt.mousefocus = true
opt.clipboard = "unnamedplus"
opt.confirm = true

-- Performance
opt.updatetime = 150
opt.timeoutlen = 300
opt.lazyredraw = true
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- Scrolling
opt.scrolloff = 10
opt.sidescrolloff = 10

-- File handling
opt.swapfile = false
opt.undofile = true
opt.undolevels = 1000
opt.backup = false
opt.writebackup = false
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.wildmode = "longest:full,full"
opt.wildignorecase = true

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit"

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.shiftround = true
opt.breakindent = true
opt.linebreak = true
opt.conceallevel = 0
opt.joinspaces = false

-- Folds
opt.foldenable = false
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "0"

-- Grep / search programs
opt.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
opt.grepformat = "%f:%l:%c:%m"

-- 2-space indentation override
autocmd("FileType", {
    pattern = "json",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

autocmd("FileType", {
    pattern = "ts",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

autocmd("FileType", {
    pattern = "js",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- Markdown / gitcommit: soften text defaults
autocmd("FileType", {
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.conceallevel = 0
    end,
})

-- General autocommands
local general_group = augroup("GeneralSettings", { clear = true })

autocmd("TextYankPost", {
    group = general_group,
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
    end,
    desc = "Briefly highlight on yank",
})

autocmd("BufReadPost", {
    group = general_group,
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lcount = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
    end,
    desc = "Return to last cursor position",
})

autocmd("VimResized", {
    group = general_group,
    callback = function() vim.cmd("tabdo wincmd =") end,
    desc = "Keep splits balanced after resize",
})

autocmd("FileType", {
    group = general_group,
    callback = function() pcall(vim.treesitter.start) end,
    desc = "Enable treesitter highlighting",
})

autocmd("BufWritePre", {
    group = general_group,
    pattern = { "*.lua", "*.ts", "*.tsx", "*.js", "*.jsx", "*.json", "*.go", "*.rs", "*.py" },
    callback = function(args)
        local view = vim.fn.winsaveview()
        vim.api.nvim_buf_call(args.buf, function()
            vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
        end)
        vim.fn.winrestview(view)
    end,
    desc = "Trim trailing whitespace on save",
})

-- ========================
-- Keymaps
-- ========================

-- Window navigation
map("n", "<leader>ah", "<C-w>h")
map("n", "<leader>aj", "<C-w>j")
map("n", "<leader>ak", "<C-w>k")
map("n", "<leader>al", "<C-w>l")
map("n", "<leader>aa", "<C-w>w", { desc = "Window: next (cycle)" })

-- File operations
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")

-- Buffers
map("n", "<leader>b", "<C-^>")

-- Clear search highlights
map("n", "<leader>h", "<cmd>noh<CR>")

-- Paragraph navigation (° on AZERTY)
map("n", "°", "(")

-- Redo
map("n", "U", "<C-r>")

-- Prevent yanked text from being replaced during visual paste
map("v", "p", '"_dP', { noremap = true, silent = true })

-- ========================
-- Quickfix Keymaps
-- ========================

vim.api.nvim_create_autocmd("FileType", {
    pattern = "TelescopePrompt",
    callback = function(args)
        local actions = require("telescope.actions")
        local opts = { buffer = args.buf, silent = true, nowait = true }

        vim.keymap.set({ "i", "n" }, "<leader>mq", function()
            actions.smart_send_to_qflist(args.buf)
        end, vim.tbl_extend("force", opts, { desc = "Marked → quickfix (replace)" }))

        vim.keymap.set({ "i", "n" }, "<leader>mQ", function()
            actions.smart_add_to_qflist(args.buf)
        end, vim.tbl_extend("force", opts, { desc = "Marked → quickfix (append)" }))
    end,
})

map("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Quickfix: open" })

map("n", "<leader>cq", function()
    vim.fn.setqflist({}, "r")
    vim.notify("Quickfix list cleared", vim.log.levels.INFO)
end, { desc = "Quickfix: clear list" })
