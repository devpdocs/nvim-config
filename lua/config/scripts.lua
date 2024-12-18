local venv_selector = require("venv-selector")
local job_django = nil
local job_ng = nil
local titles = { 'Django', 'Ng' }

vim.api.nvim_create_user_command('DjangoServerStart', function()
  local venv = venv_selector.get_active_venv()
  local pattern = "(v?env/?)?(bin/?)?(activate?)?"
  -- if the venv has been activated
  if venv == nil then
    vim.notify("There isn´t any venv actived yet", vim.log.levels.WARN, {
      title = titles[1]
    })
    return 0
  end

  local base_path = string.gsub(venv, pattern, '')
  base_path = string.gsub(base_path, '(v?env/?)', 'manage.py')

  vim.notify('Server runs in the http://localhost:8000', vim.log.levels.INFO, {
    title = titles[1] .. 'running'
  })
  job_django = vim.system({ 'python3', base_path, 'runserver' }, {}, function()
    vim.notify('Server stopped in http:localhost:8000', vim.log.levels.INFO, {
      title = titles[1] .. 'stopped'
    })
  end)
end, {})


vim.api.nvim_create_user_command('DjangoServerStop', function()
  if job_django ~= nil then
    job_django:kill(15)
  end
end, {})

vim.api.nvim_create_user_command('NgServe', function(opts)
  if opts.args == '-o' then
    vim.notify('Angular running in the http://localhost:4200 with the flag -o')

    job_ng = vim.system({ 'ng', 'serve', '-o' }, {}, function()
      vim.notify('Angular stopped in the http://localhost:4200', vim.log.levels.INFO, {
        title = titles[2] .. "stopped"
      })
    end)
  else
    vim.notify('Angular running in the http://localhost:4200')

    job_ng = vim.system({ 'ng', 'serve' }, {}, function()
      vim.notify('Angular stopped in the http://localhost:4200', vim.log.levels.INFO, {
        title = titles[2] .. "stopped"
      })
    end)
  end
end, { nargs = '?' })

vim.api.nvim_create_user_command('NgStop', function()
  if job_ng ~= nil then
    job_ng:kill(15)
  end
end, {})

vim.keymap.set({ 'n' }, '<leader><leader>dr', ':DjangoServerStart<cr>', {})
vim.keymap.set({ 'n' }, '<leader><leader>ds', ':DjangoServerStop<cr>', {})
vim.keymap.set({ 'n' }, '<leader><leader>ngr', ':NgServe<cr>', {})
vim.keymap.set({ 'n' }, '<leader><leader>ngo', ':NgServe -o<cr>', {})
vim.keymap.set({ 'n' }, '<leader><leader>ngs', ':NgStop<cr>', {})

vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
  callback = function()
    if job_django ~= nil then
      job_django:kill(15)
    else
      vim.notify("The django server currently is stop " .. venv_selector.get_active_venv(), vim.log.levels.WARN, {
        title = "Django server"
      })
    end

    if job_ng ~= nil then
      job_ng:kill(15)
    else
      vim.notify("The ng server currently is stop ", vim.log.levels.WARN, {
        title = "Ng Server"
      })
    end
  end
})
