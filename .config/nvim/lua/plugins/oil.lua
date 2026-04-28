-- oil.nvim — edit your filesystem like a buffer.
-- Open with `-` (parent dir of current buffer), or `:Oil` from anywhere.
-- Inside oil: edit the buffer (rename, delete, create files via line edits),
-- then `:w` to apply changes. `g?` shows all keymaps.
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false, -- recommended by oil docs so `nvim <dir>` opens oil
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = false, -- keep neo-tree/snacks as netrw replacement
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vsplit" },
      ["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in hsplit" },
      ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open in new tab" },
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh", -- conflicts with vim-tmux-navigator; remap if needed
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to current dir" },
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    use_default_keymaps = false,
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Oil: open parent directory" },
    { "<leader>fo", "<cmd>Oil<cr>", desc = "Oil (parent dir)" },
    { "<leader>fO", function() require("oil").open(vim.fn.getcwd()) end, desc = "Oil (cwd)" },
  },
}
