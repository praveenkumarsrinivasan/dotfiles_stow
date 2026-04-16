# Kubernetes aliases and completion

if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    complete -F __start_kubectl k
fi

alias k='kubectl'

# Get resources
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgi='kubectl get ing'

# Logs
alias klg='kubectl logs'

# Describe resources
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'

# Create/delete from file
alias kcf='kubectl create -f'
alias kdf='kubectl delete -f'
