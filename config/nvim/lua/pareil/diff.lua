local ui = require("pareil.ui")

local M = {}

---@class pareil.Side
---@field name string
---@field content string

---@param a pareil.Side
---@param b pareil.Side
---@return boolean
local function is_binary(a, b)
    return a.content:find("\0", 1, true) ~= nil or b.content:find("\0", 1, true) ~= nil
end

---@param a pareil.Side
---@param b pareil.Side
---@param config table
function M.show(a, b, config)
    if a.content == b.content then
        vim.notify("No differences found.", vim.log.levels.INFO)
        return
    end

    if is_binary(a, b) then
        vim.notify(("Binary files %s and %s differ."):format(a.name, b.name), vim.log.levels.INFO)
        return
    end

    local opts = vim.tbl_extend("force", config.diff, { result_type = "unified" })
    local hunks = vim.text.diff(a.content, b.content, opts)
    if hunks == "" then
        vim.notify("No differences found.", vim.log.levels.INFO)
        return
    end

    local lines = { "--- " .. a.name, "+++ " .. b.name }
    vim.list_extend(lines, vim.split(hunks, "\n", { plain = true, trimempty = true }))
    ui.show_popup(lines, config.popup)
end

return M
