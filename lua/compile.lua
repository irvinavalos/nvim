local M = {}

local state = {
  buf = nil,
  win = nil,
  job = nil,
  term_chan = nil,
  last_cmd = nil,
}

---@param title string
local function win_opts(title)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "single",
    title = " " .. title .. " ",
    title_pos = "center",
  }
end

local function close_win()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

local function kill_job()
  if state.job then
    vim.fn.jobstop(state.job)
    state.job = nil
  end
end

---@param title string
---@return integer buf, integer term_chan
local function open_float(title)
  close_win()
  kill_job()

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "hide"

  -- create a terminal buffer we can write to programmatically
  state.term_chan = vim.api.nvim_open_term(state.buf, {})

  state.win = vim.api.nvim_open_win(state.buf, true, win_opts(title))

  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].winfixbuf = true

  local close = function()
    close_win()
  end
  vim.keymap.set("n", "q", close, { buffer = state.buf, silent = true })
  vim.keymap.set("n", "<esc>", close, { buffer = state.buf, silent = true })

  vim.api.nvim_create_autocmd("VimResized", {
    buffer = state.buf,
    callback = function()
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_set_config(state.win, win_opts(title))
      end
    end,
  })

  return state.buf, state.term_chan
end

---@param output string[]
---@param root string
local function populate_quickfix(output, root)
  -- strip ANSI escapes for errorformat parsing
  local clean = {}
  for _, line in ipairs(output) do
    clean[#clean + 1] = line:gsub("\27%[[%d;]*%a", ""):gsub("\27%[%a", "")
  end

  vim.fn.setqflist({}, " ", {
    title = "make",
    lines = clean,
    efm = vim.o.errorformat,
  })

  -- filter to only keep entries within the project root
  local qf = vim.fn.getqflist()
  local filtered = {}
  for _, entry in ipairs(qf) do
    if entry.valid == 1 and entry.bufnr > 0 then
      local name = vim.api.nvim_buf_get_name(entry.bufnr)
      if name:find(root, 1, true) == 1 then
        filtered[#filtered + 1] = entry
      end
    else
      if #filtered > 0 then
        filtered[#filtered + 1] = entry
      end
    end
  end

  vim.fn.setqflist(filtered, "r")

  local has_errors = false
  for _, entry in ipairs(filtered) do
    if entry.valid == 1 and entry.bufnr > 0 then
      has_errors = true
      break
    end
  end

  if has_errors then
    vim.notify("quickfix populated —  :cn / :cp to navigate", vim.log.levels.WARN)
  end
end

---@param target string
---@param root string
local function run(target, root)
  local cmd = "make -C " .. vim.fn.shellescape(root) .. " " .. target
  local title = "make " .. target
  local _, term_chan = open_float(title)
  local output = {}

  state.job = vim.fn.jobstart(cmd, {
    pty = true,
    on_stdout = function(_, data)
      if not data then
        return
      end
      for _, chunk in ipairs(data) do
        -- accumulate raw output for quickfix (strip \r from pty)
        output[#output + 1] = chunk:gsub("\r", "")
      end
      -- send raw data (with ANSI escapes) to the terminal buffer for display
      vim.schedule(function()
        if state.term_chan then
          local raw = table.concat(data, "\r\n")
          vim.api.nvim_chan_send(term_chan, raw)
        end
        -- auto-scroll to bottom
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          local count = vim.api.nvim_buf_line_count(state.buf)
          pcall(vim.api.nvim_win_set_cursor, state.win, { count, 0 })
        end
      end)
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        -- send status line to terminal
        if state.term_chan then
          local status = code == 0 and "\r\n\r\n✓ PASS" or "\r\n\r\n✗ FAIL (exit " .. code .. ")"
          vim.api.nvim_chan_send(term_chan, status)
        end

        -- update float title
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          local tag = code == 0 and "PASS" or "FAIL"
          vim.api.nvim_win_set_config(state.win, {
            title = " " .. title .. " [" .. tag .. "] ",
            title_pos = "center",
          })
          -- scroll to bottom
          local count = vim.api.nvim_buf_line_count(state.buf)
          pcall(vim.api.nvim_win_set_cursor, state.win, { count, 0 })
        end

        populate_quickfix(output, root)

        state.job = nil
      end)
    end,
  })

  if state.job <= 0 then
    vim.api.nvim_chan_send(term_chan, "Failed to start: " .. cmd)
  end
end

---@return string
local function project_root()
  return vim.fs.root(0, "Makefile") or vim.uv.cwd() --[[@as string]]
end

local function makefile_targets()
  local makefile = project_root() .. "/Makefile"
  local ok, lines = pcall(vim.fn.readfile, makefile)
  if not ok then
    return {}
  end

  local targets = {}
  local seen = {}
  for _, line in ipairs(lines) do
    local phony = line:match("^%.PHONY:%s*(.+)")
    if phony then
      for t in phony:gmatch("%S+") do
        if not seen[t] then
          seen[t] = true
          targets[#targets + 1] = t
        end
      end
    end

    local t = line:match("^([a-zA-Z_][a-zA-Z0-9_-]*)%s*:")
    if t and not seen[t] then
      seen[t] = true
      targets[#targets + 1] = t
    end
  end
  return targets
end

---@param lead string
---@return string[]
local function complete(lead)
  return vim.tbl_filter(function(t)
    return t:find(lead, 1, true) == 1
  end, makefile_targets())
end

function M.setup()
  vim.api.nvim_create_user_command("Compile", function(opts)
    local root = project_root()
    local target
    if opts.args ~= "" then
      target = opts.args
    elseif state.last_cmd then
      target = state.last_cmd --[[@as string]]
    else
      target = "build"
    end
    state.last_cmd = target
    run(target, root)
  end, {
    nargs = "?",
    complete = function(lead)
      return complete(lead)
    end,
    desc = "Run a Makefile target in a floating terminal (default: last command or build)",
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        return
      end
      local ok, cmdline = pcall(vim.fn.getcmdline)
      if not ok then
        return
      end
      local cmd = cmdline:match("^%s*(%S+)")
      if vim.tbl_contains({ "cn", "cp", "cnext", "cprev", "cfirst", "clast", "cc" }, cmd) then
        vim.schedule(function()
          close_win()
        end)
      end
    end,
  })

  vim.api.nvim_create_user_command("CompileLog", function()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_win() -- toggle: if open, close it
      else
        local title = state.last_cmd and ("make " .. state.last_cmd) or "Compile"
        state.win = vim.api.nvim_open_win(state.buf, true, win_opts(title))
        vim.wo[state.win].number = false
        vim.wo[state.win].relativenumber = false
        vim.wo[state.win].signcolumn = "no"
        vim.wo[state.win].winfixbuf = true
        local close = function()
          close_win()
        end
        vim.keymap.set("n", "q", close, { buffer = state.buf, silent = true })
        vim.keymap.set("n", "<esc>", close, { buffer = state.buf, silent = true })
      end
    else
      vim.notify("No compile output available", vim.log.levels.INFO)
    end
  end, { desc = "Toggle the compile output window" })
end

M.setup()

return M
