vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight selection on yank",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  pattern = "*",
  callback = function()
    return vim.hl.on_yank({ timeout = 150, visual = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable inserting comments on new line",
  group = vim.api.nvim_create_augroup("disable-auto-comments", { clear = true }),
  callback = function()
    return vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
