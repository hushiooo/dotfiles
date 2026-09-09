{ lib, ... }:
let
  # Personal agent-skill library. Each subdirectory of ../skills is a skill
  # (a folder with a SKILL.md) and gets symlinked into ~/.agents/skills, the
  # shared location pi and other agents auto-discover. Drop a new folder in
  # ../skills and run `hms` to add a skill.
  skillsDir = ../skills;

  skillNames = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)
  );
in
{
  home.file = lib.listToAttrs (
    map (name: {
      name = ".agents/skills/${name}";
      value.source = skillsDir + "/${name}";
    }) skillNames
  );
}
