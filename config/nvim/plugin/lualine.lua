require("lualine").setup({
    options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard" },
    },
    sections = {
        lualine_a = {
            { "mode", icon = "" },
        },
        lualine_b = {
            { "branch", icon = "" },
            {
                "diff",
                symbols = {
                    added = " ",
                    modified = " ",
                    removed = " ",
                },
                colored = true,
            },
        },
        lualine_c = {
            { "filename", path = 1, padding = { left = 1, right = 1 } },
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = {
                    error = " ",
                    warn = " ",
                    info = " ",
                    hint = "󰌵 ",
                },
                colored = true,
            },
        },
        lualine_x = {
            {
                function()
                    local clients = vim.lsp.get_clients({ bufnr = 0 })
                    if #clients == 0 then return "  No LSP" end
                    local names = {}
                    for _, c in pairs(clients) do table.insert(names, c.name) end
                    return "  " .. table.concat(names, ", ")
                end,
            },
            { "filetype", icon_only = true },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
})
