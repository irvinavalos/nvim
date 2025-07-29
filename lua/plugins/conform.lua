return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "[F]ormat [F]ile",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			tex = { "tex-fmt" },
			md = { "prettier" },
			python = {
				"ruff_fix",
				"ruff_format",
				"ruff_organize_imports",
			},
			java = { "google-java-format" },
			jsonc = { "prettier" },
			json = { "prettier" },
		},
	},
}
