-- Formatters for conform.nvim. LazyVim already loads conform; this just
-- overrides per-filetype config.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "sqlfluff" },
      },
      formatters = {
        sqlfluff = {
          -- Reads the buffer from stdin and writes formatted SQL to stdout.
          -- Per-project rules (lowercase keywords, indent width, etc.) live in
          -- a .sqlfluff file at the project root.
          --
          -- --templater=jinja: ~/.sqlfluff sets templater=dbt for dbt projects,
          -- but the dbt templater crashes on Python 3.14 (mashumaro/dbt-core
          -- incompatibility). Override to jinja for ad-hoc nvim formatting;
          -- jinja still handles plain SQL fine.
          command = "sqlfluff",
          args = { "format", "--dialect=snowflake", "--templater=jinja", "-" },
          stdin = true,
        },
      },
    },
  },
}
