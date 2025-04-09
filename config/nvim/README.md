# Standalone Neovim Configuration Setup Guide

This guide will help you set up your Neovim configuration without needing home-manager or nix-darwin. This setup has been extracted from your existing nix-based configuration and converted to a standalone format using lazy.nvim as the plugin manager.

## Prerequisites

1. Neovim (version 0.8.0 or later recommended)
2. Git
3. A terminal that supports Nerd Fonts (for icons)
4. A C compiler (for some plugins that need to be built)
5. Node.js (for LSP servers)

## Installation Steps

### 1. Install Neovim

If you haven't already installed Neovim, do so using your package manager of choice.

For example, on macOS with Homebrew:
```
brew install neovim
```

### 2. Set up the Configuration Directory

Create the Neovim config directory if it doesn't exist:

```bash
mkdir -p ~/.config/nvim/lua/{core,plugins/specs}
```

### 3. Copy Configuration Files

Copy all the configuration files you've created to the appropriate directories:

- `init.lua` → `~/.config/nvim/init.lua`
- `lua/core/*.lua` → `~/.config/nvim/lua/core/`
- `lua/plugins/init.lua` → `~/.config/nvim/lua/plugins/`
- `lua/plugins/specs/*.lua` → `~/.config/nvim/lua/plugins/specs/`

### 4. Install a Nerd Font

For the icons to display correctly, you'll need a Nerd Font. You can download one from the [Nerd Fonts website](https://www.nerdfonts.com/font-downloads).

For example, JetBrains Mono Nerd Font is a good choice:

```bash
# On macOS with Homebrew
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

Then configure your terminal to use this font.

### 5. First Run

Launch Neovim:

```bash
nvim
```

The first time you start Neovim with this configuration, lazy.nvim (the plugin manager) will be automatically installed and will begin installing all the plugins defined in your configuration.

lazy.nvim will install all the plugins in the background. You can monitor the progress by checking the lazy.nvim UI, which should open automatically.

### 6. Install LSP Servers

Most LSP servers will be installed automatically by Mason. You can open Mason to check the status of language servers by running:

```
:Mason
```

You might need to manually install some dependencies:

- Node.js (for most language servers)
- Python (for Python-based servers)
- Rust (for rust-analyzer)
- Go (for gopls)
- C/C++ compilers (for clangd)

Mason should handle the installation of the actual language servers through its interface.

## Key Features

Your Neovim configuration includes:

1. Tokyo Night theme
2. File explorer (nvim-tree)
3. Fuzzy finder (Telescope)
4. LSP support with autocompletion
5. Syntax highlighting via Treesitter
6. Git integration
7. Status line (lualine)
8. Enhanced UI with notifications
9. Code commenting and text surrounding plugins

## Key Mappings

Some important key mappings to remember:

- `<Space>` is your leader key
- `<leader>e` - Toggle file explorer
- `<leader>ff` - Find files with Telescope
- `<leader>fg` - Live grep with Telescope
- `<leader>fb` - Find open buffers
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<C-h/j/k/l>` - Navigate between splits
- `<leader>ca` - Code actions (when LSP is available)
- `<leader>cf` - Format code (when LSP is available)
- `gd` - Go to definition
- `K` - Show documentation hover
- `<leader>cr` - Rename symbol

## Customization

You can customize this configuration by editing the Lua files in the appropriate directories:

1. Edit `lua/core/options.lua` for basic Vim settings
2. Edit `lua/core/keymaps.lua` for key mappings
3. Edit plugin configurations in `lua/plugins/specs/` directory

## Troubleshooting

If you encounter issues:

1. Make sure your Neovim version is 0.8.0 or higher
2. Check if required dependencies (like Node.js) are installed
3. Run `:checkhealth` inside Neovim to diagnose issues
4. If a plugin isn't working, try reinstalling it with `:Lazy sync`
5. Check `:Lazy` for plugin status and errors

## Managing Plugins

- `:Lazy` - Open the lazy.nvim interface
- `:Lazy sync` - Sync plugins (install, update, clean)
- `:Lazy update` - Update all plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy check` - Check for updates
- `:Lazy log` - Show the log
- `:Lazy restore` - Restore plugins from a lockfile

## Upgrading LSP Servers

To update LSP servers, use Mason's interface by running `:Mason` and updating the servers from there.
