-- Browser-based markdown preview with native Mermaid rendering.
-- Opens the current markdown file in the default browser; live-updates as you edit.
-- Toggle with <leader>mp or :MarkdownPreviewToggle.

return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  build = "cd app && npx --yes yarn install",
  init = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_theme = "dark"
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview (toggle)" },
  },
}
