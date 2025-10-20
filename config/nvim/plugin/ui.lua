local border = "rounded"

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
    lualine_bold = false,
    on_highlights = function(hl, c)
        hl.NormalFloat = { bg = c.bg }
        hl.FloatBorder = { fg = c.blue0, bg = c.bg }
        hl.FloatTitle = { fg = c.blue, bg = c.bg, bold = true }
        hl.WinSeparator = { fg = c.blue0, bg = c.none }
        hl.StatusLineNC = { fg = c.comment, bg = c.bg_dark }
        hl.CursorLine = { bg = c.bg_highlight }
        hl.CursorLineNr = { fg = c.orange, bg = c.none, bold = true }
        hl.Visual = { bg = c.bg_highlight, fg = c.none }
        hl.Pmenu = { bg = c.bg_dark, fg = c.fg }
        hl.PmenuSel = { bg = c.blue0, fg = c.bg_dark, bold = true }
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopeSelection = { bg = c.bg_highlight, fg = c.fg }
        hl.TelescopePromptNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopePromptBorder = { fg = c.blue, bg = c.bg_dark }
        hl.TelescopePromptTitle = { fg = c.bg_dark, bg = c.blue, bold = true }
        hl.TelescopeResultsNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopeResultsBorder = { fg = c.blue0, bg = c.bg_dark }
        hl.TelescopeResultsTitle = { fg = c.bg_dark, bg = c.blue0, bold = true }
        hl.TelescopePreviewNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopePreviewBorder = { fg = c.blue0, bg = c.bg_dark }
        hl.TelescopePreviewTitle = { fg = c.bg_dark, bg = c.blue0, bold = true }
        hl.NotifyBackground = { bg = c.bg_dark }
    end,
})
vim.cmd.colorscheme("tokyonight")

-- Notify
local notify = require("notify")

notify.setup({
    background_colour = "#1a1b26",
    fps = 30,
    icons = {
        DEBUG = " ",
        ERROR = " ",
        INFO = " ",
        TRACE = "✎ ",
        WARN = " ",
    },
    level = vim.log.levels.INFO,
    minimum_width = 40,
    max_width = function() return math.floor(vim.o.columns * 0.3) end,
    max_height = function() return math.floor(vim.o.lines * 0.3) end,
    timeout = 2500,
    render = "minimal",
    stages = "fade_in_slide_out",
    top_down = false,
    on_open = function(win)
        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:NormalFloat,FloatBorder:FloatBorder")
    end,
})
vim.notify = notify

-- Dressing
local function with_border(conf)
    conf.border = border
    conf.relative = conf.relative or "editor"
    conf.title_pos = conf.title_pos or "center"
    conf.col = conf.col or 0
    conf.row = conf.row or 0
    conf.width = conf.width or math.min(math.floor(vim.o.columns * 0.6), 80)
    return conf
end

require("dressing").setup({
    input = {
        enabled = true,
        default_prompt = "➤ ",
        win_options = {
            winblend = 0,
            wrap = false,
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
        },
        override = function(conf)
            conf = with_border(conf)
            conf.relative = "cursor"
            conf.width = math.min(math.floor(vim.o.columns * 0.4), 60)
            return conf
        end,
    },
    select = {
        enabled = true,
        backend = { "telescope", "builtin" },
        trim_prompt = true,
        win_options = {
            winblend = 0,
            wrap = false,
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
        },
        override = function(conf)
            return with_border(conf)
        end,
    },
})

-- Gitsigns
local gitsigns = require("gitsigns")

gitsigns.setup({
    signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "┆" },
    },
    attach_to_untracked = false,
    max_file_length = 20000,
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        virt_text_priority = 100,
        ignore_whitespace = true,
        delay = 600,
    },
    current_line_blame_formatter = "<author>, <author_time:%R> • <summary>",
    preview_config = {
        border = border,
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
    },
})

-- UI keymaps
local map = vim.keymap.set

-- Gitsigns
map("n", "<leader>gb", function() gitsigns.toggle_current_line_blame() end, { desc = "Toggle git blame" })
map("n", "<leader>gp", function() gitsigns.preview_hunk() end, { desc = "Preview git hunk" })

-- Clear notifications
map("n", "<leader>md", function()
    require("notify").dismiss({ silent = true, pending = true })
end, { desc = "Dismiss notifications" })
