vim.loader.enable()

---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-doc-name

-- LSP
vim.lsp.enable({ "lua_ls", "clangd", "pyright", "ruff" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })

-- General
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.showcmd = false
vim.opt.writebackup = false
vim.opt.swapfile = false

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
vim.opt.winborder = "rounded"
vim.opt.signcolumn = "yes"
vim.opt.showmatch = true
vim.opt.showmode = false

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

require("lazy").setup({
	defaults = { lazy = false },
	spec = {
		{ "webhooked/kanso.nvim" },
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			-- ft = { "html", "css", "javascript", "typescript", "tsx" },
			branch = "master",
			build = ":TSUpdate",
			opts = {
				auto_install = false,
				highlight = {
					enable = true,
					disable = function(_, buf)
						local max = 100 * 1024
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						return ok and stats and stats.size > max
					end,
				},
			},
			config = function(_, opts)
				require("nvim-treesitter.configs").setup(opts)
			end,
		},
		{
			"nvim-mini/mini.nvim",
			-- version = false,
			-- lazy = true,
			event = "VeryLazy",
			config = function()
				require("mini.surround").setup()
				require("mini.ai").setup()
			end,
		},
		{
			"ibhagwan/fzf-lua",
			event = "VeryLazy",
			cmd = "FzfLua",
			keys = {
				{ "<leader>.", "<Cmd>FzfLua files<CR>", desc = "Find files" },
				{ "<leader>,", "<Cmd>FzfLua buffers<CR>", desc = "Find buffers" },
				{ "<leader>/", "<Cmd>FzfLua grep<CR>", desc = "Grep" },
			},
			opts = { winopts = { preview = { hidden = "hidden" } } },
		},
		{
			"saghen/blink.cmp",
			event = "InsertEnter",
			opts = {
				completion = {
					menu = { border = "rounded" },
					documentation = { window = { border = "rounded" } },
				},
				sources = { default = { "lsp", "path", "snippets" } },
			},
		},
		{
			"stevearc/conform.nvim",
			keys = {
				{
					"<leader>ff",
					function()
						require("conform").format({ async = true })
					end,
					desc = "Format Buffer",
				},
			},
			---@module "conform"
			---@type conform.setupOpts
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					latex = { "tex-fmt" },
				},
			},
		},
		{
			"mfussenegger/nvim-lint",
			event = { "InsertLeave" },
			opts = {
				linters_by_ft = {
					python = { "ruff" },
					c = { "clangtidy" },
					cpp = { "clangtidy" },
					html = { "eslint" },
					css = { "eslint" },
				},
				linters = {},
			},
			config = function(_, opts)
				local lint = require("lint")
				lint.linters_by_ft = opts.linters_by_ft
				if opts.linters then
					for name, l in pairs(opts.linters) do
						lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name] or {}, l)
					end
				end

				vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
					callback = function()
						lint.try_lint()
					end,
				})
			end,
		},
	},
	ui = { border = "rounded" },
	change_detection = { notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tutor",
				"tarPlugin",
				"zipPlugin",
				"tohtml",
				"matchparen",
			},
		},
	},
})

vim.cmd.colorscheme("kanso-zen")

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
