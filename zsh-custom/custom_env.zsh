# Linux-specific environment variables.
export PATH="$HOME/.local/bin:$PATH"

# Machine-specific environment variables. Edit paths before use.
# export JAVA_HOME=$(/usr/libexec/java_home)

export DOTFILES_DIR=~/dotfiles

# Let gpg-agent/pinentry find the current terminal (needed by pass).
export GPG_TTY=$(tty)

