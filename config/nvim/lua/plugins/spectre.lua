-- plugins/spectre.lua

require("spectre").setup({
    color_devicons = true,
    open_cmd = "vnew",
    live_update = true,
    line_sep_start = "┌───────────────────────────────────────────────",
    result_padding = "│ ",
    line_sep = "└───────────────────────────────────────────────",
    highlight = {
        ui = "String",
        search = "DiffChange",
        replace = "DiffDelete",
    },
    mapping = {
        ['toggle_line'] = {
            map = "dd",
            cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
            desc = "toggle current item"
        },
        ['enter_file'] = {
            map = "<CR>",
            cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
            desc = "go to file"
        },
        ['send_to_qf'] = {
            map = "Q",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all items to quickfix"
        },
        ['replace_cmd'] = {
            map = "<leader>R",
            cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
            desc = "input replace command"
        },
        ['show_option_menu'] = {
            map = "<leader>o",
            cmd = "<cmd>lua require('spectre').toggle_options()<CR>",
            desc = "toggle options"
        },
        ['run_current_replace'] = {
            map = "<leader>rc",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "replace current line"
        },
        ['run_replace'] = {
            map = "<leader>ra",
            cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
            desc = "replace all"
        },
        ['change_view_mode'] = {
            map = "<leader>v",
            cmd = "<cmd>lua require('spectre').change_view()<CR>",
            desc = "change result view mode"
        },
        ['toggle_ignore_case'] = {
            map = "<leader>ic",
            cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
            desc = "toggle ignore case"
        },
        ['toggle_ignore_hidden'] = {
            map = "<leader>ih",
            cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
            desc = "toggle hidden files"
        },
    },
})

-- Global Spectre entry points
vim.keymap.set("n", "<leader>sr", function()
    require("spectre").open()
end, { desc = "Search and replace in project" })

vim.keymap.set("n", "<leader>sw", function()
    require("spectre").open_visual({ select_word = true })
end, { desc = "Search word under cursor" })

vim.keymap.set("v", "<leader>sw", function()
    require("spectre").open_visual()
end, { desc = "Search selected text" })

vim.keymap.set("n", "<leader>sf", function()
    require("spectre").open_file_search({ select_word = true })
end, { desc = "Search current file" })
