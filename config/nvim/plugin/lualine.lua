require("lualine").setup({
    options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = {},
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
                    -- ":." is already cwd-relative.
                    local rel = vim.fn.fnamemodify(fname, ":.")
                    local parts = vim.split(rel, "/")

                    local name = rel
                    if #parts > 3 then
                        name = string.format("%s/…/%s/%s", parts[1], parts[#parts - 1], parts[#parts])
                    end

                    -- A `symbols` table is ignored on a function component, so
                    -- the flags below are rendered inline instead.
                    if vim.bo.modified then
                        name = name .. " +"
                    elseif vim.bo.readonly then
                        name = name .. " ~"
                    end

                    return name
                end,
                padding = { left = 1, right = 1 },
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
