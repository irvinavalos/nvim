local icons = require("icons")
local function lsp_diagnostics_count(severity_level)
  if not rawget(vim, "lsp") then
    return 0
  else
    local count = vim.diagnostic.count(0, {severity = severity_level})[severity_level]
    if (count == nil) then
      return 0
    else
      return count
    end
  end
end
local function git_diff(diff_type)
  local gsd = vim.b.gitsigns_status_dict
  if (gsd and gsd[diff_type]) then
    return gsd[diff_type]
  else
    return 0
  end
end
local function mode()
  return string.format("%%#StatusLineMode# %s %%*", vim.api.nvim_get_mode().mode)
end
local function python_env()
  local venv = os.getenv("VIRTUAL_ENV_PROMPT")
  if (venv == nil) then
    return ""
  else
    local venv_str = string.gsub(venv, "%s+", "")
    return string.format("%%#StatusLineMedium# %s%%*", venv_str)
  end
end
local function lsp_active()
  if not rawget(vim, "lsp") then
    return ""
  else
    local curr_buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({bufnr = curr_buf})
    local space = "%#StatusLineMedium# %*"
    if (#clients > 0) then
      return (space .. "%#StatusLineMedium#LSP%* ")
    else
      return ""
    end
  end
end
local function diagnostics_error()
  local count = lsp_diagnostics_count(vim.diagnostic.severity.ERROR)
  if (count > 0) then
    return string.format("%%#StatusLineLspError# %s %s%%*", icons.diagnostics.ERROR, count)
  else
    return ""
  end
end
local function diagnostics_warning()
  local count = lsp_diagnostics_count(vim.diagnostic.severity.WARN)
  if (count > 0) then
    return string.format("%%#StatusLineLspWarn# %s %s%%*", icons.diagnostics.WARN, count)
  else
    return ""
  end
end
local function diagnostics_info()
  local count = lsp_diagnostics_count(vim.diagnostic.severity.INFO)
  if (count > 0) then
    return string.format("%%#StatusLineLspInfo# %s %s%%*", icons.diagnostics.INFO, count)
  else
    return ""
  end
end
local function diagnostics_hint()
  local count = lsp_diagnostics_count(vim.diagnostic.severity.HINT)
  if (count > 0) then
    return string.format("%%#StatusLineLspHint# %s %s%%*", icons.diagnostics.HINT, count)
  else
    return ""
  end
end
local lsp_progress = {client = nil, kind = nil, title = nil, percentage = nil, message = nil}
local statusline_augroup = vim.api.nvim_create_augroup("gmr_statusline", {clear = true})
local function _11_(args)
  if (args.data and args.data.client_id) then
    lsp_progress.client = vim.lsp.get_client_by_id(args.data.client_id)
    lsp_progress.kind = args.data.params.value.kind
    lsp_progress.message = args.data.params.value.message
    lsp_progress.percentage = args.data.params.value.percentage
    lsp_progress.title = args.data.params.value.title
    if (lsp_progress.kind == "end") then
      lsp_progress.title = nil
      local function _12_()
        return vim.cmd.redrawstatus()
      end
      return vim.defer_fn(_12_, 500)
    else
      return vim.cmd.redrawstatus()
    end
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("LspProgress", {group = statusline_augroup, desc = "Update LSP progress bar in statusline", pattern = {"begin", "report", "end"}, callback = _11_})
local function lsp_status()
  if not rawget(vim, "lsp") then
    return ""
  elseif (vim.o.columns < 120) then
    return ""
  elseif (not lsp_progress.client or not lsp_progress.title) then
    return ""
  else
    local title = (lsp_progress.title or "")
    local percentage = ((lsp_progress.percentage and (lsp_progress.percentage .. "%%")) or "")
    local message = (lsp_progress.message or "")
    local lsp_message = string.format("%s", title)
    if (message ~= "") then
      lsp_message = string.format("%s %s", lsp_message, message)
    else
    end
    if (percentage ~= "") then
      lsp_message = string.format("%s %s", lsp_message, percentage)
    else
    end
    return string.format("%%#StatusLineLspMessages#%s%%* ", lsp_message)
  end
end
local function git_diff_added()
  local added = git_diff("added")
  if (added > 0) then
    return string.format("%%#StatusLineGitDiffAdded#+%s%%*", added)
  else
    return ""
  end
end
local function git_diff_changed()
  local changed = git_diff("changed")
  if (changed > 0) then
    return string.format("%%#StatusLineGitDiffChanged#~%s%%*", changed)
  else
    return ""
  end
end
local function git_diff_removed()
  local removed = git_diff("removed")
  if (removed > 0) then
    return string.format("%%#StatusLineGitDiffRemoved#-%s%%*", removed)
  else
    return ""
  end
end
local function git_branch_icon()
  return "%#StatusLineGitBranchIcon#\239\144\152%*"
end
local function git_branch()
  local branch = vim.b.gitsigns_head
  if ((branch == "") or (branch == nil)) then
    return ""
  else
    return string.format("%%#StatusLineMedium#%s%%*", branch)
  end
end
local function full_git()
  local full = ""
  local space = "%#StatusLineMedium# %*"
  local branch = git_branch()
  if (branch ~= "") then
    local icon = git_branch_icon()
    full = (full .. space .. icon .. space .. branch .. space)
  else
  end
  local added = git_diff_added()
  if (added ~= "") then
    full = (full .. added .. space)
  else
  end
  local changed = git_diff_changed()
  if (changed ~= "") then
    full = (full .. changed .. space)
  else
  end
  local removed = git_diff_removed()
  if (removed ~= "") then
    full = (full .. removed .. space)
  else
  end
  return full
end
local function file_percentage()
  local curr_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_line_count(0)
  return string.format("%%#StatusLineMedium# \238\152\146 %d%%%% %%*", math.ceil(((curr_line / lines) * 100)))
end
local function total_lines()
  local lines = vim.fn.line("$")
  return string.format("%%#StatusLineMedium#of %s %%*", lines)
end
local function cursor_position()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1]
  local col = (pos[2] + 1)
  return string.format("%%#StatusLineMedium# %d:%d %%*", line, col)
