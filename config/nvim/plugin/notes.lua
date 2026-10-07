-- Notes repo (~/dev/notes): pickers plus the `notes` CLI for anything that
-- creates, deletes or syncs, so nvim and the shell share one implementation.
local root = vim.env.NOTES_ROOT or vim.fn.expand("~/dev/notes")
local cli = root .. "/bin/notes"
if vim.fn.executable(cli) == 0 then
    return
end

local builtin = require("telescope.builtin")
local dir = root .. "/notes"
local map = vim.keymap.set

-- Runs the CLI non-interactively; returns trimmed stdout, or nil after
-- reporting stderr.
local function notes(args)
    local res = vim.system(vim.list_extend({ cli }, args), { text = true, stdin = false }):wait()
    if res.code ~= 0 then
        vim.notify(vim.trim(res.stderr), vim.log.levels.ERROR, { title = "notes" })
        return nil
    end
    local lines = vim.split(vim.trim(res.stdout), "\n")
    return lines[#lines]
end

local function edit(path)
    if path and path ~= "" then
        vim.cmd.edit(vim.fn.fnameescape(path))
    end
end

local function in_notes(path)
    return vim.startswith(path, dir .. "/")
end

map("n", "<leader>nf", function()
    builtin.find_files({ cwd = dir, prompt_title = "Notes" })
end, { desc = "Notes: find" })

map("n", "<leader>ng", function()
    builtin.live_grep({ cwd = dir, prompt_title = "Grep notes" })
end, { desc = "Notes: grep" })

map("n", "<leader>nt", function()
    edit(notes({ "today", "--no-edit" }))
end, { desc = "Notes: today" })

map("n", "<leader>nn", function()
    vim.ui.input({ prompt = "New note: " }, function(title)
        if title and vim.trim(title) ~= "" then
            edit(notes({ "new", "--no-edit", "--", title }))
        end
    end)
end, { desc = "Notes: new" })

map("n", "<leader>na", function()
    vim.ui.input({ prompt = "Inbox: " }, function(text)
        if text and vim.trim(text) ~= "" and notes({ "add", "--", text }) then
            vim.notify("Added to inbox", vim.log.levels.INFO, { title = "notes" })
        end
    end)
end, { desc = "Notes: add to inbox" })

map("n", "<leader>nx", function()
    local path = vim.api.nvim_buf_get_name(0)
    if not in_notes(path) then
        vim.notify("Not a note: " .. path, vim.log.levels.WARN, { title = "notes" })
        return
    end
    local name = path:sub(#dir + 2)
    if vim.fn.confirm("Move " .. name .. " to the trash?", "&Yes\n&No", 2) ~= 1 then
        return
    end
    if notes({ "rm", "--force", path }) then
        vim.cmd.bwipeout({ bang = true })
        vim.notify("Trashed " .. name, vim.log.levels.INFO, { title = "notes" })
    end
end, { desc = "Notes: delete current" })

map("n", "<leader>ns", function()
    vim.cmd("silent! wall")
    vim.notify("Syncing…", vim.log.levels.INFO, { title = "notes" })
    vim.system({ cli, "sync" }, { text = true, stdin = false }, function(res)
        vim.schedule(function()
            local ok = res.code == 0
            vim.notify(
                vim.trim(ok and res.stderr or (res.stderr .. res.stdout)),
                ok and vim.log.levels.INFO or vim.log.levels.ERROR,
                { title = "notes sync" }
            )
            -- prettier may have rewrapped open notes.
            vim.cmd("checktime")
        end)
    end)
end, { desc = "Notes: sync" })
