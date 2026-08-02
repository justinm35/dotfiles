-- Live-reload buffers when files change on disk (e.g. edits made by Claude
-- or other external tools). autoread alone doesn't poll, so we nudge it.
vim.opt.autoread = true
vim.opt.updatetime = 1000 -- CursorHold fires after 1s idle

local grp = vim.api.nvim_create_augroup("live_reload", { clear = true })

-- fallback nudge for non-Claude edits; autoread doesn't poll on its own
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" },
  {
    group = grp,
    callback = function()
      if vim.fn.mode() ~= "c" then
        vim.cmd("checktime")
      end
    end,
  }
)

-- flash a message when a buffer gets reloaded under you
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = grp,
  callback = function()
    vim.notify("buffer reloaded from disk", vim.log.levels.INFO)
  end,
})

-- register this instance's RPC socket so the reload script can find it
local dir = vim.fn.expand("~/.cache/nvim/servers")
vim.fn.mkdir(dir, "p")
local reg = dir .. "/" .. vim.fn.getpid()
vim.fn.writefile({ vim.v.servername }, reg)
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = grp,
  callback = function()
    vim.fn.delete(reg)
  end,
})
