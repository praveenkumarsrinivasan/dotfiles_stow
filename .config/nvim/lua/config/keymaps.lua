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

-- Toggle raw markdown view: flips conceallevel and render-markdown.nvim.
vim.keymap.set("n", "<leader>um", function()
  local cl = vim.opt_local.conceallevel:get()
  vim.opt_local.conceallevel = cl == 0 and 2 or 0
  pcall(vim.cmd, "RenderMarkdown toggle")
end, { desc = "Toggle markdown rendering" })

-- Insert current datetime (yyyy-mm-dd hh:mm:ss) at cursor.
vim.keymap.set("n", "<leader>id", function()
  vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M:%S") }, "c", true, true)
end, { desc = "Insert datetime" })

vim.keymap.set("i", "<C-g>d", function()
  vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M:%S") }, "c", false, true)
end, { desc = "Insert datetime" })

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
