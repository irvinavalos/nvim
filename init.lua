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
vim.opt.scrolloff = 12
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.winborder = "double"
vim.opt.hlsearch = false
vim.opt.updatetime = 100
vim.opt.syntax = "on"
vim.opt.writebackup = false

vim.lsp.enable({ "lua_ls", "pyright", "ruff", "clangd", "texlab", "ts_ls" })

local lsp_log_group = vim.api.nvim_create_augroup("PythonLspDebug", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
	group = lsp_log_group,
	pattern = "*",
	callback = function(args)
		if args.match ~= "python" then
			vim.lsp.set_log_level("warn") -- Switch LSP log level to WARN for non python files
		else
			vim.lsp.set_log_level("debug") -- Switch LSP log level to DEBUG for python files
		end
	end,
})

vim.keymap.set("n", "n", "nzzzv", { desc = "Center next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center half page up" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line selection up", silent = true })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect", silent = true })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect", silent = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })

require("lazy").setup({
	spec = {
		{
			"vyfor/cord.nvim",
			build = ":Cord update",
			event = "VeryLazy",
			opts = { display = { theme = "catppuccin", flavor = "accent" } },
		},
		{
			"webhooked/kanso.nvim",
			priority = 1000,
			opts = {
				transparent = true,
				commentStyle = { italic = true },
				functionStyle = { bold = true },
				keywordStyle = { bold = true },
				statementStyle = { bold = true },
				typeStype = { bold = true },
			},
		},
		{ "nvim-mini/mini.statusline", version = "*", event = "VeryLazy", opts = {} },
		{ "nvim-mini/mini.diff", version = false, event = "VeryLazy", opts = {} },
		{
			"nvim-mini/mini-git",
			version = false,
			event = "VeryLazy",
			config = function()
				require("mini.git").setup()
			end,
		},
		{ "nvim-mini/mini.ai", version = false, event = "VeryLazy", opts = {} },
		{ "nvim-mini/mini.surround", version = false, event = "VeryLazy", opts = {} },
		{
			"ibhagwan/fzf-lua",
			cmd = { "FzfLua" },
			keys = {
				{
					"<leader>.",
					function()
						require("fzf-lua").files()
					end,
					desc = "Files",
				},
				{
					"<leader>,",
					function()
						require("fzf-lua").buffers()
					end,
					desc = "Buffers",
				},
				{
					"<leader>/",
					function()
						require("fzf-lua").grep()
					end,
					desc = "Grep",
				},
				{
					"<leader>fd",
					function()
						require("fzf-lua").lsp_document_diagnostics()
					end,
					desc = "File diagnostics",
				},
			},
			opts = {
				winopts = { preview = { hidden = true } },
				oldfiles = { cwd_only = true, include_current_session = true },
				defaults = { file_icons = false },
			},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			event = "BufRead",
			branch = "main",
			build = ":TSUpdate",
			---@class TSConfig
			opts = {
				ensure_installed = {
					-- Systems
					"bash",
					"make",
					"cmake",
					"dockerfile",
					"zathurarc",
					-- Languages
					"python",
					"lua",
					-- Web
					"html",
					"css",
					"javascript",
					"jsx",
					"typescript",
					"tsx",
					-- Data formats
					"json",
					"yaml",
					"toml",
					-- Git
					"gitignore",
				},
			},
			config = function(_, opts)
				-- install parsers from custom opts.ensure_installed
				if opts.ensure_installed and #opts.ensure_installed > 0 then
					require("nvim-treesitter").install(opts.ensure_installed)
					-- register and start parsers for filetypes
					for _, parser in ipairs(opts.ensure_installed) do
						local filetypes = parser -- In this case, parser is the filetype/language name
						vim.treesitter.language.register(parser, filetypes)

						vim.api.nvim_create_autocmd({ "FileType" }, {
							pattern = filetypes,
							callback = function(event)
								vim.treesitter.start(event.buf, parser)
							end,
						})
					end
				end
			end,
		},
		{
			"saghen/blink.cmp",
			version = "1.*",
			dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
			event = { "InsertEnter" },
			opts = {
				snippets = { preset = "luasnip" },
				signature = { enabled = true },
				completion = {
					menu = { border = "rounded" },
					documentation = { window = { border = "rounded" } },
				},
				sources = { default = { "lsp", "path", "snippets" } },
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
						require("conform").format({ async = true, lsp_format = "fallback" })
						-- require("conform").format({ timeout_ms = 500, lsp_format = "fallback" })
					end,
					desc = "Format buffer",
				},
			},
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					tex = { "tex-fmt" },
				},
			},
		},
		{
			"lervag/vimtex",
			init = function()
				vim.g.tex_flavor = "latex"
				vim.g.vimtex_view_general_viewer = "zathura"
				vim.g.vimtex_compiler_latexmk = {
					options = {
						"-auxdir=build",
					},
				}
				vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
			end,
		},
	},
	ui = { border = "rounded" },
	checker = { enabled = false },
})

vim.cmd.colorscheme("kanso-zen")
