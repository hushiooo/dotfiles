require("lualine").setup({
    options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
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
            {
                function()
                    local fname = vim.api.nvim_buf_get_name(0)
                    if fname == "" then return "[No Name]" end
                    local cwd = vim.loop.cwd() or ""
                    local rel = vim.fn.fnamemodify(fname, ":.")
                    if cwd ~= "" and fname:sub(1, #cwd) == cwd then rel = fname:sub(#cwd + 2) end

                    local parts = vim.split(rel, "/")
                    if #parts <= 2 then return rel end

                    local root = parts[1]
                    local parent = parts[#parts - 1]
                    local file = parts[#parts]

                    if #parts == 3 then return table.concat(parts, "/") end

                    return string.format("%s/…/%s/%s", root, parent, file)
                end,
                padding = { left = 1, right = 1 },
                symbols = {
                    readonly = " ",
                    modified = " ",
                    unnamed = "",
                },
            },
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
            { "filetype", icon_only = true },
            {
                "encoding",
                fmt = string.upper,
                cond = function()
                    local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
                    return enc ~= "utf-8"
                end,
            },
            {
                "fileformat",
                icons_enabled = false,
                cond = function() return vim.bo.fileformat ~= "unix" end,
            },
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
