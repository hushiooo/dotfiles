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
      url = "github:herdrdev/herdr/v0.9.5";
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
          ruff
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
                "*.ts"
              ];
            };
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };
            ruff = {
              command = "ruff";
              options = [ "format" ];
              includes = [ "*.py" ];
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
                ruff
                shellcheck
                statix
              ];
            }
            ''
              cd ${self}
              statix check .
              deadnix --fail .
              shellcheck setup.sh
              ruff check --no-cache .
              touch $out
            '';
        pi-schedule =
          pkgs.runCommandLocal "pi-schedule-tests"
            {
              nativeBuildInputs = [ pkgs.python3 ];
              PYTHONDONTWRITEBYTECODE = 1;
            }
            ''
              cd ${self}/config/pi/schedule
              python3 -m unittest -q test_pi_schedule
              touch $out
            '';
        auto-router = pkgs.runCommandLocal "auto-router-tests" { nativeBuildInputs = [ pkgs.nodejs ]; } ''
          cd ${self}/config/pi/agent/extensions/auto-router
          node --test policy.test.ts
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
          typescript
        ];
      };
    };
}
