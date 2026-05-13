return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          local groups = {
            "Normal",
            "NormalNC",
            "NormalFloat",
            "FloatBorder",
            "SignColumn",
            "EndOfBuffer",
            "LineNr",
            "CursorLineNr",
            "StatusLine",
            "StatusLineNC",
            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "NeoTreeEndOfBuffer",
            "NvimTreeNormal",
            "TelescopeNormal",
            "TelescopeBorder",
            "WhichKeyFloat",
            "MsgArea",
          }
          for _, g in ipairs(groups) do
            vim.api.nvim_set_hl(0, g, { bg = "none" })
          end
        end,
      })
    end,
  },
}
