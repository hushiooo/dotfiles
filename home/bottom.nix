{
  enable = true;
  settings = {
    flags = {
      temperature_type = "celsius";
      rate = 500;
      tree = true;
      group_processes = true;
      hide_table_gap = true;
      battery = true;
      disable_click = false;
      expanded_on_startup = true;
    };
    colors = {
      high_battery_color = "#9ece6a";
      medium_battery_color = "#e0af68";
      low_battery_color = "#f7768e";
      table_header_color = "#7aa2f7";
      widget_title_color = "#7aa2f7";
      avg_cpu_color = "#bb9af7";
      cpu_core_colors = [
        "#7aa2f7"
        "#9ece6a"
        "#e0af68"
        "#f7768e"
        "#bb9af7"
        "#7dcfff"
      ];
    };
  };
}
