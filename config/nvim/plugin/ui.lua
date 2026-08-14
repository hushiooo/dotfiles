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
    sidebars = { "qf", "help", "terminal" },
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
    end,
})
vim.cmd.colorscheme("tokyonight")

-- Dressing. Borders come from vim.o.winborder, set in init.lua.
local function with_border(conf)
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

-- ]c / [c need Option on AZERTY, so hunk movement gets leader keys.
map("n", "<leader>gn", function() gitsigns.nav_hunk("next") end, { desc = "Git hunk: next" })
map("n", "<leader>gN", function() gitsigns.nav_hunk("prev") end, { desc = "Git hunk: previous" })
