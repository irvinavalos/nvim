return {
    -- {
    --     "webhooked/kanso.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require("kanso").setup({
    --             background = { dark = "zen", light = "zen" },
    --             foreground = "saturated",
    --         })
    --         vim.cmd.colorscheme("kanso")
    --     end,
    -- },
    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        lazy = false,
        priority = 1000,
        config = function()
            require("github-theme").setup()
            vim.cmd.colorscheme("github_dark")
        end
    },
    -- {
    --     "oskarnurm/koda.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require("koda").setup({ transparent = true })
    --         vim.cmd.colorscheme("koda-dark")
    --     end
    -- }
}
