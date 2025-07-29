return {
	"lervag/vimtex",
	lazy = false,
	ft = { "tex" },
	init = function()
		vim.g.vimtex_view_method = "zathura"
	end,
}
