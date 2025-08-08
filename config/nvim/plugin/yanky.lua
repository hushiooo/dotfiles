require("yanky").setup({
    max_items = 300,
    auto_paste_on_select = false,
})

vim.keymap.set("n", "<leader>sy", function()
    require("yanky").yank_history_picker()
end, { desc = "Yank History Picker" })
