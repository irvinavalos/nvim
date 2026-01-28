return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>ff",
            function() require("conform").format({ timeout_ms = 500, lsp_format = "fallback" }) end,
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
            javascript = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            ocaml = { "ocamlformat" },
            go = { "gofmt" },
        },
    },
}
