{
  description = "My work laptop nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      username = "joad.goutal";
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.mbp-joad = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./system/packages.nix
          ./system/homebrew.nix
          ./system/defaults.nix
          home-manager.darwinModules.home-manager
          {
            system = {
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 5;
            };

            nix = {
              settings = {
                experimental-features = "nix-command flakes";
                trusted-users = [ "joad.goutal" ];
                sandbox = false;
                max-jobs = "auto";
                cores = 0;
              };

              gc = {
                automatic = true;
                options = "--delete-older-than 30d";
              };

              useDaemon = true;
            };

            services.nix-daemon.enable = true;

            nixpkgs.config.allowUnfree = true;
          }
          {
            networking = {
              hostName = "mbp-joad";
              localHostName = "mbp-joad";
              computerName = "mbp-joad";
            };

            users.users.${username}.home = "/Users/${username}";

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
