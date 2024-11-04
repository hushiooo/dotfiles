{
  description = "hushio's prime nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    username = "hushio";
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = [
        # Terminal Essentials
        pkgs.alacritty
        pkgs.bat
        pkgs.coreutils
        pkgs.eza
        pkgs.fd
        pkgs.fzf
        pkgs.ripgrep
        pkgs.tmux
        pkgs.tree
        pkgs.wget
        pkgs.xz
        pkgs.yazi
        pkgs.zoxide

        # Development Tools - General
        pkgs._0xproto
        pkgs.cmake
        pkgs.delta
        pkgs.direnv
        pkgs.gcc
        pkgs.gh
        pkgs.git
        pkgs.git-lfs
        pkgs.gnumake
        pkgs.jq
        pkgs.lazygit
        pkgs.neovim
        pkgs.nil
        pkgs.nixd
        pkgs.nixfmt
        pkgs.sqlc
        pkgs.tree-sitter

        # Python Development
        pkgs.python311
        pkgs.poetry
        pkgs.ruff
        pkgs.black
        pkgs.isort
        pkgs.mypy
        pkgs.uv
        pkgs.python311Packages.pip
        pkgs.python311Packages.python-lsp-server
        pkgs.python311Packages.pylsp-mypy
        pkgs.python311Packages.python-lsp-black
        pkgs.python311Packages.python-lsp-ruff

        # Go Development
        pkgs.go
        pkgs.gopls
        pkgs.golangci-lint
        pkgs.go-tools

        # JavaScript/TypeScript Development
        pkgs.bun
        pkgs.nodejs_20
        pkgs.nodePackages.typescript
        pkgs.nodePackages.typescript-language-server
        pkgs.nodePackages.eslint
        pkgs.nodePackages.prettier

        # Rust Development
        pkgs.rustup
        pkgs.rust-analyzer

        # Language Servers & Formatters
        pkgs.yaml-language-server
        pkgs.nodePackages.jsonlint
        pkgs.shellcheck
        pkgs.shfmt

        # Cloud & Database Tools
        pkgs.awscli
        pkgs.pgadmin4
        pkgs.postgresql_16
        pkgs.docker
        pkgs.docker-compose
        pkgs.docker-credential-helpers

        # Utilities
        pkgs.ffmpeg
        pkgs.imagemagick
        pkgs.mactop
        pkgs.mkalias
        pkgs.neofetch
        pkgs.oh-my-posh
        pkgs.tldr

        # GUI Applications
        pkgs.google-chrome
        pkgs.obsidian
        pkgs.raycast
        pkgs.spotify
        pkgs.zed-editor
      ];

      assertions = [
        {
          assertion = pkgs.stdenv.isDarwin;
          message = "This configuration only works on Darwin (macOS) systems";
        }
      ];

      # Environment Variables
      environment.variables = {
        # Path
        PATH = lib.concatStringsSep ":" [
            "$HOME/go/bin"
            "$HOME/.cargo/bin"
            "$HOME/.local/bin"
            "/opt/homebrew/bin"
            "/opt/homebrew/sbin"
            "$PATH"
          ];

        # Python
        PYTHONPATH = "${pkgs.python311Packages.python-lsp-server}/lib/python3.11/site-packages";
        PYTHONUNBUFFERED = "1";

        # Go
        GOPATH = "$HOME/go";
        GOBIN = "$HOME/go/bin";

        # Node.js
        NODE_PATH = "${pkgs.nodePackages.typescript}/lib/node_modules";

        # Pour Docker
        DOCKER_CONFIG = "$HOME/.docker";

        # Pour Rust
        RUSTUP_HOME = "$HOME/.rustup";
        CARGO_HOME = "$HOME/.cargo";

        # General
        EDITOR = "nvim";
        VISUAL = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };

      users.users.hushio = {
        name = username;
        home = "/Users/hushio";
      };

      nix.settings = {
        experimental-features = "nix-command flakes";
        trusted-users = [ username ];
        auto-optimise-store = true;
        sandbox = true;
        max-jobs = "auto";
        cores = 0;  # Use all available cores
      };

      homebrew = {
        enable = true;
        global = {
          brewfile = true;
          autoUpdate = false;
        };
        brews = [
        ];
        casks = [
          "devtoys"
          "docker"
          "hiddenbar"
          "linear-linear"
          "proton-pass"
          "protonvpn"
        ];
        onActivation.cleanup = "zap";
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      services.nix-daemon.enable = true;

      networking = {
        dns = ["1.1.1.1" "8.8.8.8"];
        knownNetworkServices = ["Wi-Fi" "Ethernet"];
      };

      virtualisation = {
        docker = {
          enable = true;
          enableOnBoot = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_16;
      };

      programs.zsh.enable = true;

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 4;

      system.defaults = {
        # Dock Settings
        dock = {
          autohide = true;
          mru-spaces = false;
          magnification = false;
          largesize = null;
          launchanim = false;
          minimize-to-application = false;
          orientation = "bottom";
          show-process-indicators = false;
          show-recents = false;
          tilesize = 32;
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
          # Persistent apps
          persistent-apps = [
            {
              "tile-data" = {
                "file-data" = {
                  "_CFURLString" = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Finder.app";
                  "_CFURLStringType" = 0;
                };
              };
            }
            {
              "tile-data" = {
                "file-data" = {
                  "_CFURLString" = "/Applications/Nix Apps/Google Chrome.app";
                  "_CFURLStringType" = 0;
                };
              };
            }
            {
              "tile-data" = {
                "file-data" = {
                  "_CFURLString" = "/Applications/Nix Apps/Zed.app";
                  "_CFURLStringType" = 0;
                };
              };
            }
            {
              "tile-data" = {
                "file-data" = {
                  "_CFURLString" = "/Applications/Nix Apps/Alacritty.app";
                  "_CFURLStringType" = 0;
                };
              };
            }
            {
              "tile-data" = {
                "file-data" = {
                  "_CFURLString" = "/Applications/Nix Apps/Spotify.app";
                  "_CFURLStringType" = 0;
                };
              };
            }
            {
              "tile-data" = {
                "file-data" = {
                  "_CFURLString" = "/Applications/Nix Apps/Obsidian.app";
                  "_CFURLStringType" = 0;
                };
              };
            }
          ];
        };

        # Global System Settings
        NSGlobalDomain = {
          # Appearance
          AppleInterfaceStyle = "Dark";
          _HIHideMenuBar = true;
          NSAutomaticWindowAnimationsEnabled = false;
          NSWindowResizeTime = 0.001;
          NSWindowShouldDragOnGesture = true;

          # Regional Settings
          AppleICUForce24HourTime = true;
          AppleMeasurementUnits = "Centimeters";
          AppleTemperatureUnit = "Celsius";
          AppleMetricUnits = 1;

          # File System
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;

          # Keyboard & Input
          ApplePressAndHoldEnabled = false;
          InitialKeyRepeat = 15;
          KeyRepeat = 2;

          # Mouse & Trackpad
          "com.apple.mouse.tapBehavior" = null;
          "com.apple.swipescrolldirection" = true;
          "com.apple.trackpad.forceClick" = false;
          AppleScrollerPagingBehavior = true;

          # Misc
          NSDocumentSaveNewDocumentsToCloud = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          NSTableViewDefaultSizeMode = 2;
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;
        };

        # Finder Settings
        finder = {
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "clmv";
          FXDefaultSearchScope = "This Mac";
          FXEnableExtensionChangeWarning = false;
          NewWindowTarget = "Home";
          QuitMenuItem = true;
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXSortFoldersFirst = true;
          CreateDesktop = false;
          FXEnableRemoveFromICloudDriveWarning = false;
          ShowRecentTags = false;
        };

        # Security & Privacy
        alf = {
          allowdownloadsignedenabled = 1;
          allowsignedenabled = 1;
          globalstate = 0;
        };

        # Login & Security
        loginwindow = {
          GuestEnabled = false;
          DisableConsoleAccess = true;
          SHOWFULLNAME = false;
        };

        # Window Management
        WindowManager = {
          EnableStandardClickToShowDesktop = false;
          GloballyEnabled = false;
        };

        # Menu Bar & Clock
        menuExtraClock = {
          Show24Hour = true;
          ShowDate = 1;
          ShowSeconds = true;
          ShowAMPM = false;
          ShowDayOfWeek = true;
        };

        # Trackpad & Mouse
        trackpad = {
          Clicking = false;
          Dragging = false;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = false;
        };

        # Other Settings
        ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;
        screensaver.askForPassword = true;
        hitoolbox.AppleFnUsageType = "Do Nothing";
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      };

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    darwinConfigurations."prime" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hushio = import ./home.nix;
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."prime".pkgs;
  };
}
