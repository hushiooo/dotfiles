{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;

    # SSH Best Practices Configuration
    extraConfig = ''
      # Security
      Protocol 2
      HashKnownHosts yes
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      PubkeyAuthentication yes
      IdentitiesOnly yes

      # Performance and reliability
      Compression yes
      TCPKeepAlive yes
      ServerAliveInterval 60
      ServerAliveCountMax 2
      ConnectTimeout 30

      # macOS specific
      UseKeychain yes
      AddKeysToAgent yes

      # Control Master for connection reuse
      ControlMaster auto
      ControlPath ~/.ssh/control-%C
      ControlPersist 3600
    '';

    # Host-specific configurations
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github";
        extraOptions = {
          PreferredAuthentications = "publickey";
        };
      };

      "*" = {
        # Default settings for all hosts
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
          StrictHostKeyChecking = "ask";
          IdentitiesOnly = "yes";
        };
      };
    };
  };

  # Create necessary directories
  home.file = {
    ".ssh/.keep".text = "";
    ".ssh/control/.keep".text = "";
  };

  # SSH utility scripts
  home.file = {
    ".local/bin/ssh-init" = {
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

        # SSH keys configuration
        declare -A SSH_KEYS=(
          ["github"]="hushio@proton.me"
          ["personal"]="hushio@proton.me"
        )

        log "INFO" "🔐 Initializing SSH configuration..."

        # Create and configure SSH directory
        mkdir -p ~/.ssh/control
        chmod 700 ~/.ssh
        chmod 700 ~/.ssh/control

        # Function to generate an SSH key
        generate_key() {
          local name=$1
          local email=$2
          local keyfile=~/.ssh/$name

          if [[ -f $keyfile ]]; then
            log "INFO" "ℹ️  Key $name already exists"
          else
            log "SUCCESS" "🔑 Generating key $name for $email..."
            ssh-keygen -t ed25519 -C "$email" -f "$keyfile" -N ""
            if ! ssh-add --apple-use-keychain "$keyfile"; then
              log "ERROR" "Failed to add key $name to SSH agent"
              return 1
            fi
          fi
        }

        # Function to backup existing keys
        backup_existing_keys() {
          local backup_dir=~/ssh_backup_$(date +%Y%m%d_%H%M%S)
          if [[ -d ~/.ssh && "$(ls -A ~/.ssh)" ]]; then
            log "INFO" "📦 Backing up existing keys to $backup_dir..."
            mkdir -p "$backup_dir"
            if ! cp -r ~/.ssh/* "$backup_dir/"; then
              log "ERROR" "Failed to create backup"
              return 1
            fi
            chmod -R 600 "$backup_dir"/*
            chmod 700 "$backup_dir"
          fi
        }

        # Function to setup SSH agent
        setup_ssh_agent() {
          log "INFO" "🔄 Configuring SSH agent..."
          if ! eval "$(ssh-agent -s)"; then
            log "ERROR" "Failed to start SSH agent"
            return 1
          fi

          # Add all existing keys to agent
          for keyfile in ~/.ssh/*; do
            if [[ -f $keyfile && $keyfile != *.pub && $keyfile != *known_hosts* && $keyfile != config ]]; then
              if ! ssh-add --apple-use-keychain "$keyfile" 2>/dev/null; then
                log "WARNING" "Failed to add $keyfile to SSH agent"
              fi
            fi
          done
        }

        # Function to display public keys
        display_public_keys() {
          log "SUCCESS" "📋 Generated public keys:"
          for key in ~/.ssh/*.pub; do
            if [[ -f $key ]]; then
              log "INFO" "=> $key:"
              cat "$key"
              echo
            fi
          done
        }

        # Main execution
        if ! backup_existing_keys; then
          log "ERROR" "Backup failed, aborting..."
          exit 1
        fi

        # Generate keys
        for key in "''${!SSH_KEYS[@]}"; do
          if ! generate_key "$key" "''${SSH_KEYS[$key]}"; then
            log "ERROR" "Key generation failed for $key"
            exit 1
          fi
        done

        if ! setup_ssh_agent; then
          log "ERROR" "SSH agent setup failed"
          exit 1
        fi

        display_public_keys

        log "SUCCESS" "✅ SSH configuration complete!"
        log "INFO" "ℹ️  Remember to add the public keys to your services (GitHub, GitLab, etc.)"
      '';
    };

    # SSH backup script
    ".local/bin/ssh-backup" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Colors for messages
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        BLUE='\033[0;34m'
        NC='\033[0m'

        BACKUP_DIR=~/ssh_backup_$(date +%Y%m%d_%H%M%S)

        # Check if SSH directory exists and is not empty
        if [[ ! -d ~/.ssh ]] || [[ -z "$(ls -A ~/.ssh)" ]]; then
          echo -e "''${RED}Error: SSH directory doesn't exist or is empty''${NC}"
          exit 1
        fi

        # Create backup directory
        if ! mkdir -p "$BACKUP_DIR"; then
          echo -e "''${RED}Error: Failed to create backup directory''${NC}"
          exit 1
        fi

        # Backup SSH files
        echo -e "''${BLUE}Creating SSH backup...''${NC}"
        if ! cp -r ~/.ssh/* "$BACKUP_DIR/"; then
          echo -e "''${RED}Error: Failed to copy SSH files''${NC}"
          exit 1
        fi

        # Set proper permissions
        chmod -R 600 "$BACKUP_DIR"/*
        chmod 700 "$BACKUP_DIR"

        echo -e "''${GREEN}SSH backup successfully created in $BACKUP_DIR''${NC}"
      '';
    };

    # SSH restore script
    ".local/bin/ssh-restore" = {
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

        # Check if backup directory is provided
        if [ $# -ne 1 ]; then
          echo -e "''${RED}Error: Please provide the backup directory path''${NC}"
          echo "Usage: ssh-restore <backup-directory>"
          exit 1
        fi

        BACKUP_DIR=$1

        # Validate backup directory
        if [[ ! -d $BACKUP_DIR ]]; then
          echo -e "''${RED}Error: Backup directory not found''${NC}"
          exit 1
        fi

        # Backup current SSH configuration before restore
        CURRENT_BACKUP=~/ssh_backup_before_restore_$(date +%Y%m%d_%H%M%S)
        if [[ -d ~/.ssh ]]; then
          echo -e "''${YELLOW}Backing up current SSH configuration...''${NC}"
          mkdir -p "$CURRENT_BACKUP"
          cp -r ~/.ssh/* "$CURRENT_BACKUP/" 2>/dev/null || true
        fi

        # Restore from backup
        echo -e "''${BLUE}Restoring SSH configuration from $BACKUP_DIR...''${NC}"
        mkdir -p ~/.ssh
        cp -r "$BACKUP_DIR/"* ~/.ssh/

        # Set proper permissions
        chmod 700 ~/.ssh
        chmod -R 600 ~/.ssh/*

        echo -e "''${GREEN}SSH configuration successfully restored!''${NC}"
        echo -e "''${BLUE}Previous configuration backed up to $CURRENT_BACKUP''${NC}"
      '';
    };
  };

  # SSH agent service
  services.ssh-agent = {
    enable = true;
    enableSSHKeys = true;
  };
}