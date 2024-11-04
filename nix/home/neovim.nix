{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;    # Allows using 'vi' command
  vimAlias = true;   # Allows using 'vim' command

  # Dependencies for Neovim - packages required for full functionality
  package = pkgs.neovim.override {
    extraPackages = with pkgs; [
      # LSP (Language Server Protocol) Servers
      nodePackages.typescript-language-server # Provides TypeScript/JavaScript support
      nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers
      nodePackages.prettier # Code formatting for JS/TS/HTML/CSS
      ruff-lsp # Fast Python linter & formatter
      python311Packages.ruff # Required for ruff-lsp
      gopls # Go language server with advanced features
      nil # Nix language server

      # Telescope (fuzzy finder) Dependencies
      fd    # Faster alternative to 'find'
      ripgrep # Fast text search tool (required for live grep)

      # Language Dependencies
      nodejs  # Required for TS/JS tools and many LSP servers
      python311 # Python runtime
      go     # Go runtime

      # Syntax Support
      tree-sitter # Required for syntax highlighting and code navigation
    ];
  };

  # Neovim plugins configuration
  plugins = with pkgs.vimPlugins; [
    # Essential - Core functionality plugins
    plenary-nvim     # Utility functions used by many plugins
    nvim-web-devicons # Icons for file explorer and statusline

    # Theme and UI - Visual enhancements
    catppuccin-nvim          # Modern, clean theme
    lualine-nvim             # Enhanced status line
    indent-blankline-nvim    # Show indent guides
    which-key-nvim           # Shows key binding hints
    nvim-colorizer-lua       # Displays color codes in their actual color
    nvim-notify              # Better notifications
    trouble-nvim             # Better diagnostics display
    todo-comments-nvim       # Highlight and search TODO comments
    vim-illuminate           # Highlight other uses of word under cursor

    # File Navigation - File management and search
    telescope-nvim           # Fuzzy finder for files, buffers, and more
    telescope-fzf-native-nvim # Better sorting performance for telescope
    telescope-ui-select-nvim  # Better UI for code actions
    nvim-tree-lua           # File explorer sidebar

    # Editor Features - Text editing enhancements
    vim-surround            # Easily change surroundings (parentheses, quotes, etc.)
    comment-nvim            # Easy code commenting
    nvim-autopairs          # Auto close brackets, parentheses, etc.
    gitsigns-nvim          # Git integration in buffer
    vim-fugitive           # Git commands within Neovim

    # Completion and Snippets - Code completion
    nvim-cmp               # Completion engine
    cmp-nvim-lsp          # LSP completion source
    cmp-buffer            # Buffer words completion source
    cmp-path              # Path completion source
    cmp-cmdline           # Command line completion source
    luasnip               # Snippet engine
    cmp_luasnip           # Snippet completion source
    friendly-snippets     # Collection of useful snippets

    # LSP - Language Server Protocol integration
    nvim-lspconfig         # Easy LSP configuration
    null-ls-nvim          # Use non-LSP tools with LSP interface

    # Treesitter - Advanced syntax highlighting and code navigation
    (nvim-treesitter.withPlugins (plugins: with plugins; [
      tree-sitter-nix
      tree-sitter-lua
      tree-sitter-vim
      tree-sitter-bash
      tree-sitter-go
      tree-sitter-python
      tree-sitter-typescript
      tree-sitter-javascript
      tree-sitter-json
      tree-sitter-yaml
      tree-sitter-markdown
      tree-sitter-html
      tree-sitter-scss
      tree-sitter-css
    ]))
    nvim-treesitter-textobjects  # Additional text objects based on syntax
    nvim-treesitter-context      # Shows current code context at top of window
  ];

  # Lua configuration for Neovim and plugins
    extraLuaConfig = ''
      -- General Settings - Basic Neovim configuration
      vim.g.mapleader = " "               -- Set leader key to space
      vim.opt.number = true               -- Show line numbers
      vim.opt.relativenumber = true       -- Show relative line numbers
      vim.opt.mouse = 'a'                 -- Enable mouse support
      vim.opt.ignorecase = true          -- Ignore case in search
      vim.opt.smartcase = true           -- Case sensitive if search contains uppercase
      vim.opt.hlsearch = false           -- Don't highlight search results
      vim.opt.wrap = false               -- Don't wrap lines
      vim.opt.breakindent = true         -- Maintain indent when wrapping
      vim.opt.tabstop = 2                -- Number of spaces tabs count for
      vim.opt.shiftwidth = 2             -- Size of indent
      vim.opt.expandtab = true           -- Use spaces instead of tabs
      vim.opt.signcolumn = "yes"         -- Always show sign column
      vim.opt.termguicolors = true       -- Enable 24-bit RGB colors

      -- Theme Setup - Catppuccin colorscheme configuration
      require("catppuccin").setup({
        flavour = "mocha",               -- Choose theme variant
        transparent_background = false,
        integrations = {
          telescope = true,
          cmp = true,
          treesitter = true,
          which_key = true,
          gitsigns = true,
          indent_blankline = {
            enabled = true,
          },
          native_lsp = {
            enabled = true,
          },
        },
      })
      vim.cmd.colorscheme "catppuccin"

      -- Lualine Setup - Status line configuration
      require('lualine').setup({
        options = {
          theme = "catppuccin",
          component_separators = '|',
          section_separators = '',
        },
      })

      -- Telescope Setup - Fuzzy finder configuration
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
          mappings = {
            i = {
              ['<C-u>'] = false,        -- Clear prompt
              ['<C-d>'] = false,        -- Scroll preview down
            },
          },
        },
      })

      -- Keybindings for Telescope
      -- <leader> is space key
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})    -- Find files
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})     -- Find text
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})       -- Find buffers
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})     -- Find help

      -- LSP Setup - Language Server Protocol configuration
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = true,              -- Show diagnostics beside text
        signs = true,                     -- Show signs in sign column
        underline = true,                 -- Underline problems
        update_in_insert = false,         -- Don't update diagnostics in insert mode
        severity_sort = true,             -- Sort by severity
        float = {
          border = 'rounded',
          source = 'always',
        },
      })

      -- Add diagnostic symbols
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- LSP Keybindings - Applied to buffers with LSP attached
      local on_attach = function(client, bufnr)
        local opts = { noremap=true, silent=true, buffer=bufnr }
        -- Code navigation
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)         -- Go to declaration
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)          -- Go to definition
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                -- Show hover info
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)      -- Go to implementation
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)   -- Show signature help
        -- Code actions
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)      -- Rename symbol
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- Code actions
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)          -- Find references
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts) -- Format code
        -- Diagnostics
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)        -- Previous diagnostic
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)        -- Next diagnostic
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- Show diagnostic in float

        -- Enable word highlighting
        require('illuminate').on_attach(client)
      end

      -- Configure LSP servers
      -- TypeScript/JavaScript
      lspconfig.tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Python
      lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- HTML
      lspconfig.html.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- CSS
      lspconfig.cssls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })

      -- Nix
      lspconfig.nil_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Null-ls for additional formatting capabilities
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,  -- For JS/TS/HTML/CSS
          null_ls.builtins.formatting.ruff,      -- For Python
          null_ls.builtins.formatting.gofmt,     -- For Go
        },
      })

      -- Completion Setup - nvim-cmp configuration
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },    -- From LSP
          { name = 'luasnip' },     -- From snippets
          { name = 'buffer' },      -- From current buffer
          { name = 'path' },        -- From file system path
        }),
      })

      -- Treesitter Setup - Advanced syntax highlighting
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,            -- Enable syntax highlighting
        },
        indent = {
          enable = true,            -- Enable indentation
        },
        textobjects = {
          enable = true,            -- Enable text objects
        },
      })

      -- Additional Plugin Setup
      require('Comment').setup()              -- Easy commenting
      require('nvim-autopairs').setup()       -- Auto-close pairs
      require('gitsigns').setup()             -- Git signs in gutter
      require('nvim-tree').setup()            -- File explorer
      require('which-key').setup()            -- Key binding hints
      require('colorizer').setup()            -- Color highlighter

      -- Trouble setup (better diagnostics window)
      require("trouble").setup({
        icons = true,
        padding = false,
        action_keys = {
          close = "q",
          cancel = "<esc>",
          refresh = "r",
          jump = {"<cr>", "<tab>"},
          open_split = { "<c-x>" },
          open_vsplit = { "<c-v>" },
          open_tab = { "<c-t>" },
          jump_close = {"o"},
          toggle_mode = "m",
          switch_severity = "s",
          toggle_preview = "P",
          hover = "K",
          preview = "p",
          close_folds = {"zM", "zm"},
          open_folds = {"zR", "zr"},
          toggle_fold = {"zA", "za"},
          previous = "k",
          next = "j"
        },
      })

      -- Todo comments setup
      require("todo-comments").setup()

      -- Notifications setup
      require("notify").setup({
        background_colour = "#000000",
        timeout = 3000,
        max_width = 80,
      })
      vim.notify = require("notify")

      -- Set up telescope-ui-select
      require("telescope").load_extension("ui-select")

      -- Additional keymaps for new features
      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>")                           -- Toggle trouble
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")     -- Workspace diagnostics
      vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")      -- Document diagnostics
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>")                   -- Location list
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>")                  -- Quickfix list
      vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<cr>")                             -- Todo list

      -- Basic window navigation
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')    -- Toggle file explorer
      vim.keymap.set('n', '<leader>w', ':w<CR>')                 -- Save
      vim.keymap.set('n', '<leader>q', ':q<CR>')                 -- Quit
      vim.keymap.set('n', '<C-h>', '<C-w>h')                     -- Move to left window
      vim.keymap.set('n', '<C-j>', '<C-w>j')                     -- Move to window below
      vim.keymap.set('n', '<C-k>', '<C-w>k')                     -- Move to window above
      vim.keymap.set('n', '<C-l>', '<C-w>l')                     -- Move to right window
    '';
  }
