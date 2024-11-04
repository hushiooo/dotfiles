{ ... }:
{
  enable = true;
  settings = {
    logo = {
      type = "auto";
    };
    modules = [
      {
        type = "title";
        color = {
          "1" = "cyan";
        };
      }
      {
        type = "separator";
        string = "────────────";
        color = {
          "1" = "blue";
        };
      }
      {
        type = "os";
        key = "󰀵 OS";
      }
      {
        type = "kernel";
        key = "󰒋 Kernel";
      }
      {
        type = "packages";
        key = "󰏖 Packages";
      }
      {
        type = "shell";
        key = "󰞷 Shell";
      }
      {
        type = "terminal";
        key = "󰆍 Terminal";
      }
      {
        type = "terminalfont";
        key = "󰛖 Font";
      }
      {
        type = "display";
        key = "󰍹 Resolution";
      }
      {
        type = "de";
        key = "󱂬 DE";
      }
      {
        type = "wm";
        key = "󱂬 WM";
      }
      {
        type = "cpu";
        key = "󰻠 CPU";
      }
      {
        type = "gpu";
        key = "󰢮 GPU";
      }
      {
        type = "memory";
        key = "󰍛 Memory";
      }
      {
        type = "disk";
        key = "󰋊 Disk";
      }
      {
        type = "uptime";
        key = "󰅐 Uptime";
      }
      {
        type = "battery";
        key = "󰁹 Battery";
      }
      {
        type = "poweradapter";
        key = "󰚥 Power";
      }
      {
        type = "locale";
        key = "󰊿 Locale";
      }
      {
        type = "break";
      }
      {
        type = "wifi";
        key = "󰤢 WiFi";
      }
      {
        type = "publicip";
        key = "󰩟 Public IP";
      }
      {
        type = "localip";
        key = "󰩠 Local IP";
      }
      {
        type = "break";
      }
      {
        type = "colors";
      }
    ];
  };
}
