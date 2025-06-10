{
  description = "My personal nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      username = "hushio";
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.hushio = nix-darwin.lib.darwinSystem {
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
              primaryUser = username;
            };

            nix = {
              settings = {
                experimental-features = "nix-command flakes";
                trusted-users = [ username ];
                sandbox = false;
                max-jobs = "auto";
                cores = 0;
              };

              gc = {
                automatic = true;
                options = "--delete-older-than 30d";
              };
            };

            nixpkgs.config.allowUnfree = true;
          }
          {
            networking = {
              hostName = "hushio";
              localHostName = "hushio";
              computerName = "huhshio";
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
