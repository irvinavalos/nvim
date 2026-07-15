local function get_hl(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local reverse = hl.reverse or false
  local fg = hl.fg and ("#%06x"):format(hl.fg) or nil
  local bg = hl.bg and ("#%06x"):format(hl.bg) or nil
  if reverse then
    return { fg = bg, bg = fg }
  end
  return { fg = fg, bg = bg }
end

local function set_statusline_highlights()
  local sl = get_hl("StatusLine")
  local normal = get_hl("Normal")

  local sl_bg = normal.bg or "#1c1c1c"
  local sl_fg = sl.fg or normal.fg or "#c0c0c0"
  local dim_fg = get_hl("Comment").fg or "#808080"

  local normal_bg = get_hl("Function").fg or "#808080"
  local insert_bg = get_hl("String").fg or "#a0a0a0"
  local visual_bg = get_hl("Keyword").fg or "#ae81ff"
  local replace_bg = get_hl("DiagnosticError").fg or "#ff5874"
  local mode_fg = normal.bg or "#000000"

  local git_icon_fg = get_hl("Special").fg or "#88c0d0"
  local diff_add_fg = get_hl("DiagnosticOk").fg or get_hl("String").fg or "#addb67"
  local diff_change_fg = get_hl("DiagnosticWarn").fg or "#e2b93d"
  local diff_remove_fg = get_hl("DiagnosticError").fg or "#ff5874"

  local error_fg = get_hl("DiagnosticError").fg or "#ff5874"
  local warn_fg = get_hl("DiagnosticWarn").fg or "#e2b93d"
  local info_fg = get_hl("DiagnosticInfo").fg or "#88c0d0"
  local hint_fg = get_hl("DiagnosticHint").fg or "#808080"

  vim.api.nvim_set_hl(0, "StatusLineModeNormal", { fg = mode_fg, bg = normal_bg, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineModeInsert", { fg = mode_fg, bg = insert_bg, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineModeVisual", { fg = mode_fg, bg = visual_bg, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineModeReplace", { fg = mode_fg, bg = replace_bg, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineModeCommand", { fg = mode_fg, bg = normal_bg, bold = true })

  vim.api.nvim_set_hl(0, "StatusLineMedium", { fg = sl_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineGitBranch", { fg = git_icon_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineGitAdd", { fg = diff_add_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineGitChange", { fg = diff_change_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineGitRemove", { fg = diff_remove_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineLspMessages", { fg = dim_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineDiagError", { fg = error_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineDiagWarn", { fg = warn_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineDiagInfo", { fg = info_fg, bg = sl_bg })
  vim.api.nvim_set_hl(0, "StatusLineDiagHint", { fg = hint_fg, bg = sl_bg })

  vim.api.nvim_set_hl(0, "StatusLine", { fg = sl_fg, bg = sl_bg })
end

local mode_hl_map = {
  n = "StatusLineModeNormal",
  i = "StatusLineModeInsert",
  v = "StatusLineModeVisual",
  V = "StatusLineModeVisual",
  ["\22"] = "StatusLineModeVisual",
  R = "StatusLineModeReplace",
  c = "StatusLineModeCommand",
  t = "StatusLineModeNormal",
}

local function mode()
  local m = vim.api.nvim_get_mode().mode
  local hl_group = mode_hl_map[m] or "StatusLineModeNormal"
  return string.format("%%#%s# %s %%*", hl_group, m)
end

local function filename()
  local name = vim.fn.expand("%:t")
  if name == "" then
    name = "[no name]"
  end
  return string.format("%%#StatusLineMedium# %s%%*", name)
end

local function git_info()
  local dict = vim.b.gitsigns_status_dict
  if not dict then
    return ""
  end

  local parts = {}
  if dict.head and dict.head ~= "" then
    table.insert(parts, string.format("|%%#StatusLineGitBranch# %s%%*", dict.head))
  end
  if dict.added and dict.added > 0 then
    table.insert(parts, string.format("%%#StatusLineGitAdd#+%d%%*", dict.added))
  end
  if dict.changed and dict.changed > 0 then
    table.insert(parts, string.format("%%#StatusLineGitChange#~%d%%*", dict.changed))
  end
  if dict.removed and dict.removed > 0 then
    table.insert(parts, string.format("%%#StatusLineGitRemove#-%d%%*", dict.removed))
  end

  if #parts == 0 then
    return ""
  end
  return "%#StatusLineMedium# %*" .. table.concat(parts, " ") .. " "
end

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local parts = {}

  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warnings = counts[vim.diagnostic.severity.WARN] or 0
  local info = counts[vim.diagnostic.severity.INFO] or 0
  local hints = counts[vim.diagnostic.severity.HINT] or 0

  if errors > 0 then
    table.insert(parts, string.format("%%#StatusLineDiagError# %d%%*", errors))
  end
  if warnings > 0 then
    table.insert(parts, string.format("%%#StatusLineDiagWarn# %d%%*", warnings))
  end
  if info > 0 then
    table.insert(parts, string.format("%%#StatusLineDiagInfo# %d%%*", info))
  end
  if hints > 0 then
    table.insert(parts, string.format("%%#StatusLineDiagHint# %d%%*", hints))
  end

  if #parts == 0 then
    return ""
  end
  return table.concat(parts, " ") .. " "
end

local function python_env()
  local venv = os.getenv("VIRTUAL_ENV_PROMPT")
  if not venv then
    local path = os.getenv("VIRTUAL_ENV")
    if not path then
      return ""
    end
    venv = vim.fn.fnamemodify(path, ":t")
  end
  local venv_str = string.gsub(venv, "%s+", "")
  return string.format("%%#StatusLineMedium# (%s)%%*", venv_str)
end

local function lsp_active()
  if not rawget(vim, "lsp") then
    return ""
  end

  local curr_buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = curr_buf })

  if #clients > 0 then
    return "%#StatusLineMedium# lsp+ |%*"
  end
  return ""
end

local lsp_progress = { client = nil, kind = nil, title = nil, percentage = nil, message = nil }

set_statusline_highlights()

local statusline_augroup = vim.api.nvim_create_augroup("gmr_statusline", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = statusline_augroup,
  callback = set_statusline_highlights,
})

vim.api.nvim_create_autocmd("LspProgress", {
  group = statusline_augroup,
  desc = "Update LSP progress in statusline",
  pattern = { "begin", "report", "end" },
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    lsp_progress.client = vim.lsp.get_client_by_id(args.data.client_id)
    lsp_progress.kind = args.data.params.value.kind
    lsp_progress.message = args.data.params.value.message
    lsp_progress.percentage = args.data.params.value.percentage
    lsp_progress.title = args.data.params.value.title
    if lsp_progress.kind == "end" then
      lsp_progress.title = nil
      vim.defer_fn(function()
        vim.cmd.redrawstatus()
      end, 500)
    else
      vim.cmd.redrawstatus()
    end
  end,
})

local function lsp_status()
  if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
    return ""
  end
  if not rawget(vim, "lsp") then
    return ""
  elseif vim.o.columns < 120 then
    return ""
  elseif not lsp_progress.client or not lsp_progress.title then
    return ""
  end
  local title = lsp_progress.title or ""
  local percentage = (lsp_progress.percentage and (lsp_progress.percentage .. "%%")) or ""
  local message = lsp_progress.message or ""
  local lsp_message = string.format("%s", title)
  if message ~= "" then
    lsp_message = string.format("%s %s", lsp_message, message)
  end
  if percentage ~= "" then
    lsp_message = string.format("%s %s", lsp_message, percentage)
  end
  return string.format("%%#StatusLineLspMessages#%s%%* ", lsp_message)
end

local function cursor_position()
  local pos = vim.api.nvim_win_get_cursor(0)
  return string.format("%%#StatusLineMedium# 󰍒 %d:%d %%*", pos[1], pos[2] + 1)
end

local function formatted_filetype(hlgroup)
  local file_type = vim.bo.filetype or vim.fn.expand("%:e", false)
  return string.format("%%#%s# %s %%*", hlgroup, file_type)
end

---@class StatusLine
StatusLine = {}

local readable_filetypes = { qf = true, help = true }

function StatusLine.inactive()
  return table.concat({ formatted_filetype("StatusLineMode") })
end

function StatusLine.active()
  local mode_str = vim.api.nvim_get_mode().mode

  if mode_str == "t" or mode_str == "nt" then
    return table.concat({
      mode(),
      "%=",
      "%=",
    })
  elseif readable_filetypes[vim.bo.filetype] or vim.o.modifiable == false then
    return table.concat({
      formatted_filetype("StatusLineMode"),
      "%=",
      "%=",
    })
  end

  return table.concat({
    mode(),
    filename(),
    git_info(),
    "%=",
    "%=",
    lsp_status(),
    diagnostics(),
    lsp_active(),
    python_env(),
    cursor_position(),
  })
end

vim.opt.statusline = "%!v:lua.StatusLine.active()"

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
  group = statusline_augroup,
  pattern = { "netrw", "qf", "help", "fzf" },
  callback = function()
    vim.opt_local.statusline = "%!v:lua.StatusLine.inactive()"
  end,
})
