{
  description = "Nix-darwin system flake";

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
  } @ inputs: let
    username = "hushio";
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
      assertions = [
        {
          assertion = pkgs.stdenv.isDarwin;
          message = "This configuration only works on macOS";
        }
        {
          assertion = pkgs.stdenv.isAarch64;
          message = "This configuration is for Apple Silicon Macs";
        }
      ];

      system = {
        configurationRevision = let
          hasRev = self ? rev;
          revision = if hasRev then self.rev else self.dirtyRev;
        in lib.mkIf hasRev (revision or null);

        stateVersion = 4;
      };

      nix.settings = {
        experimental-features = "nix-command flakes";
        trusted-users = [ username ];
        auto-optimise-store = true;
        sandbox = true;
        max-jobs = "auto";
        cores = 0;
      };

      nix.gc = {
        automatic = true;
        interval = { Hour = 24; };
        options = "--delete-older-than 30d";
      };

      networking = {
        hostName = "prime";
        computerName = "hushio's MacBook";
        localHostName = "prime";
      };

      services.nix-daemon.enable = true;

      nixpkgs.hostPlatform = "aarch64-darwin";

      environment.systemPackages = with pkgs; [
        _0xproto
        alacritty
        cmake
        coreutils
        curl
        gcc
        git
        gnumake
        gnupg
        mkalias
        neovim
        tmux
        wget
      ];

      homebrew = {
        enable = true;
        global = {
          brewfile = true;
          autoUpdate = true;
          brewfileCommand = "bundle dump";
          interval = { hours = 24; };
        };
        brews = [
        ];
        casks = [
          "docker"
          "hiddenbar"
          "postico"
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

      system.defaults = {
        # Dock Settings
        dock = {
          autohide = true;
          expose-animation-duration = 0.1;
          mru-spaces = false;
          magnification = false;
          largesize = null;
          launchanim = false;
          minimize-to-application = false;
          orientation = "left";
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
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSDisableAutomaticTermination = true;
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
    };
  in {
    darwinConfigurations."prime" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
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
  };
}
