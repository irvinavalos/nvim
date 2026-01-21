return {
    "lervag/vimtex",
    init = function()
        vim.g.tex_flavor = "latex"
        vim.g.vimtex_view_general_viewer = "zathura"
        -- vim.g.vimtex_compiler_latexmk = { options = { "-auxdir=build" } }
        -- vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
    end,
}
