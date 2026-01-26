{ ... }:
{
  enable = true;
  settings = {
    logo.type = "auto";
    modules = [
      { type = "title"; }
      {
        type = "separator";
        string = "────────────";
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
        type = "shell";
        key = "󰞷 Shell";
      }
      {
        type = "terminal";
        key = "󰆍 Terminal";
      }
      {
        type = "cpu";
        key = "󰻠 CPU";
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
      { type = "break"; }
      { type = "colors"; }
    ];
  };
}
