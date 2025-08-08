require("pareil").setup()

vim.keymap.set("n", "<leader>pd", function()
    require("pareil").open()
end, { desc = "Pareils diff (popup)", silent = true })
