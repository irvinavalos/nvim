vim.loader.enable()

-- Disable external providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
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

-- General
vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.showcmd = false

-- Tabs/Indentation
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Searching
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- Visuals
vim.opt.termguicolors = true
vim.opt.winborder = "single"
vim.opt.signcolumn = "yes"
vim.opt.showmatch = true

-- Files
vim.opt.writebackup = false
vim.opt.swapfile = false

-- LSP
-- vim.lsp.enable({ "texlab", "html", "cssls", "ts_ls" })

-- "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
-- "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
-- "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
-- "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
-- "grt" is mapped in Normal mode to |vim.lsp.buf.type_definition()|
-- "gO" is mapped in Normal mode to |vim.lsp.buf.document_symbol()|
-- - CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|

vim.api.nvim_create_autocmd("LspAttach", {
	once = true,
	callback = function()
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })
	end,
})

require("lazy").setup({
	defaults = { lazy = true },
	spec = {
		{ "webhooked/kanso.nvim", priority = 1000 },
		{ "nvim-treesitter/nvim-treesitter", branch = "master", lazy = false, build = ":TSUpdate" },
		{ "nvim-mini/mini.nvim", version = false, event = "VeryLazy" },
		{ "saghen/blink.cmp", version = "1.*", event = "InsertEnter" },
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			---@module "conform"
			---@type conform.setupOpts
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					html = { "prettier" },
					css = { "prettier" },
					javascript = { "prettier" },
					latex = { "tex-fmt" },
				},
				default_format_opts = { lsp_format = "fallback" },
				formatters = { shfmt = { append_args = { "-i", "2" } } },
			},
		},
		{
			"mfussenegger/nvim-lint",
			event = "BufWritePost",
			config = function()
				require("lint").linters_by_ft = {
					python = { "ruff" },
					c = { "clangtidy" },
					cpp = { "clangtidy" },
					html = { "eslint" },
					css = { "eslint" },
				}
				vim.api.nvim_create_autocmd("BufWritePost", {
					callback = function()
						require("lint").try_lint()
					end,
				})
			end,
		},
	},
	ui = { border = "rounded" },
	change_detection = { notify = false },
	performance = { rtp = { disabled_plugins = {
		"gzip",
		"tutor",
		"tarPlugin",
		"zipPlugin",
		"tohtml",
	} } },
})

vim.cmd.colorscheme("kanso-zen")

vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		require("blink.cmp").setup({
			completion = {
				menu = { border = "rounded" },
				documentation = { window = { border = "rounded" } },
			},
			sources = { default = { "lsp", "path", "snippets" } },
			snippets = { preset = "mini_snippets" },
			signature = { enabled = true },
		})
	end,
})

-- Appearance/Visuals
require("mini.snippets").setup()
require("mini.icons").setup()
require("mini.hipatterns").setup()

-- Text
require("mini.surround").setup()
require("mini.ai").setup()

-- Workflow
require("mini.git").setup()
require("mini.diff").setup()
require("mini.pick").setup()
require("mini.statusline").setup()

-- Treesitter


-- Centered navigation
vim.keymap.set("n", "n", "nzzzv", { desc = "Center next search result", silent = true })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result", silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center half page up", silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center half page down", silent = true })

-- Window resizing
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height", silent = true })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height", silent = true })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width", silent = true })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width", silent = true })

-- Text handling
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect", silent = true })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect", silent = true })

-- Formatting
vim.keymap.set("n", "<leader>ff", function()
	require("conform").format({ async = true })
end, { desc = "Format file" })

-- Pickers
vim.keymap.set("n", "<leader>.", "<Cmd>lua MiniPick.builtin.files()<CR>", { desc = "Files", silent = true })
vim.keymap.set("n", "<leader>,", "<Cmd>lua MiniPick.builtin.buffers()<CR>", { desc = "Buffers", silent = true })
vim.keymap.set("n", "<leader>/", "<Cmd>lua MiniPick.builtin.grep()<CR>", { desc = "Grep", silent = true })
