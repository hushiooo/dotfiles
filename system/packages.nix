{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bun
    cmake
    coreutils
    curl
    delta
    fd
    gcc
    go
    hexyl
    jq
    lazydocker
    lua
    mactop
    nixd
    nixfmt-rfc-style
    nodejs_22
    postgresql_16
    python313
    python313Packages.debugpy
    rustup
    sqlc
    tldr
    tree
    tree-sitter
    wget
    poetry
    uv
    ruff
    earthly
    pre-commit
    dbmate
    terraform
    terragrunt
    tflint
    sops
    go-task
    tailscale
    gum
  ];

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
  ];
}
