return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    popup_border_style = "single",
    use_popups_for_input = false,
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      width = 35,
      mappings = {
        ["o"] = "open",
      },
    },
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer (Neo-tree)" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Explorer: reveal current file" },
  },
}
