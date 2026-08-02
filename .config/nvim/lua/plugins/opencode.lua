local terms = {}

local function normalize_path(path)
  return vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
end

local function current_dir()
  local bufdir = vim.fn.expand("%:p:h")
  if bufdir ~= "" and vim.fn.isdirectory(bufdir) == 1 then
    return bufdir
  end

  return vim.fn.getcwd()
end

local function git_root(dir)
  local out = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 and #out > 0 then
    return out[1]
  end
end

local function project_root()
  local dir = current_dir()
  local home = normalize_path(vim.fn.expand("$HOME"))
  local root = git_root(dir)
  if root and normalize_path(root) == home then
    root = nil
  end
  return normalize_path(root or dir)
end

local function project_key(root)
  return vim.fn.sha256(root):sub(1, 12)
end

local function project_port(root)
  local hash = vim.fn.sha256(root):sub(1, 8)
  local value = tonumber(hash, 16) or 0
  return 20000 + (value % 40000)
end

local function term_for(root)
  root = normalize_path(root or project_root())
  local key = project_key(root)

  terms[key] = terms[key] or {
    key = key,
    cwd = root,
    port = project_port(root),
    buf = nil,
    win = nil,
    job = nil,
    pid = nil,
  }

  return terms[key]
end

local function current_term()
  return term_for(project_root())
end

local function term_by_buf(buf)
  for _, term in pairs(terms) do
    if term.buf == buf then
      return term
    end
  end
end

