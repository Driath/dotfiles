-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Absolute line numbers (no relative)
vim.opt.relativenumber = false

-- Force after LazyVim overrides + start in insert mode
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.opt.relativenumber = false
    vim.opt.winbar = ""
    vim.cmd("startinsert")
  end,
})

-- Send title to terminal (visible in tmux pane title)
vim.opt.title = true
vim.opt.titlestring = "%t"  -- just the filename

-- Hide key presses in statusline
vim.opt.showcmd = false
