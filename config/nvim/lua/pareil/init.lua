local M = {}
local git = require("pareil.git")
local diff = require("pareil.diff")

M.config = {
    delta_width = 120,
}

---@param opts table|nil
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- Main command: branch1 -> file1 (from branch1) -> branch2 -> (auto same path if exists) else file2 picker
function M.open()
    if not git.is_inside_repo() then
        vim.notify("❌ Not inside a Git repository.", vim.log.levels.ERROR)
        return
    end

    git.select_branch("Select first branch", function(branch1)
        git.select_file("Select file from first branch", function(file1)
            git.select_branch("Select second branch", function(branch2)
                -- Fast path: try same path on branch2; if it exists, reuse it.
                if git.exists_in_branch(branch2, file1) then
                    git.extract_files(file1, file1, branch1, branch2, function(tmp1, tmp2)
                        diff.show(tmp1, tmp2, M.config)
                    end)
                else
                    -- Fallback: let the user pick a file from branch2's tree
                    git.select_file("Select file from second branch", function(file2)
                        git.extract_files(file1, file2, branch1, branch2, function(tmp1, tmp2)
                            diff.show(tmp1, tmp2, M.config)
                        end)
                    end, { branch = branch2 })
                end
            end)
        end, { branch = branch1 })
    end)
end

vim.api.nvim_create_user_command("PareilsDiff", M.open, {})

return M
