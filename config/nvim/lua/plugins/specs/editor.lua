return {
    -- Code commenting
    {
        'numToStr/Comment.nvim',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require('Comment').setup()
        end
    },

    -- Surround text objects
    {
        'kylechui/nvim-surround',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-surround").setup()
        end
    },

    -- Git signs in the gutter
    {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require('gitsigns').setup({
                signs = {
                    add          = { text = '│' },
                    change       = { text = '│' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                    untracked    = { text = '┆' },
                },
                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol',
                    ignore_whitespace = true,
                    delay = 1000,
                },
            })
        end
    }
}
