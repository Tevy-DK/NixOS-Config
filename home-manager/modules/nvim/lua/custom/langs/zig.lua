-- lua/custom/langs/zig.lua

-- 1. 启用 Zig 语言服务器 (zls)
Ice.lsp["zls"] = {
    enabled = true,
}

-- 2. 添加语法高亮
local ts_parsers = Ice.plugins["nvim-treesitter"].opts.ensure_installed

if not vim.tbl_contains(ts_parsers, "zig") then
    table.insert(ts_parsers, "zig")
end
