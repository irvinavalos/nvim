vim.loader.enable()

require("vim._core.ui2").enable({})

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.g.loaded_zipPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tar = 1

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

require("options")
require("keymaps")
require("autocmds")
require("compile")

vim.pack.add({
  "https://github.com/vague-theme/vague.nvim",

  "https://github.com/nvim-mini/mini.ai",
  "https://github.com/nvim-mini/mini.surround",
  "https://github.com/nvim-mini/mini.icons",

  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/stevearc/oil.nvim",

  "https://github.com/lewis6991/gitsigns.nvim",

  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/saghen/blink.lib",

  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",

  "https://github.com/nvim-treesitter/nvim-treesitter",

  "https://github.com/lervag/vimtex",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",

  "https://github.com/vyfor/cord.nvim",
})

require("vague").setup({ italic = false })

vim.cmd.colorscheme("vague")

require("mini.icons").setup({})
package.preload["nvim-web-devicons"] = function()
  require("mini.icons").mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end

require("gitsigns").setup({
  gh = true,
  current_line_blame = false,

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Previous hunk", buffer = bufnr })
    vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk", buffer = bufnr })
    vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "[G]it [P]review hunk", buffer = bufnr })

    vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { desc = "[G]it [R]eset buffer", buffer = bufnr })
    vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "[G]it [R]eset hunk", buffer = bufnr })

    vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { desc = "[G]it [S]tage buffer", buffer = bufnr })
    vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "[G]it [S]tage hunk", buffer = bufnr })

    vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "[G]it [B]lame", buffer = bufnr })
  end,
})

require("statusline")

require("mini.ai").setup({
  n_lines = 500,
  mappings = {
    around_next = "aa",
    inside_next = "ii",
  },
})

require("mini.surround").setup({})

require("fzf-lua").setup({
  defaults = { file_icons = false },
  winopts = {
    height = 0.5,
    width = 0.5,
    preview = { hidden = true },
  },
  oldfiles = {
    cwd_only = true,
    include_current_session = true,
  },
})

vim.keymap.set("n", "<leader>.", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })

vim.keymap.set("x", "<leader>fg", "<cmd>FzfLua grep_visual<cr>", { desc = "Grep visual" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua grep_cword<cr>", { desc = "Grep word" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help" })
vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua lsp_document_diagnostics<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua resume<cr>", { desc = "Resume" })

if not os.getenv("WAYLAND_DISPLAY") then
  require("cord").setup({})
end

require("oil").setup({
  show_hidden = true,
  columns = {
    "icon",
    "permissions",
    "size",
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })

-- LSP + Autocomplete
require("luasnip.loaders.from_vscode").lazy_load({})

local blink = require("blink.cmp")

blink.build():pwait()

blink.setup({
  snippets = { preset = "luasnip" },
  cmdline = { enabled = true },
  appearance = { nerd_font_variant = "normal" },
  fuzzy = { implementation = "rust" },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  keymap = { preset = "default" },

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = "single" },
    },

    menu = {
      border = "single",
      scrollbar = false,
      draw = {
        columns = {
          { "kind_icon" },
          { "label" },
          { "kind" },
        },
      },
    },
  },
})

vim.diagnostic.config({
  virtual_text = { prefix = " ", spacing = 2 },
  update_in_insert = false,
  virtual_lines = false,
  underline = true,
  signs = false,
  float = {
    style = "minimal",
    border = "single",
    source = "if_many",
    header = "",
    prefix = "",
  },
})

---@param client vim.lsp.Client
---@param bufnr integer
local function lsp_on_attach(client, bufnr)
  vim.keymap.set("n", "[e", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
  end, { desc = "Previous error", buffer = bufnr })

  vim.keymap.set("n", "]e", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
  end, { desc = "Next error", buffer = bufnr })

  vim.keymap.set("n", "grn", require("lsp_renamer"), { desc = "LSP Rename", buffer = bufnr })

  if client:supports_method("textDocument/references") then
    vim.keymap.set("n", "grr", "<cmd>FzfLua lsp_references<cr>", { desc = "vim.lsp.buf.references()", buffer = bufnr })
  end

  if client:supports_method("textDocument/typeDefinition") then
    vim.keymap.set("n", "grt", "<cmd>FzfLua lsp_typedefs<cr>", { desc = "type definition", buffer = bufnr })
  end

  if client:supports_method("textDocument/definition") then
    vim.keymap.set("n", "gd", function()
      require("fzf-lua").lsp_definitions({ jump1 = true })
    end, { desc = "Go to definition", buffer = bufnr })
    vim.keymap.set("n", "gD", function()
      require("fzf-lua").lsp_definitions({ jump1 = false })
    end, { desc = "Peek definition", buffer = bufnr })
  end

  if client:supports_method("textDocument/inlayHint") then
    vim.keymap.set("n", "<leader>ih", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { desc = "Inlay hints", buffer = bufnr })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Configure LSP keymaps",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then
      return
    end

    lsp_on_attach(client, bufnr)
    require("lsp_signature").setup(client, bufnr)
  end,
})

vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })

local servers = vim
  .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
  :map(function(file)
    return vim.fn.fnamemodify(file, ":t:r")
  end)
  :totable()

vim.lsp.enable(servers)

-- Formatter + Linter
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
    tex = { "tex-fmt" },
    rust = { "rustfmt" },
  },

  formatters = {
    ["tex-fmt"] = {
      command = "tex-fmt",
      args = { "$FILENAME" },
      stdin = false,
    },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>ff", function()
  conform.format({ async = true })
end, { desc = "[F]ormat [F]ile" })

local lint = require("lint")

lint.linters_by_ft = {
  python = { "ruff" },
  c = { "clangtidy" },
  cpp = { "clangtidy" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    if vim.bo.modifiable then
      lint.try_lint()
    end
  end,
})

-- Vimtex + Markdown
vim.g.vimtex_view_general_viewer = "/home/irvin/.local/bin/sumatrapdf.fish"
vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"

require("render-markdown").setup({
  latex = { enabled = false },
  completions = {
    lsp = { enabled = true },
  },
  html = {
    enabled = true,
    comment = { conceal = false },
  },
})

-- Treesitter
local parsers = {
  "python",
  "lua",
  "vimdoc",
  "markdown",
  "markdown_inline",
  "html",
  "yaml",
  "toml",
}

require("nvim-treesitter").install(parsers):wait(300000)

vim.api.nvim_create_autocmd("FileType", {
  pattern = parsers,
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
