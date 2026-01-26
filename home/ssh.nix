{ ... }:
{
  enable = true;
  enableDefaultConfig = false;

  matchBlocks = {
    "*" = {
      extraOptions = {
        ChallengeResponseAuthentication = "no";
        Compression = "yes";
        ConnectTimeout = "30";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control/%C";
        ControlPersist = "10m";
        HashKnownHosts = "yes";
        PasswordAuthentication = "no";
        PubkeyAuthentication = "yes";
        ServerAliveCountMax = "3";
        ServerAliveInterval = "60";
        TCPKeepAlive = "yes";
        UpdateHostKeys = "yes";
        VisualHostKey = "no";
        AddKeysToAgent = "yes";
        IdentitiesOnly = "yes";
        StrictHostKeyChecking = "ask";
        UseKeychain = "yes";
      };
    };
    "github.com" = {
      hostname = "github.com";
      identityFile = [ "~/.ssh/id_ed25519" ];
      user = "git";
      extraOptions = {
        PreferredAuthentications = "publickey";
      };
    };
    "gitlab.com" = {
      hostname = "gitlab.com";
      identityFile = [ "~/.ssh/id_ed25519" ];
      user = "git";
      extraOptions = {
        PreferredAuthentications = "publickey";
      };
    };
  };
}
