# fzf Setup
eval "$(fzf --zsh)"

# Wire into fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1"; }

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'" export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

alias inv='nvim $(fzf -m --preview="bat --color=always {}")'

# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias z="cd"


# Previews (with bat + eza)
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

# eza
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza --tree --level=2 --icons"


