-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Absolute line numbers (no relative)
vim.opt.relativenumber = false

-- Force after LazyVim overrides
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.opt.relativenumber = false
    vim.opt.winbar = ""
  end,
})
