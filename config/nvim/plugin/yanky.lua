require("yanky").setup({
    ring = {
        history_length = 300,
        storage = "shada",
    },
    -- Yank highlighting stays with the TextYankPost autocmd in init.lua.
    highlight = {
        on_put = true,
        on_yank = false,
        timer = 150,
    },
})

require("telescope").load_extension("yank_history")

vim.keymap.set("n", "<leader>sy", function()
    require("telescope").extensions.yank_history.yank_history()
end, { desc = "Yank history" })

vim.keymap.set("n", "<leader>sY", "<cmd>YankyClearHistory<CR>", { desc = "Clear yank history" })

-- Route normal-mode puts through yanky so the ring is live. Visual-mode p keeps
-- the "_dP mapping from init.lua, which preserves the unnamed register.
vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)", { desc = "Put after" })
vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)", { desc = "Put before" })
vim.keymap.set("n", "gp", "<Plug>(YankyGPutAfter)", { desc = "Put after (cursor after)" })
vim.keymap.set("n", "gP", "<Plug>(YankyGPutBefore)", { desc = "Put before (cursor after)" })

-- Cycle through earlier yanks immediately after a put.
vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "Yank ring: older" })
vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)", { desc = "Yank ring: newer" })
