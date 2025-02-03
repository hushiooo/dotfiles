{ ... }:
{
  system = {
    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        magnification = false;
        launchanim = false;
        minimize-to-application = true;
        orientation = "left";
        show-process-indicators = false;
        show-recents = false;
        tilesize = 32;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        persistent-apps = [ ];
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowShouldDragOnGesture = true;
        AppleICUForce24HourTime = true;
        AppleMeasurementUnits = "Centimeters";
        AppleTemperatureUnit = "Celsius";
        AppleMetricUnits = 1;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ApplePressAndHoldEnabled = false;
        "com.apple.mouse.tapBehavior" = null;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.forceClick" = false;
        AppleScrollerPagingBehavior = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSTableViewDefaultSizeMode = 2;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      finder = {
        FXPreferredViewStyle = "clmv";
        FXDefaultSearchScope = "This Mac";
        FXEnableExtensionChangeWarning = false;
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXSortFoldersFirst = true;
        CreateDesktop = false;
      };

      menuExtraClock = {
        ShowDate = 1;
        ShowAMPM = false;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
        ShowSeconds = true;
      };

      trackpad = {
        Clicking = false;
        Dragging = false;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      screensaver.askForPassword = true;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
