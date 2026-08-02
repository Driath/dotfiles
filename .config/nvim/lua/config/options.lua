-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable LazyVim plugin order warning
vim.g.lazyvim_check_order = false

-- Absolute line numbers (no relative)
vim.opt.relativenumber = false

-- Force after LazyVim overrides + start in insert mode
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.opt.relativenumber = false
    vim.opt.winbar = nil
    vim.cmd("startinsert")
  end,
})

-- Kill winbar whenever a plugin tries to set it
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "WinEnter" }, {
  callback = function()
    vim.opt_local.winbar = nil
  end,
})

-- Send title to terminal (visible in pane title)
vim.opt.title = true
vim.opt.titlestring = "%t"  -- just the filename

-- Hide key presses in statusline
vim.opt.showcmd = false

