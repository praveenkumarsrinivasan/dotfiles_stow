# find markdown files
  # findmd              # searches current directory
  # findmd ~/Documents  # searches given path
fmdr() { find "${2:-.}" -maxdepth "${1:-1}" -type f -iname "*.md"; }
fmd() { find "${1:-.}" -maxdepth 1 -type f -iname "*.md"; }
