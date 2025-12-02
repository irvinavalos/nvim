return {
    -- {
    --     "webhooked/kanso.nvim",
    --     lazy = false,
    --     priority = 100,
    -- },
    {
        "vague-theme/vague.nvim",
        lazy = false,
        priority = 1000,
        config = function() vim.cmd.colorscheme("vague") end,
    },
}
