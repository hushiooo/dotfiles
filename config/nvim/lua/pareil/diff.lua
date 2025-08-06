local ui = require("pareil.ui")

---@param file1 string
---@param file2 string
---@param config table
local function show(file1, file2, config)
    if type(file1) ~= "string" or type(file2) ~= "string" then
        vim.notify("❌ Invalid file paths for diff", vim.log.levels.ERROR)
        return
    end

    local ok1, content1 = pcall(vim.fn.readfile, file1)
    local ok2, content2 = pcall(vim.fn.readfile, file2)

    if not ok1 or not ok2 or not content1 or not content2 then
        vim.notify("❌ Failed to read extracted files", vim.log.levels.ERROR)
        return
    end

    local str1 = table.concat(content1, "\n")
    local str2 = table.concat(content2, "\n")

    local diff_lines = vim.diff(str1, str2, {
        result_type = "unified",
        ctxlen = 3,
    })

    if not diff_lines or diff_lines == "" then
        vim.notify("✅ No differences found.", vim.log.levels.INFO)
        return
    end

    ui.show_popup(vim.split(diff_lines, "\n", { plain = true }), config)
end

return {
    show = show,
}
