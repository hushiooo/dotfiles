local dap = require("dap")
local dapui = require("dapui")
local dap_python = require("dap-python")
local map = vim.keymap.set

local function path_exists(path)
    return path and vim.loop.fs_stat(path) ~= nil
end

local function get_start_path()
    local cwd = vim.loop.cwd() or vim.fn.getcwd()
    local bufname = vim.api.nvim_buf_get_name(0)
    return bufname ~= "" and vim.fs.dirname(bufname) or cwd
end

local function find_root(markers)
    local start = get_start_path()
    local root = vim.fs.find(markers, { path = start, upward = true })[1]
    return root and vim.fs.dirname(root) or (vim.loop.cwd() or vim.fn.getcwd())
end

local function get_project_root()
    return find_root({
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "poetry.lock",
        ".git",
    })
end

local function get_repo_root()
    return find_root({ ".git" })
end

local function get_api_root()
    local repo_root = get_repo_root()
    local api_root = repo_root .. "/api"
    if path_exists(api_root .. "/pyproject.toml") then
        return api_root
    end
    return get_project_root()
end

local function has_api_project()
    local repo_root = get_repo_root()
    return path_exists(repo_root .. "/api/pyproject.toml")
end

local function first_existing(paths)
    for _, path in ipairs(paths) do
        if path_exists(path) then
            return path
        end
    end
    return nil
end

local function env_file_for(root, include_tests)
    local candidates = {}
    if include_tests then
        table.insert(candidates, root .. "/tests/.env")
    end
    table.insert(candidates, root .. "/.env")
    return first_existing(candidates)
end

local function get_env_file()
    return env_file_for(get_project_root(), false)
end

local function get_api_env_file()
    return env_file_for(get_api_root(), false) or get_env_file()
end

local function get_api_tests_env_file()
    return env_file_for(get_api_root(), true) or get_env_file()
end

local function get_python_path_for_root(root)
    local python = first_existing({
        root .. "/.venv/bin/python",
        root .. "/venv/bin/python",
        root .. "/.env/bin/python",
        root .. "/.tox/venv/bin/python",
    })
    if python then
        return python
    end

    local function from_env(var)
        local value = vim.env[var]
        if value and value ~= "" then
            local python = value .. "/bin/python"
            if path_exists(python) then
                return python
            end
        end
        return nil
    end

    local env_python = from_env("VIRTUAL_ENV") or from_env("CONDA_PREFIX")
    if env_python then
        return env_python
    end

    local exepath = vim.fn.exepath("python3")
    if exepath ~= "" then
        return exepath
    end
    exepath = vim.fn.exepath("python")
    if exepath ~= "" then
        return exepath
    end
    return "python"
end

local function get_python_path()
    return get_python_path_for_root(get_project_root())
end

local function get_api_python_path()
    return get_python_path_for_root(get_api_root())
end

local function get_adapter_python()
    if has_api_project() then
        return get_api_python_path()
    end
    return get_python_path()
end

local function parse_args(input)
    local args = {}
    local current = {}
    local quote = nil
    local i = 1

    while i <= #input do
        local c = input:sub(i, i)
        if quote then
            if c == quote then
                quote = nil
            elseif c == "\\" and quote == "\"" and i < #input then
                i = i + 1
                table.insert(current, input:sub(i, i))
            else
                table.insert(current, c)
            end
        else
            if c == "'" or c == "\"" then
                quote = c
            elseif c:match("%s") then
                if #current > 0 then
                    table.insert(args, table.concat(current))
                    current = {}
                end
            else
                table.insert(current, c)
            end
        end
        i = i + 1
    end

    if #current > 0 then
        table.insert(args, table.concat(current))
    end
    return args
end

local python_defaults = {
    justMyCode = false,
    console = "integratedTerminal",
    pythonPath = get_python_path,
    cwd = get_project_root,
    envFile = get_env_file,
    subProcess = true,
}

local function apply_python_defaults(config)
    for key, value in pairs(python_defaults) do
        if config[key] == nil then
            config[key] = value
        end
    end
