local spectre = require("spectre")
local actions = require("spectre.actions")
local map = vim.keymap.set
local separator = string.rep("─", 46)

spectre.setup({
    color_devicons = true,
    open_cmd = "vnew",
    live_update = false,
    is_open_target_win = true,
    is_insert_mode = false,
    default = {
        find = {
            cmd = "rg",
            options = { "ignore-case" },
        },
        replace = {
            cmd = "sed",
        },
    },
    find_engine = {
        ["rg"] = {
            cmd = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--fixed-strings",
            },
            options = {
                ["ignore-case"] = {
                    value = "--ignore-case",
                    icon = "[I]",
                    desc = "ignore case",
                },
                ["hidden"] = {
                    value = "--hidden",
                    desc = "search hidden files",
                    icon = "[H]",
                },
            },
        },
    },
    replace_engine = {
        ["sed"] = {
            cmd = "sed",
            args = { "-i" },
        },
    },
    line_sep_start = "╭" .. separator,
    result_padding = "│ ",
    line_sep = "╰" .. separator,
    highlight = {
        ui = "CursorLine",
        search = "IncSearch",
        replace = "DiffText",
    },
    view = {
        cmd = "vsplit",
        layout = "vertical",
        show_line = true,
        show_result = true,
        show_replace = true,
    },
    mapping = {
        ["toggle_line"] = { map = "dd", cmd = spectre.toggle_line, desc = "Toggle current item" },
        ["enter_file"] = { map = "<CR>", cmd = actions.select_entry, desc = "Go to file" },
        ["send_to_qf"] = { map = "Q", cmd = actions.send_to_qf, desc = "Send results to quickfix" },
        ["replace_cmd"] = { map = "cr", cmd = actions.replace_cmd, desc = "Input replace command" },
        ["show_option_menu"] = { map = "go", cmd = spectre.toggle_options, desc = "Toggle options" },
        ["run_current_replace"] = { map = "gr", cmd = actions.run_current_replace, desc = "Replace current line" },
        ["run_replace"] = { map = "gR", cmd = actions.run_replace, desc = "Replace all" },
        ["change_view_mode"] = { map = "gv", cmd = spectre.change_view, desc = "Change result view mode" },
        ["toggle_ignore_case"] = {
            map = "ti",
            cmd = function() spectre.change_options("ignore-case") end,
            desc = "Toggle ignore case",
        },
        ["toggle_ignore_hidden"] = {
            map = "th",
            cmd = function() spectre.change_options("hidden") end,
            desc = "Toggle hidden files",
        },
        ["toggle_regex"] = {
            map = "tr",
            cmd = function() spectre.change_options("regex") end,
            desc = "Toggle regex mode",
        },
        ["toggle_word_match"] = {
            map = "tw",
            cmd = function() spectre.change_options("word") end,
            desc = "Toggle whole word match",
        },
    },
})

map("n", "<leader>sr", spectre.open, { desc = "Search and replace (project)", silent = true })
map("n", "<leader>sw", function()
    spectre.open_visual({ select_word = true })
end, { desc = "Search word under cursor", silent = true })
map("v", "<leader>sw", spectre.open_visual, { desc = "Search selected text", silent = true })
map("n", "<leader>sf", function()
    spectre.open_file_search({ select_word = true })
end, { desc = "Search current file", silent = true })
map("n", "<leader>sS", spectre.open_file_search, { desc = "Search current file (prompt)", silent = true })
