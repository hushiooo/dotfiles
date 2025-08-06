local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

--- Checks if inside a Git repository.
function M.is_inside_repo()
    local result = vim.fn.systemlist("git rev-parse --is-inside-work-tree")
    return result[1] == "true"
end

--- Prompts the user to select a file tracked by Git.
---@param prompt string
---@param callback fun(file: string)
function M.select_file(prompt, callback)
    local files = vim.fn.systemlist("git ls-files")

    pickers.new({}, {
        prompt_title = prompt,
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

--- Extracts file contents from Git into temporary files.
---@param file1 string
---@param file2 string
---@param branch1 string
---@param branch2 string
---@param callback fun(path1: string, path2: string)
function M.extract_files(file1, file2, branch1, branch2, callback)
    local tmp1 = vim.fn.tempname()
    local tmp2 = vim.fn.tempname()

    vim.system({ "git", "show", string.format("%s:%s", branch1, file1) }, { text = true }, function(res1)
        if res1.code ~= 0 then
            vim.schedule(function()
                vim.notify("❌ Failed to extract file1: " .. (res1.stderr or "Unknown error"), vim.log.levels.ERROR)
            end)
            return
        end

        vim.system({ "git", "show", string.format("%s:%s", branch2, file2) }, { text = true }, function(res2)
            if res2.code ~= 0 then
                vim.schedule(function()
                    vim.notify("❌ Failed to extract file2: " .. (res2.stderr or "Unknown error"), vim.log.levels.ERROR)
                end)
                return
            end

            vim.schedule(function()
                vim.fn.writefile(vim.split(res1.stdout, "\n"), tmp1)
                vim.fn.writefile(vim.split(res2.stdout, "\n"), tmp2)
                callback(tmp1, tmp2)
            end)
        end)
    end)
end

return M
