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

return {
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
            menu = { border = "rounded", scrollbar = false },
        },
        cmdline = { enabled = false },
        appearance = { kind_icons = symbols },
        sources = { default = { "lsp", "path", "snippets" } },
        signature = { enabled = true },
    },
    config = function(_, opts)
        require("blink.cmp").setup(opts)
        vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
    end,
}
