{ ... }:
{
  enable = true;
  arguments = [
    "--smart-case"
    "--follow"
    "--hidden"
    "--glob=!.git/*"
    "--glob=!node_modules/*"
    "--glob=!.direnv/*"
    "--glob=!.venv/*"
    "--glob=!__pycache__/*"
    "--colors=line:style:bold"
    "--colors=path:style:bold"
    "--colors=match:fg:yellow"
  ];
}
