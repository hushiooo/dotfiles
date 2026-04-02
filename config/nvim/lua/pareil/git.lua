local M = {}

local function notify_error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

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

    local cmd = vim.list_extend({ "git" }, args)
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

---@return string|nil
function M.get_repo_root()
    local start = vim.api.nvim_buf_get_name(0)
    if start ~= "" then
        start = vim.fn.fnamemodify(start, ":p:h")
    else
        start = vim.fn.getcwd()
    end

    local result = vim.system({ "git", "-C", start, "rev-parse", "--show-toplevel" }, { text = true }):wait()
    if result and result.code == 0 and result.stdout then
        local root = vim.trim(result.stdout)
        if root ~= "" then
            return vim.fs.normalize(root)
        end
    end

    return nil
end

function M.is_inside_repo()
    return M.get_repo_root() ~= nil
end

---@param branch string|nil
---@param root string
---@return string[]
local function list_files(branch, root)
    local args
    if branch and branch ~= "" then
        args = { "ls-tree", "-r", "--name-only", branch }
    else
        args = { "ls-files" }
    end

    local result, err = run_git(args, { root = root })
    if not result then
        notify_error("Failed to list files from Git.\n" .. err)
        return {}
    end

    return vim.split(result.stdout or "", "\n", { trimempty = true })
end

---@param branch string
---@param path string
---@param root string
---@return boolean
local function exists_in_branch(branch, path, root)
    if not root or branch == nil or branch == "" or path == nil or path == "" then
        return false
    end

    local result = run_git(
        { "cat-file", "-e", string.format("%s:%s", branch, path) },
        { root = root, allow_nonzero = true }
    )
    return result ~= nil and result.code == 0
end

---@param prompt string
---@param callback fun(file: string)
---@param opts { branch?: string, root: string }
function M.select_file(prompt, callback, opts)
    opts = opts or {}
    local root = opts.root or M.get_repo_root()
    if not root then
        notify_error("Not inside a Git repository.")
        return
    end

    local files = list_files(opts.branch, root)
    if #files == 0 then
        notify_error("No files available to select.")
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

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

---@param prompt string
---@param callback fun(branch: string)
---@param opts? { root?: string }
function M.select_branch(prompt, callback, opts)
    opts = opts or {}
    local root = opts.root or M.get_repo_root()
    if not root then
        notify_error("Not inside a Git repository.")
        return
    end

    local result, err = run_git({ "for-each-ref", "--format=%(refname:short)", "refs/heads/" }, { root = root })
    if not result then
        notify_error("Failed to list branches.\n" .. err)
        return
    end

    local branches = vim.split(result.stdout or "", "\n", { trimempty = true })
    if #branches == 0 then
        notify_error("No local branches found.")
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

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

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

---@param file1 string
---@param file2 string
---@param branch1 string
---@param branch2 string
---@param callback fun(path1: string, path2: string)
---@param root string
function M.extract_files(file1, file2, branch1, branch2, callback, root)
    root = root or M.get_repo_root()
    if not root then
        notify_error("Unable to determine Git repository root.")
        return
    end

    if not exists_in_branch(branch1, file1, root) then
        notify_error(("'%s' does not exist on branch '%s'.\nTip: Pick the file from that branch's tree."):format(file1, branch1))
        return
    end

    if not exists_in_branch(branch2, file2, root) then
        notify_error(("'%s' does not exist on branch '%s'.\nTip: Pick the file from that branch's tree."):format(file2, branch2))
        return
    end

    local tmp1 = vim.fn.tempname()
    local tmp2 = vim.fn.tempname()
    local revpath1 = string.format("%s:%s", branch1, file1)
    local revpath2 = string.format("%s:%s", branch2, file2)

    vim.system({ "git", "show", revpath1 }, { text = true, cwd = root }, function(res1)
        if res1.code ~= 0 then
            vim.schedule(function()
                notify_error(("Failed to extract %s:\n%s"):format(revpath1, res1.stderr or "Unknown error"))
            end)
            return
        end

        vim.system({ "git", "show", revpath2 }, { text = true, cwd = root }, function(res2)
            if res2.code ~= 0 then
                vim.schedule(function()
                    notify_error(("Failed to extract %s:\n%s"):format(revpath2, res2.stderr or "Unknown error"))
                end)
                return
            end

            vim.schedule(function()
                vim.fn.writefile(vim.split(res1.stdout or "", "\n"), tmp1)
                vim.fn.writefile(vim.split(res2.stdout or "", "\n"), tmp2)
                callback(tmp1, tmp2)
                vim.fn.delete(tmp1)
                vim.fn.delete(tmp2)
            end)
        end)
    end)
end

M.exists_in_branch = exists_in_branch

return M
