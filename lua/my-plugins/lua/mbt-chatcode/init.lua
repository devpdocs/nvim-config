local M = {}

local state = {
  winnr = -1,
  bufnr = -1,
  chan_id = nil,
}

local is_open = nil

local check_and_install_gemini_cli = function()
  if vim.fn.executable("gemini") == 1 then
    return true
  end

  -- Not installed, ask the user
  local answer = vim.fn.input("gemini-cli not found. Install with npm? (y/n): ")
  if string.lower(answer or "") ~= "y" then
    vim.notify("Installation skipped.", vim.log.levels.WARN)
    return false
  end

  -- User agreed, attempt installation
  --
  vim.notify("Installing @google/gemini-cli via npm...", vim.log.levels.INFO)

  local cmd = "npm install -g @google/gemini-cli"

  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.notify("Gemini CLI installation finished. Please restart Neovim to use the plugin.")
    end,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to install gemini-cli. Error: " .. output, vim.log.levels.ERROR)
    return false
  end

  -- Verify installation after attempting to install
  if vim.fn.executable("gemini") == 1 then
    vim.notify("gemini-cli installed successfully!", vim.log.levels.INFO)
  else
    vim.notify("Installation command ran, but 'gemini' is still not in PATH.", vim.log.levels.ERROR)
    return false
  end
  return true
end

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

local kill_chat_code = function()
  is_open = false

  if vim.api.nvim_buf_is_valid(state.bufnr) then
    vim.api.nvim_buf_delete(state.bufnr, { force = true })
    state.bufnr = -1

    vim.notify("Chat code has been closed", vim.log.levels.INFO, {
      title = "chatcode_nvim",
    })
  else
    vim.notify("There isn't chat code open", vim.log.levels.WARN, {
      title = "chatcode_nvim",
    })
  end
end

M.chatcode = function()
  local function decrease_width()
    if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
      local current_width = vim.api.nvim_win_get_width(state.winnr)
      vim.api.nvim_win_set_width(state.winnr, current_width + 5)
    end
  end

  local function increase_width()
    if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
      local current_width = vim.api.nvim_win_get_width(state.winnr)
      vim.api.nvim_win_set_width(state.winnr, current_width - 5)
    end
  end

  local toggle_chat = function()
    if not vim.api.nvim_win_is_valid(state.winnr) then
      open_chat_code()
    else
      hide_chat_terminal()
    end
  end

  vim.api.nvim_create_user_command("ChatCode", toggle_chat, {})
  vim.keymap.set({ "n", "t" }, "<leader>cc", toggle_chat, { desc = "Toggle floating terminal" })
  vim.keymap.set({ "n", "t" }, "<leader>cl", set_chat_windown)
  vim.keymap.set({ "n", "t" }, "<leader><Right>", increase_width, { desc = "Increase chat width" })
  vim.keymap.set({ "n", "t" }, "<leader><Left>", decrease_width, { desc = "Decrease chat width" })
end

M.setup = function(opts)

  if not check_and_install_gemini_cli() then
    return
  end

  if opts.kill_chat_code == true then
    vim.api.nvim_create_user_command("ChatCodeKill", kill_chat_code, {})
    vim.keymap.set({ "n", "t" }, "<leader>cd", kill_chat_code)
  end

  
end

return M