local function float_opts()
  local width = math.floor(vim.o.columns * 0.9)
  local editor_height = vim.o.lines - vim.o.cmdheight
  local height = math.floor(editor_height * 0.9)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((editor_height - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
  }
end

local function configure_win(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
end

local function buf_valid(term)
  return term.buf and vim.api.nvim_buf_is_valid(term.buf)
end

local function visible(term)
  return buf_valid(term) and #vim.fn.win_findbuf(term.buf) > 0
end

local function focus_terminal(term)
  if not buf_valid(term) then
    return
  end

  local win = vim.fn.bufwinid(term.buf)
  if win == -1 then
    return
  end

  term.win = win
  configure_win(win)
  vim.api.nvim_set_current_win(win)
  vim.cmd("startinsert")
end

local function hide_terminal(term)
  term = term or current_term()

  if not buf_valid(term) then
    return
  end

  local win = vim.fn.bufwinid(term.buf)
  if win ~= -1 then
    vim.api.nvim_win_hide(win)
  end
  term.win = nil
end

local function hide_other_terms(active)
  for _, term in pairs(terms) do
    if term ~= active and visible(term) then
      hide_terminal(term)
    end
  end
end

local function cleanup_terminal(term, job_id)
  if not term then
    return
  end
  if job_id and term.job and job_id ~= term.job then
    return
  end

  local buf = term.buf
  local win = term.win

  term.buf = nil
  term.win = nil
  term.job = nil
  term.pid = nil
  terms[term.key] = nil

  if win and vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_close, win, true)
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

local function terminate(pid)
  if vim.fn.has("unix") == 1 then
    os.execute("kill -TERM -" .. pid .. " 2>/dev/null")
  else
    pcall(vim.uv.kill, pid, "SIGTERM")
  end
end

local function stop_terminal(term)
  term = term or current_term()

  if term.pid then
    terminate(term.pid)
  elseif term.job then
    vim.fn.jobstop(term.job)
  end

  cleanup_terminal(term, term.job)
end

local function stop_all_terminals()
  local snapshot = vim.tbl_values(terms)
  for _, term in ipairs(snapshot) do
    stop_terminal(term)
  end
end

local function disconnect_if_project_changed(term)
  local ok, events = pcall(require, "opencode.events")
  if not ok then
    return
  end

  local server = events.connected_server
  if server and normalize_path(server.cwd) ~= term.cwd then
    events.disconnect()
  end
end

local toggle_terminal
local fresh_session
local resume_session

local function setup_terminal_keymaps(term)
  _G.__opencode_float_hide = function(key)
    hide_terminal(terms[key])
  end
  _G.__opencode_float_toggle = function(key)
    toggle_terminal(terms[key])
  end
  _G.__opencode_float_fresh = function(key)
    fresh_session(terms[key])
  end
  _G.__opencode_float_resume = function(key)
    resume_session(terms[key])
  end

  local key = term.key
  local hide = string.format([[<C-\><C-n><Cmd>lua _G.__opencode_float_hide("%s")<CR>]], key)
  local toggle = string.format([[<C-\><C-n><Cmd>lua _G.__opencode_float_toggle("%s")<CR>]], key)
  local fresh = string.format([[<C-\><C-n><Cmd>lua _G.__opencode_float_fresh("%s")<CR>]], key)
  local resume = string.format([[<C-\><C-n><Cmd>lua _G.__opencode_float_resume("%s")<CR>]], key)
  local interrupt = [[<C-\><C-n><Cmd>lua require("opencode").command("session.interrupt")<CR>]]

  local t_opts = { buffer = term.buf, noremap = true, silent = true, nowait = true }
  pcall(vim.keymap.del, "t", "<Esc><Esc>", { buffer = term.buf })
  vim.keymap.set("t", "<C-c>", hide, vim.tbl_extend("force", t_opts, { desc = "Hide opencode" }))
  vim.keymap.set("t", "<M-o>", toggle, vim.tbl_extend("force", t_opts, { desc = "Toggle opencode" }))
  vim.keymap.set("t", "<leader>on", fresh, vim.tbl_extend("force", t_opts, { desc = "New opencode session" }))
  vim.keymap.set("t", "<leader>or", resume, vim.tbl_extend("force", t_opts, { desc = "Resume opencode session" }))
  vim.keymap.set("t", "<C-g>", interrupt, vim.tbl_extend("force", t_opts, { desc = "Interrupt opencode" }))

  local n_opts = { buffer = term.buf, noremap = true, silent = true, nowait = true }
  vim.keymap.set("n", "q", function()
    hide_terminal(term)
  end, vim.tbl_extend("force", n_opts, { desc = "Hide opencode" }))
  vim.keymap.set("n", "<C-c>", function()
    hide_terminal(term)
  end, vim.tbl_extend("force", n_opts, { desc = "Hide opencode" }))
  vim.keymap.set("n", "<C-g>", function()
    require("opencode").command("session.interrupt")
  end, vim.tbl_extend("force", n_opts, { desc = "Interrupt opencode" }))
  vim.keymap.set("n", "<C-u>", function()
    require("opencode").command("session.half.page.up")
  end, vim.tbl_extend("force", n_opts, { desc = "Scroll opencode up" }))
  vim.keymap.set("n", "<C-d>", function()
    require("opencode").command("session.half.page.down")
  end, vim.tbl_extend("force", n_opts, { desc = "Scroll opencode down" }))
  vim.keymap.set("n", "gg", function()
    require("opencode").command("session.first")
  end, vim.tbl_extend("force", n_opts, { desc = "First opencode message" }))
  vim.keymap.set("n", "G", function()
    require("opencode").command("session.last")
  end, vim.tbl_extend("force", n_opts, { desc = "Last opencode message" }))
end

local function show_terminal(term)
  if not buf_valid(term) then
    return false
  end

  hide_other_terms(term)

  if not visible(term) then
    term.win = vim.api.nvim_open_win(term.buf, true, float_opts())
  end

  focus_terminal(term)
  return true
end

local function open_terminal(term)
  term = term or current_term()
  disconnect_if_project_changed(term)

  if show_terminal(term) then
    return
  end

  local previous_win = vim.api.nvim_get_current_win()

  term.buf = vim.api.nvim_create_buf(false, false)
  vim.bo[term.buf].bufhidden = "hide"
  vim.bo[term.buf].swapfile = false
  pcall(vim.api.nvim_buf_set_name, term.buf, "opencode://" .. term.key)

  term.win = vim.api.nvim_open_win(term.buf, true, float_opts())
  configure_win(term.win)

  local job = vim.fn.jobstart({ "opencode", "--continue", "--port", tostring(term.port) }, {
    cwd = term.cwd,
    env = {
      OPENCODE_ENABLE_EXA = "1",
    },
    term = true,
    on_exit = function(job_id)
      vim.schedule(function()
        cleanup_terminal(term, job_id)
      end)
    end,
  })

  if job <= 0 then
    vim.notify("Failed to start opencode", vim.log.levels.ERROR, { title = "opencode" })
    cleanup_terminal(term)
    if vim.api.nvim_win_is_valid(previous_win) then
      vim.api.nvim_set_current_win(previous_win)
    end
    return
  end

  term.job = job
  local ok, pid = pcall(vim.fn.jobpid, job)
  if ok then
    term.pid = pid
  end

  setup_terminal_keymaps(term)

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = term.buf,
    once = true,
    callback = function()
      terms[term.key] = nil
    end,
  })

  focus_terminal(term)
