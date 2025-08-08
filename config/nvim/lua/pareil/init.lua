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

function M.open()
    git.select_file("Select first file", function(file1)
        git.select_file("Select second file", function(file2)
            git.select_branch("Select first branch", function(branch1)
                git.select_branch("Select second branch", function(branch2)
                    git.extract_files(file1, file2, branch1, branch2, function(tmp1, tmp2)
                        diff.show(tmp1, tmp2, M.config)
                    end)
                end)
            end)
        end)
    end)
end

vim.api.nvim_create_user_command("PareilsDiff", M.open, {})

return M
