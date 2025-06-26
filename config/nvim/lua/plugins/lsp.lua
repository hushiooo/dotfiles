local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function setup_lsp(server, config)
    config = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
    }, config or {})
    lspconfig[server].setup(config)
end

setup_lsp("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off",
                diagnosticMode = "workspace",
            },
        },
    },
})

setup_lsp("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

setup_lsp("gopls", {
    settings = {
        gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

setup_lsp("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
    },
})

setup_lsp("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
        },
    },
})

setup_lsp("yamlls", {
    settings = {
        yaml = {
            schemaStore = { enable = true },
            validate = true,
            format = { enable = true },
        },
    },
})

setup_lsp("jsonls", {
    settings = {
        json = {
            format = { enable = true },
        },
    },
})

setup_lsp("nil_ls", {
    settings = {
        ['nil'] = {
            formatting = {
                command = { "nixfmt" },
            },
        },
    },
})

setup_lsp("bashls", {
    on_attach = function(client, bufnr)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename:match("%.env$") then
            client.stop()
            return
        end
    end,
})

for _, server in ipairs({
    "ts_ls",
    "html",
    "cssls",
    "bashls",
    "dockerls",
    "marksman",
    "tflint",
    "ruff",
}) do
    setup_lsp(server)
end

vim.diagnostic.config({
    virtual_text = false,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
        style = "minimal",
    },
    signs = true,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
})

for type, icon in pairs({
    Error = " ",
    Warn  = " ",
    Hint  = "󰌵 ",
    Info  = " ",
}) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>ct", vim.lsp.buf.type_definition, opts)
    end,
})

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostics in float" })
vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
