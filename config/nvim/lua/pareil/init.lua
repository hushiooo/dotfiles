local M = {}
local git = require("pareil.git")
local diff = require("pareil.diff")

M.config = {
    popup = {
        max_width = 120,
        border = "rounded",
        title = "pareil.nvim diff",
        title_pos = "center",
        close_mappings = { "q" },
    },
    diff = {
        result_type = "unified",
        ctxlen = 3,
    },
}

---@param opts table|nil
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.open()
    local root = git.get_repo_root()
    if not root then
        vim.notify("Not inside a Git repository.", vim.log.levels.ERROR)
        return
    end

    git.select_branch("Select first branch", function(branch1)
        git.select_file("Select file from first branch", function(file1)
            git.select_branch("Select second branch", function(branch2)
                git.select_file("Select file from second branch", function(file2)
                    git.extract_files(file1, file2, branch1, branch2, function(tmp1, tmp2)
                        diff.show(tmp1, tmp2, M.config)
                    end, root)
                end, { branch = branch2, root = root })
            end, { root = root })
        end, { branch = branch1, root = root })
    end, { root = root })
end

return M
