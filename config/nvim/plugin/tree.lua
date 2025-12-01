local function tree_on_attach(bufnr)
    local api = require("nvim-tree.api")
    api.config.mappings.default_on_attach(bufnr)

    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    local map = vim.keymap.set
    map("n", "o", api.node.open.edit, opts("Open"))
    map("n", "O", api.node.open.no_window_picker, opts("Open (no picker)"))
    map("n", "P", api.node.navigate.parent_close, opts("Parent close"))
    map("n", "<leader>rn", api.fs.rename_sub, opts("Rename keep extension"))
    map("n", "yy", api.fs.copy.node, opts("Copy"))
    map("n", "yn", api.fs.copy.filename, opts("Copy Name"))
    map("n", "cc", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
    map("n", "x", api.fs.cut, opts("Cut"))
    map("n", "p", api.fs.paste, opts("Paste"))
    map("n", "dd", api.fs.remove, opts("Delete"))
    map("n", "R", api.tree.reload, opts("Refresh"))
end

require("nvim-tree").setup({
    sort = { sorter = "case_sensitive", folders_first = true },
    hijack_cursor = true,
    respect_buf_cwd = true,
    sync_root_with_cwd = true,
    reload_on_bufenter = true,
    update_focused_file = {
        enable = true,
        debounce_delay = 100,
        update_root = false,
        ignore_list = {},
    },
    view = {
        width = 50,
        side = "right",
        signcolumn = "no",
        number = false,
        relativenumber = false,
        preserve_window_proportions = true,
    },
    renderer = {
        group_empty = true,
        root_folder_label = false,
        highlight_git = false,
        highlight_diagnostics = true,
        highlight_opened_files = "none",
        indent_width = 2,
        indent_markers = {
            enable = true,
            inline_arrows = false,
            icons = {
                corner = "╰",
                edge = "│",
                item = "│",
                none = " ",
            },
        },
        icons = {
            padding = "  ",
            show = {
                file = true,
                folder = true,
                folder_arrow = false,
                git = false,
            },
            glyphs = {
                default = "󰈚",
                symlink = "",
                bookmark = "",
                modified = "●",
                folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
                git = {
                    unstaged = "",
                    staged = "",
                    unmerged = "",
                    renamed = "",
                    untracked = "",
                    deleted = "",
                    ignored = "◌",
                },
            },
        },
    },
    diagnostics = {
        enable = true,
        show_on_dirs = false,
        show_on_open_dirs = true,
        debounce_delay = 100,
        icons = {
            hint = "󰌵",
            info = "",
            warning = "",
            error = "",
        },
    },
    git = {
        enable = true,
        ignore = false,
        timeout = 400,
    },
    filters = {
        dotfiles = false,
        custom = { "^.git$", "node_modules", "__pycache__" },
    },
    actions = {
        open_file = {
            resize_window = true,
            window_picker = {
                enable = true,
                chars = "AOEUIDHTNS",
            },
        },
        file_popup = {
            open_win_config = {
                border = "rounded",
            },
        },
    },
    on_attach = tree_on_attach,
})

-- Keymaps
local tree_api = require("nvim-tree.api")
vim.keymap.set("n", "<leader>e", function()
    tree_api.tree.toggle({ focus = true })
end, { desc = "Toggle nvim-tree", silent = true })
vim.keymap.set("n", "<leader>o", function()
    tree_api.tree.focus()
end, { desc = "Focus nvim-tree", silent = true })
