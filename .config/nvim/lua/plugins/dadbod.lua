-- vim-dadbod: database client inside Neovim.
-- Stack:
--   * vim-dadbod            -> core (run queries, :DB command)
--   * vim-dadbod-ui         -> sidebar UI to browse connections, tables, saved queries
--   * vim-dadbod-completion -> SQL keyword + schema-aware completion
return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB" },
    dependencies = {
      { "kristijanhusak/vim-dadbod-ui", cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" } },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
    },
    init = function()
      -- Store saved queries / connections under ~/.local/share/nvim/db_ui
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/db_ui/tmp"
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_execute_on_save = 0 -- don't run query on every :w

      -- Database connections. Snowflake uses snowsql under the hood; the named
      -- connections live in ~/.snowsql/config (see [connections.zip_prod]).
      vim.g.dbs = {
        zip_prod = "snowflake://?connection=zip_prod",
      }

      -- Buffer-local keymaps in result buffers (filetype=dbout) for exporting
      -- the rendered query output to a file under ~/.local/share/nvim/db_ui/results.
      local results_dir = vim.fn.stdpath("data") .. "/db_ui/results"
      vim.fn.mkdir(results_dir, "p")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbout",
        callback = function(args)
          local function default_name(ext)
            return results_dir .. "/" .. os.date("%Y%m%d-%H%M%S") .. "." .. ext
          end

          -- Quick save: timestamped .txt in the results dir.
          vim.keymap.set("n", "<leader>de", function()
            local path = default_name("txt")
            vim.cmd("write! " .. vim.fn.fnameescape(path))
            vim.notify("Saved result -> " .. path, vim.log.levels.INFO)
          end, { buffer = args.buf, desc = "DB: save result (auto name)" })

          -- Save as: prompt for path, default to timestamped file.
          vim.keymap.set("n", "<leader>dE", function()
            local path = vim.fn.input("Save result to: ", default_name("txt"), "file")
            if path == "" then return end
            vim.cmd("write! " .. vim.fn.fnameescape(vim.fn.expand(path)))
            vim.notify("Saved result -> " .. path, vim.log.levels.INFO)
          end, { buffer = args.buf, desc = "DB: save result (prompt path)" })
        end,
      })

      -- :DBExportCSV — runs SQL through snowsql with CSV output and saves the
      -- file. With a range (visual mode) it uses the selection; otherwise the
      -- current paragraph (lines around the cursor delimited by blank lines).
      vim.api.nvim_create_user_command("DBExportCSV", function(opts)
        local lines
        if opts.range > 0 then
          lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        else
          local start_line = vim.fn.search("^\\s*$", "bnW")
          local end_line = vim.fn.search("^\\s*$", "nW")
          start_line = start_line == 0 and 1 or start_line + 1
          end_line = end_line == 0 and vim.fn.line("$") or end_line - 1
          lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        end

        local query = table.concat(lines, "\n"):gsub("^%s*(.-)%s*$", "%1")
        if query == "" then
          vim.notify("No query under cursor", vim.log.levels.WARN)
          return
        end

        local out = results_dir .. "/" .. os.date("%Y%m%d-%H%M%S") .. ".csv"
        local tmp = vim.fn.tempname() .. ".sql"
        vim.fn.writefile(vim.split(query, "\n"), tmp)

        vim.notify("Running snowsql -> " .. out, vim.log.levels.INFO)
        vim.fn.jobstart({
          "snowsql", "-c", "zip_prod",
          "-f", tmp,
          "-o", "output_format=csv",
          "-o", "friendly=false",
          "-o", "header=true",
          "-o", "timing=false",
          "-o", "output_file=" .. out,
        }, {
          on_exit = function(_, code)
            vim.schedule(function()
              os.remove(tmp)
              if code == 0 then
                vim.notify("Saved CSV -> " .. out, vim.log.levels.INFO)
              else
                vim.notify("snowsql exited with code " .. code .. " (see " .. out .. ")", vim.log.levels.ERROR)
              end
            end)
          end,
        })
      end, { range = true, desc = "Run query and export to CSV" })

      -- SQL buffer keymaps:
      --   <leader>dc -> export current paragraph/selection to CSV
      --   <leader>db -> bind scratch buffer to zip_prod so <leader>S works
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function(args)
          vim.keymap.set("n", "<leader>dc", "<cmd>DBExportCSV<cr>",
            { buffer = args.buf, desc = "DB: export query (CSV)" })
          vim.keymap.set("v", "<leader>dc", ":DBExportCSV<cr>",
            { buffer = args.buf, desc = "DB: export query (CSV)" })
          vim.keymap.set("n", "<leader>db", function()
            vim.b.db = vim.g.dbs.zip_prod
            vim.b.dbui_db_key_name = "zip_prod"
            vim.notify("Buffer bound to zip_prod", vim.log.levels.INFO)
          end, { buffer = args.buf, desc = "DB: bind buffer to zip_prod" })
        end,
      })
    end,
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
      { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "DBUI: find buffer" },
      { "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", desc = "DBUI: rename buffer" },
      { "<leader>dq", "<cmd>DBUILastQueryInfo<cr>", desc = "DBUI: last query info" },
    },
  },

  -- Wire vim-dadbod-completion into blink.cmp for sql/mysql/plsql buffers.
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      for _, ft in ipairs({ "sql", "mysql", "plsql" }) do
        opts.sources.per_filetype[ft] = vim.list_extend(
          vim.deepcopy(opts.sources.default or {}),
          { "dadbod" }
        )
      end
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.dadbod = {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink",
      }
    end,
  },
}
