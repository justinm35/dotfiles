#!/usr/bin/env bash
# poke every running nvim to re-stat its buffers
shopt -s nullglob
for reg in "$HOME/.cache/nvim/servers/"*; do
  sock="$(cat "$reg" 2>/dev/null)" || continue
  if [ -S "$sock" ]; then
    nvim --server "$sock" --remote-expr 'execute("checktime")' >/dev/null 2>&1 \
      || rm -f "$reg"
  else
    rm -f "$reg"   # stale, instance is gone
  fi
done
