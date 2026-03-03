{ pkgs, ... }:
{
  home.packages = [ pkgs.cursor-cli ];

  home.file = {
    ".cursor/mcp.json".source = ../config/cursor/mcp.json;
    ".cursor/memory/.keep".text = "";
    ".cursor/skills".source = ../config/cursor/skills;
    ".cursor/commands".source = ../config/cursor/commands;
    ".cursor/rules".source = ../config/cursor/rules;
    "AGENTS.md".source = ../config/cursor/AGENTS.md;
  };
}