end

local function ensure_python_config(config)
    dap.configurations.python = dap.configurations.python or {}
    for _, existing in ipairs(dap.configurations.python) do
        if existing.name == config.name then
            return
        end
    end
    apply_python_defaults(config)
    table.insert(dap.configurations.python, config)
end

require("nvim-dap-virtual-text").setup({
    commented = true,
    virt_text_pos = "eol",
})

dapui.setup({
    layouts = {
        {
            elements = {
                { id = "scopes",  size = 0.5 },
                { id = "stacks",  size = 0.25 },
                { id = "watches", size = 0.25 },
            },
            size = 50,
            position = "left",
        },
        {
            elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
        },
    },
    controls = {
        enabled = true,
        element = "repl",
    },
    floating = {
        max_height = 0.6,
        max_width = 0.6,
        border = "rounded",
        mappings = { close = { "q", "<Esc>" } },
    },
    render = { indent = 2, max_value_lines = 100 },
})

dap_python.setup(get_adapter_python())
dap_python.test_runner = "pytest"

for _, config in ipairs(dap.configurations.python or {}) do
    apply_python_defaults(config)
end

ensure_python_config({
    type = "python",
    request = "launch",
    name = "Launch: current file",
    program = "${file}",
})

ensure_python_config({
    type = "python",
    request = "launch",
    name = "Launch: current file with args",
    program = "${file}",
    args = function()
        local input = vim.fn.input("Arguments: ")
        return parse_args(input)
    end,
})

ensure_python_config({
    type = "python",
    request = "launch",
    name = "Launch: module",
    module = function()
        return vim.fn.input("Module name: ")
    end,
})

ensure_python_config({
    type = "python",
    request = "launch",
    name = "Launch: module with args",
    module = function()
        return vim.fn.input("Module name: ")
    end,
    args = function()
        local input = vim.fn.input("Arguments: ")
        return parse_args(input)
    end,
})

if has_api_project() then
    local api_defaults = {
        cwd = get_api_root,
        pythonPath = get_api_python_path,
    }
    local api_env = { envFile = get_api_env_file }
    local api_tests_env = { envFile = get_api_tests_env_file }

    ensure_python_config(vim.tbl_extend("force", api_defaults, api_tests_env, {
        type = "python",
        request = "launch",
        name = "Pytest: current file",
        module = "pytest",
        args = function()
            local file = vim.api.nvim_buf_get_name(0)
            if file == "" then
                return {}
            end
            return { "-vv", "-n", "0", file }
        end,
    }))

    ensure_python_config(vim.tbl_extend("force", api_defaults, api_tests_env, {
        type = "python",
        request = "launch",
        name = "Pytest: node id",
        module = "pytest",
        args = function()
            local file = vim.api.nvim_buf_get_name(0)
            local default = file ~= "" and (file .. "::") or ""
            local input = vim.fn.input("Pytest node id: ", default)
            if input == "" then
                return {}
            end
            return { "-vv", "-n", "0", input }
        end,
    }))

    ensure_python_config(vim.tbl_extend("force", api_defaults, api_env, {
        type = "python",
        request = "launch",
        name = "Flask: API (debug)",
        module = "flask",
        args = { "run", "--no-reload" },
        env = {
            FLASK_APP = "application.py",
            FLASK_ENV = "dev",
            FLASK_DEBUG = "true",
        },
    }))
end

ensure_python_config({
    type = "python",
    request = "attach",
    name = "Attach: remote debugger",
    connect = function()
        local host = vim.fn.input("Host [127.0.0.1]: ")
        local port = vim.fn.input("Port [5678]: ")
        return {
            host = host ~= "" and host or "127.0.0.1",
            port = tonumber(port ~= "" and port or "5678"),
        }
    end,
})

ensure_python_config({
    type = "python",
    request = "attach",
    name = "Attach: local process",
    processId = require("dap.utils").pick_process,
})

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "CursorLine", numhl = "DiagnosticOk" })

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

