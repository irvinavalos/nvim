vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then return end
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false -- Disable hover in favor of Pyright
        end
    end,
    desc = "LSP: Disable hover capability from Ruff",
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("General", { clear = true }),
    pattern = "*",
    callback = function() vim.opt.formatoptions:remove({ "c", "r", "o" }) end,
    desc = "Disable new line comment",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 100 }) end,
})
