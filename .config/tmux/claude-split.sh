#!/usr/bin/env bash
set -euo pipefail
cwd="${1:-$HOME}"
id="$(printf '%s' "$cwd" | cksum | cut -d' ' -f1)"
sess="claudepop_${id}"

# if a claude split is already in this window, close it (toggle off)
existing="$(tmux list-panes -F '#{pane_id} #{@claude_pane}' \
  | awk '$2=="1"{print $1; exit}')"
if [ -n "$existing" ]; then
  tmux kill-pane -t "$existing"
  exit 0
fi

# otherwise ensure the session exists and open the split
tmux has-session -t "=$sess" 2>/dev/null \
  || tmux new-session -d -s "$sess" -c "$cwd" "claude"

tmux set -g @claude_status "" 2>/dev/null || true

pane="$(tmux split-window -h -l 33% -c "$cwd" -P -F '#{pane_id}' \
  "TMUX= tmux attach-session -t '=$sess'")"
# tag it so the toggle can find it next time
tmux set -p -t "$pane" @claude_pane 1
