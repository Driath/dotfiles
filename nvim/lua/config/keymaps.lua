-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Option+Arrow: jump words (Option sends <M-b>/<M-f> via terminal)
vim.keymap.set({ "n", "v" }, "<M-f>", "w", { desc = "Next word" })
vim.keymap.set({ "n", "v" }, "<M-b>", "b", { desc = "Prev word" })
vim.keymap.set("i", "<M-f>", "<C-Right>", { desc = "Next word" })
vim.keymap.set("i", "<M-b>", "<C-Left>", { desc = "Prev word" })

-- Cmd+S → save (Ghostty sends Ctrl+S direct)
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save" })

-- Option+Z → undo, Option+Shift+Z → redo
vim.keymap.set({ "n", "i", "v" }, "<M-z>", "<Cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set({ "n", "i", "v" }, "<M-Z>", "<Cmd>redo<CR>", { desc = "Redo" })

-- Option+A → select all
vim.keymap.set({ "n", "i", "v" }, "<M-a>", "<Esc>ggVG", { desc = "Select all" })

-- Option+/ → toggle comment
vim.keymap.set({ "n", "v" }, "<M-/>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("i", "<M-/>", "<Esc>gcca", { remap = true, desc = "Toggle comment" })
