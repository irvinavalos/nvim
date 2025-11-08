vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.syntax = "on"
vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.showcmd = false
vim.opt.clipboard = "unnamedplus"
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.updatetime = 100
vim.opt.signcolumn = "yes"
vim.opt.guicursor = ""
vim.opt.winborder = "rounded"

local highlight_group = vim.api.nvim_create_augroup("vimrc-incsearch-highlight", { clear = true })

vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
	group = highlight_group,
	callback = function()
		vim.opt.hlsearch = true
	end,
})

vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
	group = highlight_group,
	callback = function()
		vim.opt.hlsearch = false
	end,
})

vim.keymap.set("n", "n", "nzzzv", { desc = "Center next search result", silent = true })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result", silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center half page up", silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center half page down", silent = true })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move highlighted lines down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move highlighted lines up", silent = true })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect", silent = true })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect", silent = true })

vim.lsp.enable({ "lua_ls", "clangd", "pyright", "ruff" })

local lsp_log_group = vim.api.nvim_create_augroup("PythonLspDebug", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
	group = lsp_log_group,
	pattern = "*",
	callback = function(args)
		if args.match ~= "python" then
			vim.lsp.set_log_level("warn")
		else
			vim.lsp.set_log_level("debug")
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buf = args.buf
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition", buffer = buf })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration", buffer = buf })
	end,
})

require("lazy").setup({
	spec = {
		{ "webhooked/kanso.nvim", lazy = false, priority = 1000 },
		{
			"nvim-mini/mini.surround",
			event = { "InsertEnter" },
			version = false,
			config = function()
				require("mini.surround").setup()
			end,
		},
		{
			"nvim-mini/mini.ai",
			event = { "InsertEnter" },
			version = false,
			config = function()
				require("mini.ai").setup()
			end,
		},
		{
			"ibhagwan/fzf-lua",
			cmd = { "FzfLua" },
			keys = {
				{ "<leader>.", "<Cmd>FzfLua files<CR>", desc = "Files" },
				{ "<leader>,", "<Cmd>FzfLua buffers<CR>", desc = "Buffers" },
				{ "<leader>/", "<Cmd>FzfLua grep<CR>", desc = "Grep" },
				{ "<leader>of", "<Cmd>FzfLua oldfiles<CR>", desc = "Oldfiles" },
			},
			opts = {
				winopts = { preview = { hidden = true } },
				oldfiles = { cwd_only = true, include_current_session = true },
			},
		},
		{
			"saghen/blink.cmp",
			version = "1.*",
			event = { "InsertEnter" },
			opts = {
				completion = {
					menu = { border = "rounded" },
					documentation = { window = { border = "rounded" } },
				},
				sources = {
					default = { "lsp", "path", "snippets" },
				},
			},
		},
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>ff",
					function()
						require("conform").format({ timeout_ms = 500, lsp_format = "fallback" })
					end,
					desc = "Format Buffer",
				},
			},
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
					c = { "clang-format" },
					cpp = { "clang-format" },
				},
			},
		},
		{
			"mfussenegger/nvim-lint",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				local lint = require("lint")
				lint.linters_by_ft = {
					python = { "ruff" },
					c = { "clangtidy" },
					cpp = { "clangtidy" },
				}

				local lint_group = vim.api.nvim_create_augroup("lint", { clear = true })

				vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
					group = lint_group,
					callback = function()
						if vim.bo.modifiable then
							lint.try_lint()
						end
					end,
				})
			end,
		},
	},
	ui = { border = "rounded" },
	checker = { enabled = false },
})

vim.cmd.colorscheme("kanso-zen")
