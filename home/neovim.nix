{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    # UI and theming
    tokyonight-nvim
    lualine-nvim
    nvim-web-devicons
    noice-nvim
    nvim-notify
    dressing-nvim

    # Navigation and file management
    nvim-tree-lua
    telescope-nvim
    telescope-fzf-native-nvim
    which-key-nvim
    plenary-nvim

    # Editor enhancements
    comment-nvim
    nvim-surround
    gitsigns-nvim

    # LSP and completion
    mason-nvim
    mason-lspconfig-nvim
    nvim-lspconfig
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    cmp_luasnip
    luasnip

    # Syntax highlighting and parsing
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        html
        typescript
        javascript
        css
        tsx
        python
        rust
        go
        c
        cpp
        lua
        json
        yaml
        toml
        nix
        bash
        dockerfile
        markdown
        markdown_inline
        git_rebase
        gitcommit
        gitignore
        regex
        vim
      ]
    ))
  ];

  # Base Vim settings in VimScript
  extraConfig = ''
    " General Settings
    set number          " Show line numbers
    set mouse=a         " Enable mouse support
    set hidden          " Allow hidden buffers

    " Search settings
    set ignorecase      " Case-insensitive search
    set smartcase       " Smart case sensitivity

    " Editor behavior
    set expandtab       " Use spaces instead of tabs
    set shiftwidth=4    " Indentation width
    set tabstop=4       " Tab width
    set scrolloff=10    " Keep cursor away from screen edges
    set sidescrolloff=10

    " UI settings
    set signcolumn=yes  " Always show sign column
    set cursorline      " Highlight current line
    set pumheight=12    " Maximum number of popup menu items
    set cmdheight=0     " Command line height
    set laststatus=3    " Global status line

    " Performance settings
    set updatetime=200  " Faster updates
    set timeoutlen=300  " Key sequence timeout

    " Completion settings
    set completeopt=menuone,noselect

    " File handling
    set noswapfile      " Disable swap files
    set undofile        " Persistent undo
    set undolevels=1000 " Raise max undo
    set clipboard=unnamedplus  " Use system clipboard

    " Split behavior
    set splitright      " Open vertical splits to the right
    set splitbelow      " Open horizontal splits below

    " UI customization
    set fillchars=eob:\  " Hide end of buffer marker

    " Leader key configuration
    let mapleader = " "

    " Window navigation
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    " File operations
    nnoremap <leader>w :w<CR>
    nnoremap <leader>q :q<CR>

    " Undo/Redo
    nnoremap U <C-r>
    nnoremap <leader>u u
    nnoremap <leader>U U

    " Clipboard operations
    vnoremap <leader>y "+y
    nnoremap <leader>y "+y
    nnoremap <leader>p "+p

    " Miscellaneous
    nnoremap <leader>h :noh<CR>
    nnoremap k gk
    nnoremap j gj
  '';

  # Lua configuration for plugins
  extraLuaConfig = ''
    -- Theme Configuration
    require("tokyonight").setup({
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false },
        variables = {},
        sidebars = "normal",
        floats = "normal",
      },
      sidebars = { "qf", "help", "terminal", "nvim-tree" },
      dim_inactive = false,
      lualine_bold = true,
    })

    vim.cmd([[colorscheme tokyonight]])

    -- UI Customization
    vim.opt.fillchars = {
      eob = " ",
      vert = "│",
      horiz = "─",
      horizup = "┴",
      horizdown = "┬",
      vertleft = "┤",
      vertright = "├",
      verthoriz = "┼",
    }

    vim.opt.termguicolors = true
    vim.opt.cursorline = true
    vim.opt.smoothscroll = true
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#292e42" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7aa2f7", bold = true })

    -- File Explorer
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

        -- File explorer keymaps
        vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "dd", api.fs.remove, opts("Delete"))
        vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
        vim.keymap.set("n", "yy", api.fs.copy.node, opts("Copy"))
        vim.keymap.set("n", "yn", api.fs.copy.filename, opts("Copy Name"))
        vim.keymap.set("n", "cc", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
        vim.keymap.set("n", "a", api.fs.create, opts("Create File/Folder"))
        vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
        vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
        vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
        vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
      end,
    })

    -- Tree-sitter Configuration
    require("nvim-treesitter.configs").setup({
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
      auto_install = false,
    })

    -- Telescope Configuration
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "   ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
            preview_height = 0.5,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        path_display = { "truncate" },
        winblend = 0,
        border = true,
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        color_devicons = true,
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "%.sqlite3",
          "%.ipynb",
          "vendor/*",
          "%.jpg",
          "%.jpeg",
          "%.png",
          "%.svg",
          "%.otf",
          "%.ttf",
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          previewer = false,
          hidden = true,
          fuzzy = true,
          prompt_title = "Find Files",
          results_title = "Files",
        },
        live_grep = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.95,
            height = 0.95,
            preview_width = 0.6,
            horizontal = {
              preview_width = 0.6,
              results_width = 0.4,
            },
          },
          prompt_title = "Live Grep",
          results_title = "Matches",
        },
        buffers = {
          theme = "dropdown",
          previewer = false,
          prompt_title = "Find Buffers",
          results_title = "Buffers",
        },
        help_tags = {
          theme = "dropdown",
          prompt_title = "Help Tags",
          results_title = "Results",
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    -- Load Telescope extensions
    telescope.load_extension("fzf")

    -- Status Line Configuration
    require('lualine').setup({
      options = {
        theme = 'tokyonight',
        globalstatus = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'dashboard' },
      },
      sections = {
        lualine_a = {
          { 'mode', icon = '' },
        },
        lualine_b = {
          { 'branch', icon = '' },
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
            colored = true,
          },
        },
        lualine_c = {
          { 'filename', path = 1, padding = { left = 1, right = 1 } },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = '󰌵 ',
            },
            colored = true,
          },
        },
        lualine_x = {
          {
            function()
              local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
              if #buf_clients == 0 then
                return "  No LSP"
              end
              local buf_client_names = {}
              for _, client in pairs(buf_clients) do
                table.insert(buf_client_names, client.name)
              end
              return "  " .. table.concat(buf_client_names, ", ")
            end,
            padding = { left = 1, right = 1 },
          },
          { 'filetype', icon_only = true, padding = { left = 1, right = 1 } },
        },
        lualine_y = {
          { 'progress', padding = { left = 1, right = 1 } },
        },
        lualine_z = {
          { 'location', padding = { left = 1, right = 1 } },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
    })

    -- UI Enhancement Plugins Configuration
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { icon = " " },
          search_down = { icon = " " },
          search_up = { icon = " " },
          filter = { icon = " " },
          lua = { icon = " " },
          help = { icon = " " },
        },
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        message = {
          enabled = true,
          view = "notify",
          opts = {},
        },
        progress = {
          enabled = true,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle = 1000 / 30,
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
      },
    })

    require("notify").setup({
        background_colour = "#24283b",
        fps = 30,
        icons = {
            DEBUG = " ",
            ERROR = " ",
            INFO = " ",
            TRACE = "✎ ",
            WARN = " ",
        },
        level = 2,
        minimum_width = 50,
        max_width = 80,
        timeout = 3000,
        render = "default",
        stages = "fade",
        top_down = true
    })

    vim.notify = require("notify")
    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#24283b" })

    require("dressing").setup({
      input = {
        enabled = true,
        default_prompt = "➤ ",
        win_options = {
          winblend = 0,
          wrap = true,
        },
        override = function(conf)
          conf.border = "rounded"
          conf.col = 1
          conf.row = 1
          return conf
        end,
      },
      select = {
        enabled = true,
        backend = { "telescope", "builtin" },
        trim_prompt = true,
        win_options = {
          winblend = 0,
          wrap = true,
        },
        override = function(conf)
          conf.border = "rounded"
          conf.col = 1
          conf.row = 1
          return conf
        end,
      },
    })

    -- Git Integration Configuration
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

    -- LSP Configuration
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "ruff",
        "pyright",
        "ts_ls",
        "lua_ls",
        "html",
        "cssls",
        "jsonls",
        "gopls",
        "clangd",
        "bashls",
        "marksman",
        "dockerls",
        "yamlls",
        "rust_analyzer",
      },
      automatic_installation = true,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    local servers = {
      ruff = {
        settings = {
          args = { "--ignore=E501" },
          organizeImports = true,
          fixAll = true,
          lint = {
            args = { "--select=E,F,W,I" },
          },
        },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentRangeFormattingProvider = true
        end,
      },
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      },
      ts_ls = {
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      },
      gopls = {
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      },
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
      },
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      },
      nixd = {}
    }

    -- Set up LSP servers
    for server, config in pairs(servers) do
      config.capabilities = capabilities
      lspconfig[server].setup(config)
    end

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        spacing = 2,
        severity = { min = vim.diagnostic.severity.WARN },
      },
      float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
        style = "minimal",
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local signs = {
      Error = " ",
      Warn = " ",
      Hint = "󰌵 ",
      Info = " ",
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
    vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Set diagnostic list" })
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbol" })
        vim.keymap.set("n", "<leader>ct", vim.lsp.buf.type_definition, { desc = "Type definition" })
      end,
    })

    -- Completion setup
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          scrollbar = true,
          side_padding = 1,
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,Search:None",
          max_height = math.floor(vim.o.lines * 0.5),
          max_width = math.floor(vim.o.columns * 0.4),
        },
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local icons = {
            Text = "",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰜢",
            Variable = "󰀫",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "󰑭",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "󰈇",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "󰙅",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "󰅲",
          }
          vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snip]",
            buffer = "[Buf]",
            path = "[Path]",
            nvim_lua = "[Lua]",
          })[entry.source.name]
          return vim_item
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-l>"] = cmp.mapping(function()
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function()
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "nvim_lua" },
      }),
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
        { name = "cmdline" },
      }),
    })

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- Additional plugin keymaps

    -- Telescope
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })

    -- NvimTree
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle nvim-tree", silent = true })
    vim.keymap.set('n', '<leader>o', ':NvimTreeFocus<CR>', { desc = "Focus nvim-tree", silent = true })

    -- Noice
    vim.keymap.set("n", "<leader>mn", ":Noice<CR>", { desc = "Show notification history" })
    vim.keymap.set("n", "<leader>ml", ":Noice last<CR>", { desc = "Show last notification" })
    vim.keymap.set("n", "<leader>md", ":Noice dismiss<CR>", { desc = "Dismiss notifications" })

    -- Initialize basic editing plugins
    require('Comment').setup()
    require("nvim-surround").setup()
  '';
}
