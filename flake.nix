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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      herdr,
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
    in
    {
      homeConfigurations."joad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };

      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixd
          nixfmt
        ];
      };
    };
}
