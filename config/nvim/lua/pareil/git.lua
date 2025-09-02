local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- Detect whether we're inside a Git repository
function M.is_inside_repo()
    local result = vim.fn.systemlist("git rev-parse --is-inside-work-tree")
    return result[1] == "true"
end

-- List repo-relative files for a given branch (tree), or current worktree if branch is nil
---@param branch string|nil
---@return string[]
local function list_files(branch)
    if branch and branch ~= "" then
        return vim.fn.systemlist(string.format("git ls-tree -r --name-only %s", vim.fn.shellescape(branch)))
    else
        return vim.fn.systemlist("git ls-files")
    end
end

-- Check if a path exists at <branch>:<path> in Git
---@param branch string
---@param path string
---@return boolean
local function exists_in_branch(branch, path)
    -- git cat-file -e returns success if the object exists
    local cmd = string.format("git cat-file -e %s:%s 2>/dev/null; echo $?", branch, path)
    local out = vim.fn.systemlist(cmd)
    local rc = out[#out]
    return rc == "0"
end

--- Prompts the user to select a file (optionally from a specific branch's tree).
---@param prompt string
---@param callback fun(file: string)
---@param opts table|nil  -- { branch = "my-branch" }
function M.select_file(prompt, callback, opts)
    opts = opts or {}
    local files = list_files(opts.branch)

    pickers.new({}, {
        prompt_title = opts.branch and (prompt .. " [" .. opts.branch .. "]") or prompt,
        finder = finders.new_table({ results = files }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection or not selection[1] then
                    vim.notify("No file selected", vim.log.levels.WARN)
                    return
                end
                callback(selection[1])
            end)
            return true
        end,
    }):find()
end

--- Prompts the user to select a local Git branch.
---@param prompt string
---@param callback fun(branch: string)
function M.select_branch(prompt, callback)
    local output = vim.fn.systemlist("git for-each-ref --format='%(refname:short)' refs/heads/")
    local branches = vim.tbl_filter(function(branch)
        return branch ~= ""
    end, output)

    pickers.new({}, {
        prompt_title = prompt,
        finder = finders.new_table({ results = branches }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection or not selection[1] then
                    vim.notify("No branch selected", vim.log.levels.WARN)
                    return
                end
                callback(selection[1])
            end)
            return true
        end,
    }):find()
end

--- Extracts file contents from Git into temporary files (with preflight checks and clear errors).
---@param file1 string
---@param file2 string
---@param branch1 string
---@param branch2 string
---@param callback fun(path1: string, path2: string)
function M.extract_files(file1, file2, branch1, branch2, callback)
    if not M.is_inside_repo() then
        vim.notify("❌ Not inside a Git repository.", vim.log.levels.ERROR)
        return
    end

    -- Preflight existence checks to fail fast with actionable messages
    if not exists_in_branch(branch1, file1) then
        vim.notify(
            ("❌ %s:%s does not exist.\nTip: Pick the file from the %s tree."):format(branch1, file1, branch1),
            vim.log.levels.ERROR
        )
        return
    end

    if not exists_in_branch(branch2, file2) then
        vim.notify(
            ("❌ %s:%s does not exist.\nTip: Pick the file from the %s tree (path may differ)."):format(branch2, file2,
                branch2),
            vim.log.levels.ERROR
        )
        return
    end

    local tmp1 = vim.fn.tempname()
    local tmp2 = vim.fn.tempname()
    local revpath1 = string.format("%s:%s", branch1, file1)
    local revpath2 = string.format("%s:%s", branch2, file2)

    vim.system({ "git", "show", revpath1 }, { text = true }, function(res1)
        if res1.code ~= 0 then
            vim.schedule(function()
                vim.notify(
                    ("❌ Failed to extract file1 (%s):\n%s"):format(revpath1, res1.stderr or "Unknown error"),
                    vim.log.levels.ERROR
                )
            end)
            return
        end

        vim.system({ "git", "show", revpath2 }, { text = true }, function(res2)
            if res2.code ~= 0 then
                vim.schedule(function()
                    vim.notify(
                        ("❌ Failed to extract file2 (%s):\n%s"):format(revpath2, res2.stderr or "Unknown error"),
                        vim.log.levels.ERROR
                    )
                end)
                return
            end

            vim.schedule(function()
                vim.fn.writefile(vim.split(res1.stdout or "", "\n"), tmp1)
                vim.fn.writefile(vim.split(res2.stdout or "", "\n"), tmp2)
                callback(tmp1, tmp2)
            end)
        end)
    end)
end

M.exists_in_branch = exists_in_branch

return M
