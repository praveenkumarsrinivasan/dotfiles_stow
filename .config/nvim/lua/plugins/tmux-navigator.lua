-- Seamless Ctrl-h/j/k/l navigation between Neovim splits and tmux panes.
-- Requires christoomey/vim-tmux-navigator on the tmux side too (in tmux.conf).
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left (Neovim/tmux)" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down (Neovim/tmux)" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up (Neovim/tmux)" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (Neovim/tmux)" },
  },
}
