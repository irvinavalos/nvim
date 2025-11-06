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
vim.g.netrw_liststyle = 3
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require("options")
require("keymaps")
require("autocmds")
require("lsp")

require("lazy").setup({
	spec = {
		{ "NeogitOrg/neogit", dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" } },
		{ "webhooked/kanso.nvim", lazy = false, priority = 1000, opts = {} },
		{ "nvim-mini/mini.icons", lazy = false, version = false, opts = {} },
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
