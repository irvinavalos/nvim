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

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.o
local key = vim.keymap.set

-- Basic Settings

opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.scrolloff = 10
opt.sidescrolloff = 8

-- Indentation

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search Settings

opt.ignorecase = true
opt.smartcase = true
-- opt.hlsearch = false
opt.incsearch = true

-- Visual Settings

opt.winborder = "rounded"
opt.cursorline = true
opt.signcolumn = "yes"
opt.statuscolumn = " %s %l %r "
opt.showmatch = true
opt.termguicolors = true
opt.guicursor = "n-c-v:block-nCursor"
opt.cmdheight = 0

-- File Settings

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = false
opt.updatetime = 300
opt.autoread = true
opt.autowrite = false
opt.fileencoding = "utf8"

-- Behavior Settings

opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Centered Screen Jumps

key("n", "n", "nzzzv", { desc = "Next search result (centered)" })
key("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
key("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
key("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer Navigation

key("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
key("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
key("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })
key("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })

-- Line Movement

key("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
key("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
key("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line selection down", silent = true })
key("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line selection up", silent = true })

-- Visual Mode Indentation

key("v", "<", "<gv", { desc = "Indent left and reselect", silent = true })
key("v", ">", ">gv", { desc = "Indent right and reselect", silent = true })

-- Quick Config Edit

key("n", "<leader>ec", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit Config", silent = true })

-- LSP

vim.lsp.enable({ "lua_ls", "pyright", "ruff", "texlab", "html", "cssls", "clangd", "tinymist", "ts_ls" })

key("n", "<leader>li", ":checkhealth vim.lsp<CR>", { desc = "LSP Info", silent = true })

vim.diagnostic.config({
	virtual_text = false,
	update_in_insert = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

require("lazy").setup({
	spec = {
		{ "webhooked/kanso.nvim", lazy = false, priority = 1000, config = true, opts = { transparent = false } },
		{ "echasnovski/mini.nvim", version = false },
		{ "chomosuke/typst-preview.nvim", ft = "typst", version = "1.*", opts = {} },
		-- { "andweeb/presence.nvim", event = "VeryLazy" },
		{
			"saghen/blink.cmp",
			version = "1.*",
			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				snippets = { preset = "mini_snippets" },
				keymap = { preset = "default" },
				appearance = {
					nerd_font_variant = "mono",
				},
				completion = { documentation = { auto_show = false } },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" },
		},
		{
			"stevearc/conform.nvim",
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>ff",
					function()
						require("conform").format({ async = true })
					end,
					mode = "",
					desc = "Format File",
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
					html = { "prettier" },
					css = { "prettier" },
					javascript = { "prettier" },
					typst = { "typstyle" },
					latex = { "tex-fmt" },
				},
				default_format_opts = {
					lsp_format = "fallback",
				},
				formatters = {
					shfmt = {
						prepend_args = { "-i", "2" },
					},
				},
			},
			init = function()
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},
		{
			"mfussenegger/nvim-lint",
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			config = function()
				require("lint").linters_by_ft = {
					python = { "ruff" },
					c = { "clangtidy" },
					cpp = { "clangtidy" },
					html = { "eslint" },
					css = { "eslint" },
				}
				vim.api.nvim_create_autocmd({ "BufWritePost" }, {
					callback = function()
						require("lint").try_lint()
					end,
				})
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "master",
			lazy = false,
			build = ":TSUpdate",
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"c",
						"lua",
						"vim",
						"vimdoc",
						"query",
						"markdown",
						"markdown_inline",
						-- Personal
						"latex",
						"typst",
						"bash",
						"regex",
						"cpp",
						"python",
						"html",
						"css",
						"javascript",
						"typescript",
					},
					ignore_install = {},
					sync_install = false,
					auto_install = false,
					modules = {},
					highlight = {
						enable = true,
						disable = function(_, buf)
							local max_filesize = 100 * 1024 -- 100 KB
							local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
							if ok and stats and stats.size > max_filesize then
								return true
							end
						end,
						additional_vim_regex_highlighting = false,
					},
				})
			end,
		},
		{
			"folke/noice.nvim",
			dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
			event = "VeryLazy",
			opts = {},
		},
		{
			"catgoose/nvim-colorizer.lua",
			lazy = true,
			cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerReloadAllBuffers" },
			opts = {},
		},
		{
			"windwp/nvim-ts-autotag",
			ft = { "jsx", "html" },
			config = function()
				require("nvim-ts-autotag").setup({
					opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
				})
			end,
		},
		-- {
		-- 	"rachartier/tiny-inline-diagnostic.nvim",
		-- 	event = "VeryLazy",
		-- 	priority = 1000,
		-- 	config = function()
		-- 		require("tiny-inline-diagnostic").setup({ preset = "minimal" })
		-- 	end,
		-- },
	},
	ui = { border = "rounded", size = { width = 0.7, height = 0.7 } },
	install = { colorscheme = { "kanso" } },
	checker = { enabled = false },
	change_detection = { notify = false },
})

vim.cmd.colorscheme("kanso-zen")

require("mini.snippets").setup()
require("mini.icons").setup()
-- require("mini.statusline").setup()
require("mini.diff").setup()
require("mini.pick").setup()
require("mini.extra").setup()
require("mini.surround").setup()
require("mini.ai").setup()
-- require("mini.pairs").setup()

key("n", "<leader>.", ":Pick files<CR>", { desc = "Find Files", silent = true })
key("n", "<leader>,", ":Pick buffers<CR>", { desc = "Open Buffers", silent = true })
key("n", "<leader>/", ":Pick grep_live<CR>", { desc = "Live Grep", silent = true })
key("n", "<leader>xx", ":Pick diagnostic<CR>", { desc = "Show Diagnostics", silent = true })

key("n", "<leader>cc", ":ColorizerToggle<CR>", { desc = "Toggle Colorizer", silent = true })

require("notify").setup({
	background_colour = "#000000",
})

-- require("noice").setup({
-- 	lsp = {
-- 		override = {
-- 			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
-- 			["vim.lsp.util.stylize_markdown"] = true,
-- 		},
-- 	},
-- 	presets = {
-- 		bottom_search = true,
-- 		command_palette = true,
-- 		long_message_to_split = true,
-- 		inc_rename = false,
-- 		lsp_doc_border = true,
-- 	},
-- })

vim.keymap.set("n", "<leader>tw", function()
	vim.cmd("w")
	local file = vim.fn.expand("%:p")
	local cwd = vim.fn.expand("%:p:h")

	local id = vim.fn.jobstart(
		{ "typst", "watch", file },
		{ cwd = cwd, stdout = "null", stderr = "null", detach = true }
	)

	if id > 0 then
		vim.notify("Typst watch started (PID " .. id .. ")")
	else
		vim.notify("Failed to start typst watch", vim.log.levels.ERROR)
	end
end, { desc = "Typst Watch File (detached job)" })
