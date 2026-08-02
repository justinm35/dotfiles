return {
  -- tpope endwise (no config needed)
  {
    "tpope/vim-endwise",
    event = "InsertEnter",
  },

  -- autopairs with opts (no need for config = true here)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      disable_filetype = { "TelescopePrompt", "vim" },
      map_cr = true,
    },
  },

  -- undotree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle", -- Optional lazy-load trigger
  },

  -- goto preview
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = function()
      require('goto-preview').setup {
        width = 120, -- works fine
        height = 15,
        default_mappings = true,
        post_open_hook = nil,
        focus_on_open = true,
      }
    end,
  },
  {
    "joshuavial/aider.nvim",
    opts = {

      border = {
        style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- or e.g. "rounded"
        color = "#fab387",
      },
      -- your configuration comes here
      -- if you don't want to use the default settings
      auto_manage_context = true, -- automatically manage buffer context
      default_bindings = true,    -- use default <leader>A keybindings
      debug = false,              -- enable debug logging
    },
  },

  -- animated cursor
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
    },
  },

  -- tpope utilities
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-eunuch",   event = "VeryLazy" },
  { "tpope/vim-rails",    ft = { "ruby", "eruby" } },
  { "tpope/vim-repeat",   event = "VeryLazy" },
}
