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
vim.cmd([[colorscheme tokyonight]])

-- Noice
require("noice").setup({
    cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
            cmdline = { icon = " " },
            search_down = { icon = " " },
            search_up = { icon = " " },
            filter = { icon = " " },
            lua = { icon = " " },
            help = { icon = " " },
        },
    },
    messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
    },
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
        message = {
            enabled = true,
            view = "notify",
        },
        progress = {
            enabled = true,
            format = "lsp_progress",
            format_done = "lsp_progress_done",
            throttle = 1000 / 30,
            view = "mini",
        },
    },
    presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
    },
    routes = {
        {
            filter = {
                event = "msg_show",
                kind = "",
                find = "written",
            },
            opts = { skip = true },
        },
    },
})

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
vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#24283b" })

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
        backend = { "telescope", "builtin" },
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

-- UI keymaps
vim.keymap.set("n", "<leader>mn", ":Noice<CR>", { desc = "Show notification history" })
vim.keymap.set("n", "<leader>ml", ":Noice last<CR>", { desc = "Show last notification" })
vim.keymap.set("n", "<leader>md", ":Noice dismiss<CR>", { desc = "Dismiss notifications" })
