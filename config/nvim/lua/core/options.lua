-- General Settings
vim.opt.number = true -- Show line numbers
vim.opt.mouse = "a"   -- Enable mouse support
vim.opt.hidden = true -- Allow hidden buffers

-- Search settings
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true  -- Smart case sensitivity

-- Editor behavior
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4   -- Indentation width
vim.opt.tabstop = 4      -- Tab width
vim.opt.scrolloff = 10   -- Keep cursor away from screen edges
vim.opt.sidescrolloff = 10

-- UI settings
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.cursorline = true  -- Highlight current line
vim.opt.pumheight = 12     -- Maximum number of popup menu items
vim.opt.cmdheight = 0      -- Command line height
vim.opt.laststatus = 3     -- Global status line

-- Performance settings
vim.opt.updatetime = 200 -- Faster updates
vim.opt.timeoutlen = 300 -- Key sequence timeout

-- Completion settings
vim.opt.completeopt = "menuone,noselect"

-- File handling
vim.opt.swapfile = false          -- Disable swap files
vim.opt.undofile = true           -- Persistent undo
vim.opt.undolevels = 1000         -- Raise max undo
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Split behavior
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below

-- UI customization
vim.opt.fillchars = { eob = " " } -- Hide end of buffer marker
vim.opt.termguicolors = true      -- True color support

-- Set leader key
vim.g.mapleader = " "
