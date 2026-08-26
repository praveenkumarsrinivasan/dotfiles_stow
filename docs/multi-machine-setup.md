# Multi-machine setup: personal + work Macs

## Context

The dotfiles repo at `~/dotfiles` is used on two Macs whose usernames differ:

- **Personal**: user `praveenkumarsrinivasan`, identity `Praveen Kumar Srinivasan <praveen.sxi@gmail.com>`
- **Work**: user `praveensrinivasan`, identity `Praveen Srinivasan <praveen.srinivasan@zip.co>`

Today, four spots in the repo bake in one machine's values, which causes drift in `git status` whenever the repo is touched on the "wrong" machine:

- `.config/nvim/lua/plugins/obsidian.lua:15` — absolute personal path to the Obsidian vault
- `.config/nvim/plugin/task-rollover.lua:10` — absolute *work* path to the same vault (the two files disagree)
- `.gitconfig:8-10` — single `[user]` block hardcoded to the personal identity
- `.zshrc:12` — `DEFAULT_USER="praveensrinivasan"` (used by p10k to hide `user@host` in the prompt — only effective on the work Mac)

The goal: one set of files that works on both machines with no per-machine edits, so the repo stays clean and `git pull` is the only deploy step. Machine detection uses `$USER` (the two usernames already differ uniquely). Git identity switches by repo location, not by machine, via `[includeIf "gitdir:..."]`.

## Changes

### 1. Standardize the Obsidian vault to `~/Documents/Notes/pks`

`.config/nvim/lua/plugins/obsidian.lua:15` — replace the absolute path with `~`-expansion:

```lua
path = vim.fn.expand("~/Documents/Notes/pks"),
```

`.config/nvim/plugin/task-rollover.lua:10` — same standardized location:

```lua
local VAULT = vim.fn.expand("~/Documents/Notes/pks")
```

### 2. Git identity by directory via `includeIf`

Edit `.gitconfig`:

- Keep the existing `[user]` block (personal identity) as the default — covers the dotfiles repo itself at `~/dotfiles` and any repo outside the Sandbox tree.
- Append two conditional includes near the end of the file:

```ini
[includeIf "gitdir:~/Documents/Sandbox/Personal/"]
    path = ~/.gitconfig-personal
[includeIf "gitdir:~/Documents/Sandbox/Work/"]
    path = ~/.gitconfig-work
```

Create two new tracked files in the repo root (stow will symlink them into `~`):

- `.gitconfig-personal`:
  ```ini
  [user]
      name = Praveen Kumar Srinivasan
      email = praveen.sxi@gmail.com
  ```
- `.gitconfig-work`:
  ```ini
  [user]
      name = Praveen Srinivasan
      email = praveen.srinivasan@zip.co
  ```

Both files end up at `~/.gitconfig-personal` / `~/.gitconfig-work` via stow, matching the `path =` directives. Don't add them to `.stow-local-ignore`.

Note: gitdir patterns require the trailing slash and case-sensitively match the working tree's path — the Sandbox directories must be created exactly as `Personal` and `Work`.

### 3. Make `DEFAULT_USER` machine-aware

`.zshrc:12` — replace the hardcoded value with the current shell user so p10k correctly hides `user@host` on either Mac:

```sh
DEFAULT_USER="$USER"
```

## Files to modify

- `.gitconfig` (add two `[includeIf]` blocks at the bottom)
- `.gitconfig-personal` (new)
- `.gitconfig-work` (new)
- `.config/nvim/lua/plugins/obsidian.lua` (line 15)
- `.config/nvim/plugin/task-rollover.lua` (line 10)
- `.zshrc` (line 12)

## One-time per-machine setup (manual, outside the repo)

After pulling these changes:

**Both machines:**
1. `mkdir -p ~/Documents/Sandbox/Personal ~/Documents/Sandbox/Work`
2. Move existing clones into the matching parent dir (work repos → `Sandbox/Work/`, personal → `Sandbox/Personal/`).
3. Re-run `stow -t ~ .` from `~/dotfiles` so the two new `.gitconfig-*` files get symlinked.

**Work Mac only:**
4. Move the vault: `mv ~/Documents/pks ~/Documents/Notes/pks` (create `~/Documents/Notes` first if needed). Or symlink: `mkdir -p ~/Documents/Notes && ln -s ~/Documents/pks ~/Documents/Notes/pks`.

## Verification

On each machine, after pulling and running stow:

1. `echo $USER` — confirms which profile is active.
2. `git -C ~/Documents/Sandbox/Personal/<any-repo> config user.email` → `praveen.sxi@gmail.com`.
3. `git -C ~/Documents/Sandbox/Work/<any-repo> config user.email` → `praveen.srinivasan@zip.co`.
4. `git -C ~/dotfiles config user.email` → `praveen.sxi@gmail.com` (default, since dotfiles isn't under either Sandbox dir).
5. `nvim` → `:lua print(vim.fn.expand("~/Documents/Notes/pks"))` resolves to the right absolute path on the current machine; `:ObsidianToday` opens a daily note; `:TaskRollover` runs without "file not found".
6. Open a new shell — prompt no longer shows `user@host` on either Mac (proves `DEFAULT_USER=$USER` took effect).
7. `git status` in `~/dotfiles` on each machine is clean immediately after the next sync.
