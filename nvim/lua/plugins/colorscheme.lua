return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          CursorLine = { bg = "NONE", bold = true },
          -- Line numbers: inactive=brightblack, active=cyan (matches design system)
          LineNr = { fg = "#7f849c" },
          CursorLineNr = { fg = "#89dceb", bold = true },
          -- Transparent statusline
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          -- Lualine sections transparent
          lualine_c_normal = { bg = "NONE" },
          lualine_c_insert = { bg = "NONE" },
          lualine_c_visual = { bg = "NONE" },
          lualine_c_command = { bg = "NONE" },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
