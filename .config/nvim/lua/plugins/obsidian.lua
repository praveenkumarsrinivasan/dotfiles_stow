-- Obsidian integration for the `pks` vault.
-- Plugins:
--   1. obsidian.nvim       - vault navigation, daily notes, checkbox toggle, wiki-links
--   2. render-markdown.nvim - pretty in-buffer rendering of markdown + checkboxes
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "pks",
          path = "/Users/praveensrinivasan/Documents/pks",
        },
      },

      daily_notes = {
        folder = "Daily Notes",
        date_format = "%Y-%m-%d",
        template = "Daily Note.md",
      },

      templates = {
        folder = "Resources/Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      completion = {
        nvim_cmp = false, -- LazyVim uses blink.cmp
        blink = true,
        min_chars = 2,
      },

      new_notes_location = "current_dir",

      -- Open URLs / images with the OS handler
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,

      -- Disable obsidian.nvim's built-in UI/concealment.
      -- render-markdown.nvim handles all rendering; running both causes
      -- double-conceal and eats characters on list lines.
      ui = { enable = false },
    },
    keys = {
      { "<leader>oo", "<cmd>ObsidianOpen<cr>",           desc = "Obsidian: open in app" },
      { "<leader>ot", "<cmd>ObsidianToday<cr>",          desc = "Obsidian: today" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>",      desc = "Obsidian: yesterday" },
      { "<leader>oT", "<cmd>ObsidianTomorrow<cr>",       desc = "Obsidian: tomorrow" },
      { "<leader>on", "<cmd>ObsidianNew<cr>",            desc = "Obsidian: new note" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>",         desc = "Obsidian: search" },
      { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>",    desc = "Obsidian: quick switch" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",      desc = "Obsidian: backlinks" },
      { "<leader>ol", "<cmd>ObsidianLink<cr>",           desc = "Obsidian: link selection", mode = "v" },
      { "<leader>oh", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Obsidian: toggle checkbox" },

      -- Add a new todo on a new line below current, cursor positioned for typing.
      -- Respects autoindent, so nesting works: hit <leader>oa while on an
      -- indented task and the new task inherits that indentation.
      { "<leader>oa", "o- [ ] ", mode = "n", desc = "Task: add new todo below" },
      { "<leader>oA", "O- [ ] ", mode = "n", desc = "Task: add new todo above" },

      -- Set checkbox to a specific state on current line or visual selection.
      -- Works on ranges (V then keymap) which the toggle command cannot do.
      { "<leader>o<Space>", [[:s/\[.\]/[ ]/<CR>:nohl<CR>]], mode = { "n", "v" }, desc = "Task: todo",        silent = true },
      { "<leader>ox",       [[:s/\[.\]/[x]/<CR>:nohl<CR>]], mode = { "n", "v" }, desc = "Task: done",        silent = true },
      { "<leader>od",       [[:s/\[.\]/[-]/<CR>:nohl<CR>]], mode = { "n", "v" }, desc = "Task: in progress", silent = true },
      { "<leader>of",       [[:s/\[.\]/[>]/<CR>:nohl<CR>]], mode = { "n", "v" }, desc = "Task: forwarded",   silent = true },
      { "<leader>oc",       [[:s/\[.\]/[~]/<CR>:nohl<CR>]], mode = { "n", "v" }, desc = "Task: cancelled",   silent = true },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      file_types = { "markdown" },
      heading = {
        sign = false,
      },
      checkbox = {
        enabled = true,
        -- Using standard Unicode ballot-box glyphs (U+2610-2612) instead of
        -- Nerd Font private-range codepoints so the icons are stable across
        -- fonts and survive editor copy/paste.
        unchecked = { icon = "☐ ", highlight = "RenderMarkdownUnchecked" },
        checked   = { icon = "☑ ", highlight = "RenderMarkdownChecked" },
        custom = {
          todo      = { raw = "[-]", rendered = "◐ ", highlight = "RenderMarkdownTodo" },
          forwarded = { raw = "[>]", rendered = "▶ ", highlight = "RenderMarkdownTodo" },
          cancelled = { raw = "[~]", rendered = "☒ ", highlight = "RenderMarkdownTodo" },
        },
      },
    },
  },
}
