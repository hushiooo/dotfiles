{ ... }:
{
  homebrew = {
    enable = true;
    global = {
      brewfile = true;
      autoUpdate = true;
    };
    brews = [ ];
    casks = [
      "docker"
      "ghostty"
      "google-chrome"
      "hiddenbar"
      "postico"
      "proton-pass"
      "protonvpn"
      "raycast"
      # "zed"
    ];
    onActivation.cleanup = "zap";
  };
}
