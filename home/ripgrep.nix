{
  enable = true;
  arguments = [
    "--smart-case"
    "--follow"
    "--hidden"
    "--max-columns=200"
    "--max-columns-preview"
    "--glob=!.git/*"
    "--glob=!node_modules/*"
    "--glob=!.direnv/*"
    "--glob=!.venv/*"
    "--glob=!__pycache__/*"
    "--glob=!*.pyc"
    "--glob=!.mypy_cache/*"
    "--glob=!.pytest_cache/*"
    "--glob=!target/*"
    "--glob=!dist/*"
    "--glob=!build/*"
    "--colors=line:style:bold"
    "--colors=path:style:bold"
    "--colors=path:fg:cyan"
    "--colors=match:fg:yellow"
    "--colors=match:style:bold"
  ];
}
