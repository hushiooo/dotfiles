{ ... }:
{
  enable = true;
  arguments = [
    "--colors=line:style:bold"
    "--colors=match:fg:yellow"
    "--colors=match:style:bold"
    "--colors=path:fg:cyan"
    "--colors=path:style:bold"
    "--follow"
    "--glob=!*.pyc"
    "--glob=!.direnv/*"
    "--glob=!.git/*"
    "--glob=!.mypy_cache/*"
    "--glob=!.pytest_cache/*"
    "--glob=!.venv/*"
    "--glob=!__pycache__/*"
    "--glob=!build/*"
    "--glob=!dist/*"
    "--glob=!node_modules/*"
    "--glob=!target/*"
    "--hidden"
    "--max-columns-preview"
    "--max-columns=200"
    "--smart-case"
  ];
}
