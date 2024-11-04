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
    gh
    go
    hexyl
    jq
    lua
    mactop
    nixd
    nodejs_22
    postgresql_16
    python313
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
