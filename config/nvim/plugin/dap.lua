local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
    layouts = {
        {
            elements = {
                { id = "repl",        size = 0.30 },
                { id = "breakpoints", size = 0.20 },
                { id = "stacks",      size = 0.25 },
                { id = "watches",     size = 0.25 },
            },
            size = 50,
            position = "left",
        },
        {
            elements = {
                { id = "scopes", size = 1.0 },
            },
            size = 15,
            position = "bottom",
        },
    },
    controls = {
        enabled = true,
        element = "scopes",
        icons = {
            pause = "⏸",
            play = "▶",
            step_into = "↘",
            step_over = "⏭",
            step_out = "↩",
            step_back = "⏪",
            run_last = "🔁",
            terminate = "🛑",
        },
    },
    floating = {
        max_height = 0.4,
        max_width = 0.5,
        border = "rounded",
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    render = {
        indent = 2,
    },
})

dap.adapters.python = {
    type = "executable",
    command = "uv",
    args = { "run", "python", "-m", "debugpy.adapter" },
}

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Debug current test file",
        module = "pytest",
        args = function()
            local file = vim.fn.expand("%:p")
            local rel = vim.fn.fnamemodify(file, ":.:s?^api/??")
            return { "--dist", "loadscope", rel }
        end,
        justMyCode = false,
        console = "integratedTerminal",
        cwd = "api",
    },
}

-- DAP UI lifecycle
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- Sign definitions
vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "🔵", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "👉", texthl = "DiagnosticInfo", linehl = "CursorLine" })

-- Keybindings
vim.keymap.set("n", "<leader>dd", dap.continue, { desc = "Start debugger" })
vim.keymap.set("n", "<leader>dbp", function()
    require("telescope").extensions.dap.list_breakpoints()
end, { desc = "List DAP breakpoints" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Set conditional breakpoint" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dv", function()
    require("dap.ui.widgets").hover()
end, { desc = "Hover variable under cursor" })
vim.keymap.set("v", "<leader>dv", function()
    require("dap.ui.widgets").visual_hover()
end, { desc = "Hover selected variable" })
vim.keymap.set("n", "<leader>dO", dap.step_over, { desc = "Step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out" })
vim.keymap.set("n", "<leader>dq", function()
    dap.terminate()
    dapui.close()
end, { desc = "Stop debugging" })
