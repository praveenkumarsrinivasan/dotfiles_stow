return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>fy", "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
    { "<leader>fY", "<cmd>Yazi cwd<cr>", desc = "Open yazi in cwd" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume last yazi session" },
  },
  opts = {
    open_for_directories = false,
    keymaps = { show_help = "<f1>" },
  },
}
