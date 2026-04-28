-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Free up Shift+H / Shift+L so default H/M/L (top/middle/bottom of screen) work again.
-- LazyVim binds these to buffer navigation; unmap and move buffer nav to <leader>bp / <leader>bn.
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Buffer navigation on <leader>h / <leader>l (overrides LazyVim's <leader>l = Lazy).
vim.keymap.set("n", "<leader>h", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<leader>l", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Lazy moved to <leader>L since <leader>l now navigates buffers.
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Reload Neovim config (re-sources init.lua; plugin specs require a restart).
vim.keymap.set("n", "<leader>R", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^config") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload config" })
