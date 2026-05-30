local colors = {
    bg = "#11111B",
    fg = "#c3ccdc",
    fg_dim = "#a1aab8",
    mode_normal = "#828697",
    mode_insert = "#c3ccdc",
    mode_visual = "#ae81ff",
    mode_replace = "#ff5874",
    mode_fg = "#092236",
}

vim.api.nvim_set_hl(0, "StatusLineModeNormal", { fg = colors.mode_fg, bg = colors.mode_normal, bold = true })
vim.api.nvim_set_hl(0, "StatusLineModeInsert", { fg = colors.mode_fg, bg = colors.mode_insert, bold = true })
vim.api.nvim_set_hl(0, "StatusLineModeVisual", { fg = colors.mode_fg, bg = colors.mode_visual, bold = true })
vim.api.nvim_set_hl(0, "StatusLineModeReplace", { fg = colors.mode_fg, bg = colors.mode_replace, bold = true })
vim.api.nvim_set_hl(0, "StatusLineModeCommand", { fg = colors.mode_fg, bg = colors.mode_normal, bold = true })

vim.api.nvim_set_hl(0, "StatusLineMedium", { fg = colors.fg, bg = colors.bg })
vim.api.nvim_set_hl(0, "StatusLineGitBranchIcon", { fg = "#A6D4DE", bg = colors.bg })
vim.api.nvim_set_hl(0, "StatusLineGitDiffAdded", { fg = "#addb67", bg = colors.bg })
vim.api.nvim_set_hl(0, "StatusLineGitDiffChanged", { fg = "#e2b93d", bg = colors.bg })
vim.api.nvim_set_hl(0, "StatusLineGitDiffRemoved", { fg = "#ff5874", bg = colors.bg })
vim.api.nvim_set_hl(0, "StatusLineLspMessages", { fg = colors.fg_dim, bg = colors.bg })

local function diagnostics()
    if not rawget(vim, "lsp") then return "" end
    local status = vim.diagnostic.status()
    if status == "" then return "" end
    return string.format("%%#StatusLineMedium# %s%%*", status)
end

local function git_diff(diff_type)
    local gsd = vim.b.gitsigns_status_dict
    if gsd and gsd[diff_type] then return gsd[diff_type] end
    return 0
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

local function python_env()
    local venv = os.getenv("VIRTUAL_ENV_PROMPT")
    if not venv then
        local path = os.getenv("VIRTUAL_ENV")
        if not path then return "" end
        venv = vim.fn.fnamemodify(path, ":t")
    end
    local venv_str = string.gsub(venv, "%s+", "")
    return string.format("%%#StatusLineMedium# (%s)%%*", venv_str)
end

local function lsp_active()
    if not rawget(vim, "lsp") then return "" end
    local curr_buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = curr_buf })
    local space = "%#StatusLineMedium# %*"
    if #clients > 0 then return space .. "%#StatusLineMedium#LSP%* " end
    return ""
end

local function filetype()
    local ft = vim.bo.filetype
    if ft == "" then return "" end

    local icon, icon_hl = require("mini.icons").get("filetype", ft)

    if icon_hl then
        local fg = vim.api.nvim_get_hl(0, { name = icon_hl })
        if fg.fg then
            vim.api.nvim_set_hl(0, "StatusLine" .. icon_hl, { fg = ("#%06x"):format(fg.fg), bg = colors.bg })
            return string.format("%%#StatusLine%s#%s %%#StatusLineMedium#%s%%*", icon_hl, icon, ft)
        end
    end

    return string.format("%%#StatusLineMedium#%s%%*", ft)
end

local lsp_progress = { client = nil, kind = nil, title = nil, percentage = nil, message = nil }

local statusline_augroup = vim.api.nvim_create_augroup("gmr_statusline", { clear = true })

vim.api.nvim_create_autocmd("LspProgress", {
    group = statusline_augroup,
    desc = "Update LSP progress bar in statusline",
    pattern = { "begin", "report", "end" },
    callback = function(args)
        if not (args.data and args.data.client_id) then return end
        lsp_progress.client = vim.lsp.get_client_by_id(args.data.client_id)
        lsp_progress.kind = args.data.params.value.kind
        lsp_progress.message = args.data.params.value.message
        lsp_progress.percentage = args.data.params.value.percentage
        lsp_progress.title = args.data.params.value.title
        if lsp_progress.kind == "end" then
            lsp_progress.title = nil
            vim.defer_fn(function() vim.cmd.redrawstatus() end, 500)
        else
            vim.cmd.redrawstatus()
        end
    end,
})

