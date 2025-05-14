local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
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

-- Load extensions
telescope.load_extension("fzf")
telescope.load_extension("dap")

-- Keybindings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
