local M = {}

local state = {
  winnr = -1,
  bufnr = nil,
  chan_id = nil
}

local is_open = nil

local hide_chat_terminal = function()
  vim.api.nvim_win_hide(state.winnr)
end


local open_gemini_cli = function()
  state.chan_id = vim.fn.termopen({ "gemini" }, {
    cwd = vim.loop.cwd(),
    on_exit = function(_, code, _)
      if code ~= 0 then
        vim.notify("Gemini CLI terminó con código: " .. code, vim.log.levels.WARN)
      end
    end,
  })
end

local set_chat_windown = function()
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_set_current_win(state.winnr)

    return
  end
end

local create_floating_window = function(opts)
  opts = opts or {}

  -- Obtener dimensiones del viewport
  local width = vim.o.columns
  local height = vim.o.lines

  local win_width = math.floor(opts.width or (width * 0.4))
  local win_height = math.floor(opts.height or (height * 0.9))

  local buf
  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
    state.bufnr = buf
  end

  -- Borde solo en el lado izquierdo (plano)
  local left_border = {
    { " ", "Normal" },
    { " ", "Normal" },
    { " ", "Normal" },
    { " ", "Normal" },
    { " ", "Normal" },
    { " ", "Normal" },
    { " ", "Normal" },
    { "│", "FloatBorder" },
  }

  local win_opts = {
    relative = "editor",
    width = win_width,
    height = height,
    row = math.floor((height - win_height) / 2),
    col = width - win_width,
    style = "minimal",
    border = left_border,
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)


  return { winnr = win, bufnr = buf }
end

local open_chat_code = function()
  state = create_floating_window({ buf = state.bufnr })

  if not is_open then
    open_gemini_cli()

    is_open = true
  end

  vim.cmd("startinsert")
end

M.chatcode = function()
  local toggle_chat = function()
    if not vim.api.nvim_win_is_valid(state.winnr) then
      open_chat_code()
    else
      hide_chat_terminal()
    end
  end

  vim.api.nvim_create_user_command("ChatCode", toggle_chat, {})
  vim.keymap.set({ 'n', 't' }, '<leader>cc', toggle_chat, { desc = "Toggle floating terminal" })
  vim.keymap.set({ 'n', 't' }, '<leader>l', set_chat_windown)
end


M.setup = function(opts)
end





return M
