{ ... }:
{
  enable = true;
  settings = {
    flags = {
      temperature_type = "celsius";
      default_time_value = 60000;
      rate = 500;
      left_legend = true;
      current_usage = true;
      group_processes = true;
      tree = true;
      show_table_scroll_position = true;
    };
    colors = {
      high_battery_color = "green";
      medium_battery_color = "yellow";
      low_battery_color = "red";
    };
    disk_filter = {
      is_list_ignored = true;
      list = [
        "/dev/loop"
        "overlay"
        "shm"
      ];
    };
  };
}
