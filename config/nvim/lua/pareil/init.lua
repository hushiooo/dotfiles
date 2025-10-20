local M = {}
local git = require("pareil.git")
local diff = require("pareil.diff")

M.config = {
    delta_width = 120, -- legacy alias for popup.max_width
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
    opts = opts or {}

    if opts.delta_width and (not opts.popup or not opts.popup.max_width) then
        opts = vim.tbl_deep_extend("force", { popup = { max_width = opts.delta_width } }, opts)
    end

    M.config = vim.tbl_deep_extend("force", vim.deepcopy(M.config), opts)

    if not (M.config.popup and M.config.popup.max_width) and M.config.delta_width then
        M.config.popup = M.config.popup or {}
        M.config.popup.max_width = M.config.delta_width
    end

    if M.config.popup and M.config.popup.max_width then
        M.config.delta_width = M.config.popup.max_width
    end
end

-- Main command: branch1 -> file1 (from branch1) -> branch2 -> file2 (from branch2) -> diff
function M.open()
    if not git.is_inside_repo() then
        vim.notify("❌ Not inside a Git repository.", vim.log.levels.ERROR)
        return
    end

    git.select_branch("Select first branch", function(branch1)
        git.select_file("Select file from first branch", function(file1)
            git.select_branch("Select second branch", function(branch2)
                git.select_file("Select file from second branch", function(file2)
                    git.extract_files(file1, file2, branch1, branch2, function(tmp1, tmp2)
                        diff.show(tmp1, tmp2, M.config)
                    end)
                end, { branch = branch2 })
            end)
        end, { branch = branch1 })
    end)
end

vim.api.nvim_create_user_command("PareilsDiff", M.open, {})

return M
