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
      "stoikio/tools/stoik-auth"
      "stoikio/tools/stoik-dlq-redrive"
      "stoikio/tools/stoik-external-scan"
      "awscli"
      "aws-iam-authenticator"
      "poppler"
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
    ];
    onActivation.cleanup = "zap";
  };
}
