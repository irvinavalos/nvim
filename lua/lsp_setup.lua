local function key(lhs, rhs, opts, bufnr)
  local mode = "n"
  local key_opts = (((type(opts) == "string") and {desc = opts}) or opts)
  key_opts.buffer = bufnr
  return vim.keymap.set(mode, lhs, rhs, key_opts)
end
local function on_attach(client, bufnr)
  if client:supports_method("textDocument/codeAction") then
    key("gca", "<cmd>FzfLua lsp_code_actions<CR>", "vim.lsp.buf.code_action()", bufnr)
  else
  end
  if client:supports_method("textDocument/references") then
    key("grr", "<cmd>FzfLua lsp_references<CR>", "vim.lsp.buf.references()", bufnr)
  else
  end
  if client:supports_method("textDocument/implementation") then
    key("gri", "<cmd>FzfLua lsp_implementations<CR>", "vim.lsp.buf.implementation()", bufnr)
  else
  end
  if client:supports_method("textDocument/typeDefinition") then
    key("grt", "<cmd>FzfLua lsp_typedefs<CR>", "vim.lsp.buf.type_definition()", bufnr)
  else
  end
  if client:supports_method("textDocument/definition") then
    key("gd", "<cmd>FzfLua lsp_definitions<CR>", "vim.lsp.buf.definition()", bufnr)
  else
  end
  if client:supports_method("textDocument/declaration") then
    return key("gD", "<cmd>FzfLua lsp_declarations<CR>", "vim.lsp.buf.declaration()", bufnr)
  else
    return nil
  end
end
local function _7_(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client then
    return on_attach(client, args.buf)
  else
    return nil
  end
end
vim.api.nvim_create_autocmd({"LspAttach"}, {desc = "Configure LSP keymaps", callback = _7_})
local function _9_(...)
  local tbl_26_ = {}
  local i_27_ = 0
  for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local val_28_ = vim.fn.fnamemodify(file, ":t:r")
    if (nil ~= val_28_) then
      i_27_ = (i_27_ + 1)
      tbl_26_[i_27_] = val_28_
    else
    end
  end
  return tbl_26_
end
vim.lsp.enable(_9_(...))
local diagnostic_icons = {ERROR = "\239\129\151  ", WARN = "\239\129\177  ", HINT = "\239\131\171  ", INFO = "\239\129\154  "}
local function _11_(diagnostic)
  local sources = {["Lua Diagnostics."] = "lua", ["Lua Syntax Check."] = "lua"}
  local msg = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
  if diagnostic.source then
    msg = (string.format("%s %s", msg, sources[diagnostic.source]) or diagnostic.source())
  else
  end
  if diagnostic.code then
    msg = string.format("%s[%s]", msg, diagnostic.code)
  else
  end
  return (msg .. " ")
end
local function _14_(diagnostic)
  local level = vim.diagnostic.severity[diagnostic.severity]
  local prefix = string.format(" %s ", diagnostic_icons.level)
  return prefix, ("Diagnostic" .. string.gsub(level, "^%l", string.upper))
end
return vim.diagnostic.config({status = {format = {["vim.diagnostic.severity.ERROR"] = diagnostic_icons.ERROR, ["vim.diagnostic.severity.WARN"] = diagnostic_icons.WARN, ["vim.diagnostic.severity.INFO"] = diagnostic_icons.INFO, ["vim.diagnostic.severity.HINT"] = diagnostic_icons.HINT}}, virtual_text = {prefix = "", spacing = 2, format = _11_}, float = {source = "if_many", prefix = _14_}, signs = false})
