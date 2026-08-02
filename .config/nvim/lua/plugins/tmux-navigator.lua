return {
  'christoomey/vim-tmux-navigator',
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
    local opts = { silent = true }
    vim.keymap.set('n', '<C-h>', ':TmuxNavigateLeft<CR>', opts)
    vim.keymap.set('n', '<C-j>', ':TmuxNavigateDown<CR>', opts)
    vim.keymap.set('n', '<C-k>', ':TmuxNavigateUp<CR>', opts)
    vim.keymap.set('n', '<C-l>', ':TmuxNavigateRight<CR>', opts)
    -- in terminal:
    vim.keymap.set('t', '<C-h>', '<C-\\><C-n>:TmuxNavigateLeft<CR>', opts)
    vim.keymap.set('t', '<C-j>', '<C-\\><C-n>:TmuxNavigateDown<CR>', opts)
    vim.keymap.set('t', '<C-k>', '<C-\\><C-n>:TmuxNavigateUp<CR>', opts)
    vim.keymap.set('t', '<C-l>', '<C-\\><C-n>:TmuxNavigateRight<CR>', opts)
  end
}
