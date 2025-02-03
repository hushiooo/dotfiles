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
    lua
    mactop
    nixd
    nixfmt-rfc-style
    nodejs_22
    postgresql_16
    python313
    rustup
    sqlc
    tldr
    tree
    tree-sitter
    wget
    poetry
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
    awscli2
    aws-iam-authenticator
  ];

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
  ];
}