end

toggle_terminal = function(term)
  term = term or current_term()
  disconnect_if_project_changed(term)

  if visible(term) then
    hide_terminal(term)
  else
    open_terminal(term)
  end
end

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    {
      ---@module "snacks"
      "folke/snacks.nvim",
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  init = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        port = function(callback)
          callback(current_term().port)
        end,
        start = function()
          open_terminal(current_term())
        end,
        stop = function()
          stop_terminal(current_term())
        end,
        toggle = function()
          toggle_terminal(current_term())
        end,
      },
    }
  end,
  config = function()
    local opencode = require("opencode")

    vim.o.autoread = true -- Required for `opts.events.reload`

    local function ensure_project_server(term)
      term = term or current_term()
      disconnect_if_project_changed(term)
      return term
    end

    local function ensure_visible(term)
      term = ensure_project_server(term)

      if not visible(term) then
        open_terminal(term)
      else
        focus_terminal(term)
      end
    end

    local function after_server_ready(term, cb)
      term = ensure_project_server(term)

      local server = require("opencode.events").connected_server
      if server and normalize_path(server.cwd) == term.cwd then
        cb()
        return
      end

      require("opencode.server")
        .get()
        :next(function()
          vim.schedule(cb)
        end)
        :catch(function(err)
          if err then
            vim.notify("Failed to connect to opencode: " .. err, vim.log.levels.WARN, { title = "opencode" })
          end
        end)
    end

    fresh_session = function(term)
      term = term or current_term()
      ensure_visible(term)
      after_server_ready(term, function()
        opencode.command("session.new")
      end)
    end

    resume_session = function(term)
      term = term or current_term()
      ensure_visible(term)
      after_server_ready(term, function()
        require("opencode.ui.select_session").select_session()
      end)
    end

    _G.__opencode_float_hide = function(key)
      hide_terminal(terms[key])
    end
    _G.__opencode_float_toggle = function(key)
      toggle_terminal(terms[key])
    end
    _G.__opencode_float_fresh = function(key)
      fresh_session(terms[key])
    end
    _G.__opencode_float_resume = function(key)
      resume_session(terms[key])
    end

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      ensure_project_server()
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<leader>ox", function()
      ensure_project_server()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })
    vim.keymap.set("n", "<M-o>", function()
      toggle_terminal(current_term())
    end, { desc = "Toggle opencode" })
    vim.keymap.set("n", "<leader>on", function()
      fresh_session(current_term())
    end, { desc = "New opencode session" })
    vim.keymap.set("n", "<leader>or", function()
      resume_session(current_term())
    end, { desc = "Resume opencode session" })

    vim.keymap.set({ "n", "x" }, "go", function()
      ensure_project_server()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function()
      ensure_project_server()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function()
      ensure_project_server()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function()
      ensure_project_server()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })

    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("OpencodeTermOpts", { clear = true }),
      callback = function(args)
        local term = term_by_buf(args.buf)
        if not term then
          return
        end

        local win = vim.fn.bufwinid(args.buf)
        if win ~= -1 then
          configure_win(win)
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
      group = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true }),
      callback = function(args)
        if not term_by_buf(args.buf) then
          return
        end

        vim.schedule(function()
          vim.cmd("checktime")
        end)
      end,
    })

    vim.api.nvim_create_autocmd("ExitPre", {
      group = vim.api.nvim_create_augroup("OpencodeTerminalExit", { clear = true }),
      callback = stop_all_terminals,
    })
  end,
}
