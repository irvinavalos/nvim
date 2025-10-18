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

vim.g.mapleader = " " -- Defaults
vim.g.maplocalleader = "\\"
vim.g.loaded_node_provider = 0 -- Disable providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.ignorecase = true -- Turn on ignorecase
vim.opt.smartcase = true -- Turn on smartcase
vim.opt.scrolloff = 10 -- Number of lines to keep below and above cursor (scrolloff)
vim.opt.nu = true -- Turn on line numbers
vim.opt.relativenumber = true -- Turn on relative line numbers
vim.opt.wrap = false -- Turn off text wrapping
vim.opt.termguicolors = true -- Enable terminal colors
vim.opt.splitbelow = true -- Split window below the current one
vim.opt.splitright = true -- Vertical split window to the right of the current one
vim.opt.showcmd = false -- Turn off show command in the last line of screen
vim.opt.clipboard = "unnamedplus" -- Use clipboard register + quoteplus
vim.opt.undofile = true -- Save undo history to an undo file @ $XDG_STATE_HOME/nvim/undo
vim.opt.softtabstop = 2 -- Tab settings
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true -- 'Smart' indent?
vim.opt.swapfile = false -- Turn off swapfile
vim.opt.updatetime = 50 -- Set updatime time
vim.opt.signcolumn = "yes" -- Always have sign column enabled
vim.opt.guicursor = "" -- Disable cursor styling
vim.opt.winborder = "rounded" -- Rounded window borders
vim.opt.hlsearch = false -- Disable search highlighting

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

vim.lsp.enable({ "lua_ls", "pyright", "ruff", "clangd", "texlab", "html", "cssls", "ts_ls" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })

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

require("lazy").setup({
	spec = {
		{ "webhooked/kanso.nvim", lazy = false, priority = 1000, opts = { transparent = true } },
		{
			"nvim-mini/mini.ai",
			version = false,
			event = "VeryLazy",
			opts = {},
		},
		{
			"nvim-mini/mini.surround",
			version = false,
			event = "VeryLazy",
			opts = {},
		},
		{
			"nvim-mini/mini.snippets",
			version = false,
			event = "VeryLazy",
			opts = {},
		},
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
			"folke/lazydev.nvim",
			ft = { "lua" },
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		{
			"saghen/blink.cmp",
			version = "1.*",
			event = { "InsertEnter" },
			opts = {
                snippets = { preset = "mini_snippets" },
				signature = { enabled = true },
				completion = {
					menu = { border = "rounded" },
					documentation = { window = { border = "rounded" } },
					ghost_text = { enabled = false },
				},
				sources = {
					default = { "lsp", "path", "snippets", "lazydev" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							score_offset = 100,
						},
					},
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
			"mfussenegger/nvim-lint",
			event = { "BufReadPost", "BufNewFile" },
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
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "master",
			build = ":TSUpdate",
			lazy = false,
			config = function()
				---@diagnostic disable: missing-fields
				require("nvim-treesitter.configs").setup({
					ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python" },
					auto_install = false,
					ignore_install = { "latex" },
					highlight = { enable = true },
				})
			end,
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
		{
			"L3MON4D3/LuaSnip",
			ft = { "tex" },
			version = "v2.*",
			config = function()
				local ls = require("luasnip")

				ls.config.set_config({
					history = false,
					enable_autosnippets = true,
					-- store_selection_keys = "<Tab>",
				})

				-- vim.cmd([[
				--                 imap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
				--                 smap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
				--             ]])

				vim.keymap.set(
					"",
					"<leader>sr",
					"<Cmd>lua require('luasnip.loaders.from_lua').lazy_load({paths = '~/.config/nvim/LuaSnip/'})<CR><Cmd>echo 'Snippets reloaded'<CR>",
					{ desc = "Reloaded snippets" }
				)

				_G.s = ls.snippet
				_G.sn = ls.snippet_node
				_G.t = ls.text_node
				_G.i = ls.insert_node
				_G.f = ls.function_node
				_G.d = ls.dynamic_node
				_G.fmt = require("luasnip.extras.fmt").fmt
				_G.fmta = require("luasnip.extras.fmt").fmta
				_G.rep = require("luasnip.extras").rep

				---@diagnostic disable: assign-type-mismatch
				require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/LuaSnip/" })
			end,
		},
	},
	ui = { border = "rounded" },
	checker = { enabled = false },
})

vim.cmd.colorscheme("kanso-zen")

if true then
    print("Hello")
end
