local M = {}

local default_config = {
  tool = "opencode",
  kill_chat_code = false,
  providers = {
    -- qwen = {
    --   cmd = { "qwen" },
    -- },
    opencode = {
      cmd = { "opencode" },
      agent = "build",
    },
    gemini = {
      cmd = { "gemini" },
    },
    codex = {
      cmd = { "codex" },
    },
    claude = {
      cmd = { "claude" },
    },
  },
}

local config = vim.deepcopy(default_config)

local state = {
  winnr = -1,
  bufnr = -1,
  chan_id = nil,
}

local is_open = false
local active_tool = default_config.tool

local function normalize_cmd(cmd)
  if type(cmd) == "string" then
    return { cmd }
  end

  if type(cmd) == "table" and #cmd > 0 then
    return cmd
  end

  return nil
end

local function ensure_codex_bypass_flag(provider_name, cmd)
  if provider_name ~= "codex" then
    return cmd
  end

  local flag = "--dangerously-bypass-approvals-and-sandbox"
  for _, arg in ipairs(cmd) do
    if arg == flag then
      return cmd
    end
  end

  local patched_cmd = vim.deepcopy(cmd)
  table.insert(patched_cmd, flag)
  return patched_cmd
end

local function ensure_opencode_agent_flag(provider_name, provider)
  if provider_name ~= "opencode" then
    return provider.cmd
  end

  for _, arg in ipairs(provider.cmd) do
    if arg == "--agent" or string.match(arg, "^%-%-agent=") then
      return provider.cmd
    end
  end

  local agent = vim.trim(tostring(provider.agent or ""))
  if agent == "" then
    return provider.cmd
  end

  local patched_cmd = vim.deepcopy(provider.cmd)
  table.insert(patched_cmd, "--agent")
  table.insert(patched_cmd, agent)
  return patched_cmd
end

local function list_provider_names()
  local names = {}
  for name, _ in pairs(config.providers or {}) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

local function check_and_install_gemini_cli()
  if vim.fn.executable("gemini") == 1 then
    return true
  end

  local answer = vim.fn.input("gemini-cli not found. Install with npm? (y/n): ")
  if string.lower(answer or "") ~= "y" then
    vim.notify("Installation skipped.", vim.log.levels.WARN, { title = "chatcode_nvim" })
    return false
  end

  vim.notify("Installing @google/gemini-cli via npm...", vim.log.levels.INFO, { title = "chatcode_nvim" })
  local output = vim.fn.system({ "npm", "install", "-g", "@google/gemini-cli" })

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to install gemini-cli: " .. (output or ""), vim.log.levels.ERROR, { title = "chatcode_nvim" })
    return false
  end

  if vim.fn.executable("gemini") == 1 then
    vim.notify("gemini-cli installed successfully!", vim.log.levels.INFO, { title = "chatcode_nvim" })
    return true
  end

  vim.notify("Installation finished, but 'gemini' is still not in PATH.", vim.log.levels.ERROR, { title = "chatcode_nvim" })
  return false
end

local function ensure_provider_available(provider_name)
  local provider = config.providers[provider_name]
  if not provider then
    vim.notify("Unknown provider: " .. tostring(provider_name), vim.log.levels.ERROR, { title = "chatcode_nvim" })
    return false
  end

  provider.cmd = normalize_cmd(provider.cmd)
  if not provider.cmd then
    vim.notify("Invalid command for provider: " .. provider_name, vim.log.levels.ERROR, { title = "chatcode_nvim" })
    return false
  end
  provider.cmd = ensure_codex_bypass_flag(provider_name, provider.cmd)
  provider.cmd = ensure_opencode_agent_flag(provider_name, provider)

  local executable = provider.cmd[1]
  if vim.fn.executable(executable) == 1 then
    return true
  end

  if provider_name == "gemini" and executable == "gemini" then
    return check_and_install_gemini_cli()
  end

  vim.notify(
    string.format("Provider '%s' is not available. Missing executable: %s", provider_name, executable),
    vim.log.levels.ERROR,
    { title = "chatcode_nvim" }
  )
  return false
end

local function hide_chat_terminal()
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_win_hide(state.winnr)
  end
end

local function set_chat_windown()
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_set_current_win(state.winnr)
    return
  end
end

local function create_floating_window(opts)
  opts = opts or {}

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

local function open_provider_cli(provider_name)
  local provider = config.providers[provider_name]

  state.chan_id = vim.fn.termopen(provider.cmd, {
    cwd = vim.loop.cwd(),
    on_exit = function(_, code, _)
      if code ~= 0 then
        vim.notify(
          string.format("%s terminó con código: %s", provider_name, tostring(code)),
          vim.log.levels.WARN,
          { title = "chatcode_nvim" }
        )
      end
    end,
  })

  if state.chan_id <= 0 then
    vim.notify("Failed to open terminal for provider: " .. provider_name, vim.log.levels.ERROR, { title = "chatcode_nvim" })
    return false
  end

  return true
end

local function open_chat_code()
  state = create_floating_window({ buf = state.bufnr })

  if not is_open then
    if not ensure_provider_available(active_tool) then
      hide_chat_terminal()
      return
    end

    if not open_provider_cli(active_tool) then
      hide_chat_terminal()
      return
    end

    is_open = true
  end

  vim.cmd("startinsert")
end

local function kill_chat_code()
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

local function set_active_tool(tool_name, opts)
  opts = opts or {}

  if not config.providers[tool_name] then
    vim.notify("Invalid tool: " .. tostring(tool_name), vim.log.levels.ERROR, { title = "chatcode_nvim" })
    return false
  end

  active_tool = tool_name

  local available = ensure_provider_available(active_tool)
  if not available then
    vim.notify(
      "Tool selected but unavailable right now: " .. active_tool,
      vim.log.levels.WARN,
      { title = "chatcode_nvim" }
    )
  end

  vim.notify("Active ChatCode tool: " .. active_tool, vim.log.levels.INFO, { title = "chatcode_nvim" })

  if opts.restart and is_open then
    kill_chat_code()
    open_chat_code()
  end

  return true
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

  local function toggle_chat()
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
  opts = opts or {}
  config = vim.tbl_deep_extend("force", vim.deepcopy(default_config), opts)

  if not config.providers[config.tool] then
    vim.notify(
      string.format("Unknown default tool '%s'. Falling back to opencode.", tostring(config.tool)),
      vim.log.levels.WARN,
      { title = "chatcode_nvim" }
    )
    config.tool = "opencode"
  end

  active_tool = config.tool
  ensure_provider_available(active_tool)

  vim.api.nvim_create_user_command("ChatCodeTool", function(command_opts)
    local name = vim.trim(command_opts.args or "")

    if name == "" then
      vim.notify("Active ChatCode tool: " .. active_tool, vim.log.levels.INFO, { title = "chatcode_nvim" })
      return
    end

    set_active_tool(name, { restart = true })
  end, {
    nargs = "?",
    complete = function()
      return list_provider_names()
    end,
  })

  if config.kill_chat_code == true then
    vim.api.nvim_create_user_command("ChatCodeKill", kill_chat_code, {})
    vim.keymap.set({ "n", "t" }, "<leader>cd", kill_chat_code)
  end
end

return M
