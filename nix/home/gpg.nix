{ config, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    settings = {
      # Best practices for GPG configuration
      no-emit-version = true;
      no-comments = true;
      keyid-format = "0xlong";
      with-fingerprint = true;
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      use-agent = true;
      display-charset = "utf-8";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    };
  };

  # GPG agent configuration
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
  };

  # GPG initialization script
  home.file.".local/bin/gpg-init" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Colors for messages
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      YELLOW='\033[1;33m'
      NC='\033[0m'

      # Logging function
      log() {
        local level=$1
        local message=$2
        local color=""
        case $level in
          "INFO") color=$BLUE ;;
          "SUCCESS") color=$GREEN ;;
          "WARNING") color=$YELLOW ;;
          "ERROR") color=$RED ;;
        esac
        echo -e "''${color}[$level] $message''${NC}"
      }

      # GPG keys configuration
      declare -A GPG_KEYS=(
        ["personal"]="hushio@proton.me"
        ["github"]="hushio@proton.me"
      )

      log "INFO" "🔐 Initializing GPG configuration..."

      # Create GPG directory with correct permissions
      mkdir -p ~/.gnupg
      chmod 700 ~/.gnupg

      # Function to generate a GPG key
      generate_key() {
        local name=$1
        local email=$2

        if gpg --list-secret-keys "$email" >/dev/null 2>&1; then
          log "INFO" "ℹ️  Key for $email already exists"
          return 0
        fi

        log "SUCCESS" "🔑 Generating GPG key for $email..."

        # Generate key configuration
        cat > /tmp/gpg-gen-key << EOF
        Key-Type: RSA
        Key-Length: 4096
        Key-Usage: sign
        Subkey-Type: RSA
        Subkey-Length: 4096
        Subkey-Usage: encrypt
        Name-Real: $name
        Name-Email: $email
        Expire-Date: 0
        %no-protection
        %commit
EOF

        if ! gpg --batch --generate-key /tmp/gpg-gen-key; then
          log "ERROR" "Failed to generate key for $email"
          rm -f /tmp/gpg-gen-key
          return 1
        fi

        rm -f /tmp/gpg-gen-key
      }

      # Function to backup existing keys
      backup_existing_keys() {
        local backup_dir=~/gpg_backup_$(date +%Y%m%d_%H%M%S)
        if [[ -d ~/.gnupg && "$(ls -A ~/.gnupg)" ]]; then
          log "INFO" "📦 Backing up existing GPG configuration to $backup_dir..."
          mkdir -p "$backup_dir"
          if ! cp -r ~/.gnupg/* "$backup_dir/"; then
            log "ERROR" "Failed to create backup"
            return 1
          fi
          chmod -R 600 "$backup_dir"
          chmod 700 "$backup_dir"
        fi
      }

      # Function to display public keys
      display_public_keys() {
        log "SUCCESS" "📋 Generated GPG keys:"
        gpg --list-secret-keys

        log "INFO" "Public keys for GitHub:"
        for email in "''${GPG_KEYS[@]}"; do
          echo
          log "INFO" "=> Key for $email:"
          gpg --armor --export "$email"
        done
      }

      # Function to configure GPG agent
      configure_gpg_agent() {
        log "INFO" "🔄 Configuring GPG agent..."

        # Create gpg-agent.conf
        cat > ~/.gnupg/gpg-agent.conf << EOF
default-cache-ttl 3600
max-cache-ttl 7200
enable-ssh-support
EOF

        # Restart GPG agent
        gpgconf --kill gpg-agent
        gpg-agent --daemon
      }

      # Main execution
      if ! backup_existing_keys; then
        log "ERROR" "Backup failed, aborting..."
        exit 1
      fi

      # Generate keys
      for key in "''${!GPG_KEYS[@]}"; do
        if ! generate_key "$key" "''${GPG_KEYS[$key]}"; then
          log "ERROR" "Key generation failed for $key"
          exit 1
        fi
      done

      if ! configure_gpg_agent; then
        log "ERROR" "GPG agent configuration failed"
        exit 1
      fi

      display_public_keys

      log "SUCCESS" "✅ GPG configuration complete!"
      log "INFO" "ℹ️  Remember to:"
      log "INFO" "  1. Add the GPG keys to your services (GitHub, GitLab, etc.)"
      log "INFO" "  2. Configure git to use GPG signing:"
      log "INFO" "     git config --global commit.gpgsign true"
      log "INFO" "     git config --global user.signingkey <your-key-id>"
    '';
  };

  # GPG backup script
  home.file.".local/bin/gpg-backup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Colors for messages
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      NC='\033[0m'

      BACKUP_DIR=~/gpg_backup_$(date +%Y%m%d_%H%M%S)

      if [[ ! -d ~/.gnupg ]] || [[ -z "$(ls -A ~/.gnupg)" ]]; then
        echo -e "''${RED}Error: GPG directory doesn't exist or is empty''${NC}"
        exit 1
      fi

      mkdir -p "$BACKUP_DIR"
      echo -e "''${BLUE}Creating GPG backup...''${NC}"

      # Export public keys
      gpg --export --armor > "$BACKUP_DIR/public_keys.asc"

      # Export private keys
      gpg --export-secret-keys --armor > "$BACKUP_DIR/private_keys.asc"

      # Export trust database
      gpg --export-ownertrust > "$BACKUP_DIR/trustdb.txt"

      # Copy configuration
      cp ~/.gnupg/gpg.conf "$BACKUP_DIR/" 2>/dev/null || true
      cp ~/.gnupg/gpg-agent.conf "$BACKUP_DIR/" 2>/dev/null || true

      chmod -R 600 "$BACKUP_DIR"/*
      chmod 700 "$BACKUP_DIR"

      echo -e "''${GREEN}GPG backup successfully created in $BACKUP_DIR''${NC}"
    '';
  };

  # GPG restore script
  home.file.".local/bin/gpg-restore" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Colors for messages
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      YELLOW='\033[1;33m'
      NC='\033[0m'

      if [ $# -ne 1 ]; then
        echo -e "''${RED}Error: Please provide the backup directory path''${NC}"
        echo "Usage: gpg-restore <backup-directory>"
        exit 1
      fi

      BACKUP_DIR=$1

      if [[ ! -d $BACKUP_DIR ]]; then
        echo -e "''${RED}Error: Backup directory not found''${NC}"
        exit 1
      fi

      # Backup current GPG configuration before restore
      CURRENT_BACKUP=~/gpg_backup_before_restore_$(date +%Y%m%d_%H%M%S)
      if [[ -d ~/.gnupg ]]; then
        echo -e "''${YELLOW}Backing up current GPG configuration...''${NC}"
        mkdir -p "$CURRENT_BACKUP"
        gpg --export --armor > "$CURRENT_BACKUP/public_keys.asc"
        gpg --export-secret-keys --armor > "$CURRENT_BACKUP/private_keys.asc"
        gpg --export-ownertrust > "$CURRENT_BACKUP/trustdb.txt"
      fi

      echo -e "''${BLUE}Restoring GPG configuration from $BACKUP_DIR...''${NC}"

      # Import keys
      gpg --import "$BACKUP_DIR/public_keys.asc"
      gpg --import "$BACKUP_DIR/private_keys.asc"
      gpg --import-ownertrust "$BACKUP_DIR/trustdb.txt"

      # Restore configuration files
      mkdir -p ~/.gnupg
      cp "$BACKUP_DIR/gpg.conf" ~/.gnupg/ 2>/dev/null || true
      cp "$BACKUP_DIR/gpg-agent.conf" ~/.gnupg/ 2>/dev/null || true

      chmod 700 ~/.gnupg
      chmod 600 ~/.gnupg/*

      echo -e "''${GREEN}GPG configuration successfully restored!''${NC}"
      echo -e "''${BLUE}Previous configuration backed up to $CURRENT_BACKUP''${NC}"
    '';
  };
}
