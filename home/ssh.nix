{ ... }:
{
  enable = true;

  enableDefaultConfig = false;

  extraConfig = ''
    HashKnownHosts yes
    PubkeyAuthentication yes
    KbdInteractiveAuthentication no
    PasswordAuthentication no
    Compression yes
    TCPKeepAlive yes
    ServerAliveInterval 60
    ServerAliveCountMax 2
    ConnectTimeout 30
    ControlMaster auto
    ControlPath ~/.ssh/control-%C
    ControlPersist 3600
  '';

  matchBlocks = {
    "github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = [ "~/.ssh/id_ed25519" ];
      extraOptions = {
        PreferredAuthentications = "publickey";
      };
    };

    "*" = {
      extraOptions = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
        StrictHostKeyChecking = "ask";
        IdentitiesOnly = "yes";
      };
    };
  };
}