end
local function formatted_filetype(hlgroup)
  local filetype = (vim.bo.filetype or vim.fn.expand("%:e", false))
  return string.format("%%#%s# %s %%*", hlgroup, filetype)
end
local function filename()
  local name = vim.fn.expand("%:t")
  if (name == "") then
    name = "[No Name]"
  else
  end
  return string.format("%%#StatusLineMedium# %s %%*", name)
end
StatusLine = {}
local function _27_()
  return table.concat({formatted_filetype("StatusLineMode")})
end
StatusLine.inactive = _27_
local readable_filetypes = {qf = true, help = true, tsplayground = true}
local function _28_()
  local mode_str = vim.api.nvim_get_mode().mode
  if ((mode_str == "t") or (mode_str == "nt")) then
    return table.concat({mode(), "%=", "%=", file_percentage(), total_lines()})
  elseif (readable_filetypes[vim.bo.filetype] or (vim.o.modifiable == false)) then
    return table.concat({formatted_filetype("StatusLineMode"), "%=", "%=", file_percentage(), total_lines()})
  else
    return table.concat({mode(), filename(), full_git(), "%=", "%=", "%S", lsp_status(), diagnostics_error(), diagnostics_warning(), diagnostics_hint(), diagnostics_info(), lsp_active(), python_env(), cursor_position(), file_percentage(), total_lines()})
  end
end
StatusLine.active = _28_
vim.opt.statusline = "%!v:lua.StatusLine.active()"
local function _30_()
  vim.opt_local.statusline = "%!v:lua.StatusLine.inactive()"
  return nil
end
return vim.api.nvim_create_autocmd({"WinEnter", "BufEnter", "FileType"}, {group = statusline_augroup, pattern = {"NvimTree_1", "NvimTree", "TelescopePrompt", "fzf", "lspinfo", "lazy", "netrw", "mason", "noice", "qf"}, callback = _30_})
