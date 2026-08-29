-- lua/custom/langs/typescript.lua

-- 1. 启用 TypeScript 语言服务器
if not Ice.lsp["typescript-language-server"] then
    Ice.lsp["typescript-language-server"] = {}
end
Ice.lsp["typescript-language-server"].enabled = true

-- 2. 添加语法高亮 (Treesitter)
-- 获取 treesitter 的安装列表引用
local ts_parsers = Ice.plugins["nvim-treesitter"].opts.ensure_installed

-- 辅助函数：防止重复添加
local function ensure_parser(parser_name)
    if not vim.tbl_contains(ts_parsers, parser_name) then
        table.insert(ts_parsers, parser_name)
    end
end

ensure_parser("typescript")
ensure_parser("tsx")       -- React 支持
ensure_parser("javascript")
ensure_parser("jsdoc")