local function load_launchjs()
    local roots = { get_repo_root(), get_project_root() }
    local seen = {}
    for _, root in ipairs(roots) do
        if not seen[root] then
            seen[root] = true
            local launchjs = root .. "/.vscode/launch.json"
            if path_exists(launchjs) then
                require("dap.ext.vscode").load_launchjs(launchjs, { python = { "python" } })
                vim.notify("Loaded " .. launchjs, vim.log.levels.INFO)
                return
            end
        end
    end
    vim.notify("No launch.json found in repo or project root", vim.log.levels.WARN)
end

vim.api.nvim_create_user_command("DapLoadLaunchJSON", load_launchjs, {})

local exception_breakpoints_enabled = false
local function toggle_exception_breakpoints()
    exception_breakpoints_enabled = not exception_breakpoints_enabled
    if exception_breakpoints_enabled then
        dap.set_exception_breakpoints({ "raised", "uncaught" })
        vim.notify("DAP: break on exceptions enabled", vim.log.levels.INFO)
    else
        dap.set_exception_breakpoints({})
        vim.notify("DAP: break on exceptions disabled", vim.log.levels.INFO)
    end
end

map("n", "<leader>dd", dap.continue, { desc = "Start/Continue" })
map("n", "<leader>dq", function()
    dap.terminate()
    dapui.close()
end, { desc = "Stop debugging" })
map("n", "<leader>dr", dap.restart, { desc = "Restart session" })
map("n", "<leader>dR", dap.run_last, { desc = "Run last session" })
map("n", "<leader>dp", dap.pause, { desc = "Pause" })

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dl", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, { desc = "Logpoint" })
map("n", "<leader>dx", dap.clear_breakpoints, { desc = "Clear all breakpoints" })
map("n", "<leader>dX", toggle_exception_breakpoints, { desc = "Toggle exception breakpoints" })

map("n", "<leader>do", dap.step_over, { desc = "Step over" })
map("n", "<leader>di", dap.step_into, { desc = "Step into" })
map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
map("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })
map("n", "<leader>dj", dap.down, { desc = "Go down in stack" })
map("n", "<leader>dk", dap.up, { desc = "Go up in stack" })

map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
map("n", "<leader>de", dapui.eval, { desc = "Eval expression" })
map("v", "<leader>de", dapui.eval, { desc = "Eval selection" })
map("n", "<leader>dE", function()
    dapui.eval(vim.fn.input("Expression: "))
end, { desc = "Eval input expression" })
map("n", "<leader>dL", load_launchjs, { desc = "Load launch.json" })
map("n", "<leader>df", function()
    dapui.float_element("scopes", { enter = true })
end, { desc = "Float scopes" })
map("n", "<leader>dw", function()
    dapui.float_element("watches", { enter = true })
end, { desc = "Float watches" })
map("n", "<leader>dh", function()
    require("dap.ui.widgets").hover()
end, { desc = "Hover variable" })
map("v", "<leader>dh", function()
    require("dap.ui.widgets").visual_hover()
end, { desc = "Hover selection" })

map("n", "<leader>dtn", function()
    dap_python.test_method()
end, { desc = "Debug nearest test" })
map("n", "<leader>dtc", function()
    dap_python.test_class()
end, { desc = "Debug test class" })
map("v", "<leader>ds", function()
    dap_python.debug_selection()
end, { desc = "Debug selection" })

local telescope_ok, telescope = pcall(require, "telescope")
if telescope_ok then
    pcall(function() telescope.load_extension("dap") end)
    map("n", "<leader>dTb", "<cmd>Telescope dap list_breakpoints<cr>", { desc = "List breakpoints" })
    map("n", "<leader>dTc", "<cmd>Telescope dap configurations<cr>", { desc = "List configurations" })
    map("n", "<leader>dTf", "<cmd>Telescope dap frames<cr>", { desc = "List frames" })
    map("n", "<leader>dTv", "<cmd>Telescope dap variables<cr>", { desc = "List variables" })
end
