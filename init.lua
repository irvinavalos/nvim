vim.loader.enable()

require("vim._core.ui2").enable({
    enable = true,
    msg = {
        target = "cmd",
        pager = { height = 0.5 },
        dialog = { height = 0.5 },
        cmd = { height = 0.5 },
        msg = { height = 0.5, timeout = 400 },
    },
})

----- Global Variables -----

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.g.have_nerd_font = true

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

----- Editor Options -----

vim.o.termguicolors = true
vim.o.winborder = "rounded"

vim.o.number = true
vim.o.relativenumber = true

vim.o.breakindent = true

vim.o.undofile = true
vim.o.swapfile = false
vim.o.writebackup = false
vim.o.exrc = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 300
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 10

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.inccommand = "split"

vim.o.scrolloff = 10
vim.o.sidescrolloff = 10

vim.o.confirm = true

vim.o.laststatus = 3
vim.o.showmode = false
vim.o.showcmd = false

vim.o.clipboard = "unnamedplus"

----- QOL Keymaps -----

vim.keymap.set("n", "n", "nzzzv", { desc = "Center search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center page up" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center page down" })

vim.keymap.set("n", "<A-j>", ":m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<cr>==", { desc = "Move line up" })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

----- QOL Plugins -----

vim.pack.add({
    -- "https://github.com/oskarnurm/koda.nvim",
    "https://github.com/webhooked/kanso.nvim",
    "https://github.com/NMAC427/guess-indent.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/lukas-reineke/indent-blankline.nvim",
    "https://github.com/nvim-mini/mini.nvim",
})

vim.cmd.colorscheme("kanso-zen")

require("guess-indent").setup()

require("gitsigns").setup({
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
    },
    gh = true,
    current_line_blame = true,
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Previous hunk", buffer = bufnr })
        vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk", buffer = bufnr })

        vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { desc = "[G]itsigns [R]eset buffer", buffer = bufnr })
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "[G]itsigns [R]eset hunk", buffer = bufnr })
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "[G]itsigns [S]tage hunk", buffer = bufnr })
    end,
})

require("ibl").setup({})

require("mini.ai").setup({
    mappings = {
        around_next = "aa",
        inside_next = "ii",
    },
    n_lines = 500,
})

require("mini.surround").setup({})

local pick = require("mini.pick")
pick.setup({})

vim.keymap.set("n", "<leader>.", "<cmd>Pick files<cr>", { desc = "Search files" })
vim.keymap.set("n", "<leader>,", "<cmd>Pick buffers<cr>", { desc = "Search files" })
vim.keymap.set("n", "<leader>fh", "<cmd>Pick help<cr>", { desc = "Search help tags" })

----- LSP Setup -----

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.enable({
    "lua_ls",
    "pyright",
    "clangd",
})

----- Formatting + Linting -----

vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/mfussenegger/nvim-lint",
})

local conform = require("conform")
conform.setup({
    formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
    },
})

vim.keymap.set(
    { "n", "v" },
    "<leader>ff",
    function() conform.format({ async = true }) end,
    { desc = "[F]ormat [F]ile" }
)

local lint = require("lint")
lint.linters_by_ft = {
    markdown = { "markdownlint" },
    python = { "ruff" },
    c = { "clangtidy" },
    cpp = { "clangtidy" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
        if vim.bo.modifiable then lint.try_lint() end
    end,
})

----- Autocomplete -----

vim.pack.add({
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/saghen/blink.cmp",
    "https://github.com/saghen/blink.lib",
})

require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("blink.cmp")

cmp.build():wait(60000)
cmp.setup({
    completion = {
        list = { selection = { auto_insert = true, preselect = false }, max_items = 10 },
        documentation = { window = { border = "rounded" }, auto_show = true },
        menu = { border = "rounded", scrollbar = false },
    },
    snippets = { preset = "luasnip" },
    cmdline = { enabled = false },
    sources = { default = { "lsp", "path", "snippets" } },
    signature = { enabled = true },
})
