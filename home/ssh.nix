{ ... }:
{
  enable = true;
  enableDefaultConfig = false;
  settings = {
    "*" = {
      KbdInteractiveAuthentication = false;
      Compression = true;
      ConnectTimeout = 30;
      ControlMaster = "auto";
      ControlPath = "~/.ssh/control/%C";
      ControlPersist = "10m";
      HashKnownHosts = true;
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      ServerAliveCountMax = 3;
      ServerAliveInterval = 60;
      TCPKeepAlive = true;
      UpdateHostKeys = true;
      VisualHostKey = false;
      AddKeysToAgent = "yes";
      IdentitiesOnly = true;
      StrictHostKeyChecking = "ask";
      UseKeychain = "yes";
    };
    "github.com" = {
      HostName = "github.com";
      IdentityFile = [ "~/.ssh/id_ed25519" ];
      User = "git";
      PreferredAuthentications = "publickey";
    };
    "gitlab.com" = {
      HostName = "gitlab.com";
      IdentityFile = [ "~/.ssh/id_ed25519" ];
      User = "git";
      PreferredAuthentications = "publickey";
    };
    "chipwise" = {
      HostName = "i-008a178ab4fcdb62b";
      User = "ubuntu";
      IdentityFile = [ "~/.ssh/chipwise-backend-key-pair.pem" ];
      ProxyCommand = "sh -c 'aws --profile chipwise ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p --region eu-west-3'";
    };
  };
}
