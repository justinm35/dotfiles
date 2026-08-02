---
name: code-walkthrough
description: >
  Walk the user through a code path by driving their Neovim live: jump the
  cursor, highlight the relevant lines, and explain each step in chat. Trigger
  when the user asks to "walk me through", "trace", "step through", "explain
  how X works", or otherwise wants a guided tour of a code path in their editor.
---

# Code walkthrough

You drive the user's running Neovim with `~/.config/scripts/nvimctl` while you
narrate the logic in chat. The editor shows *where*; chat carries the *why*.

## Procedure

1. Read the relevant files first. Trace the actual execution order (entry point,
   then each call it makes), not the order files happen to sit in.
2. Plan an ordered list of stops: function entry, branch, call site, mutation.
3. Present ONE stop at a time. For each stop:
   - Run:
     `nvimctl --dir <project root> step '{"file":"<abs path>","line":<n>,"hl_start":<n>,"hl_end":<n>,"note":"<one-liner>"}'`
     Always use absolute paths. Omit hl_start/hl_end to highlight only `line`.
   - Explain that stop in chat: what runs, what it does, why it matters.
   - Stop and wait for the user to say "next", ask, or redirect.
4. When done or at the end, run `nvimctl clear`.

## Targeting the right nvim

- Before the first step: `nvimctl --dir <project root> count`.
  - 1: proceed, passing `--dir <project root>` on every step.
  - more than 1: run `nvimctl --dir <project root> which`, show the panes, ask
    which, then pass BOTH `--dir <root>` and `--pane <%n>` on every step.
  - 0: ask the user to focus the nvim they want driven, then retry.

## Rules

- One stop per turn. Keep `note` to a few words; real explanation goes in chat.
