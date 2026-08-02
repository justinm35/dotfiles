-- Allow half page jumping with cursor in middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Move highlighted chunk
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keep copied text in paste buffer
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Switch Tmux Sessions
vim.keymap.set("n", "<leader>ts", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>")
vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- navigate the quick fix list
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set('n', '<leader>qd', function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = 'Diagnostics → Quickfix' })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>ql", "<cmd>lopen<CR>", { desc = "Open location list" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [jj] to escape insert mode
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })

-- open file_browser with the path of the current buffer
vim.keymap.set("n", "<space>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

-- Open the undo tree
vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { noremap = true, silent = true, buffer = bufnr })


-----------------------------------
---------- Neogit ----------
-----------------------------------
-- vim.keymap.set("n", "<leader>gg", function()
--   require("neogit").open({ kind = "floating" })
-- end, { noremap = true, silent = true, desc = "Open Neogit popup" })


-----------------------------------
---------- Git Diff View ----------
-----------------------------------
-- vim.keymap.set("n", "gd", function()
--   vim.cmd("DiffviewOpen")
-- end, { noremap = true, silent = true, desc = "Open Diffview" })

vim.keymap.set("n", "gq", function()
  vim.cmd("DiffviewClose")
end, { noremap = true, silent = true, desc = "Quit Diffview" })



-----------------------------------
------------- Utils --------------
-----------------------------------
---
-- Map Cmd+Shift+, to copy the relative path of the current file
vim.keymap.set("n", "<D-S-,>", function()
  local relative_path = vim.fn.expand("%")
  vim.fn.setreg("+", relative_path)
  print("Relative path copied: " .. relative_path)
end, { noremap = true, silent = true })


-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Preview Git hunk inline (gitsigns)
vim.keymap.set("n", "<leader>hp", function()
  require("gitsigns").preview_hunk_inline()
end, { noremap = true, silent = true, desc = "Preview Git hunk inline" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>ii', ':AiderOpen<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>da', ':AiderAddModifiedFiles<CR>', { noremap = true, silent = true })

-- Map Cmd+Shift+, to copy the relative path of the current file
vim.keymap.set("n", "<D-<>", function()
  local relative_path = vim.fn.expand("%")
  vim.fn.setreg("+", relative_path)
  print("Relative path copied: " .. relative_path)
end, { noremap = true, silent = true, desc = "Copy relative file path" })
