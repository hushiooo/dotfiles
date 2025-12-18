local dap = require("dap")
local dapui = require("dapui")
local dap_python = require("dap-python")
local map = vim.keymap.set

require("nvim-dap-virtual-text").setup({
    commented = true,
    virt_text_pos = "eol",
})

dapui.setup({
    layouts = {
        {
            elements = {
                { id = "scopes", size = 0.5 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
            },
            size = 50,
            position = "left",
        },
        {
            elements = {
                { id = "repl", size = 0.5 },
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

dap_python.setup("python")
dap_python.test_runner = "pytest"

for _, config in ipairs(dap.configurations.python or {}) do
    config.justMyCode = false
    config.console = "integratedTerminal"
end

table.insert(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Launch: current file",
    program = "${file}",
    justMyCode = false,
    console = "integratedTerminal",
    cwd = "${workspaceFolder}",
})

table.insert(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Launch: current file with args",
    program = "${file}",
    args = function()
        local input = vim.fn.input("Arguments: ")
        return vim.split(input, " ", { trimempty = true })
    end,
    justMyCode = false,
    console = "integratedTerminal",
    cwd = "${workspaceFolder}",
})

table.insert(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Launch: module",
    module = function()
        return vim.fn.input("Module name: ")
    end,
    justMyCode = false,
    console = "integratedTerminal",
    cwd = "${workspaceFolder}",
})

table.insert(dap.configurations.python, {
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
    justMyCode = false,
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
