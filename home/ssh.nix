{
  enable = true;

  extraConfig = ''
    HashKnownHosts yes
    PubkeyAuthentication yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    Compression yes
    TCPKeepAlive yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ConnectTimeout 30
    ControlMaster auto
    ControlPath ~/.ssh/control/%C
    ControlPersist 10m
    UpdateHostKeys yes
    VisualHostKey no
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

    "gitlab.com" = {
      hostname = "gitlab.com";
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
        IdentitiesOnly = "yes";
        StrictHostKeyChecking = "ask";
      };
    };
  };
}
