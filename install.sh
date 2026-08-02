#!/usr/bin/env bash
# Symlink every tracked dotfile into $HOME, mirroring this repo's layout.
# Existing real files are backed up to <file>.bak before being replaced.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Every tracked file except repo meta, mirrored relative to $HOME.
git ls-files \
  | grep -vE '^(README\.md|install\.sh|\.gitignore)$' \
  | while IFS= read -r rel; do
      src="$DOTFILES_DIR/$rel"
      dest="$HOME/$rel"
      mkdir -p "$(dirname "$dest")"
      if [ -L "$dest" ]; then
        rm "$dest"
      elif [ -e "$dest" ]; then
        mv "$dest" "$dest.bak"
        echo "backed up  $dest -> $dest.bak"
      fi
      ln -s "$src" "$dest"
      echo "linked     $dest"
    done

echo "Done."
