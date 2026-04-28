-- Auto-continue and auto-renumber list items in markdown/text.
-- Pressing <CR> on a `- foo` line creates `- ` on the next line.
-- Pressing `o`/`O` in normal mode does the same.
-- <Tab>/<S-Tab> indent/dedent inside a list.
-- Empty bullet + <CR> terminates the list.
--
-- Note: <CR> in normal mode is intentionally NOT mapped here — that key is
-- already used by obsidian.nvim for checkbox toggling.
return {
  "gaoDean/autolist.nvim",
  ft = {
    "markdown",
    "text",
    "tex",
    "plaintex",
    "norg",
  },
  config = function()
    require("autolist").setup()

    vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
    vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
    vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
  end,
}
