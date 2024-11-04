{ ... }:
{
  enable = true;
  userSettings = {
    # Core Editor Settings
    vim_mode = true;
    base_keymap = "VSCode";
    preferred_line_length = 120;
    tab_size = 2;
    soft_wrap = "preferred_line_length";
    relative_line_numbers = false;
    bracket_pairing = "always";
    show_whitespaces = "selection";
    scroll_beyond_last_line = "one_page";
    hover_popover_enabled = true;
    show_inline_completions = false;
    use_autoclose = true;
    cursor_blink = false;

    # Font and UI Settings
    ui_font_family = "0xProto Nerd Font";
    buffer_font_family = "0xProto Nerd Font";
    ui_font_size = 14;
    buffer_font_size = 14;

    # Theme Settings
    theme = {
      mode = "dark";
      dark = "Tokyo Night Storm";
      light = "Tokyo Night Day";
    };

    # Auto-install extensions
    auto_install_extensions = {
      "Tokyo Night Themes" = true;
    };

    # Autosave Configuration
    autosave = {
      after_delay = {
        milliseconds = 1000;
      };
    };

    # Terminal Configuration
    terminal = {
      dock = "bottom";
      font_family = "0xProto Nerd Font";
      working_directory = "current_project_directory";
      copy_on_select = true;
      shell = {
        program = "zsh";
      };
      env = {
        TERM = "xterm-256color";
      };
      font_size = 14;
      scrollback_lines = 10000;
      background_color = "#1a1b26";
      foreground_color = "#c0caf5";
    };

    # Project Panel Settings
    project_panel = {
      button = true;
      dock = "right";
      git_status = true;
      default_width = 280;
    };

    # Minimap Settings
    minimap = {
      enabled = true;
      size = 100;
      show_git_diff = true;
    };

    # Tab Settings
    tabs = {
      file_icons = true;
      show_close_button = "hover";
    };

    # Quick Open Settings
    quick_open = {
      filter_ignore = [
        ".git"
        "node_modules"
        "venv"
        "__pycache__"
        "*.pyc"
        "dist"
        "build"
        "target"
      ];
      workspace_history_size = 50;
    };

    # Git Configuration
    git = {
      enabled = true;
      autoFetch = true;
      autoFetchInterval = 300;
      autoFetchOnFocus = true;
      autoFetchOnWindowChange = true;
      autoFetchOnBuild = true;
      git_status = true;
      autoFetchOnBuildEvents = [
        "build"
        "run"
        "debug"
      ];
      autoFetchOnBuildEventsDelay = 1000;
      autoFetchOnBuildDelay = 1000;
      git_gutter = "tracked_files";
    };

    # AI Assistant Settings
    assistant = {
      default_model = {
        provider = "zed.dev";
        model = "claude-3-5-sonnet-latest";
      };
      version = "2";
    };

    # Feature Toggles
    features = {
      copilot = false;
    };
    show_copilot_suggestions = false;

    # Telemetry Settings
    telemetry = {
      diagnostics = false;
      metrics = false;
    };

    # Formatting Settings
    format_on_save = "on";
    formatter = {
      code_actions = {
        "source.fixAll.eslint" = true;
        "source.organizeImports" = true;
        "source.removeUnusedImports" = true;
        "source.fixAll.prettier" = true;
      };
    };

    # Prettier Configuration
    prettier = {
      printWidth = 100;
      tabWidth = 2;
      useTabs = false;
      semi = true;
      singleQuote = true;
      trailingComma = "all";
      bracketSpacing = true;
      arrowParens = "avoid";
      proseWrap = "preserve";
      endOfLine = "lf";
    };

    # ESLint Configuration
    eslint = {
      enabled = true;
      autoFixOnSave = true;
      autoFixOnFormat = true;
      autoFixOnFormatDelay = 1000;
    };

    # Language-specific Settings
    languages = {
      JavaScript = {
        code_actions_on_format = {
          "source.fixAll.eslint" = true;
        };
        format_on_save = "on";
      };
      TypeScript = {
        code_actions_on_format = {
          "source.organizeImports" = true;
          "source.removeUnusedImports" = true;
          "source.fixAll.eslint" = true;
        };
        format_on_save = "on";
        language_server = {
          initialization_options = {
            preferences = {
              importModuleSpecifierPreference = "relative";
              quotePreference = "single";
            };
          };
        };
      };
      TSX = {
        code_actions_on_format = {
          "source.organizeImports" = true;
          "source.removeUnusedImports" = true;
          "source.fixAll.eslint" = true;
        };
      };
      HTML = {
        code_actions_on_format = {
          "source.fixAll.eslint" = true;
        };
        linked_edits = false;
        format_on_save = "on";
      };
      CSS = {
        code_actions_on_format = {
          "source.fixAll.eslint" = true;
        };
        format_on_save = "on";
      };
      SCSS = {
        code_actions_on_format = {
          "source.fixAll.eslint" = true;
        };
        format_on_save = "on";
      };
      Python = {
        code_actions_on_format = {
          "source.organizeImports" = true;
          "source.removeUnusedImports" = true;
          "source.fixAll.ruff" = true;
        };
        format_on_save = {
          external = {
            command = "ruff";
            arguments = [
              "format"
              "--stdin-filename"
              "{buffer_path}"
              "-"
            ];
          };
        };
        language_server = {
          command = "pylsp";
          initialization_options = {
            plugins = {
              pylsp_mypy = {
                enabled = true;
                live_mode = true;
              };
              pylsp_black = {
                enabled = true;
              };
              pyls_isort = {
                enabled = true;
              };
            };
          };
        };
      };
      Go = {
        format_on_save = "on";
        code_actions_on_format = {
          "source.organizeImports" = true;
        };
        language_server = {
          command = "gopls";
          initialization_options = {
            usePlaceholders = true;
            completionDocumentation = true;
            completeUnimported = true;
            deepCompletion = true;
            matcher = "fuzzy";
          };
        };
      };
    };

    # Nightly Settings
    nightly = {
      enabled = true;
      channel = "stable";
    };
  };
}
