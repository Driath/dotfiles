-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- Philosophy: Option (left) = app shortcuts, Cmd = tmux/system
-- Kitty keyboard protocol transmits Option+key natively through tmux

-- ==========================================================================
-- Navigation layers: Arrow / Shift+Arrow / Option+Arrow / Option+Shift+Arrow
-- ==========================================================================

-- Arrow keys: char/line movement (default Neovim behavior)
-- Shift+Arrow: visual selection char/line (default Neovim behavior)

-- Option+Left/Right: jump by word (both Kitty CSI u and legacy Meta)
vim.keymap.set("n", "<M-Left>", "b", { desc = "Prev word" })
vim.keymap.set("n", "<M-Right>", "w", { desc = "Next word" })
vim.keymap.set("v", "<M-Left>", "b", { desc = "Prev word" })
vim.keymap.set("v", "<M-Right>", "w", { desc = "Next word" })
vim.keymap.set("i", "<M-Left>", "<C-Left>", { desc = "Prev word" })
vim.keymap.set("i", "<M-Right>", "<C-Right>", { desc = "Next word" })

-- Option+Up/Down: jump by function/method (Treesitter)
vim.keymap.set("n", "<M-Up>", "[f", { remap = true, desc = "Prev function" })
vim.keymap.set("n", "<M-Down>", "]f", { remap = true, desc = "Next function" })
vim.keymap.set("v", "<M-Up>", "[f", { remap = true, desc = "Prev function" })
vim.keymap.set("v", "<M-Down>", "]f", { remap = true, desc = "Next function" })
vim.keymap.set("i", "<M-Up>", "<C-o>[f", { remap = true, desc = "Prev function" })
vim.keymap.set("i", "<M-Down>", "<C-o>]f", { remap = true, desc = "Next function" })

-- Option+Shift+Left/Right: select by word
vim.keymap.set("n", "<M-S-Left>", "vb", { desc = "Select prev word" })
vim.keymap.set("n", "<M-S-Right>", "vw", { desc = "Select next word" })
vim.keymap.set("v", "<M-S-Left>", "b", { desc = "Extend select prev word" })
vim.keymap.set("v", "<M-S-Right>", "w", { desc = "Extend select next word" })
vim.keymap.set("i", "<M-S-Left>", "<Esc>vb", { desc = "Select prev word" })
vim.keymap.set("i", "<M-S-Right>", "<Esc>vw", { desc = "Select next word" })

-- Option+Shift+Up/Down: select by function/method
vim.keymap.set("n", "<M-S-Up>", "V[f", { remap = true, desc = "Select to prev function" })
vim.keymap.set("n", "<M-S-Down>", "V]f", { remap = true, desc = "Select to next function" })
vim.keymap.set("v", "<M-S-Up>", "[f", { remap = true, desc = "Extend select to prev function" })
vim.keymap.set("v", "<M-S-Down>", "]f", { remap = true, desc = "Extend select to next function" })
vim.keymap.set("i", "<M-S-Up>", "<Esc>V[f", { remap = true, desc = "Select to prev function" })
vim.keymap.set("i", "<M-S-Down>", "<Esc>V]f", { remap = true, desc = "Select to next function" })

-- ==========================================================================
-- Editor actions: Option+key (replaces Cmd+key hacks)
-- ==========================================================================

-- Option+S → save (Cmd+S routed here via tmux)
vim.keymap.set({ "n", "i", "v" }, "<M-s>", "<Cmd>w<CR>", { desc = "Save" })

-- Option+Z → undo, Option+Shift+Z → redo
vim.keymap.set({ "n", "i", "v" }, "<M-z>", "<Cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set({ "n", "i", "v" }, "<M-S-z>", "<Cmd>redo<CR>", { desc = "Redo" })

-- Option+A → select all
vim.keymap.set({ "n", "i", "v" }, "<M-a>", "<Esc>ggVG", { desc = "Select all" })

-- Option+: → toggle comment (/ on AZERTY = Shift+:)
vim.keymap.set({ "n", "v" }, "<M-:>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("i", "<M-:>", "<Esc>gcca", { remap = true, desc = "Toggle comment" })

-- Option+C → copy to system clipboard
vim.keymap.set("v", "<M-c>", '"+y', { desc = "Copy to clipboard" })

-- Option+V → paste from system clipboard
vim.keymap.set({ "n", "v" }, "<M-v>", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("i", "<M-v>", '<C-r>+', { desc = "Paste from clipboard" })

-- Option+X → cut to clipboard
vim.keymap.set("n", "<M-x>", '"+dd', { desc = "Cut line" })
vim.keymap.set("i", "<M-x>", '<Esc>"+ddi', { desc = "Cut line" })
vim.keymap.set("v", "<M-x>", '"+d', { desc = "Cut selection" })

-- ==========================================================================
-- Other editor shortcuts
-- ==========================================================================

-- Visual mode: Backspace deletes selection
vim.keymap.set("v", "<BS>", '"_d', { desc = "Delete selection" })

-- Option+Backspace → delete word backwards (IDE behavior)
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word back" })
