#!/usr/bin/env bash
set -e

DOTFILES=~/dotfiles

echo "==> Cloning dotfiles..."
git clone --recursive git@github.com:praveensxi/dotfiles.git "$DOTFILES" 2>/dev/null || true
cd "$DOTFILES"

echo "==> Installing stow..."
brew install stow 2>/dev/null || sudo apt install -y stow

echo "==> Stowing dotfiles..."
stow -t ~ .

echo "==> Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "==> Installing tmux plugins (TPM)..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true

echo "==> Done! Restart your shell."
