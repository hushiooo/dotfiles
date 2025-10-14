local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function setup(server, config)
    vim.lsp.config(server, vim.tbl_deep_extend("force", { capabilities = capabilities }, config or {}))
    vim.lsp.enable(server)
end

-- Lua
setup("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- Go
setup("gopls", {
    settings = {
        gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

-- C/C++
setup("clangd", {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
})

-- Rust
setup("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
        },
    },
})

-- YAML
setup("yamlls", {
    settings = {
        yaml = { schemaStore = { enable = true }, validate = true, format = { enable = true } },
    },
})

-- JSON
setup("jsonls", {
    settings = { json = { format = { enable = true } } },
})

-- Nix
setup("nixd", {
    settings = {
        nixd = {
            formatting = { command = { "nixfmt" } },
            nixpkgs = { expr = "(import <nixpkgs> {})" },
            options = {
                nixos = { expr = "(import <nixpkgs/nixos> { configuration = {}; }).options" },
            },
        },
    },
})

-- Bash
setup("bashls", {
    on_attach = function(_, bufnr)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename:match("%.env$") then
            vim.schedule(function()
                for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if c.name == "bashls" then c.stop() end
                end
            end)
        end
    end,
})

-- Python
setup("ruff", {
    init_options = {
        settings = {
            configurationPreference = "filesystemFirst",
            fixAll = true,
            organizeImports = true,
            showSyntaxErrors = true,
            lineLength = 110,
            logLevel = "warn",
        },
    },
})

setup("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off",
                diagnosticMode = "openFilesOnly",
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
    on_attach = function(client)
        -- disable all diagnostics from Pyright
        client.handlers["textDocument/publishDiagnostics"] = function() end
    end,
})

vim.lsp.config('ty', {
    settings = {
        ty = {
            disableLanguageServices = true,
            diagnosticMode = 'workspace',
        },
    },
})

vim.lsp.enable('ty')



-- Web & misc servers
for _, server in ipairs({
    "ts_ls",
    "html",
    "cssls",
    "dockerls",
    "marksman",
    "terraformls",
}) do
    setup(server)
end

-- Diagnostics UI
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

-- Keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts =
        { buffer = ev.buf }
        vim.keymap
            .set("n", "gD", vim.lsp.buf.declaration,
                opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim
            .keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
        vim.keymap
            .set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap
            .set("n", "<leader>cf",
                function() vim.lsp.buf.format({ async = true }) end, opts)
        vim
            .keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
        vim
            .keymap.set("n", "<leader>ct", vim.lsp.buf.type_definition, opts)
        vim.keymap.set(
            "n", "<leader>cd", vim.diagnostic.open_float,
            { desc = "Show diagnostics in float", silent = true })

        local client =
            vim.lsp.get_client_by_id(ev.data.client_id)
        if client and
            client.server_capabilities.inlayHintProvider then
            pcall(
                vim.lsp.inlay_hint, ev.buf, true)
        end
    end,
})
