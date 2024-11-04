{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    # Essential plugins
    plenary-nvim        # Required by many plugins
    telescope-nvim      # Fuzzy finder
    which-key-nvim      # Key binding hints
    comment-nvim        # Easy commenting
    vim-sleuth          # Automatic indentation detection

    # File tree
    nvim-tree-lua
    nvim-web-devicons   # Icons for nvim-tree

    # Git integration
    gitsigns-nvim
    vim-fugitive

    # Treesitter
    (nvim-treesitter.withPlugins (plugins: with plugins; [
      bash
      c
      cpp
      go
      javascript
      json
      lua
      markdown
      nix
      python
      rust
      tsx
      typescript
      yaml
    ]))
    nvim-treesitter-textobjects
    nvim-treesitter-context    # Shows context (function/class) at top of screen

    # Completion and snippets
    nvim-cmp              # Completion engine
    cmp-buffer            # Buffer completions
    cmp-path              # Path completions
    cmp-nvim-lsp          # LSP completions
    cmp-nvim-lua          # Lua completions
    luasnip               # Snippet engine
    cmp_luasnip           # Snippet completions
    friendly-snippets     # Preconfigured snippets

    # Aesthetics
    catppuccin-nvim        # Color scheme
    lualine-nvim           # Status line
    indent-blankline-nvim  # Indentation guides

    # Editing enhancements
    nvim-autopairs     # Auto close brackets
    vim-surround       # Surround text objects
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
    set completeopt=menu,menuone,noselect

    " Key mappings
    let mapleader = " "

    " Easy window navigation
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
  '';

  extraLuaConfig = ''
    -- Catppuccin Configuration
    require("catppuccin").setup({
      flavour = "mocha",
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
      },
    })


    -- Colorscheme
    vim.cmd.colorscheme "catppuccin"

    -- Treesitter Configuration
    require('nvim-treesitter.configs').setup {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    }

    -- Completion Configuration
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'nvim_lua' },
      }),
    }

    require('lualine').setup({
          options = {
            theme = "catppuccin"
          }
        })

    -- Other Plugin Configurations
    require('nvim-tree').setup{}
    require('telescope').setup{}
    require('gitsigns').setup{}
    require('Comment').setup{}
    require('nvim-autopairs').setup{}
    require('which-key').setup{}
    require('indent_blankline').setup{}

    -- Telescope keymaps
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>fb', builtin.buffers, {})

    -- NvimTree keymaps
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {})
  '';
}
