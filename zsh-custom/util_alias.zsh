# Utility aliases (platform-independent)

alias p='pwd'
alias dh='dirs -v'
alias s='du -sch'
alias ll='ls -al'

# Tree-like directory display
alias t='find . -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g"'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Intuitive map function (e.g., find . -name .gitattributes | map dirname)
alias map='xargs -n1'

# Move files from subfolders to parent folder
alias sub2par='find . -maxdepth 2 -type f -exec mv {} .. \;'

alias c='claude'
alias cdan='claude --dangerously-skip-permissions'