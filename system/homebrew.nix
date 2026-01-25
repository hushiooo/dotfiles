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
      "docker-desktop"
      "ghostty"
      "google-chrome"
      "hiddenbar"
      "linear-linear"
      "postico"
      "proton-pass"
      "protonvpn"
      "raycast"
    ];
    onActivation.cleanup = "zap";
  };
}
