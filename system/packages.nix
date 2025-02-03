{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bun
    dbmate
    cmake
    coreutils
    curl
    delta
    fd
    gcc
    gh
    go
    hexyl
    jq
    lua
    lazydocker
    mactop
    nixd
    nodejs_22
    postgresql_16
    pre-commit
    python313
    python313Packages.debugpy
    python313Packages.pytest
    ruff
    rustup
    sqlc
    tldr
    tree
    tree-sitter
    uv
    wget
  ];

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
  ];
}
