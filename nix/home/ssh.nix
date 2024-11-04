{ ... }:
{
  enable = true;

  # SSH Best Practices Configuration
  extraConfig = ''
    # Security
    Protocol 2
    HashKnownHosts yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    PubkeyAuthentication yes
    IdentitiesOnly yes

    # Performance and reliability
    Compression yes
    TCPKeepAlive yes
    ServerAliveInterval 60
    ServerAliveCountMax 2
    ConnectTimeout 30

    # macOS specific
    UseKeychain yes
    AddKeysToAgent yes

    # Control Master for connection reuse
    ControlMaster auto
    ControlPath ~/.ssh/control-%C
    ControlPersist 3600
  '';

  # Host-specific configurations
  matchBlocks = {
    "github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
      extraOptions = {
        PreferredAuthentications = "publickey";
      };
    };

    "*" = {
      # Default settings for all hosts
      extraOptions = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
        StrictHostKeyChecking = "ask";
        IdentitiesOnly = "yes";
      };
    };
  };
}
