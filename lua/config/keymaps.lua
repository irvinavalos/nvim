local map = vim.keymap

-- Movement

map.set("n", "<C-d>", "<C-d>zz", { silent = true, noremap = true }) -- Move down buffer with cursor centered
map.set("n", "<C-u>", "<C-u>zz", { silent = true, noremap = true }) -- Move up buffer with cursor centered

-- Text Movement

map.set("n", "<A-k>", ":m .-2<CR>==", { silent = true, noremap = true }) -- Move line up in normal mode
map.set("n", "<A-j>", ":m .+1<CR>==", { silent = true, noremap = true }) -- Move line down in normal mode

map.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, noremap = true }) -- Move highlighted line(s) up in visual mode
map.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, noremap = true }) -- Move highlighted line(s) down in visual mode

map.set("v", "<", "<gv", { silent = true, noremap = true }) -- Stay in visual mode and shift line left
map.set("v", ">", ">gv", { silent = true, noremap = true }) -- Stay in visual mode and shift line right

-- Buffers

map.set("n", "<leader>bx", ":bdelete!<CR>", { desc = "Close Buffer", silent = true, noremap = true })
map.set("n", "<leader>b[", ":bprev<CR>", { desc = "Next Buffer", silent = true, noremap = true })
map.set("n", "<leader>b]", ":bnext<CR>", { desc = "Previous Buffer", silent = true, noremap = true })

-- Spell Suggest

local spell_types = { "text", "plaintex", "typst", "gitcommit", "markdown" }

vim.api.nvim_create_augroup("Spellcheck", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
	group = "Spellcheck",
	pattern = spell_types,
	callback = function()
		vim.opt_local.spell = true
	end,
})
