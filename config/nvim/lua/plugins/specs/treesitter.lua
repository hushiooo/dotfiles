return {
    -- Treesitter for syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "html",
                    "typescript",
                    "javascript",
                    "css",
                    "tsx",
                    "python",
                    "rust",
                    "go",
                    "c",
                    "cpp",
                    "lua",
                    "json",
                    "yaml",
                    "toml",
                    "nix",
                    "bash",
                    "dockerfile",
                    "markdown",
                    "markdown_inline",
                    "git_rebase",
                    "gitcommit",
                    "gitignore",
                    "regex",
                    "vim",
                    "hcl",
                },
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        node_incremental = "<TAB>",
                        node_decremental = "<S-TAB>",
                    },
                },
                context_commentstring = { enable = true },
                auto_install = true,
            })
        end
    }
}
