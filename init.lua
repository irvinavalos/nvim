vim.loader.enable(true)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.netrw_liststyle = 3

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.showcmd = false
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.writebackup = true
vim.opt.undofile = true
vim.opt.syntax = "on"
vim.opt.termguicolors = true
vim.opt.winborder = "single"
vim.opt.wrap = false
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "n", "nzzzv", { desc = "Center next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center half page up" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line selection up", silent = true })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect", silent = true })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect", silent = true })

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

require("lsp")
require("statusline")

local symbols = {
    Array = "󰅪",
    Class = "",
    Color = "󰏘",
    Constant = "󰏿",
    Constructor = "",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "󰜢",
    File = "󰈙",
    Folder = "󰉋",
    Function = "󰆧",
    Interface = "",
    Keyword = "󰌋",
    Method = "󰆧",
    Module = "",
    Operator = "󰆕",
    Property = "󰜢",
    Reference = "󰈇",
    Snippet = "",
    Struct = "",
    Text = "",
    TypeParameter = "",
    Unit = "",
    Value = "",
    Variable = "󰀫",
}

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
        {
            "oskarnurm/koda.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                require("koda").setup({ transparent = true })
                vim.cmd.colorscheme("koda-dark")
            end,
        },
        -- {
        --     "projekt0n/github-nvim-theme",
        --     name = "github-theme",
        --     lazy = false,
        --     priority = 1000,
        --     config = function()
        --         require("github-theme").setup()
        --         -- vim.cmd.colorscheme("github_dark_default")
        --         vim.cmd.colorscheme("github_dark_high_contrast")
        --         -- vim.cmd.colorscheme("github_dark_colorblind")
        --         -- vim.cmd.colorscheme("github_dark_tritanopia")
        --     end
        -- },
        {
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
            },
            opts = {
                winopts = { width = 0.55, height = 0.6, preview = { hidden = true } },
                oldfiles = { cwd_only = true, include_current_session = true },
                defaults = { file_icons = false },
            },
        },
        {
            "nvim-mini/mini.surround",
            version = false,
            event = "VeryLazy",
        },
        {
            "lewis6991/gitsigns.nvim",
            event = "VeryLazy",
            opts = { preview_config = { border = "rounded" }, signcolumn = false, numhl = true },
        },
        {
            "saghen/blink.cmp",
            version = "1.*",
            dependencies = { "rafamadriz/friendly-snippets" },
            event = "InsertEnter",
            opts = {
                keymap = {
                    ["<C-u>"] = { "scroll_documentation_up" },
                    ["<C-d>"] = { "scroll_documentation_down" },
                },
                snippets = { preset = "default" },
                completion = {
                    list = { selection = { preselect = false, auto_insert = false }, max_items = 8 },
                    documentation = { window = { border = "rounded" }, auto_show = false },
                    menu = { border = "rounded", scrollbar = false },
                },
                cmdline = { enabled = false },
                appearance = { kind_icons = symbols },
                sources = { default = { "lsp", "path", "snippets" } },
		ghost_text = { enabled = true },
                signature = { enabled = true },
            },
            config = function(_, opts)
                require("blink.cmp").setup(opts)
                vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
            end,
        }
    },
    checker = { enabled = false },
    change_detection = { notify = false },
    rocks = { enabled = false },
    performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor", "rplugin" } } },
})
