{ pkgs, ... }:
{
  # CLI tools and language toolchains without a dedicated module in home/.
  home.packages = with pkgs; [
    # Core utilities
    cmake
    coreutils
    curl
    fd
    gnumake
    jq
    nerd-fonts._0xproto
    tflint
    tldr
    wget
    yq-go

    # Language toolchains
    cargo
    clippy
    go
    lua
    nodejs
    python314
    rustc
    rustfmt
    zig

    # Language tools
    pnpm
    prek
    ruff
    sqlc
    sqlfluff
    ty
    uv

    # Infra / Cloud
    awscli2
    crane
    dbmate
    terraform
    terragrunt
    trivy

    # Build / Task runners
    go-task
    just
    process-compose

    # General CLI
    duf
    gum
    hexyl
    lazydocker
    mergiraf
    postgresql_16
  ];
}
