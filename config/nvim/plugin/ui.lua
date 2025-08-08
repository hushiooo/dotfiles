-- Colorscheme
require("tokyonight").setup({
    style = "night",
    transparent = false,
    terminal_colors = true,
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false },
        variables = {},
        sidebars = "normal",
        floats = "normal",
    },
    sidebars = { "qf", "help", "terminal", "nvim-tree" },
    dim_inactive = false,
    lualine_bold = true,
})
vim.cmd.colorscheme("tokyonight")

-- Notify
require("notify").setup({
    background_colour = "#24283b",
    fps = 30,
    icons = {
        DEBUG = " ",
        ERROR = " ",
        INFO = " ",
        TRACE = "✎ ",
        WARN = " ",
    },
    level = 2,
    minimum_width = 50,
    max_width = 80,
    timeout = 3000,
    render = "default",
    stages = "fade",
    top_down = true,
})
vim.notify = require("notify")

-- Dressing
require("dressing").setup({
    input = {
        enabled = true,
        default_prompt = "➤ ",
        win_options = {
            winblend = 0,
            wrap = true,
        },
        override = function(conf)
            conf.border = "rounded"
            conf.col = 1
            conf.row = 1
            return conf
        end,
    },
    select = {
        enabled = true,
        backend = "telescope",
        trim_prompt = true,
        win_options = {
            winblend = 0,
            wrap = true,
        },
        override = function(conf)
            conf.border = "rounded"
            conf.col = 1
            conf.row = 1
            return conf
        end,
    },
})

-- Gitsigns
require("gitsigns").setup({
    signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
    },
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        ignore_whitespace = true,
        delay = 1000,
    },
})

-- UI keymaps
local map = vim.keymap.set

-- Gitsigns
map("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })
map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })

-- Clear notifications
map("n", "<leader>md", function()
    require("notify").dismiss({ silent = true, pending = true })
end, { desc = "Dismiss notifications" })
