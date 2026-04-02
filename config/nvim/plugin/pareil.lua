require("pareil").setup()

vim.keymap.set("n", "<leader>pd", function()
    require("pareil").open()
end, { desc = "Pareil diff (popup)", silent = true })

vim.api.nvim_create_user_command("PareilsDiff", function()
    require("pareil").open()
end, {})
