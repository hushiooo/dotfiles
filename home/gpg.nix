{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      keyid-format = "0xlong";
      no-comments = true;
      no-emit-version = true;
      use-agent = true;
      with-fingerprint = true;
    };
  };

  # GPG signing only; SSH keys live in the macOS ssh-agent + Keychain (ssh.nix).
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
    pinentry.package = pkgs.pinentry_mac;
  };
}
