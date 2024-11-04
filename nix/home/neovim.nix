{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    # Essential plugins
    plenary-nvim
    telescope-nvim # Quick file navigation
    which-key-nvim # Command hints
    comment-nvim # Easy commenting
    vim-sleuth # Auto indentation

    # File tree and icons
    nvim-tree-lua
    nvim-web-devicons

    # Git integration
    gitsigns-nvim

    # Basic LSP support
    nvim-lspconfig

    # Syntax highlighting
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        bash
        go
        python
        json
        lua
        markdown
        nix
        yaml
      ]
    ))

    # Theme
    tokyonight-nvim

    # Status line
    lualine-nvim

    # Basic editing improvements
    nvim-autopairs
    vim-surround
  ];

  extraConfig = ''
    " Basic Settings
    set number relativenumber
    set mouse=a
    set clipboard=unnamedplus
    set ignorecase
    set smartcase
    set undofile
    set expandtab
    set shiftwidth=2
    set hidden
    set termguicolors
    set scrolloff=8
    set cursorline
    set signcolumn=yes

    " Set colorscheme
    colorscheme tokyonight-moon

    " Key mappings
    let mapleader = " "

    " Easy window navigation
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    " Quick save and quit
    nnoremap <leader>w :w<CR>
    nnoremap <leader>q :q<CR>

    " Undo / Redo
    nnoremap U <C-r>
    nnoremap <leader>u u
    nnoremap <leader>U U

    " Better navigation
    nnoremap <leader>h :noh<CR>
  '';

  extraLuaConfig = ''
    -- Silence which-key warnings about overlapping keymaps
    vim.g.which_key_ignore_overlapping = 1

    -- Theme Configuration
    require("tokyonight").setup({
      style = "moon",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark"
      }
    })

    -- Treesitter
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
      },
      indent = { enable = true }
    })

    -- LSP Configuration
    local lspconfig = require("lspconfig")

    -- Common LSP keybindings
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })

    -- Python LSP
    lspconfig.pyright.setup({})

    -- Go LSP
    lspconfig.gopls.setup({})

    -- Nix LSP
    lspconfig.nixd.setup({
      cmd = { "nixd" },
      filetypes = { "nix" },
      root_dir = lspconfig.util.root_pattern(".git", "flake.nix", "default.nix"),
      settings = {
        nixd = {
          formatting = {
            command = "nixfmt"
          }
        }
      }
    })

    -- Status line
    require("lualine").setup({
      options = {
        theme = "tokyonight",
        component_separators = "|",
        section_separators = ""
      },
      sections = {
        lualine_a = {"mode"},
        lualine_b = {"filename"},
        lualine_c = {"branch"},
        lualine_x = {"filetype"},
        lualine_y = {"progress"},
        lualine_z = {"location"}
      }
    })

    -- File Explorer
    require("nvim-tree").setup({
      view = {
        width = 30,
        side = "right"
      }
    })

    -- Telescope
    require("telescope").setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.95,
          height = 0.85
        }
      }
    })

    -- Git signs
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" }
      }
    })

    -- Other Plugin Configurations
    require("Comment").setup({})
    require("nvim-autopairs").setup({})
    require("which-key").setup({
      win = {
        border = "single"
      }
    })

    -- Essential keymaps
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
  '';
}
