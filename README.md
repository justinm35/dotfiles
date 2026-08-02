# dotfiles

Personal macOS config, versioned. Mirrors `$HOME` layout — a file at
`.config/tmux/tmux.conf` here belongs at `~/.config/tmux/tmux.conf`.

## What's included

- **Shell**: `.zshenv`, `.zprofile`, `.zshrc`, `.zshrc.pre-oh-my-zsh`, `.profile`,
  `.bashrc`, `.fzf.zsh`, `.fzf.bash`, and the real config under `.config/zsh/`
  (`.zshrc`, `.zshenv`, `.p10k.zsh`). `ZDOTDIR` is `~/.config/zsh`.
- **Git**: `.gitconfig` (identity uses personal email) and `.config/git/ignore`
  (global gitignore).
- **Terminal / tools**: `.config/ghostty`, `.config/tmux` (conf + helper scripts,
  no installed plugins), `.config/lazygit`, `.config/lazynotion`, `.config/gh-dash`,
  `.config/hammerspoon`, `.config/scripts`.
- **Claude Code**: `.claude/settings.json`, `.claude/settings.local.json`,
  `.claude/statusline-command.sh`, `.claude/skills/`.
- **Neovim**: full config under `.config/nvim` (init.lua, lua/, lazy-lock.json).

## Deliberately NOT included

- Secrets: `.npmrc` (had a token — rotate it), `.netrc`, `.env.secrets`, `.ssh`,
  `.aws`, `.kube`, `.docker`, `.pulumi`, `.terraform.d`, `.mcp-auth`, gcloud/gh/op
  credentials, Claude credentials & session state.
- Reinstallable toolchains/frameworks: `.oh-my-zsh`, `.nvm`, `.nodenv`, `.volta`,
  `.cargo`, `.rustup`, `.gem`, `.bun`, Homebrew.
- History, caches, and OS cruft.

`.gitignore` hard-blocks the secret paths as a safety net.

## Install on a new machine

```sh
git clone git@github.com:justinm35/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

`install.sh` symlinks each tracked file into `$HOME` (backing up anything already
there to `*.bak`). Review it before running.
