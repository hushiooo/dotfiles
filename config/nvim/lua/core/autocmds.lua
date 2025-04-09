-- Create autocmd groups
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings group
local general_group = augroup("GeneralSettings", { clear = true })

-- Set 2-space indentation for certain filetypes
autocmd("FileType", {
    pattern = { "json", "yaml", "html", "css", "scss", "javascript", "typescript", "typescriptreact", "lua" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
    group = general_group,
})

-- Highlight yanked text
autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
    group = general_group,
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
    callback = function()
        local last_pos = vim.fn.line("'\"")
        if last_pos > 0 and last_pos <= vim.fn.line("$") then
            vim.fn.setpos(".", { 0, last_pos, 1, 0 })
        end
    end,
    group = general_group,
})

-- Auto-resize splits when window is resized
autocmd("VimResized", {
    command = "wincmd =",
    group = general_group,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
    group = general_group,
})
