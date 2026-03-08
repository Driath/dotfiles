-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Option+Arrow: jump words (Option sends <M-b>/<M-f> via terminal)
vim.keymap.set({ "n", "v" }, "<M-f>", "w", { desc = "Next word" })
vim.keymap.set({ "n", "v" }, "<M-b>", "b", { desc = "Prev word" })
vim.keymap.set("i", "<M-f>", "<C-Right>", { desc = "Next word" })
vim.keymap.set("i", "<M-b>", "<C-Left>", { desc = "Prev word" })

-- Option+Shift+Arrow: handled by Ghostty → sends Home/End directly

-- Cmd+S → save (Ghostty sends Ctrl+S)
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save" })

-- Cmd+Z → undo (Ghostty sends Ctrl+Z), Cmd+Shift+Z → redo (Ctrl+R)
vim.keymap.set({ "n", "i", "v" }, "<C-z>", "<Cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set("i", "<C-r>", "<Cmd>redo<CR>", { desc = "Redo" })

-- Option+Z/Shift+Z as fallback
vim.keymap.set({ "n", "i", "v" }, "<M-z>", "<Cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set({ "n", "i", "v" }, "<M-Z>", "<Cmd>redo<CR>", { desc = "Redo" })

-- Cmd+A / Option+A → select all
vim.keymap.set({ "n", "i", "v" }, "<C-a>", "<Esc>ggVG", { desc = "Select all" })
vim.keymap.set({ "n", "i", "v" }, "<M-a>", "<Esc>ggVG", { desc = "Select all" })

-- Option+/ → toggle comment
vim.keymap.set({ "n", "v" }, "<M-/>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("i", "<M-/>", "<Esc>gcca", { remap = true, desc = "Toggle comment" })

-- Cmd+C → copy to system clipboard (Ghostty sends Ctrl+C)
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })

-- Cmd+V → paste from system clipboard (handled via Ctrl+V in nvim)
-- Note: Cmd+V goes through tmux, so we use Ctrl+Shift+V as alternative
vim.keymap.set({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste from clipboard" })

-- Visual mode: Backspace deletes selection
vim.keymap.set("v", "<BS>", '"_d', { desc = "Delete selection" })

-- Cmd+X / Option+X → cut line to clipboard
vim.keymap.set("n", "<M-x>", '"+dd', { desc = "Cut line" })
vim.keymap.set("i", "<M-x>", '<Esc>"+ddi', { desc = "Cut line" })
vim.keymap.set("v", "<M-x>", '"+d', { desc = "Cut selection" })
vim.keymap.set("n", "<C-x>", '"+dd', { desc = "Cut line" })
vim.keymap.set("i", "<C-x>", '<Esc>"+ddi', { desc = "Cut line" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut selection" })

-- Option+Up/Down → page up/down (jump one screen)
vim.keymap.set({ "n", "v" }, "<M-Up>", "<C-b>", { desc = "Page up" })
vim.keymap.set({ "n", "v" }, "<M-Down>", "<C-f>", { desc = "Page down" })
vim.keymap.set("i", "<M-Up>", "<C-o><C-b>", { desc = "Page up" })
vim.keymap.set("i", "<M-Down>", "<C-o><C-f>", { desc = "Page down" })

-- Option+Shift+Up/Down → move line
vim.keymap.set("n", "<M-S-Up>", "<Cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<M-S-Down>", "<Cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("i", "<M-S-Up>", "<Esc><Cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("i", "<M-S-Down>", "<Esc><Cmd>m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("v", "<M-S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<M-S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Option+Backspace → delete word backwards (IDE behavior)
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word back" })
