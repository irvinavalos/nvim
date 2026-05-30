vim.loader.enable()

require("vim._core.ui2").enable({})

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
vim.g.netrw_fastbrowse = 2
vim.g.netrw_dirhistmax = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_bufsettings = "noma nomod nonu nobl nowrap ro rnu"

----- Editor Options -----

vim.o.termguicolors = true
vim.o.winborder = "rounded"
vim.o.pumheight = 15
vim.o.pumborder = "rounded"

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#ffffff" })
vim.o.guicursor = "a:block-Cursor"

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

vim.o.updatetime = 250
vim.o.timeoutlen = 500
vim.o.ttimeoutlen = 25

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

vim.opt.list = true
vim.opt.listchars = { tab = "| ", leadmultispace = "|" .. string.rep(" ", vim.o.shiftwidth - 1) }

----- QOL Keymaps -----

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Highlights on search" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Center search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center page up" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center page down" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

vim.keymap.set("n", "<leader>ht", "<cmd>split | terminal<CR>", { desc = "[V]ertical [T]erminal" })
vim.keymap.set("n", "<leader>vt", "<cmd>vsplit | terminal<CR>", { desc = "[H]orizontal [T]erminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

----- QOL Autocmds -----

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight selection on yank",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    pattern = "*",
    callback = function() return vim.hl.on_yank({ timeout = 100, visual = true }) end,
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Disable inserting comments on new line",
    group = vim.api.nvim_create_augroup("disable-auto-comments", { clear = true }),
    callback = function() return vim.opt_local.formatoptions:remove({ "c", "r", "o" }) end,
})

----- QOL Plugins -----

vim.pack.add({
    "https://github.com/webhooked/kanso.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/vyfor/cord.nvim",
    "https://github.com/stevearc/oil.nvim",
})

vim.cmd.colorscheme("kanso-zen")

require("mini.icons").setup({})

require("gitsigns").setup({
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
    },
    gh = true,
    current_line_blame = false,
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Previous hunk", buffer = bufnr })
        vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk", buffer = bufnr })

        vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { desc = "[G]itsigns [R]eset buffer", buffer = bufnr })
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "[G]itsigns [R]eset hunk", buffer = bufnr })
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "[G]itsigns [S]tage hunk", buffer = bufnr })
    end,
})

require("statusline") -- custom statusline

require("mini.ai").setup({
    mappings = {
        around_next = "aa",
        inside_next = "ii",
    },
    n_lines = 500,
})

require("mini.surround").setup({})

local extra = require("mini.extra")
local pick = require("mini.pick")

pick.setup({})
extra.setup({})

vim.keymap.set("n", "<leader>.", function() pick.builtin.files() end, { desc = "Mini Pick Files" })
vim.keymap.set("n", "<leader>,", function() pick.builtin.buffers() end, { desc = "Mini Pick Buffers" })
vim.keymap.set(
    "n",
    "<leader>/",
    function() pick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
    { desc = "Mini Pick Grep / Search" }
)
vim.keymap.set("n", "<leader>fh", function() pick.builtin.help() end, { desc = "Mini Help" })

vim.keymap.set("n", "<leader>fd", function() extra.pickers.diagnostic() end, { desc = "Mini Extra Diagnostics" })

require("cord").setup({})

require("oil").setup({})

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })

----- LSP + Autocomplete -----

vim.pack.add({
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/rafamadriz/friendly-snippets",
    "https://github.com/saghen/blink.cmp",
    "https://github.com/saghen/blink.lib",
})

require("luasnip.loaders.from_vscode").lazy_load({})

local cmp = require("blink.cmp")

cmp.build():wait(60000)

cmp.setup({
    completion = {
        list = {
            selection = { auto_insert = true, preselect = false },
            max_items = 10,
        },
        documentation = { window = { border = "rounded" }, auto_show = true },
        menu = {
            border = "rounded",
            scrollbar = false,
            draw = {
                gap = 2,
                columns = {
                    { "kind_icon", "kind", gap = 1 },
                    { "label", "label_description", gap = 1 },
                    { "source_name" },
                },
            },
        },
    },
    snippets = { preset = "luasnip" },
    cmdline = { enabled = false },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    signature = { enabled = true },
})

vim.diagnostic.config({
    virtual_text = true,
    update_in_insert = false,
    virtual_lines = false,
    float = {
        style = "minimal",
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = "",
    },
    signs = false,
})

local function on_attach(client, bufnr)
    if client:supports_method("textDocument/definition") then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[G]o to [D]efinition", buffer = bufnr })
        vim.keymap.set(
            "n",
            "gD",
            function() extra.pickers.lsp({ scope = "definition" }) end,
            { desc = "Peek Definition", buffer = bufnr }
        )
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Configure LSP Keybinds",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        on_attach(client, args.buf)
    end,
})

vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })

local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
    :map(function(file) return vim.fn.fnamemodify(file, ":t:r") end)
    :totable()

vim.lsp.enable(servers)

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
        tex = { "tex-fmt" },
    },
    formatters = {
        ["tex-fmt"] = {
            command = "tex-fmt",
            args = { "$FILENAME" },
            stdin = false,
        },
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

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
        if vim.bo.modifiable then lint.try_lint() end
    end,
})

----- LaTeX -----

vim.pack.add({ "https://github.com/lervag/vimtex" })

vim.g.vimtex_view_general_viewer = "/home/irvin/.local/bin/sumatrapdf.fish"
vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"

----- Markdown -----

vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

----- Treesitter -----

vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local parsers = { "python", "lua", "vimdoc", "markdown", "markdown_inline", "html", "yaml" }

require("nvim-treesitter").install(parsers):wait(300000)

vim.api.nvim_create_autocmd("FileType", {
    pattern = parsers,
    callback = function() pcall(vim.treesitter.start) end,
})
