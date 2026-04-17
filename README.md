# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's in here

- `.config/` — Neovim (LazyVim), Alacritty, Ghostty, GitHub CLI
- `.zshrc`, `.p10k.zsh` — zsh + Powerlevel10k
- `.tmux.conf` — tmux config
- `.gitconfig`, `.gitignore_global` — git config
- `zsh-custom/` — sourced from `.zshrc`: aliases, functions, keybindings (not stowed)
- `bin/install.sh` — bootstrap script (not stowed)

## Install

```sh
git clone --recursive git@github.com:praveensxi/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bin/install.sh
```

Or manually:

```sh
brew install stow
stow -t ~ .
```

`.stow-local-ignore` excludes `bin/`, `zsh-custom/`, and meta files from symlinking.

## Update

```sh
cd ~/dotfiles && git pull && stow -R -t ~ .
```

## Uninstall

```sh
cd ~/dotfiles && stow -D -t ~ .
```
