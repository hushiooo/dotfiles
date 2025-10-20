local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local function notify_error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

---Execute a Git command and return its full result.
---@param args string[]
---@param opts { root?: string, allow_nonzero?: boolean }|nil
---@return table|nil result
---@return string|nil err
local function run_git(args, opts)
    opts = opts or {}
    local root = opts.root or M.get_repo_root()
    if not root or root == "" then
        return nil, "Not inside a Git repository."
    end

    local cmd = vim.deepcopy(args)
    table.insert(cmd, 1, "git")

    local result = vim.system(cmd, { text = true, cwd = root }):wait()
    if not result then
        return nil, "Failed to spawn git process."
    end

    if result.code ~= 0 and not opts.allow_nonzero then
        local stderr = vim.trim(result.stderr or "")
        if stderr == "" then
            stderr = string.format("git %s exited with code %d", table.concat(args, " "), result.code)
        end
        return nil, stderr
    end

    return result, nil
end

--- Determine the repository root for the current context (buffer or working dir).
---@return string|nil
function M.get_repo_root()
    local candidates = {}
    local bufname = vim.api.nvim_buf_get_name(0)

    if bufname ~= "" then
        table.insert(candidates, vim.fn.fnamemodify(bufname, ":p:h"))
    end

    table.insert(candidates, vim.fn.getcwd())
    table.insert(candidates, vim.loop.cwd())

    for _, dir in ipairs(candidates) do
        if dir and dir ~= "" then
            local result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
            if result and result.code == 0 and result.stdout then
                local root = vim.trim(result.stdout)
                if vim.fs and vim.fs.normalize then
                    root = vim.fs.normalize(root)
                end
                if root ~= "" then
                    return root
                end
            end
        end
    end

    return nil
end

--- Detect whether we're inside a Git repository
function M.is_inside_repo()
    return M.get_repo_root() ~= nil
end

-- List repo-relative files for a given branch (tree), or current worktree if branch is nil
---@param branch string|nil
---@return string[]
local function list_files(branch)
    local root = M.get_repo_root()
    if not root then
        notify_error("❌ Not inside a Git repository.")
        return {}
    end

    local args
    if branch and branch ~= "" then
        args = { "ls-tree", "-r", "--name-only", branch }
    else
        args = { "ls-files" }
    end

    local result, err = run_git(args, { root = root })
    if not result then
        notify_error("❌ Failed to list files from Git.\n" .. err)
        return {}
    end

    return vim.split(result.stdout or "", "\n", { trimempty = true })
end

-- Check if a path exists at <branch>:<path> in Git
---@param branch string
---@param path string
---@return boolean
local function exists_in_branch(branch, path, root)
    root = root or M.get_repo_root()
    if not root then
        return false
    end

    if branch == nil or branch == "" or path == nil or path == "" then
        return false
    end

    local result = run_git({ "cat-file", "-e", string.format("%s:%s", branch, path) },
        { root = root, allow_nonzero = true })
    return result ~= nil and result.code == 0
end

--- Prompts the user to select a file (optionally from a specific branch's tree).
---@param prompt string
---@param callback fun(file: string)
---@param opts table|nil  -- { branch = "my-branch" }
function M.select_file(prompt, callback, opts)
    opts = opts or {}
    local files = list_files(opts.branch)

    if vim.tbl_isempty(files) then
        notify_error("❌ No files available to select.")
        return
    end

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
    local root = M.get_repo_root()
    if not root then
        notify_error("❌ Not inside a Git repository.")
        return
    end

    local result, err = run_git({ "for-each-ref", "--format=%(refname:short)", "refs/heads/" }, { root = root })
    if not result then
        notify_error("❌ Failed to list branches.\n" .. err)
        return
    end

    local branches = vim.split(result.stdout or "", "\n", { trimempty = true })
    if vim.tbl_isempty(branches) then
        notify_error("❌ No local branches found.")
        return
    end

    local current_branch
    local head_result = run_git({ "branch", "--show-current" }, { root = root })
    if head_result and head_result.stdout then
        local trimmed = vim.trim(head_result.stdout)
        if trimmed ~= "" then
            current_branch = trimmed
        end
    end

    local default_index
    if current_branch then
        for idx, branch in ipairs(branches) do
            if branch == current_branch then
                default_index = idx
                break
            end
        end
    end

    pickers.new({}, {
        prompt_title = prompt,
        finder = finders.new_table({ results = branches }),
        sorter = conf.generic_sorter({}),
        default_selection_index = default_index,
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
        notify_error("❌ Not inside a Git repository.")
        return
    end

    local root = M.get_repo_root()
    if not root then
        notify_error("❌ Unable to determine Git repository root.")
        return
    end

    -- Preflight existence checks to fail fast with actionable messages
    if not exists_in_branch(branch1, file1, root) then
        notify_error(("❌ %s:%s does not exist.\nTip: Pick the file from the %s tree."):format(branch1, file1, branch1))
        return
    end

    if not exists_in_branch(branch2, file2, root) then
        notify_error(
            ("❌ %s:%s does not exist.\nTip: Pick the file from the %s tree (path may differ)."):format(branch2, file2,
                branch2)
        )
        return
    end

    local tmp1 = vim.fn.tempname()
    local tmp2 = vim.fn.tempname()
    local revpath1 = string.format("%s:%s", branch1, file1)
    local revpath2 = string.format("%s:%s", branch2, file2)

    vim.system({ "git", "show", revpath1 }, { text = true, cwd = root }, function(res1)
        if res1.code ~= 0 then
            vim.schedule(function()
                notify_error(("❌ Failed to extract file1 (%s):\n%s"):format(revpath1, res1.stderr or "Unknown error"))
            end)
            return
        end

        vim.system({ "git", "show", revpath2 }, { text = true, cwd = root }, function(res2)
            if res2.code ~= 0 then
                vim.schedule(function()
                    notify_error(("❌ Failed to extract file2 (%s):\n%s"):format(revpath2, res2.stderr or "Unknown error"))
                end)
                return
            end

            vim.schedule(function()
                vim.fn.writefile(vim.split(res1.stdout or "", "\n"), tmp1)
                vim.fn.writefile(vim.split(res2.stdout or "", "\n"), tmp2)
                callback(tmp1, tmp2)
                vim.defer_fn(function()
                    if vim.loop.fs_stat(tmp1) then
                        vim.fn.delete(tmp1)
                    end
                    if vim.loop.fs_stat(tmp2) then
                        vim.fn.delete(tmp2)
                    end
                end, 50)
            end)
        end)
    end)
end

M.exists_in_branch = exists_in_branch

return M
