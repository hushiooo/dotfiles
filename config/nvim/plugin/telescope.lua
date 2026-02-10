local telescope = require("telescope")
local actions = require("telescope.actions")
local layout_actions = require("telescope.actions.layout")

telescope.setup({
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "❯ ",
        entry_prefix = "  ",
        multi_icon = " ",
        initial_mode = "insert",
        dynamic_preview_title = true,
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "flex",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.58,
            },
            vertical = {
                mirror = false,
                preview_height = 0.45,
            },
            width = 0.9,
            height = 0.82,
            preview_cutoff = 120,
        },
        winblend = 0,
        border = true,
        borderchars = {
            prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        color_devicons = true,
        file_ignore_patterns = {
            "node_modules",
            "%.sqlite3",
            "%.ipynb",
            "vendor/",
            "%.jpg",
            "%.jpeg",
            "%.png",
            "%.svg",
            "%.webp",
            "%.otf",
            "%.ttf",
        },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--trim",
        },
        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-d>"] = actions.delete_buffer,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<C-Down>"] = actions.cycle_history_next,
                ["<C-Up>"] = actions.cycle_history_prev,
                ["<M-p>"] = layout_actions.toggle_preview,
                ["<C-c>"] = actions.close,
                ["<Esc>"] = false,
            },
            n = {
                ["q"] = actions.close,
                ["<M-p>"] = layout_actions.toggle_preview,
                ["dd"] = actions.delete_buffer,
                ["<C-Down>"] = actions.cycle_history_next,
                ["<C-Up>"] = actions.cycle_history_prev,
            },
        },
    },
    pickers = {
        find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
            follow = true,
            prompt_title = "Files",
            results_title = false,
            path_display = { "truncate" },
        },
        live_grep = {
            prompt_title = "Grep",
            results_title = false,
            layout_strategy = "horizontal",
            layout_config = {
                width = 0.95,
                height = 0.95,
                preview_width = 0.65,
            },
        },
        buffers = {
            theme = "dropdown",
            previewer = false,
            prompt_title = "Buffers",
            results_title = false,
            sort_lastused = true,
            sort_mru = true,
            ignore_current_buffer = true,
            mappings = {
                i = { ["<C-d>"] = actions.delete_buffer },
                n = { ["dd"] = actions.delete_buffer },
            },
        },
        help_tags = {
            theme = "dropdown",
            prompt_title = "Help",
            results_title = false,
        },
        oldfiles = {
            prompt_title = "Recent",
            results_title = false,
            only_cwd = true,
            previewer = true,
            layout_strategy = "horizontal",
            layout_config = {
                width = 0.92,
                height = 0.85,
                preview_width = 0.55,
            },
            path_display = { "truncate" },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        file_browser = {
            hidden = true,
            grouped = true,
            respect_gitignore = false,
            display_stat = false,
            no_ignore = true,
            theme = "dropdown",
            previewer = false,
            layout_config = { height = 0.8 },
            hijack_netrw = true,
            initial_mode = "normal",
            git_status = false,
        },
    },
})

-- Load extensions

telescope.load_extension("fzf")
telescope.load_extension("dap")
telescope.load_extension("file_browser")

-- Keybindings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Search word under cursor" })

local telescope_browser = telescope.extensions.file_browser
local function resolve_browser_path()
    local buffer_dir = vim.fn.expand("%:p:h")
    if buffer_dir == "" then
        return vim.loop.cwd()
    end
    return buffer_dir
end

vim.keymap.set("n", "<leader>e", function()
    telescope_browser.file_browser({ path = resolve_browser_path(), select_buffer = true })
end, { desc = "File browser" })
