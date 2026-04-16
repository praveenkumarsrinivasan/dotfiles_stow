-- Task rollover for the `pks` Obsidian vault.
--
-- Provides :TaskRollover which carries forward unchecked tasks from the
-- most recent previous daily note into today's note, preserving indentation
-- (so nested sub-tasks roll over too), and marks the originals as [>]
-- (forwarded) so they don't get double-counted on dashboards.
--
-- Keymap: <leader>or  (Obsidian: Rollover tasks)

local VAULT = "/Users/praveensrinivasan/Documents/pks"
local DAILY_DIR = VAULT .. "/Daily Notes"
local TASKS_HEADING = "^## Tasks%s*$"
local UNCHECKED_PAT = "^(%s*)%- %[ %] " -- indent capture

--- Read a file into a list of lines. Returns nil if missing.
local function read_lines(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local lines = {}
  for line in f:lines() do
    table.insert(lines, line)
  end
  f:close()
  return lines
end

--- Write a list of lines to a file (trailing newline).
local function write_lines(path, lines)
  local f, err = io.open(path, "w")
  if not f then error("Cannot write " .. path .. ": " .. tostring(err)) end
  for _, line in ipairs(lines) do
    f:write(line, "\n")
  end
  f:close()
end

--- Find the most recent daily note before `today_date` (within 14 days).
--- Returns (path, date_string) or (nil, nil).
local function find_previous_daily(today_date)
  local t = os.time({
    year = tonumber(today_date:sub(1, 4)),
    month = tonumber(today_date:sub(6, 7)),
    day = tonumber(today_date:sub(9, 10)),
    hour = 12,
  })
  for i = 1, 14 do
    local prev = os.date("%Y-%m-%d", t - i * 86400)
    local path = DAILY_DIR .. "/" .. prev .. ".md"
    if vim.uv.fs_stat(path) then
      return path, prev
    end
  end
  return nil, nil
end

--- Locate "## Tasks" section bounds in a list of lines.
--- Returns (heading_idx, end_idx) or (nil, nil).
local function find_tasks_section(lines)
  local start
  for i, line in ipairs(lines) do
    if line:match(TASKS_HEADING) then
      start = i
    elseif start and line:match("^##%s") then
      return start, i - 1
    end
  end
  if start then return start, #lines end
  return nil, nil
end

--- Extract unchecked task lines from a section range (inclusive).
--- Returns { tasks = {line,...}, indices = {file_line,...} }.
local function extract_unchecked(lines, from, to)
  local out = { tasks = {}, indices = {} }
  for i = from, to do
    if lines[i] and lines[i]:match(UNCHECKED_PAT) then
      table.insert(out.tasks, lines[i])
      table.insert(out.indices, i)
    end
  end
  return out
end

local function rollover()
  local today = os.date("%Y-%m-%d")
  local today_path = DAILY_DIR .. "/" .. today .. ".md"

  local today_lines = read_lines(today_path)
  if not today_lines then
    vim.notify(
      "Today's note doesn't exist. Run :ObsidianToday first.",
      vim.log.levels.ERROR
    )
    return
  end

  local prev_path, prev_date = find_previous_daily(today)
  if not prev_path then
    vim.notify("No previous daily note found in the last 14 days.", vim.log.levels.WARN)
    return
  end

  local prev_lines = read_lines(prev_path)
  if not prev_lines then
    vim.notify("Failed to read " .. prev_path, vim.log.levels.ERROR)
    return
  end

  -- Only pull tasks from the previous note's "## Tasks" section (avoids
  -- sweeping up unrelated checkboxes elsewhere in the file).
  local p_start, p_end = find_tasks_section(prev_lines)
  if not p_start then
    vim.notify("Previous note has no '## Tasks' heading: " .. prev_date, vim.log.levels.WARN)
    return
  end
  local extracted = extract_unchecked(prev_lines, p_start + 1, p_end)

  if #extracted.tasks == 0 then
    vim.notify("No open tasks in " .. prev_date .. "'s note.", vim.log.levels.INFO)
    return
  end

  -- Locate today's "## Tasks" section and find the insertion point
  -- (last non-blank line in the section).
  local t_start, t_end = find_tasks_section(today_lines)
  if not t_start then
    vim.notify("Today's note has no '## Tasks' heading.", vim.log.levels.ERROR)
    return
  end
  local insert_at = t_end
  while insert_at > t_start and today_lines[insert_at]:match("^%s*$") do
    insert_at = insert_at - 1
  end

  -- If the only line under the heading is an empty placeholder "- [ ] ",
  -- replace it instead of appending after it.
  local replaced_placeholder = false
  if insert_at == t_start + 1 and today_lines[insert_at] and today_lines[insert_at]:match("^%- %[ %]%s*$") then
    table.remove(today_lines, insert_at)
    insert_at = insert_at - 1
    replaced_placeholder = true
  end

  -- Splice extracted tasks into today's lines.
  local new_today = {}
  for i = 1, insert_at do
    table.insert(new_today, today_lines[i])
  end
  for _, task in ipairs(extracted.tasks) do
    table.insert(new_today, task)
  end
  for i = insert_at + 1, #today_lines do
    table.insert(new_today, today_lines[i])
  end

  write_lines(today_path, new_today)

  -- Mark originals as forwarded [>].
  for _, idx in ipairs(extracted.indices) do
    prev_lines[idx] = prev_lines[idx]:gsub("%- %[ %]", "- [>]", 1)
  end
  write_lines(prev_path, prev_lines)

  -- Reload any open buffers pointing at these files.
  vim.cmd("checktime")

  vim.notify(
    string.format(
      "Rolled over %d task%s from %s%s",
      #extracted.tasks,
      #extracted.tasks == 1 and "" or "s",
      prev_date,
      replaced_placeholder and " (replaced empty placeholder)" or ""
    ),
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command("TaskRollover", rollover, {
  desc = "Copy unchecked tasks from the most recent previous daily note into today's note",
})

vim.keymap.set("n", "<leader>or", rollover, { desc = "Obsidian: rollover tasks from last daily note" })
