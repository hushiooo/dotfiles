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
})

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
