{
  description = "My workstation nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # herdr ships releases well ahead of nixpkgs, so build the pinned tag from
    # its own flake. Bump the tag here, then `nix flake update herdr`.
    herdr = {
      url = "github:herdrdev/herdr/v0.9.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Prebuilt nix-index database, for comma and command-not-found.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      herdr,
      nix-index-database,
      sops-nix,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (_final: _prev: { herdr = herdr.packages.${system}.default; })
        ];
      };

      treefmt = pkgs.treefmt.withConfig {
        runtimeInputs = with pkgs; [
          biome
          nixfmt
          stylua
        ];
        settings = {
          tree-root-file = "flake.nix";
          on-unmatched = "debug";
          formatter = {
            biome = {
              command = "biome";
              options = [
                "format"
                "--write"
              ];
              includes = [
                "*.js"
                "*.json"
              ];
            };
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };
            stylua = {
              command = "stylua";
              includes = [ "*.lua" ];
            };
          };
        };
      };
    in
    {
      homeConfigurations."joad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Absolute path of this checkout, for live (out-of-store) symlinks and nh.
        extraSpecialArgs.dotfiles = "/Users/joad/dev/dotfiles";
        modules = [
          ./home.nix
          nix-index-database.homeModules.nix-index
          sops-nix.homeModules.sops
        ];
      };

      formatter.${system} = treefmt;

      checks.${system} = {
        home = self.homeConfigurations."joad".activationPackage;
        formatting = treefmt.check self;
        lint =
          pkgs.runCommandLocal "lint"
            {
              nativeBuildInputs = with pkgs; [
                deadnix
                shellcheck
                statix
              ];
            }
            ''
              cd ${self}
              statix check .
              deadnix --fail .
              shellcheck setup.sh
              touch $out
            '';
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          deadnix
          nixd
          shellcheck
          statix
          treefmt
        ];
      };
    };
}
