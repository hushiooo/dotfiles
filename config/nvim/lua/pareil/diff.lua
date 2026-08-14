local ui = require("pareil.ui")

local DEFAULT_DIFF_OPTS = {
    result_type = "unified",
    ctxlen = 3,
}

---@param content1 string
---@param content2 string
---@param config table
local function show(content1, content2, config)
    local diff_opts = vim.tbl_deep_extend("force", {}, DEFAULT_DIFF_OPTS, (config and config.diff) or {})
    local diff_lines = vim.text.diff(content1, content2, diff_opts)

    if not diff_lines or diff_lines == "" then
        vim.notify("No differences found.", vim.log.levels.INFO)
        return
    end

    ui.show_popup(vim.split(diff_lines, "\n", { plain = true }), config)
end

return {
    show = show,
}
