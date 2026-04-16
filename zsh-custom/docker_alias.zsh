# Docker aliases

alias doci='docker images'
alias docrmi='docker rmi'
alias docps='docker ps -a'
alias docrm='docker rm'
alias docs='docker stop'
alias dcup='docker-compose up -d'
alias dcdn='docker-compose down'
alias dcps='docker-compose ps'
alias dclogs='docker-compose logs'

# Stop and remove all containers
alias docsall='docker stop $(docker ps -a -q)'
alias docrmall='docker rm $(docker ps -a -q)'

# Remove dangling images
alias docrminone='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'

# Remove all images
alias docrmiall='docker image prune -a'
