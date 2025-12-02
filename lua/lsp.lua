---@param client vim.lsp.Client
---@param bufnr number
local function on_attach(client, bufnr)
    ---@param lhs string
    ---@param rhs string | function
    ---@param opts string | vim.keymap.set.Opts
    ---@param mode? string | string[]
    local function key(lhs, rhs, opts, mode)
        mode = mode or "n"
        ---@cast opts vim.keymap.set.Opts
        opts = type(opts) == "string" and { desc = opts } or opts
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
    end

    key("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
    key("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

    if client:supports_method("textDocument/codeAction") then
        key("grt", "<Cmd>FzfLua lsp_code_actions<CR>", "vim.lsp.buf.code_action()")
    end
    if client:supports_method("textDocument/references") then
        key("grr", "<Cmd>FzfLua lsp_references<CR>", "vim.lsp.buf.references()")
    end
    if client:supports_method("textDocument/implementation") then
        key("gri", "<Cmd>FzfLua lsp_implementations<CR>", "vim.lsp.buf.implementation()")
    end
    if client:supports_method("textDocument/typeDefinition") then
        key("grt", "<Cmd>FzfLua lsp_typedefs<CR>", "vim.lsp.buf.type_definition()")
    end
    if client:supports_method("textDocument/documentSymbol") then
        key("gO", "<Cmd>FzfLua lsp_document_symbols<CR>", "vim.lsp.buf.document_symbol()")
    end
    if client:supports_method("textDocument/definition") then
        key("gd", "<Cmd>FzfLua lsp_definitions<CR>", "vim.lsp.buf.definition()")
    end
    if client:supports_method("textDocument/declaration") then
        key("gD", "<Cmd>FzfLua lsp_declarations<CR>", "vim.lsp.buf.declaration()")
    end
end

local diagnostic_icons = {
    ERROR = "",
    WARN = "",
    HINT = "",
    INFO = "",
}

vim.diagnostic.config({
    signs = false, -- Disable diagnostics in signcolumn
    virtual_text = {
        prefix = "",
        spacing = 4,
        format = function(diagnostic)
            local msg = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
            if diagnostic.source then msg = string.format("%s %s", msg, diagnostic.source) end
            if diagnostic.code then msg = string.format("%s[%s]", msg, diagnostic.code) end
            return msg .. " "
        end,
    },
    float = {
        style = "minimal",
        border = "rounded",
        source = "if_many",
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format(" %s ", diagnostic_icons[level])
            return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
        end,
    },
})

vim.api.nvim_create_autocmd({ "LspAttach" }, {
    desc = "Configure LSP keymaps",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        on_attach(client, args.buf)
    end,
})

vim.lsp.enable(
    vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
        :map(function(file) return vim.fn.fnamemodify(file, ":t:r") end)
        :totable()
)