local function lsp_status()
    if vim.startswith(vim.api.nvim_get_mode().mode, "i") then return "" end
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
    if message ~= "" then lsp_message = string.format("%s %s", lsp_message, message) end
    if percentage ~= "" then lsp_message = string.format("%s %s", lsp_message, percentage) end
    return string.format("%%#StatusLineLspMessages#%s%%* ", lsp_message)
end

local function git_diff_added()
    local added = git_diff("added")
    if added > 0 then return string.format("%%#StatusLineGitDiffAdded#+%s%%*", added) end
    return ""
end

local function git_diff_changed()
    local changed = git_diff("changed")
    if changed > 0 then return string.format("%%#StatusLineGitDiffChanged#~%s%%*", changed) end
    return ""
end

local function git_diff_removed()
    local removed = git_diff("removed")
    if removed > 0 then return string.format("%%#StatusLineGitDiffRemoved#-%s%%*", removed) end
    return ""
end

local function git_branch_icon() return "%#StatusLineGitBranchIcon#\239\144\152%*" end

local function git_branch()
    local branch = vim.b.gitsigns_head
    if branch == "" or branch == nil then return "" end
    return string.format("%%#StatusLineMedium#%s%%*", branch)
end

local function full_git()
    local full = ""
    local space = "%#StatusLineMedium# %*"
    local branch = git_branch()
    if branch ~= "" then
        local icon = git_branch_icon()
        full = full .. space .. icon .. space .. branch .. space
    end
    local added = git_diff_added()
    if added ~= "" then full = full .. added .. space end
    local changed = git_diff_changed()
    if changed ~= "" then full = full .. changed .. space end
    local removed = git_diff_removed()
    if removed ~= "" then full = full .. removed .. space end
    return full
end

local function file_percentage()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    return string.format("%%#StatusLineMedium# \238\152\146 %d%%%% %%*", math.ceil((curr_line / lines) * 100))
end

local function total_lines()
    local lines = vim.fn.line("$")
    return string.format("%%#StatusLineMedium#of %s %%*", lines)
end

local function cursor_position()
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = pos[1]
    local col = pos[2] + 1
    return string.format("%%#StatusLineMedium# %d:%d %%*", line, col)
end

local function formatted_filetype(hlgroup)
    local file_type = vim.bo.filetype or vim.fn.expand("%:e", false)
    return string.format("%%#%s# %s %%*", hlgroup, file_type)
end

local function filename()
    local name = vim.fn.expand("%:t")
    if name == "" then name = "[No Name]" end
    return string.format("%%#StatusLineMedium# %s %%*", name)
end

StatusLine = {}

local readable_filetypes = { qf = true, help = true }

function StatusLine.inactive() return table.concat({ formatted_filetype("StatusLineMode") }) end

function StatusLine.active()
    local mode_str = vim.api.nvim_get_mode().mode
    if mode_str == "t" or mode_str == "nt" then
        return table.concat({
            mode(),
            "%=",
            "%=",
            file_percentage(),
            total_lines(),
        })
    elseif readable_filetypes[vim.bo.filetype] or vim.o.modifiable == false then
        return table.concat({
            formatted_filetype("StatusLineMode"),
            "%=",
            "%=",
            file_percentage(),
            total_lines(),
        })
    end
    return table.concat({
        mode(),
        filename(),
        full_git(),
        "%=",
        "%=",
        "%S",
        lsp_status(),
        diagnostics(),
        lsp_active(),
        filetype(),
        python_env(),
        cursor_position(),
        file_percentage(),
        total_lines(),
    })
end

vim.opt.statusline = "%!v:lua.StatusLine.active()"

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
    group = statusline_augroup,
    pattern = { "netrw", "qf", "help", "mini-pick" },
    callback = function() vim.opt_local.statusline = "%!v:lua.StatusLine.inactive()" end,
})
