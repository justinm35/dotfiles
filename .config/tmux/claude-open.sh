#!/usr/bin/env bash
set -euo pipefail
cwd="${1:-$HOME}"
id="$(printf '%s' "$cwd" | cksum | cut -d' ' -f1)"
sess="claudepop_${id}"

tmux has-session -t "=$sess" 2>/dev/null \
  || tmux new-session -d -s "$sess" -c "$cwd" "claude"

tmux set -g @claude_status "" 2>/dev/null || true

tmux display-popup -w 88% -h 85% \
  -E "TMUX= tmux attach-session -t '=$sess'"
