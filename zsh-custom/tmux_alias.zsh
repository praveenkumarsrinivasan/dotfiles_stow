# Session management
alias tn='tmux new -s'              # tn mysession
alias ta='tmux attach -t'           # ta mysession
alias tat='tmux attach -t'
alias tl='tmux ls'
alias tk='tmux kill-session -t'     # tk mysession
alias tka='tmux kill-server'

# Quick attach to last / create if none
alias t='tmux attach || tmux new'

# Detach from within
alias td='tmux detach'

# Rename current session/window
alias trs='tmux rename-session'
alias trw='tmux rename-window'

# List things
alias tls='tmux list-sessions'
alias tlw='tmux list-windows'
