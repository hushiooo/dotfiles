require("nvim-tree").setup({
    sort = { sorter = "case_sensitive" },
    view = {
        width = 50,
        side = "right",
        signcolumn = "yes",
        number = false,
        relativenumber = false,
    },
    renderer = {
        group_empty = true,
        indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
                corner = "└",
                edge = "│",
                item = "│",
                none = " ",
            },
        },
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = false,
            },
            glyphs = {
                default = " ",
                symlink = "",
                folder = {
                    arrow_closed = "",
                    arrow_open = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
                git = {
                    unstaged = "",
                    staged = "",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "",
                    deleted = "",
                    ignored = "◌",
                },
            },
        },
        highlight_git = true,
    },
    git = {
        enable = true,
        ignore = false,
        timeout = 400,
    },
    filters = {
        dotfiles = false,
        custom = {},
    },
    on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        local map = vim.keymap.set
        map("n", "<CR>", api.node.open.edit, opts("Open"))
        map("n", "o", api.node.open.edit, opts("Open"))
        map("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
        map("n", "dd", api.fs.remove, opts("Delete"))
        map("n", "D", api.fs.trash, opts("Trash"))
        map("n", "yy", api.fs.copy.node, opts("Copy"))
        map("n", "yn", api.fs.copy.filename, opts("Copy Name"))
        map("n", "cc", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
        map("n", "a", api.fs.create, opts("Create File/Folder"))
        map("n", "r", api.fs.rename, opts("Rename"))
        map("n", "x", api.fs.cut, opts("Cut"))
        map("n", "p", api.fs.paste, opts("Paste"))
        map("n", "R", api.tree.reload, opts("Refresh"))
    end,
})

-- Keymaps
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle nvim-tree", silent = true })
vim.keymap.set("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "Focus nvim-tree", silent = true })
