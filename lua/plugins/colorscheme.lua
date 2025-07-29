-- return {
-- 	"webhooked/kanso.nvim",
-- 	name = "kanso",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("kanso").setup({
-- 			transparent = true,
-- 			terminalColors = true,
-- 		})
-- 		vim.cmd.colorscheme("kanso-zen")
-- 	end,
-- }

return {
	"vague2k/vague.nvim",
	name = "vague",
	lazy = false,
	priority = 1000,
	config = function()
		require("vague").setup({
			transparent = true,
		})
		vim.cmd.colorscheme("vague")
	end,
}
