# Path to your oh-my-zsh configuration.
export ZSH="$HOME/.oh-my-zsh"

# Mac user
DEFAULT_USER="praveensrinivasan"

#ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"

COMPLETION_WAITING_DOTS="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'
export PATH=$HOME/.local/bin:$PATH
export PATH="$HOME/bin:$PATH"

# Source custom aliases and functions
for f in ~/dotfiles/zsh-custom/*.zsh; do source "$f"; done


