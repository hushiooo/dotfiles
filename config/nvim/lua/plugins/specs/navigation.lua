return {
    -- File explorer
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            require("nvim-tree").setup({
                sort = { sorter = "case_sensitive" },
                view = {
                    width = 50,
                    side = "right",
                    signcolumn = "yes",
                    number = false,
                    relativenumber = false,
                },
                renderer = {
                    group_empty = true,
                    indent_markers = {
                        enable = true,
                        inline_arrows = true,
                        icons = {
                            corner = "└",
                            edge = "│",
                            item = "│",
                            none = " ",
                        },
                    },
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = false,
                        },
                        glyphs = {
                            default = " ",
                            symlink = "",
                            folder = {
                                arrow_closed = "",
                                arrow_open = "",
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                                symlink_open = "",
                            },
                            git = {
                                unstaged = "",
                                staged = "",
                                unmerged = "",
                                renamed = "➜",
                                untracked = "",
                                deleted = "",
                                ignored = "◌",
                            },
                        },
                    },
                    highlight_git = true,
                },
                git = {
                    enable = true,
                    ignore = false,
                    timeout = 400,
                },
                filters = {
                    dotfiles = false,
                    custom = {},
                },
                on_attach = function(bufnr)
                    local api = require("nvim-tree.api")
                    local function opts(desc)
                        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                    end

                    -- File explorer keymaps
                    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "dd", api.fs.remove, opts("Delete"))
                    vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
                    vim.keymap.set("n", "yy", api.fs.copy.node, opts("Copy"))
                    vim.keymap.set("n", "yn", api.fs.copy.filename, opts("Copy Name"))
                    vim.keymap.set("n", "cc", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
                    vim.keymap.set("n", "a", api.fs.create, opts("Create File/Folder"))
                    vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
                    vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
                    vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                    vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
                end,
            })

            -- Set keymaps for NvimTree
            vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle nvim-tree", silent = true })
            vim.keymap.set('n', '<leader>o', ':NvimTreeFocus<CR>', { desc = "Focus nvim-tree", silent = true })
        end
    },

    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        cmd = "Telescope",
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make'
            }
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help tags" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = "  ",
                    entry_prefix = "   ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = {
                            mirror = false,
                            preview_height = 0.5,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    path_display = { "truncate" },
                    winblend = 0,
                    border = true,
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    color_devicons = true,
                    file_ignore_patterns = {
                        "node_modules",
                        ".git/",
                        "%.sqlite3",
                        "%.ipynb",
                        "vendor/*",
                        "%.jpg",
                        "%.jpeg",
                        "%.png",
                        "%.svg",
                        "%.otf",
                        "%.ttf",
                    },
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                        previewer = false,
                        hidden = true,
                        fuzzy = true,
                        prompt_title = "Find Files",
                        results_title = "Files",
                    },
                    live_grep = {
                        layout_strategy = "horizontal",
                        layout_config = {
                            width = 0.95,
                            height = 0.95,
                            preview_width = 0.6,
                            horizontal = {
                                preview_width = 0.6,
                                results_width = 0.4,
                            },
                        },
                        prompt_title = "Live Grep",
                        results_title = "Matches",
                    },
                    buffers = {
                        theme = "dropdown",
                        previewer = false,
                        prompt_title = "Find Buffers",
                        results_title = "Buffers",
                        sort_mru = true,
                        ignore_current_buffer = true,
                    },
                    help_tags = {
                        theme = "dropdown",
                        prompt_title = "Help Tags",
                        results_title = "Results",
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })

            -- Load Telescope extensions
            telescope.load_extension("fzf")
        end
    },

    -- Which-key for keybinding help
    {
        'folke/which-key.nvim',
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                    presets = {
                        operators = true,
                        motions = true,
                        text_objects = true,
                        windows = true,
                        nav = true,
                        z = true,
                        g = true,
                    },
                },
                icons = {
                    breadcrumb = "»",
                    separator = "➜",
                    group = "+",
                },
                window = {
                    border = "rounded",
                    position = "bottom",
                    margin = { 1, 0, 1, 0 },
                    padding = { 2, 2, 2, 2 },
                    winblend = 0,
                },
                layout = {
                    height = { min = 4, max = 25 },
                    width = { min = 20, max = 50 },
                    spacing = 3,
                    align = "center",
                },
                hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
                triggers_blacklist = {
                    i = { "j", "k" },
                    v = { "j", "k" },
                },
            })
        end
    },

    -- Utility library used by many plugins
    {
        'nvim-lua/plenary.nvim',
        lazy = true
    }
}
