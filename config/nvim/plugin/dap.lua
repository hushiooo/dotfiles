local dap = require("dap")
local dapui = require("dapui")
local map = vim.keymap.set

dapui.setup({
    layouts = {
        {
            elements = {
                { id = "scopes",      size = 0.45 },
                { id = "stacks",      size = 0.20 },
                { id = "breakpoints", size = 0.20 },
                { id = "watches",     size = 0.15 },
            },
            size = 50,
            position = "left",
        },
        {
            elements = { { id = "repl", size = 1.0 } },
            size = 12,
            position = "bottom",
        },
    },
    controls = {
        enabled = true,
        element = "repl",
        icons = {
            pause = "⏸",
            play = "▶",
            step_into = "↘",
            step_over = "⏭",
            step_out = "↩",
            step_back = "↪",
            run_last = "🔁",
            terminate = "🛑",
        },
    },
    floating = {
        max_height = 0.4,
        max_width = 0.55,
        border = "rounded",
        mappings = { close = { "q", "<Esc>" } },
    },
    render = { indent = 2 },
})

dap.adapters.python = {
    type = "executable",
    command = "uv",
    args = { "run", "python", "-m", "debugpy.adapter" },
}

local log = vim.log.levels

local function find_api_root()
    local cwd = vim.fn.getcwd()
    if cwd:match("[/\\]api$") or cwd == "api" then return cwd end

    local file = vim.fn.expand("%:p")
    local search_start = (file ~= "" and vim.fs.dirname(file)) or cwd
    local api_dir = vim.fs.find("api", { path = search_start, upward = true, type = "directory" })[1]
    if api_dir then return api_dir end

    if vim.fn.isdirectory(cwd .. "/api") == 1 then return cwd .. "/api" end
    return cwd
end

local function rel_to_api_root(abs)
    local root = find_api_root()
    if not root or root == "" then return vim.fn.fnamemodify(abs, ":~:.") end

    local file_path = vim.fs.normalize(abs)
    local root_path = vim.fs.normalize(root)

    if file_path:find(root_path, 1, true) == 1 then
        local rel = file_path:sub(#root_path + 2)
        return rel ~= "" and rel or vim.fs.basename(file_path)
    end

    return vim.fn.fnamemodify(abs, ":~:.")
end

local function python_cwd()
    return find_api_root()
end

local function current_test_node()
    local file = vim.fn.expand("%:p")
    if file == "" then
        vim.notify("Save the file before debugging tests", log.WARN)
        return nil
    end

    local rel = rel_to_api_root(file)
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

    local function get_line(line) return vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1] or "" end

    local function_name
    local function_line = cursor_line
    for line = cursor_line, 1, -1 do
        local text = get_line(line)
        local name = text:match("^%s*async%s+def%s+([%w_]+)") or text:match("^%s*def%s+([%w_]+)")
        if name and name:match("^test") then
            function_name = name
            function_line = line
            break
        end
    end
    if not function_name then return rel end

    local class_name
    for line = function_line - 1, 1, -1 do
        local text = get_line(line)
        local name = text:match("^%s*class%s+([%w_]+)")
        if name and text:match(":%s*$") then
            class_name = name
            break
        end
    end

    if class_name then return string.format("%s::%s::%s", rel, class_name, function_name) end
    return string.format("%s::%s", rel, function_name)
end

local function pytest_args(target)
    local node = target or current_test_node()
    if not node then return { "--dist", "loadscope" } end
    return { "--maxfail=1", "--dist", "loadscope", node }
end

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Pytest: current file",
        module = "pytest",
        args = function()
            local file = vim.fn.expand("%:p")
            return { "--dist", "loadscope", rel_to_api_root(file) }
        end,
        justMyCode = false,
        console = "integratedTerminal",
        cwd = function() return python_cwd() end,
    },
    {
        type = "python",
        request = "launch",
        name = "Pytest: nearest test",
        module = "pytest",
        args = pytest_args,
        justMyCode = false,
        console = "integratedTerminal",
        cwd = function() return python_cwd() end,
    },
    {
        type = "python",
        request = "launch",
        name = "Pytest: prompt node",
        module = "pytest",
        args = function()
            local default = current_test_node()
            local input = vim.fn.input("Pytest node: ", default or rel_to_api_root(vim.fn.expand("%:p")), "file")
            return pytest_args(input ~= "" and input or default)
        end,
        justMyCode = false,
        console = "integratedTerminal",
        cwd = function() return python_cwd() end,
    },
    {
        type = "python",
        request = "launch",
        name = "Launch: current file",
        program = "${file}",
        justMyCode = false,
        console = "integratedTerminal",
    },
    {
        type = "python",
        request = "attach",
        name = "Attach by port",
        connect = function()
            local host = vim.fn.input("Host [127.0.0.1]: ")
            local port = tonumber(vim.fn.input("Port: "))
            return { host = (host ~= "" and host) or "127.0.0.1", port = port }
        end,
        justMyCode = false,
    },
}

local function run_python_config(name)
    local configs = dap.configurations.python or {}
    for _, cfg in ipairs(configs) do
        if cfg.name == name then
            dap.run(cfg)
            return
        end
    end
    vim.notify(string.format("DAP configuration '%s' not found", name), log.WARN)
end

-- DAP UI lifecycle
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- DAP signs
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "󰛨", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticInfo", linehl = "CursorLine" })

-- Keybindings
map("n", "<leader>dd", dap.continue, { desc = "Start/Continue debugger" })
map("n", "<leader>dr", dap.restart, { desc = "Restart session" })
map("n", "<leader>dL", dap.run_last, { desc = "Run last session" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Set conditional breakpoint" })
map("n", "<leader>dbp", function()
    local ok, telescope = pcall(require, "telescope")
    if ok and telescope.extensions and telescope.extensions.dap then
        telescope.extensions.dap.list_breakpoints()
    else
        vim.notify("telescope-dap not available", log.WARN)
    end
end, { desc = "List DAP breakpoints" })
map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
map("n", "<leader>dv", function() require("dap.ui.widgets").hover() end,
    { desc = "Hover variable under cursor" })
map("v", "<leader>dv", function() require("dap.ui.widgets").visual_hover() end,
    { desc = "Hover selected variable" })
map("n", "<leader>dO", dap.step_over, { desc = "Step over" })
map("n", "<leader>di", dap.step_into, { desc = "Step into" })
map("n", "<leader>do", dap.step_out, { desc = "Step out" })
map("n", "<leader>dq", function()
    dap.terminate()
    dapui.close()
end, { desc = "Stop debugging" })

map("n", "<leader>dtf", function() run_python_config("Pytest: current file") end, { desc = "Debug pytest file" })
map("n", "<leader>dtn", function() run_python_config("Pytest: nearest test") end, { desc = "Debug nearest pytest" })
map("n", "<leader>dtp", function() run_python_config("Pytest: prompt node") end, { desc = "Debug pytest node" })
