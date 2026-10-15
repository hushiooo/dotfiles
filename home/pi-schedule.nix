{
  config,
  pkgs,
  dotfiles,
  ...
}:
let
  piSchedule = pkgs.writeShellApplication {
    name = "pi-schedule";
    runtimeInputs = [
      pkgs.herdr
      pkgs.python3
    ];
    text = ''exec python3 ${../config/pi/schedule/pi_schedule.py} "$@"'';
  };
in
{
  home.packages = [ piSchedule ];

  # Live symlink into the checkout: task edits apply without a rebuild.
  xdg.configFile."pi-schedule/tasks".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/pi/schedule/tasks";

  # Ticks at login and every minute, so a task that fell due while the machine was
  # off or asleep starts as soon as it is back on.
  launchd.agents.pi-schedule = {
    enable = true;
    config = {
      ProgramArguments = [
        "${piSchedule}/bin/pi-schedule"
        "tick"
      ];
      RunAtLoad = true;
      StartInterval = 60;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/pi-schedule.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/pi-schedule.log";
    };
  };
}
