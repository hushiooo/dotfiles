return {
    -- Tokyo Night colorscheme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000, -- Load this first
        config = function()
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

            -- UI Customization
            vim.opt.fillchars = {
                eob = " ",
                vert = "│",
                horiz = "─",
                horizup = "┴",
                horizdown = "┬",
                vertleft = "┤",
                vertright = "├",
                verthoriz = "┼",
            }

            vim.opt.termguicolors = true
            vim.opt.cursorline = true
            vim.opt.smoothscroll = true
            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#292e42" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7aa2f7", bold = true })
        end
    },

    -- Status line
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = "VeryLazy",
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'tokyonight',
                    globalstatus = true,
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = { 'alpha', 'dashboard' },
                },
                sections = {
                    lualine_a = {
                        { 'mode', icon = '' },
                    },
                    lualine_b = {
                        { 'branch', icon = '' },
                        {
                            'diff',
                            symbols = {
                                added = ' ',
                                modified = ' ',
                                removed = ' ',
                            },
                            colored = true,
                        },
                    },
                    lualine_c = {
                        { 'filename', path = 1, padding = { left = 1, right = 1 } },
                        {
                            'diagnostics',
                            sources = { 'nvim_diagnostic' },
                            symbols = {
                                error = ' ',
                                warn = ' ',
                                info = ' ',
                                hint = '󰌵 ',
                            },
                            colored = true,
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
                                if #buf_clients == 0 then
                                    return "  No LSP"
                                end
                                local buf_client_names = {}
                                for _, client in pairs(buf_clients) do
                                    table.insert(buf_client_names, client.name)
                                end
                                return "  " .. table.concat(buf_client_names, ", ")
                            end,
                            padding = { left = 1, right = 1 },
                        },
                        { 'filetype', icon_only = true, padding = { left = 1, right = 1 } },
                    },
                    lualine_y = {
                        { 'progress', padding = { left = 1, right = 1 } },
                    },
                    lualine_z = {
                        { 'location', padding = { left = 1, right = 1 } },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end
    },

    -- Icons
    {
        'nvim-tree/nvim-web-devicons',
        lazy = true
    },

    -- Notifications and cmdline
    {
        'folke/noice.nvim',
        event = "VeryLazy",
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify',
        },
        config = function()
            require("noice").setup({
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup",
                    format = {
                        cmdline = { icon = " " },
                        search_down = { icon = " " },
                        search_up = { icon = " " },
                        filter = { icon = " " },
                        lua = { icon = " " },
                        help = { icon = " " },
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
                        opts = {},
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

            -- Set keymaps for Noice
            vim.keymap.set("n", "<leader>mn", ":Noice<CR>", { desc = "Show notification history" })
            vim.keymap.set("n", "<leader>ml", ":Noice last<CR>", { desc = "Show last notification" })
            vim.keymap.set("n", "<leader>md", ":Noice dismiss<CR>", { desc = "Dismiss notifications" })
        end
    },

    -- Notifications
    {
        'rcarriga/nvim-notify',
        lazy = true,
        config = function()
            require("notify").setup({
                background_colour = "#24283b",
                fps = 30,
                icons = {
                    DEBUG = " ",
                    ERROR = " ",
                    INFO = " ",
                    TRACE = "✎ ",
                    WARN = " ",
                },
                level = 2,
                minimum_width = 50,
                max_width = 80,
                timeout = 3000,
                render = "default",
                stages = "fade",
                top_down = true
            })

            vim.notify = require("notify")
            vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#24283b" })
        end
    },

    -- UI Improvements for inputs
    {
        'stevearc/dressing.nvim',
        event = "VeryLazy",
        config = function()
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
        end
    }
}
