return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    event = "BufRead",
    branch = "main",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            -- Systems
            "bash",
            "make",
            "cmake",
            "dockerfile",
            "zathurarc",
            -- Languages
            "python",
            -- Web
            "html",
            "css",
            "javascript",
            "typescript",
            "tsx",
            -- Data formats
            "json",
            "json5",
            "jsonc",
            "yaml",
            "toml",
            -- Git
            "gitignore",
            "gitcommit",
            -- Misc
            "markdown",
            "markdown_inline",
        },
        highlight = { enable = true },
        indent = { enable = true, disable = { "yaml" } },
    },
    config = function(_, opts) -- install parsers from custom opts.ensure_installed
        require("nvim-treesitter").setup()
        if opts.ensure_installed and #opts.ensure_installed > 0 then
            require("nvim-treesitter").install(opts.ensure_installed)
            for _, parser in ipairs(opts.ensure_installed) do -- register and start parsers for filetypes
                local filetypes = parser -- in this case, parser is the filetype/language name
                vim.treesitter.language.register(parser, filetypes)
                vim.api.nvim_create_autocmd({ "FileType" }, {
                    pattern = filetypes,
                    callback = function(event) vim.treesitter.start(event.buf, parser) end,
                })
            end
        end
    end,
}
