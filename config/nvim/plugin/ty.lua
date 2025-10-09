-- ty integration (NO LSP): run `ty check` and show diagnostics via nvim-lint.
-- Prereqs:
--   1) Plugin: nvim-lint (installed via Home Manager in your neovim.nix)
--   2) Tool: `uv` on PATH (so we can run `uvx ty ...` without managing venvs)
--   3) Optional: put ty settings in pyproject.toml ([tool.ty] ...)

local ok_lint, lint = pcall(require, "lint")
if not ok_lint then
  vim.notify("nvim-lint not found (required for ty integration)", vim.log.levels.ERROR)
  return
end

-- Parse ty's "concise" output format:
--   <file>:<line>:<col>: <severity>[<rule>] <message>
-- Examples:
--   api/foo.py:12:8: error[invalid-argument-type] Argument 1 has incompatible type "int"
--   pkg/bar.py:3:1: warning[unused-import] 'x' imported but unused
local function parse_ty(output, bufnr)
  local to_sev = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    info = vim.diagnostic.severity.INFO,
    note = vim.diagnostic.severity.HINT,
  }
  local result = {}
  local curfile = vim.api.nvim_buf_get_name(bufnr)
  local curfile_abs = vim.fn.fnamemodify(curfile, ":p")

  for line in output:gmatch("[^\r\n]+") do
    local file, lnum, col, sev, rule, msg =
      line:match("^([^:]+):(%d+):(%d+):%s*(%a+)%[([^%]]+)%]%s*(.+)$")
    if file and lnum and col and sev and msg then
      -- Keep only diagnostics for the current buffer (nvim-lint convention)
      if vim.fn.fnamemodify(file, ":p") == curfile_abs then
        table.insert(result, {
          lnum = tonumber(lnum) - 1,
          col = tonumber(col) - 1,
          end_lnum = tonumber(lnum) - 1, -- ty concise output doesn't give ranges
          end_col = tonumber(col) - 1,
          message = msg .. (rule and (" [" .. rule .. "]") or ""),
          severity = to_sev[sev:lower()] or vim.diagnostic.severity.ERROR,
          source = "ty",
        })
      end
    end
  end
  return result
end

-- Define a custom nvim-lint linter called "ty"
lint.linters.ty = {
  cmd = "uvx",
  args = {
    "ty", "check",
    "--output-format", "concise",
    "--quiet",                    -- no banner/progress
    "--no-color",                 -- make parsing robust
    -- You can add project-wide flags here if you don't put them in pyproject:
    -- "--python-version", "3.12",
    -- "--platform", "all",
  },
  stdin = false,
  stream = "stderr",              -- many tools write diagnostics to stderr
  ignore_exitcode = true,         -- ty exits nonzero when errors are found
  parser = parse_ty,
}

-- Enable ty for Python buffers
lint.linters_by_ft = lint.linters_by_ft or {}
lint.linters_by_ft.python = lint.linters_by_ft.python or {}
local has_ty = false
for _, name in ipairs(lint.linters_by_ft.python) do
  if name == "ty" then has_ty = true break end
end
if not has_ty then table.insert(lint.linters_by_ft.python, "ty") end

-- Run on save (buffer-level)
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function() require("lint").try_lint({ "ty" }) end,
})

-- Manual triggers
vim.api.nvim_create_user_command("TyCheck", function()
  require("lint").try_lint({ "ty" })
  vim.notify("ty: checked current buffer", vim.log.levels.INFO)
end, { desc = "Run ty check for current buffer" })

vim.api.nvim_create_user_command("TyProject", function()
  -- project-wide run in a terminal split (non-blocking)
  vim.cmd("botright 12split | terminal uvx ty check --output-format concise --no-color")
end, { desc = "Run ty check for whole project (terminal split)" })

-- Optional: keymaps (comment out if you prefer your own)
vim.keymap.set("n", "<leader>ty", function()
  require("lint").try_lint({ "ty" })
end, { desc = "ty: check current buffer" })
vim.keymap.set("n", "<leader>tY", function()
  vim.cmd("TyProject")
end, { desc = "ty: project-wide check" })
