return {
	"ibhagwan/fzf-lua",
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			"ivy",
			winopts = {
				preview = {
					hidden = "hidden",
				},
			},
		})

		local map = vim.keymap

		-- Personal

		map.set("n", "<leader>.", fzf.files, { desc = "Find Files" })
		map.set("n", "<leader>,", fzf.buffers, { desc = "Open Buffers" })
		map.set("n", "<leader>/", fzf.live_grep, { desc = "Grep" })
		map.set("n", "<leader>oc", function()
			fzf.files({
				cwd = vim.fn.stdpath("config"),
				prompt = "NVIM Config $ ",
				-- winopts = { height = 0.85, width = 0.7 },
			})
		end, { desc = "[O]pen [C]onfig" })

		-- Grep

		map.set("n", "<leader>gb", fzf.lgrep_curbuf, { desc = "[G]rep [B]uffer" })
		map.set("n", "<leader>gw", fzf.grep_cword, { desc = "[G]rep [W]ord" })

		-- LSP / Diagnostics

		map.set("n", "gR", fzf.lsp_references, { desc = "[G]oto [R]eferences" })
		map.set("n", "gd", fzf.lsp_definitions, { desc = "[G]oto [D]efinitions" })
		map.set("n", "gD", fzf.lsp_declarations, { desc = "[G]oto [D]eclarations" })
		map.set("n", "gi", fzf.lsp_implementations, { desc = "[G]oto [I]mplementations" })
		map.set("n", "gt", fzf.lsp_typedefs, { desc = "[G]oto [T]ype Definitions" })
		map.set("n", "<leader>sD", fzf.diagnostics_document, { desc = "[S]how [D]iagnostics" })

		-- Misc.

		map.set("n", "<leader>ss", fzf.spell_suggest, { desc = "[S]pell [S]uggest" })
		map.set("n", "<leader>sc", fzf.spellcheck, { desc = "[S]pell [C]heck" })
	end,
}
