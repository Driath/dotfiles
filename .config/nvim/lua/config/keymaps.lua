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

-- Option+Up/Down: jump by function (Treesitter), fallback to paragraph
local function jump_or_paragraph(direction)
  return function()
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    local has_parser = lang and pcall(vim.treesitter.get_parser, 0, lang)
    if has_parser then
      local key = direction == "up" and "[f" or "]f"
      vim.cmd("normal " .. vim.api.nvim_replace_termcodes(key, true, true, true))
    else
      vim.cmd("normal! " .. (direction == "up" and "{" or "}"))
    end
  end
end
vim.keymap.set("n", "<M-Up>", jump_or_paragraph("up"), { desc = "Prev function/paragraph" })
vim.keymap.set("n", "<M-Down>", jump_or_paragraph("down"), { desc = "Next function/paragraph" })
vim.keymap.set("v", "<M-Up>", jump_or_paragraph("up"), { desc = "Prev function/paragraph" })
vim.keymap.set("v", "<M-Down>", jump_or_paragraph("down"), { desc = "Next function/paragraph" })
vim.keymap.set("i", "<M-Up>", function() vim.cmd("stopinsert"); jump_or_paragraph("up")(); vim.cmd("startinsert") end, { desc = "Prev function/paragraph" })
vim.keymap.set("i", "<M-Down>", function() vim.cmd("stopinsert"); jump_or_paragraph("down")(); vim.cmd("startinsert") end, { desc = "Next function/paragraph" })

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

-- Ctrl+Option+Left/Right → switch buffers (IDE tab navigation)
vim.keymap.set({ "n", "i", "v" }, "<C-A-Left>", "<Cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set({ "n", "i", "v" }, "<C-A-Right>", "<Cmd>bnext<CR>", { desc = "Next buffer" })

-- Ctrl+Z → suspend (Kitty protocol sends CSI u instead of SIGTSTP)
vim.keymap.set({ "n", "i", "v" }, "<C-z>", "<Cmd>stop<CR>", { desc = "Suspend" })
