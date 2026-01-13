return {
    {
        "webhooked/kanso.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("kanso").setup({
                background = { dark = "zen", light = "zen" },
                foreground = "saturated",
            })
            vim.cmd.colorscheme("kanso")
        end,
    },
    -- {
    --     "yorumicolors/yorumi.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("yorumi") end,
    -- },
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("tokyonight-night") end,
    -- },
    -- {
    --     "catppuccin/nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("catppuccin-mocha") end,
    -- },
    -- {
    --     "EdenEast/nightfox.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("nordfox") end,
    -- },
    -- {
    --     "loctvl842/monokai-pro.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require("monokai-pro").setup()
    --         vim.cmd.colorscheme("monokai-pro")
    --     end,
    -- },
    -- {
    --     "bluz71/vim-moonfly-colors",
    --     lazy = false,
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("moonfly") end,
    -- },
    -- {
    --     "rose-pine/neovim",
    --     name = "rose-pine",
    --     config = function() vim.cmd("colorscheme rose-pine") end,
    -- },
    -- {
    --     "vague-theme/vague.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("vague") end,
    -- },
}
