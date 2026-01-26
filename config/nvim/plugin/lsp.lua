local capabilities = require("cmp_nvim_lsp").default_capabilities()
local sev = vim.diagnostic.severity
local border = "rounded"
local map = vim.keymap.set
local has_telescope, telescope_builtin = pcall(require, "telescope.builtin")

local function setup(server, config)
    vim.lsp.config(server, vim.tbl_deep_extend("force", { capabilities = capabilities }, config or {}))
    vim.lsp.enable(server)
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = border,
    title = "Hover",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = border,
    close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
})

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
        nixpkgs = {
            expr = "import <nixpkgs> { }",
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
setup("ty", {
    settings = {
        ty = {
            diagnosticMode = "workspace",
            experimental = {
                autoImport = true,
            },
        },
    },
})

-- Web & misc servers
for _, server in ipairs({
    "ts_ls",
    "html",
    "cssls",
    "dockerls",
    "terraformls",
}) do
    setup(server)
end


vim.diagnostic.config({
    virtual_text = false,
    float = {
        border = border,
        source = "if_many",
        header = "",
        prefix = "",
        style = "minimal",
        focusable = false,
    },
    signs = {
        text = {
            [sev.ERROR] = " ",
            [sev.WARN]  = " ",
            [sev.HINT]  = "󰌵 ",
            [sev.INFO]  = " ",
        },
        numhl = {
            [sev.ERROR] = "DiagnosticSignError",
            [sev.WARN]  = "DiagnosticSignWarn",
            [sev.HINT]  = "DiagnosticSignHint",
            [sev.INFO]  = "DiagnosticSignInfo",
        },
    },
    underline = false,
    update_in_insert = false,
    severity_sort = true,
})

-- Keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        map("n", "gD", vim.lsp.buf.declaration, opts)
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "gi", vim.lsp.buf.implementation, opts)
        map("n", "gr", vim.lsp.buf.references, opts)
        map("n", "K", vim.lsp.buf.hover, opts)
        map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        map("n", "<leader>cr", vim.lsp.buf.rename, opts)
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts)
        map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
        map("n", "<leader>ct", vim.lsp.buf.type_definition, opts)
        map("n", "<leader>cd", vim.diagnostic.open_float, { buffer = ev.buf, desc = "Show diagnostics", silent = true })

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.server_capabilities.inlayHintProvider then
            pcall(vim.lsp.inlay_hint, ev.buf, true)
        end
    end,
})

local function open_diagnostics(scope)
    if has_telescope then
        if scope == "workspace" then
            telescope_builtin.diagnostics()
        else
            telescope_builtin.diagnostics({ bufnr = 0 })
        end
        return
    end

    if scope == "workspace" then
        vim.diagnostic.setqflist()
        vim.cmd("copen")
    else
        vim.diagnostic.setloclist(0)
        vim.cmd("lopen")
    end
end

map("n", "<leader>xd", function() open_diagnostics("buffer") end, { desc = "Diagnostics (buffer)" })
map("n", "<leader>xD", function() open_diagnostics("workspace") end, { desc = "Diagnostics (workspace)" })
