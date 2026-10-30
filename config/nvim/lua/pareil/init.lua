local git = require("pareil.git")
local diff = require("pareil.diff")

local M = {}

M.config = {
    popup = {
        max_width = 120,
        title = "pareil diff",
    },
    -- Options for vim.text.diff; result_type is always "unified".
    diff = {
        ctxlen = 3,
    },
}

---@param opts table|nil
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

local function notify_error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

---@param co thread
local function resume(co, ...)
    local ok, err = coroutine.resume(co, ...)
    if not ok then
        error(debug.traceback(co, err), 0)
    end
end

---Calls `fn(..., callback)` and suspends the running coroutine until the callback fires.
---`fn` must invoke its callback asynchronously.
local function await(fn, ...)
    local co = coroutine.running()
    local n = select("#", ...)
    local args = { ... }
    args[n + 1] = function(...)
        resume(co, ...)
    end
    fn(unpack(args, 1, n + 1))
    return coroutine.yield()
end

---@param prompt string
---@param items string[]
---@param callback fun(choice: string|nil)
local function pick(prompt, items, callback)
    vim.ui.select(items, { prompt = prompt }, function(choice)
        vim.schedule(function()
            callback(choice)
        end)
    end)
end

---Returns nil if the user cancels or git fails; failures are already reported.
---@param label string
---@param refs string[]
---@param root string
---@return pareil.Side|nil
local function pick_side(label, refs, root)
    local ref = await(pick, ("Select %s ref"):format(label), refs)
    if not ref then
        return nil
    end

    local files, err = await(git.list_files, ref, root)
    if not files then
        notify_error(("Failed to list files in %s.\n%s"):format(ref, err))
        return nil
    end
    if #files == 0 then
        notify_error(("No files in %s."):format(ref))
        return nil
    end

    local path = await(pick, ("Select file from %s"):format(ref), files)
    if not path then
        return nil
    end

    local content
    content, err = await(git.show, ref, path, root)
    if not content then
        notify_error(("Failed to read %s:%s.\n%s"):format(ref, path, err))
        return nil
    end

    return { name = ref .. ":" .. path, content = content }
end

local function run()
    local root, err = await(git.repo_root)
    if not root then
        notify_error(err)
        return
    end

    local refs
    refs, err = await(git.list_refs, root)
    if not refs then
        notify_error("Failed to list refs.\n" .. err)
        return
    end
    if #refs == 0 then
        notify_error("No branches or tags found.")
        return
    end

    local a = pick_side("first", refs, root)
    if not a then
        return
    end
    local b = pick_side("second", refs, root)
    if not b then
        return
    end

    diff.show(a, b, M.config)
end

function M.open()
    resume(coroutine.create(run))
end

return M
