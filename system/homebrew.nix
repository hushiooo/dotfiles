{ ... }:
{
  homebrew = {
    enable = true;
    global = {
      brewfile = true;
      autoUpdate = true;
    };
    taps = [
      "stoikio/tools"
    ];
    brews = [
      "aws-iam-authenticator"
      "awscli"
      "gh"
      "stoikio/tools/stoik-auth"
      "stoikio/tools/stoik-dlq-redrive"
      "stoikio/tools/stoik-external-scan"
    ];
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
      "zed"
      "iterm2"
    ];
    onActivation.cleanup = "zap";
  };
}
