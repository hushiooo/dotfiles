local opt = vim.opt

-- General
opt.number = true
opt.mouse = "a"
opt.hidden = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Scroll offsets
opt.scrolloff = 10
opt.sidescrolloff = 10

-- JSON: 2-space indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "json",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- UI
opt.signcolumn = "yes"
opt.cursorline = true
opt.pumheight = 12
opt.cmdheight = 0
opt.laststatus = 3
opt.fillchars = { eob = " " }

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300

-- Completion
opt.completeopt = { "menuone", "noselect" }

-- File handling
opt.swapfile = false
opt.undofile = true
opt.undolevels = 1000
opt.clipboard = "unnamedplus"

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Colors
opt.termguicolors = true
