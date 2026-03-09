return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<M-Space>"] = { "show" },
        ["<CR>"] = { "accept", "fallback" },
      })
      opts.completion = opts.completion or {}
      opts.completion.list = { selection = { preselect = true, auto_insert = true } }
      -- Force disable ghost text with a function that always returns false
      opts.completion.ghost_text = { enabled = function() return false end }
    end,
  },
}
