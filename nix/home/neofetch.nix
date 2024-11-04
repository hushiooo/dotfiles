{ config, pkgs, ... }:

{
  programs.neofetch = {
    enable = true;
    config = ''
      print_info() {
          # Title and OS info with custom colors
          info title
          info underline

          # Basic system information
          info "󰀵  OS" distro
          info "󰌢  Host" model
          info "󰻀  CPU" cpu
          info "󰍛  Memory" memory

          # System status
          info "󰁯  Uptime" uptime
          info "󰋊  Battery" battery

          # Software environment
          prin "󰮯  Nix" "$(nix --version | cut -d' ' -f1,3)"
          prin "󱧕  Packages" "$(ls -d /nix/store/*-* | wc -l | tr -d ' ') (nix) $(brew list | wc -l | tr -d ' ') (brew)"
          info "󰆍  Shell" shell
          info "󰞷  Terminal" term
          info "󰛖  Font" term_font

          # Disk and network
          info "󰋊  Disk" disk
          prin "󰖩  IP" "$(ipconfig getifaddr en0)"

          # Additional system details
          info "󰢮  Kernel" kernel
          prin "󰨇  Resolution" "$(system_profiler SPDisplaysDataType | grep Resolution | awk '{print $2, $3, $4}')"

          # Color blocks
          info cols
      }

      # Layout
      os_arch="on"
      memory_percent="on"
      memory_unit="gib"
      package_managers="on"
      shell_path="off"
      shell_version="on"
      speed_type="bios_limit"
      speed_shorthand="on"
      cpu_brand="on"
      cpu_speed="on"
      cpu_cores="logical"
      refresh_rate="on"
      battery_display="barinfo"

      # Package count settings
      pkg_managers="on"
      has_brew="auto"

      # Appearance
      ascii_distro="Darwin"
      ascii_colors=(36 39)
      ascii_bold="on"

      block_range=(0 7)
      block_width=4
      block_height=1

      bold="on"
      underline_enabled="on"
      underline_char="━"
      separator=" "
      gap=2

      # Color settings
      colors=(distro)
      color_blocks="on"

      # Shorthand settings
      kernel_shorthand="on"
      distro_shorthand="off"
      uptime_shorthand="tiny"

      # macOS specific
      darwin_show_release_version="on"
      darwin_show_codename="on"

      # Image backend and options
      image_backend="ascii"
      image_source="auto"

      # Misc
      stdout="off"
      config_version="3.4.0"
    '';
  };
}
