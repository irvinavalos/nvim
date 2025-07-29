return {
	"saghen/blink.cmp",
	version = "1.*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		snippets = { preset = "mini_snippets" },
		keymap = { preset = "default" },
		appearance = {
			nerd_font_variant = "normal",
		},
		completion = { documentation = { auto_show = true, auto_show_delay_ms = 500 } },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		cmdline = {
			keymap = { preset = "inherit" },
			completion = {
				menu = {
					auto_show = function()
						return vim.fn.getcmdtype() == ":"
					end,
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
