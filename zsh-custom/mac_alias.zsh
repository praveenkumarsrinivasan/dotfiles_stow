# macOS-specific aliases

# Navigation
alias dt='cd ~/dotfiles'
alias dl='cd ~/Downloads'
alias dk='cd ~/Desktop'
alias doc='cd ~/Documents'
alias sbx='cd ~/Documents/Sandbox'

# Recursively delete .DS_Store files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Lock the screen (AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
