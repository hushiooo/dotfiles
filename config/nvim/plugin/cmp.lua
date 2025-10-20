local cmp = require("cmp")
local luasnip = require("luasnip")
local unpack = table.unpack or unpack

local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then return false end
    local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1] or ""
    return text:sub(col, col):match("%s") == nil
end

cmp.setup({
    completion = {
        completeopt = "menu,menuone,noinsert",
        keyword_length = 1,
    },
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    window = {
        completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            scrollbar = false,
            side_padding = 1,
        }),
        documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Search:None",
            max_height = math.floor(vim.o.lines * 0.45),
            max_width = math.floor(vim.o.columns * 0.4),
        }),
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
            vim_item.menu = ({
                nvim_lsp = "LSP",
                nvim_lua = "NVIM",
                luasnip = "SNIP",
                buffer = "BUF",
                path = "PATH",
            })[entry.source.name]
            return vim_item
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function()
            if luasnip.jumpable(-1) then luasnip.jump(-1) end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "luasnip" },
    }, {
        { name = "buffer" },
        { name = "path" },
    }),
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
        { name = "cmdline" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
})
