-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.signcolumn = "yes"

vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.ruler = false
vim.opt.laststatus = 3

vim.opt.pumheight = 15
vim.opt.winborder = "single"
vim.opt.pumborder = "single"

-- Indentation
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Persistence
vim.opt.exrc = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.writebackup = false

-- Timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Misc.
vim.opt.confirm = true
vim.opt.clipboard = "unnamedplus"
