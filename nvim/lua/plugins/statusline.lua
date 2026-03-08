return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local transparent = { bg = "NONE" }

      opts.options = opts.options or {}
      opts.options.theme = {
        normal = {
          a = transparent,
          b = transparent,
          c = transparent,
        },
        insert = {
          a = transparent,
          b = transparent,
          c = transparent,
        },
        visual = {
          a = transparent,
          b = transparent,
          c = transparent,
        },
        command = {
          a = transparent,
          b = transparent,
          c = transparent,
        },
        inactive = {
          a = transparent,
          b = transparent,
          c = transparent,
        },
      }
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "·", right = "·" }

      -- Right: clear showcmd and extras, just line count
      opts.sections.lualine_x = {}
      opts.sections.lualine_y = {}
      opts.sections.lualine_z = {
        { function() return vim.fn.line(".") .. "/" .. vim.fn.line("$") end },
      }
    end,
  },
}
