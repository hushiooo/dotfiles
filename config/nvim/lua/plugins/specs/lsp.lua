return {
    -- Mason: Package manager for LSP servers, linters, formatters
    {
        'williamboman/mason.nvim',
        cmd = "Mason",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end
    },

    -- Bridge between Mason and LSP config
    {
        'williamboman/mason-lspconfig.nvim',
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            'williamboman/mason.nvim',
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ruff",
                    "pyright",
                    "tsserver",
                    "lua_ls",
                    "gopls",
                    "clangd",
                    "rust_analyzer",
                    "yamlls",
                    "tflint",
                    "jsonls",
                },
                automatic_installation = true,
            })
        end
    },

    -- LSP configuration
    {
        'neovim/nvim-lspconfig',
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            -- Common LSP settings
            local common_config = {
                capabilities = capabilities,
            }

            -- Server specific configurations
            local servers = {
                ruff = {
                    settings = {
                        args = { "--ignore=E501" },
                    },
                },
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "off",
                                diagnosticMode = "workspace",
                            },
                        },
                    },
                },
                tsserver = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                        },
                    },
                },
                gopls = {
                    settings = {
                        gopls = {
                            analyses = { unusedparams = true },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--completion-style=detailed",
                    },
                },
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = { command = "clippy" },
                        },
                    },
                },
                yamlls = {
                    settings = {
                        yaml = {
                            schemaStore = { enable = true },
                            validate = true,
                            format = { enable = true },
                        },
                    },
                },
                tflint = {
                    settings = {
                        tflint = { enable = true },
                    },
                },
                jsonls = {
                    settings = {
                        json = {
                            format = {
                                enable = true,
                            }
                        }
                    }
                },
                nixd = {},
            }

            -- Set up LSP servers
            for server_name, server_config in pairs(servers) do
                local config = vim.tbl_deep_extend("force", common_config, server_config)
                lspconfig[server_name].setup(config)
            end

            -- Diagnostic configuration
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

            local signs = {
                Error = " ",
                Warn = " ",
                Hint = "󰌵 ",
                Info = " ",
            }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- Set up LSP keymaps
            vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
            vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Set diagnostic list" })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

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
                    vim.keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbol" })
                    vim.keymap.set("n", "<leader>ct", vim.lsp.buf.type_definition, { desc = "Type definition" })
                end,
            })
        end
    }
}
