return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    require("rose-pine").setup({
      styles = { transparency = true, italic = false },
      highlight_groups = {
        TelescopeBorder = { fg = "subtle", bg = "none" },
        TelescopeNormal = { bg = "none" },
        TelescopePromptNormal = { bg = "base" },
        NormalFloat = { bg = "surface" },
        FloatBorder = { fg = "subtle", bg = "surface" },
        DashboardHeader = { fg = "love" },
      },
    })
    vim.cmd("colorscheme rose-pine")
  end
}
