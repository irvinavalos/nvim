vim.loader.enable(true)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require("options")
require("keymaps")
require("autocmds")
require("terminal")
require("lsp")

local icons = require("icons")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { "webhooked/kanso.nvim", opts = { italics = false } },
        { "nvim-mini/mini.diff", version = false, event = "VeryLazy", opts = {} },
        { "nvim-mini/mini.ai", version = false, event = "VeryLazy", opts = {} },
        { "nvim-mini/mini.surround", version = false, event = "VeryLazy", opts = {} },
        { "nvim-mini/mini.statusline", version = false, event = "VeryLazy", opts = {} },
        {
            "ibhagwan/fzf-lua",
            cmd = "FzfLua",
            keys = {
                {
                    "<leader>.",
                    "<Cmd>FzfLua files<CR>",
                    desc = "Files",
                },
                {
                    "<leader>,",
                    "<Cmd>FzfLua buffers<CR>",
                    desc = "Buffers",
                },
                {
                    "<leader>;",
                    "<Cmd>FzfLua tabs<CR>",
                    desc = "Tabs",
                },
                {
                    "<leader>/",
                    "<Cmd>FzfLua live_grep_native<CR>",
                    desc = "Grep",
                },
                {
                    "<leader>/",
                    "<Cmd>FzfLua grep_visual<CR>",
                    desc = "Grep cwd",
                    mode = "x",
                },
                {
                    "<leader>fb",
                    "<Cmd>FzfLua lgrep_curbuf<CR>",
                    desc = "Grep current buffer",
                },
                {
                    "<leader>fB",
                    "<Cmd>FzfLua blines<CR>",
                    desc = "Grep current buffer",
                },
                {
                    "<leader>fh",
                    "<Cmd>FzfLua helptags<CR>",
                    desc = "Help",
                },
                {
                    "<leader>fd",
                    "<Cmd>FzfLua lsp_document_diagnostics<CR>",
                    desc = "File diagnostics",
                },
                {
                    "<leader>fr",
                    "<Cmd>FzfLua oldfiles<CR>",
                    desc = "Recent files",
                },
                {
                    "<leader>fc",
                    "<Cmd>FzfLua colorschemes<CR>",
                    desc = "Colorschemes",
                },
            },
            opts = {
                winopts = { width = 0.55, height = 0.6, preview = { hidden = true } },
                oldfiles = { cwd_only = true, include_current_session = true },
                defaults = { file_icons = false },
            },
        },
        {
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
                    "jsx",
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
                            callback = function(event)
                                vim.treesitter.start(event.buf, parser)
                            end,
                        })
                    end
                end
            end,
        },
        {
            "saghen/blink.cmp",
            version = "1.*",
            dependencies = { "L3MON4D3/LuaSnip" },
            event = "InsertEnter",
            opts = {
                keymap = {
                    ["<C-u>"] = { "scroll_documentation_up" },
                    ["<C-d>"] = { "scroll_documentation_down" },
                },
                snippets = { preset = "luasnip" },
                completion = {
                    list = { selection = { preselect = false, auto_insert = false }, max_items = 8 },
                    documentation = { window = { border = "rounded" }, auto_show = false },
                    menu = {
                        border = "rounded",
                        scrollbar = false,
                        draw = {
                            columns = {
                                { "kind_icon", "label", gap = 1 },
                                { "kind" },
                            },
                        },
                    },
                },
                cmdline = { enabled = true },
                appearance = { kind_icons = icons.symbol_kinds, nerd_font_variant = "mono" },
                -- signature = { enabled = true, window = { border = "rounded" } },
                sources = { default = { "lsp", "path", "snippets", "buffer" } },
            },
            config = function(_, opts)
                require("blink.cmp").setup(opts)
                vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
            end,
        },
        {
            "stevearc/conform.nvim",
            event = "BufWritePre",
            cmd = "ConformInfo",
            keys = {
                {
                    "<leader>ff",
                    function()
                        require("conform").format({ timeout_ms = 500, lsp_format = "fallback" })
                    end,
                    desc = "Format buffer",
                },
            },
            opts = {
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    tex = { "tex-fmt" },
                },
            },
        },
        {
            "lervag/vimtex",
            init = function()
                vim.g.tex_flavor = "latex"
                vim.g.vimtex_view_general_viewer = "zathura"
                vim.g.vimtex_compiler_latexmk = {
                    options = {
                        "-auxdir=build",
                    },
                }
                vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
            end,
        },
    },
    ui = { border = "rounded" },
    checker = { enabled = false },
    rocks = { enabled = false },
    performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor", "rplugin" } } },
})

vim.cmd.colorscheme("kanso-zen")
