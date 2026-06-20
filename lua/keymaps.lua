vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Highlights on search" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Center search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center page up" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

vim.keymap.set("n", "<leader>ht", "<cmd>split | terminal<CR>", { desc = "[H]orizontal [T]erminal" })
vim.keymap.set("n", "<leader>vt", "<cmd>vsplit | terminal<CR>", { desc = "[V]ertical [T]erminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
