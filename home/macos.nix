{
  config,
  lib,
  pkgs,
  ...
}:
let
  defaults = config.targets.darwin.defaults;
  stamp = pkgs.writeText "darwin-defaults.json" (builtins.toJSON defaults);
in
{
  # Merged into each domain on every switch (keys not listed here are kept).
  targets.darwin.defaults = {
    "com.apple.dock" = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.3;
      launchanim = false;
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "left";
      persistent-apps = [ ];
      show-process-indicators = false;
      show-recents = false;
      tilesize = 32;
      wvous-bl-corner = 0;
      wvous-br-corner = 0;
      wvous-tl-corner = 0;
      wvous-tr-corner = 0;
    };

    "com.apple.finder" = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv";
      NewWindowTarget = "PfHm";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowRecentTags = false;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };

    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = true;
      ApplePressAndHoldEnabled = false;
      AppleReduceDesktopTinting = true;
      AppleTemperatureUnit = "Celsius";
      InitialKeyRepeat = 12;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSWindowResizeTime = 0.001;
    };

    "com.apple.AppleMultitouchTrackpad".TrackpadThreeFingerDrag = true;
    "com.apple.driver.AppleBluetoothMultitouch.trackpad".TrackpadThreeFingerDrag = true;

    "com.apple.screencapture" = {
      disable-shadow = true;
      location = "${config.home.homeDirectory}/Desktop";
      show-thumbnail = false;
      type = "png";
    };

    "com.apple.ActivityMonitor" = {
      ShowCategory = 0;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    "com.apple.TextEdit" = {
      PlainTextEncoding = 4;
      PlainTextEncodingForWrite = 4;
      RichText = false;
    };

    "com.apple.LaunchServices".LSQuarantine = false;
    "com.apple.CrashReporter".DialogType = "none";
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
  };

  # Dock, Finder and SystemUIServer only re-read their plists on restart.
  # Restart them when the declared defaults change, not on every switch.
  home.activation.restartDarwinUI = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
    state="${config.xdg.stateHome}/home-manager/darwin-defaults.json"
    if ! cmp -s ${stamp} "$state"; then
      run /usr/bin/killall Dock Finder SystemUIServer || true
      run install -D -m 644 ${stamp} "$state"
    fi
  '';
}
