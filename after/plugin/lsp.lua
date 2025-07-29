vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client == nil then
			return
		end
		client.server_capabilities.semanticTokensProvider = nil
		local opts = { buffer = event.buf, silent = true }

		opts.desc = "[C]ode [A]ctions"
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

		opts.desc = "[S]mart [R]ename"
		vim.keymap.set("n", "<leader>sn", vim.lsp.buf.rename, opts)

		opts.desc = "Show line diagnostic"
		vim.keymap.set("n", "K", vim.diagnostic.open_float, opts)

		opts.desc = "Next diagnostic"
		vim.keymap.set("n", "<leader>d]", "<cmd>lua vim.diagnostic.jump({count = 1, float=true})<CR>", opts)

		opts.desc = "Previous diagnostic"
		vim.keymap.set("n", "<leader>d[", "<cmd>lua vim.diagnostic.jump({count = -1, float=true})<CR>", opts)

		-- opts.desc = "[H]over [D]iagnostic"
		-- vim.keymap.set("n", "hd", vim.lsp.buf.hover, opts)

		opts.desc = "Restart LSP"
		vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function(args)
		require("jdtls.jdtls_setup").setup()
	end,
})
