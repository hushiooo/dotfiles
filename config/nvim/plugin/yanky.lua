require("yanky").setup({
    max_items = 300,
    auto_paste_on_select = false,
})

vim.keymap.set({ "n", "x" }, "<leader>p", "<Plug>(YankyPutAfter)", { desc = "Put after (yank ring)" })
vim.keymap.set({ "n", "x" }, "<leader>P", "<Plug>(YankyPutBefore)", { desc = "Put before (yank ring)" })
vim.keymap.set("n", "]y", "<Plug>(YankyCycleForward)", { desc = "Next yank in ring" })
vim.keymap.set("n", "[y", "<Plug>(YankyCycleBackward)", { desc = "Prev yank in ring" })

vim.keymap.set("n", "<leader>sy", function()
    require("yanky").yank_history_picker()
end, { desc = "Yank History Picker" })
