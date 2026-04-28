# find markdown files
  # findmd              # searches current directory
  # findmd ~/Documents  # searches given path
fmdr() { find "${2:-.}" -maxdepth "${1:-1}" -type f -iname "*.md"; }
fmd() { find "${1:-.}" -maxdepth 1 -type f -iname "*.md"; }

# Render a markdown file in the terminal with Mermaid blocks as inline diagrams.
# Requires: mdcat, mermaid-cli (mmdc). Uses Ghostty's Kitty graphics protocol.
mdpreview() {
  local file="$1"
  if [[ -z "$file" || ! -r "$file" ]]; then
    echo "usage: mdpreview <markdown-file>" >&2
    return 1
  fi
  local tmpdir
  tmpdir=$(mktemp -d -t mdpreview) || return 1
  local rendered="$tmpdir/rendered.md"

  awk -v dir="$tmpdir" '
    /^```mermaid[[:space:]]*$/ { in_block=1; n++; out=dir"/d"n".mmd"; next }
    /^```[[:space:]]*$/ && in_block { in_block=0; close(out); print "![mermaid](" dir "/d" n ".png)"; next }
    in_block { print > out; next }
    { print }
  ' "$file" > "$rendered"

  for mmd in "$tmpdir"/*.mmd(N); do
    mmdc -i "$mmd" -o "${mmd%.mmd}.png" -b transparent >/dev/null 2>&1
  done

  # Inside tmux, TERM_PROGRAM=tmux hides the outer terminal from mdcat,
  # so it falls back to ANSI and skips images. Override so mdcat emits
  # Kitty graphics; tmux's allow-passthrough forwards them to Ghostty.
  if [[ -n "$TMUX" ]]; then
    TERM_PROGRAM=ghostty mdcat "$rendered"
  else
    mdcat "$rendered"
  fi
  rm -rf "$tmpdir"
}
