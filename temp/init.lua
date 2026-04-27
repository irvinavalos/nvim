vim.loader.enable(true)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.netrw_liststyle = 3

require("options")
require("keymaps")
require("autocmds")
require("terminal")
require("statusline")
require("lsp")

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

local plugins = "plugins"

require("lazy").setup(plugins, {
    ui = { border = "rounded" },
    checker = { enabled = false },
    change_detection = { notify = false },
    rocks = { enabled = false },
    performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor", "rplugin" } } },
})
