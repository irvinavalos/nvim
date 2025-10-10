vim.schedule(function()
	if not vim.lsp.get_clients({ name = "clangd", bufnr = 0 })[1] then
		vim.lsp.enable("clangd")
	end
end)
