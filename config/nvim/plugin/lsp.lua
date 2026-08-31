vim.lsp.log.set_level(vim.log.levels.ERROR)

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local sev = vim.diagnostic.severity
local map = vim.keymap.set
local telescope_builtin = require("telescope.builtin")

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
            checkOnSave = true,
            check = { command = "clippy" },
        },
    },
})

-- Zig
setup("zls")

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
setup("bashls")

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

-- Markdown
setup("marksman", {
    filetypes = { "markdown", "markdown.mdx" },
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
        -- 0.12 globals: gra, gri, grn, grr, grt, grx, gO, K; ]d/[d for diagnostics.
        -- gd is not a default; <C-k> gives normal-mode signature help (default is i<C-s>).
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts)
        map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
        map("n", "<leader>cd", vim.diagnostic.open_float, { buffer = ev.buf, desc = "Show diagnostics", silent = true })
        map("n", "<leader>ci", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
        end, { buffer = ev.buf, desc = "Toggle inlay hints", silent = true })
    end,
})

map("n", "<leader>xd", function()
    telescope_builtin.diagnostics({ bufnr = 0 })
end, { desc = "Diagnostics (buffer)" })

map("n", "<leader>xD", function()
    telescope_builtin.diagnostics()
end, { desc = "Diagnostics (workspace)" })

-- ]d / [d need Option on AZERTY, so diagnostic movement gets leader keys.
map("n", "<leader>dn", function()
    vim.diagnostic.jump({ count = 1 })
end, { desc = "Diagnostic: next" })

map("n", "<leader>dp", function()
    vim.diagnostic.jump({ count = -1 })
end, { desc = "Diagnostic: previous" })
