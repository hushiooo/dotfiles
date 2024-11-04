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

    # Tree and icons
    nvim-tree-lua
    nvim-web-devicons

    # Git
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

    # Visual enhancements
    tokyonight-nvim
    lualine-nvim
    indent-blankline-nvim
    nvim-autopairs
    vim-surround

    # Additional visual plugins
    dressing-nvim
    noice-nvim
    nvim-notify
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
    set scrolloff=10
    set sidescrolloff=10
    set cursorline
    set signcolumn=yes
    set updatetime=200
    set timeoutlen=300
    set completeopt=menuone,noselect
    set splitright
    set splitbelow
    set noswapfile
    set pumheight=12
    set cmdheight=0
    set laststatus=3
    set winblend=10
    set pumblend=10

    " Set colorscheme with transparency
    colorscheme tokyonight-night
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NormalNC guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    highlight SignColumn guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE

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
      transparent = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { italic = true },
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "help", "terminal", "packer" },
      dim_inactive = false,
      lualine_bold = true,
      on_colors = function(colors)
        colors.fg = "#c8d3f5"
        colors.fg_dark = "#a9b1d6"
        colors.comment = "#737aa2"
        colors.bg_highlight = "#292e42"
        colors.dark5 = "#737aa2"
      end,
      on_highlights = function(highlights, colors)
        highlights.LineNr = { fg = "#737aa2" }
        highlights.CursorLineNr = { fg = "#7aa2f7", bold = true }
        highlights.Visual = { bg = "#2f3549" }
        highlights.Search = { bg = "#3d59a1", fg = "#c8d3f5" }
        highlights.IncSearch = { bg = "#ff9e64", fg = "#1a1b26" }

        -- Enhanced NvimTree transparency settings
        highlights.NvimTreeNormal = { bg = "NONE", fg = colors.fg_dark }
        highlights.NvimTreeNormalNC = { bg = "NONE", fg = colors.fg_dark }
        highlights.NvimTreeEndOfBuffer = { bg = "NONE", fg = colors.fg_dark }
        highlights.NvimTreeVertSplit = { bg = "NONE", fg = colors.border_highlight }
        highlights.NvimTreeWinSeparator = { bg = "NONE", fg = colors.border_highlight }
        highlights.NvimTreeCursorLine = { bg = colors.bg_highlight }
        highlights.NvimTreeStatusLine = { bg = "NONE" }
        highlights.NvimTreeStatusLineNC = { bg = "NONE" }

        -- Enhanced folder and file highlights
        highlights.NvimTreeFolderName = { fg = colors.blue, bold = true }
        highlights.NvimTreeOpenedFolderName = { fg = colors.blue, bold = true }
        highlights.NvimTreeEmptyFolderName = { fg = colors.blue }
        highlights.NvimTreeSymlink = { fg = colors.purple }
        highlights.NvimTreeSpecialFile = { fg = colors.yellow, bold = true }
        highlights.NvimTreeImageFile = { fg = colors.purple }
        highlights.NvimTreeIndentMarker = { fg = colors.fg_gutter }
      end,
    })

    -- Noice.nvim setup for enhanced UI
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { icon = ">" },
          search_down = { icon = "🔍⌄" },
          search_up = { icon = "🔍⌃" },
          filter = { icon = "$" },
          lua = { icon = "☾" },
          help = { icon = "?" },
        },
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      lsp = {
        progress = {
          enabled = true,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle = 1000 / 30,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    })

    -- Notify setup for beautiful notifications
    require("notify").setup({
      background_colour = "#000000",
      fps = 60,
      render = "minimal",
      stages = "fade_in_slide_out",
      timeout = 3000,
    })

    -- Treesitter with enhanced settings
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
      textobjects = {
        enable = true,
        lookahead = true,
      },
    })

    -- Auto Session with enhanced git integration
    local function ensure_session_dir()
      local path = vim.fn.stdpath('data').."/sessions/"
      if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
      end
      return path
    end

    require("auto-session").setup({
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
      auto_session_use_git_branch = true,
      auto_session_root_dir = ensure_session_dir(),
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_allowed_dirs = nil,
      bypass_session_save_file_types = { "alpha", "NvimTree", "neo-tree", "dashboard" },
    })

    -- Which key
    require("which-key").setup({
      win = {
        border = "single",
        padding = { 2, 2, 2, 2 },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "center",
      },
      disable_health_check = true,
    })

    -- Completion with enhanced UI
    local cmp = require('cmp')
    local luasnip = require('luasnip')

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
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        },
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
      }),
      formatting = {
        format = function(entry, vim_item)
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]
          return vim_item
        end
      },
    })

    -- LSP Configuration
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require("lspconfig")

    -- Format on save function
    local format_on_save = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              timeout_ms = 3000,
              buffer = bufnr,
            })
          end,
        })
      end
    end

    local on_attach = function(client, bufnr)
      -- Enable format on save
      format_on_save(client, bufnr)

      -- LSP keymaps
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "Show documentation" })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = "References" })
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, { buffer = bufnr, desc = "Format" })

      -- Additional LSP keymaps
      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Type definition" })
      vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr, desc = "Add workspace folder" })
      vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr, desc = "Remove workspace folder" })
      vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { buffer = bufnr, desc = "List workspace folders" })

      -- Show diagnostic on hover
      vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
          }
          vim.diagnostic.open_float(nil, opts)
        end
      })
    end

    -- LSP servers
    local servers = {
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace"
            }
          }
        }
      },
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true
            },
            staticcheck = true,
            gofumpt = true
          }
        }
      },
      nixd = {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_dir = lspconfig.util.root_pattern(".git", "flake.nix", "default.nix"),
        settings = {
          nixd = {
            formatting = { command = "nixfmt" }
          }
        }
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false
            },
            telemetry = {
              enable = false
            }
          }
        }
      }
    }

    -- Set up each LSP server
    for server_name, server_settings in pairs(servers) do
      server_settings.capabilities = capabilities
      server_settings.on_attach = on_attach
      lspconfig[server_name].setup(server_settings)
    end

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        prefix = '●',
        spacing = 4,
        format = function(diagnostic)
          return string.format("%s (%s)", diagnostic.message, diagnostic.source)
        end
      },
      float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local signs = { Error = " ", Warn = " ", Hint = "󰌵", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    -- Status line
    require("lualine").setup({
      options = {
        theme = "tokyonight",
        component_separators = { left = "", right = ""},
        section_separators = { left = "", right = ""},
        globalstatus = true,
      },
      sections = {
        lualine_a = {{"mode", separator = { left = "", right = ""}, right_padding = 2}},
        lualine_b = {{"filename", icon = ""}},
        lualine_c = {{"branch", icon = ""}},
        lualine_x = {{"filetype", icon_only = true}},
        lualine_y = {{"progress", separator = { left = "", right = ""}, left_padding = 2}},
        lualine_z = {{"location", separator = { left = "", right = ""}, left_padding = 2}}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {"filename"},
        lualine_x = {"location"},
        lualine_y = {},
        lualine_z = {}
      },
      extensions = {"nvim-tree"}
    })

    -- Enhanced indent lines
    require("ibl").setup({
      indent = {
        char = "│",
        highlight = "IblIndent",
      },
      scope = {
        enabled = true,
        char = "│",
        show_start = false,
        show_end = false,
        highlight = "IblScope",
      },
      exclude = {
        filetypes = {
          "help",
          "terminal",
          "dashboard",
          "packer",
          "lspinfo",
          "TelescopePrompt",
          "TelescopeResults",
        },
      },
    })

    -- File Explorer
    require("nvim-tree").setup({
      view = {
        width = 30,
        side = "right",
        signcolumn = "yes",
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "editor",
            border = "rounded",
            width = 30,
            height = 30,
            row = 1,
            col = 1,
          },
        },
      },
      renderer = {
        add_trailing = false,
        group_empty = false,
        highlight_git = true,
        full_name = false,
        highlight_opened_files = "none",
        highlight_modified = "none",
        root_folder_label = false,
        indent_width = 2,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            bottom = "─",
            none = " ",
          },
        },
      },
    })

    -- Enhanced Telescope configuration
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "%.png",
          "%.jpg",
          "%.jpeg",
          "dist/",
          "build/",
          "%.lock"
        },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        winblend = 0,
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" },
      },
      pickers = {
        find_files = {
          hidden = true,
          previewer = false,
          layout_config = {
            height = 0.4,
          },
        },
        buffers = {
          show_all_buffers = true,
          previewer = false,
          layout_config = {
            height = 0.4,
          },
        },
      },
    })

    -- Enhanced Git signs
    require("gitsigns").setup({
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signcolumn = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, {expr=true})

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, {expr=true})
      end
    })

    -- Additional plugins setup
    require("Comment").setup()
    require("nvim-autopairs").setup({
      check_ts = true,
      ts_config = {
        lua = {"string"},
        javascript = {"template_string"},
      },
    })

    -- Essential keymaps
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })
    vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "Find recent files" })
    vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
  '';
}
