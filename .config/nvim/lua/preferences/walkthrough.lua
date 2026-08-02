local M = {}
local ns = vim.api.nvim_create_namespace('walkthrough')
local cache = vim.fn.expand('~/.cache/nvim')
local payload_path = cache .. '/walkthrough.json'

local meta_dir = cache .. '/meta'
vim.fn.mkdir(meta_dir, 'p')
local meta_file = meta_dir .. '/' .. vim.fn.getpid() .. '.json'
local function register()
  pcall(vim.fn.writefile, { vim.json.encode({
    socket  = vim.v.servername,
    cwd     = vim.fn.getcwd(),
    pane    = vim.env.TMUX_PANE or '',
    focused = os.time(),
  }) }, meta_file)
end
register()
local rgrp = vim.api.nvim_create_augroup('walk_meta', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'DirChanged' }, { group = rgrp, callback = register })
vim.api.nvim_create_autocmd('VimLeavePre', { group = rgrp, callback = function() vim.fn.delete(meta_file) end })

local function read_payload()
  local ok, data = pcall(vim.fn.readfile, payload_path)
  if not ok then return nil end
  return vim.json.decode(table.concat(data, '\n'))
end

function M.step()
  local ok, err = pcall(function()
    local s = read_payload()
    if not s then return end
    if M._last_buf and vim.api.nvim_buf_is_valid(M._last_buf) then
      vim.api.nvim_buf_clear_namespace(M._last_buf, ns, 0, -1)
    end
    vim.cmd('edit ' .. vim.fn.fnameescape(s.file))
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local line = s.line or 1
    local hs = s.hl_start or line
    local he = s.hl_end or line
    local mid = math.floor((hs + he) / 2)

    -- center the view on the middle of the block
    vim.api.nvim_win_set_cursor(0, { mid, 0 })
    vim.cmd('normal! zz')
    -- then place the cursor at the actual start of the stop
    vim.api.nvim_win_set_cursor(0, { line, math.max((s.col or 1) - 1, 0) })

    for l = hs, he do
      vim.api.nvim_buf_set_extmark(buf, ns, l - 1, 0, { line_hl_group = 'Visual' })
    end
    M._last_buf = buf
    if s.note and #s.note > 0 then
      vim.api.nvim_echo({ { '● ' .. s.note, 'WarningMsg' } }, false, {})
    end
  end)
  if not ok then
    vim.api.nvim_echo({ { 'walkthrough: ' .. tostring(err), 'ErrorMsg' } }, false, {})
  end
end

function M.clear()
  if M._last_buf and vim.api.nvim_buf_is_valid(M._last_buf) then
    vim.api.nvim_buf_clear_namespace(M._last_buf, ns, 0, -1)
  end
  vim.api.nvim_echo({ { '' } }, false, {})
end

vim.api.nvim_create_user_command('WalkStep', M.step, {})
vim.api.nvim_create_user_command('WalkClear', M.clear, {})
return M
