{ ... }:
{
  enable = true;
  settings = {
    colors = {
      avg_cpu_color = "#bb9af7";
      cpu_core_colors = [
        "#7aa2f7"
        "#9ece6a"
        "#e0af68"
        "#f7768e"
        "#bb9af7"
        "#7dcfff"
      ];
      high_battery_color = "#9ece6a";
      low_battery_color = "#f7768e";
      medium_battery_color = "#e0af68";
      table_header_color = "#7aa2f7";
      widget_title_color = "#7aa2f7";
    };
    flags = {
      battery = true;
      disable_click = false;
      expanded_on_startup = true;
      group_processes = true;
      hide_table_gap = true;
      rate = 500;
      temperature_type = "celsius";
      tree = true;
    };
  };
}
