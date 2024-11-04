{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    # Essential plugins
    plenary-nvim
    telescope-nvim
    which-key-nvim
    comment-nvim
    vim-sleuth
    auto-session

    # File tree and icons
    nvim-tree-lua
    nvim-web-devicons

    # Git integration
    gitsigns-nvim

    # LSP and Completion
    nvim-lspconfig
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    luasnip
    cmp_luasnip

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
        toml
      ]
    ))

    tokyonight-nvim
    lualine-nvim
    indent-blankline-nvim

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
    set tabstop=2
    set hidden
    set termguicolors
    set scrolloff=8
    set sidescrolloff=8
    set cursorline
    set signcolumn=yes
    set updatetime=250
    set timeoutlen=300
    set completeopt=menuone,noselect
    set splitright
    set splitbelow
    set noswapfile
    set pumheight=10

    " Set colorscheme
    colorscheme tokyonight-night

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

    " Copy/Paste
    vnoremap <leader>c "+y
    nnoremap <leader>c "+y
    nnoremap <leader>v "+p

    " Better navigation
    nnoremap <leader>h :noh<CR>
    nnoremap k gk
    nnoremap j gj

    " Buffer navigation
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <leader>bd :bdelete<CR>
  '';

  extraLuaConfig = ''
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.which_key_ignore_overlapping = 1

    -- Theme Configuration
    require("tokyonight").setup({
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark"
      },
      on_colors = function(colors)
        colors.bg = "#1a1b26"
        colors.fg = "#c0caf5"
      end
    })

    -- Treesitter
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-backspace>",
        },
      },
    })
    
    -- Auto Session
    require("auto-session").setup({
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
      auto_session_use_git_branch = true,
    })

    -- Which Key
    require("which-key").setup({})

    -- Completion
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
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
      })
    })

    -- LSP Configuration
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require("lspconfig")

    local on_attach = function(client, bufnr)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "Show documentation" })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = "References" })
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, { buffer = bufnr, desc = "Format" })
    end

    -- LSP Servers
    local servers = {
      pyright = {},
      gopls = {},
      nixd = {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_dir = lspconfig.util.root_pattern(".git", "flake.nix", "default.nix"),
        settings = {
          nixd = {
            formatting = { command = "nixfmt" }
          }
        }
      }
    }

    for server, config in pairs(servers) do
      config.capabilities = capabilities
      config.on_attach = on_attach
      lspconfig[server].setup(config)
    end

    -- Status line
    require("lualine").setup({
      options = {
        theme = "tokyonight",
        component_separators = "|",
        section_separators = "",
        globalstatus = true,
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

    -- Indent Lines
    require("ibl").setup({
      indent = { char = "▏" },
      scope = { enabled = false },
    })

    -- File Explorer
    require("nvim-tree").setup({
      view = {
        width = 30,
        side = "right"
      },
      filters = {
        dotfiles = true,
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true
      },
    })

    -- Telescope
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "*.png",
          "*.jpg",
          "*.jpeg",
          "dist/",
          "build/"
        },
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.95,
          height = 0.85,
          preview_cutoff = 120,
        },
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end
        },
      },
    })

    -- Git signs
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" }
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})
      end
    })

    -- Other Plugin Configurations
    require("Comment").setup()
    require("nvim-autopairs").setup()

    -- Essential keymaps
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })
    vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = "Find recent files" })
    vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = "Git status" })
  '';
}
