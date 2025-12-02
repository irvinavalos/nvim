return {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
        { "<leader>.", "<Cmd>FzfLua files<CR>", desc = "Files" },
        { "<leader>,", "<Cmd>FzfLua buffers<CR>", desc = "Buffers" },
        { "<leader>;", "<Cmd>FzfLua tabs<CR>", desc = "Tabs" },
        { "<leader>/", "<Cmd>FzfLua live_grep_native<CR>", desc = "Grep" },
        { "<leader>/", "<Cmd>FzfLua grep_visual<CR>", desc = "Grep cwd", mode = "x" },
        { "<leader>fb", "<Cmd>FzfLua lgrep_curbuf<CR>", desc = "Grep current buffer" },
        { "<leader>fB", "<Cmd>FzfLua blines<CR>", desc = "Grep current buffer" },
        { "<leader>fh", "<Cmd>FzfLua helptags<CR>", desc = "Help" },
        { "<leader>fd", "<Cmd>FzfLua lsp_document_diagnostics<CR>", desc = "File diagnostics" },
        { "<leader>fr", "<Cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
        { "<leader>fc", "<Cmd>FzfLua colorschemes<CR>", desc = "Colorschemes" },
    },
    opts = {
        winopts = { width = 0.55, height = 0.6, preview = { hidden = true } },
        oldfiles = { cwd_only = true, include_current_session = true },
        defaults = { file_icons = true },
    },
}
