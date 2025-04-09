-- Initialize lazy.nvim
return require('lazy').setup({
    -- Import all plugin specs from separate files
    { import = "plugins.specs.ui" },
    { import = "plugins.specs.navigation" },
    { import = "plugins.specs.editor" },
    { import = "plugins.specs.lsp" },
    { import = "plugins.specs.completion" },
    { import = "plugins.specs.treesitter" },
}, {
    install = {
        -- Install missing plugins on startup
        missing = true,
        -- Try to load one of these colorschemes when starting an installation
        colorscheme = { "tokyonight" },
    },
    checker = {
        -- Check for plugin updates
        enabled = true,
        -- Automatically check for plugin updates
        concurrency = nil,
        -- Check for updates on startup
        check_pinned = false,
        -- Notification settings
        notify = true,
        -- How often to check for updates (in hours)
        frequency = 24,
    },
    change_detection = {
        -- Automatically check for config file changes and reload
        enabled = true,
        notify = true,
    },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            -- Disable some rtp plugins
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    ui = {
        -- Show a border for floating windows
        border = "rounded",
        -- Icons for the lazy.nvim UI
        icons = {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🔑",
            plugin = "🔌",
            runtime = "💻",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤",
        },
    },
})
