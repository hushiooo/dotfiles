{ config, pkgs, ... }:
{
  # Secrets are decrypted at activation into a per-user tmpfs. The module stays
  # inert until `sops.secrets` is non-empty; see README "Secrets" to add one.
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

  home.packages = with pkgs; [
    age
    sops
  ];
}
