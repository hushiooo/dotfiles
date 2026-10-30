local M = {}

---Callbacks always run on the main loop, never synchronously.
---@param args string[]
---@param cwd string
---@param callback fun(stdout: string|nil, err: string|nil)
local function run(args, cwd, callback)
    local cmd = vim.list_extend({ "git" }, args)
    local ok, spawn_err = pcall(vim.system, cmd, { text = true, cwd = cwd }, function(res)
        vim.schedule(function()
            if res.code == 0 then
                callback(res.stdout or "", nil)
                return
            end
            local stderr = vim.trim(res.stderr or "")
            if stderr == "" then
                stderr = ("git %s exited with code %d"):format(args[1], res.code)
            end
            callback(nil, stderr)
        end)
    end)
    if not ok then
        vim.schedule(function()
            callback(nil, tostring(spawn_err))
        end)
    end
end

---Resolves from the current file's directory, or the cwd for terminal, oil, fugitive and other non-file buffers.
---@param callback fun(root: string|nil, err: string|nil)
function M.repo_root(callback)
    local dir = vim.fn.getcwd()
    local name = vim.api.nvim_buf_get_name(0)
    if vim.bo.buftype == "" and name ~= "" then
        local parent = vim.fs.dirname(name)
        if vim.fn.isdirectory(parent) == 1 then
            dir = parent
        end
    end

    run({ "rev-parse", "--show-toplevel" }, dir, function(stdout)
        if not stdout then
            callback(nil, "Not inside a Git repository.")
            return
        end
        callback(vim.fs.normalize(vim.trim(stdout)), nil)
    end)
end

---Local branches, then remote branches, then tags, with the current branch first.
---@param root string
---@param callback fun(refs: string[]|nil, err: string|nil)
function M.list_refs(root, callback)
    local args = {
        "for-each-ref",
        "--format=%(HEAD)\t%(refname:short)\t%(symref)",
        "refs/heads",
        "refs/remotes",
        "refs/tags",
    }
    run(args, root, function(stdout, err)
        if not stdout then
            callback(nil, err)
            return
        end

        local refs = {}
        for _, line in ipairs(vim.split(stdout, "\n", { trimempty = true })) do
            local head, name, symref = unpack(vim.split(line, "\t", { plain = true }))
            -- Symbolic refs such as origin/HEAD duplicate the branch they point to.
            if symref == "" then
                if head == "*" then
                    table.insert(refs, 1, name)
                else
                    refs[#refs + 1] = name
                end
            end
        end
        callback(refs, nil)
    end)
end

---@param ref string
---@param root string
---@param callback fun(files: string[]|nil, err: string|nil)
function M.list_files(ref, root, callback)
    -- -z keeps paths unquoted; without it git escapes non-ASCII names.
    run({ "ls-tree", "-r", "-z", "--name-only", ref }, root, function(stdout, err)
        if not stdout then
            callback(nil, err)
            return
        end
        callback(vim.split(stdout, "\0", { plain = true, trimempty = true }), nil)
    end)
end

---@param ref string
---@param path string
---@param root string
---@param callback fun(content: string|nil, err: string|nil)
function M.show(ref, path, root, callback)
    run({ "show", ref .. ":" .. path }, root, callback)
end

return M
