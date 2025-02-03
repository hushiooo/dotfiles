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
      "obsidian"
      "postico"
      "proton-pass"
      "protonvpn"
      "raycast"
    ];
    onActivation.cleanup = "zap";
  };
}
