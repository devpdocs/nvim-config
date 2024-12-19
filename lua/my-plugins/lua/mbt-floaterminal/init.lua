local M = {}
local state = {
  floating = {
    buf = -1,
    win = -1
  }
}

M.floaterminal = function()
  vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')
  local function create_floating_window(opts)
    opts = opts or {}

    -- Get the current screen dimensions
    local width = vim.o.columns
    local height = vim.o.lines

    -- Calculate default width and height (80% of screen size)
    local win_width = math.floor(opts.width or (width * 0.8))
    local win_height = math.floor(opts.height or (height * 0.8))

    -- Calculate the centered position
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    -- Create a new empty buffer
    local buf = nil

    if vim.api.nvim_buf_is_valid(opts.buf) then
      buf = opts.buf
    else
      buf = vim.api.nvim_create_buf(false, true)
    end


    -- Define window options
    local win_opts = {
      relative = "editor",
      width = win_width,
      height = win_height,
      row = row,
      col = col,
      style = "minimal",  -- Use minimal style for the floating window
      border = "rounded", -- Optional: Add a border around the window
    }

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Return buffer and window handles
    return { buf = buf, win = win }
  end

  local toggle_terminal = function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
      state.floating = create_floating_window { buf = state.floating.buf }
      if vim.bo[state.floating.buf].buftype ~= "terminal" then
        vim.cmd.term()
      end
    else
      vim.api.nvim_win_hide(state.floating.win)
    end
  end
  vim.api.nvim_create_user_command('Floaterminal', toggle_terminal, {})
  vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle_terminal)
end

M.setup = function(opts)
  if opts.killterm == true then
    local kill_terminal = function()
      if vim.api.nvim_buf_is_valid(state.floating.buf) then
        vim.api.nvim_buf_delete(state.floating.buf, {force = true})
        state.floating.buf = -1
        vim.notify("Terminal has been closed", vim.log.levels.INFO, { title = 'floaterminal_nvim'})
      else
        vim.notify("No open terminal found", vim.log.levels.WARN, { title = 'floaterminal_nvim' })
      end
    end
    vim.api.nvim_create_user_command('FloaterminalKill', kill_terminal, {})
    vim.keymap.set({'n', 't'}, '<leader>tr', kill_terminal)
  end
end

return M
