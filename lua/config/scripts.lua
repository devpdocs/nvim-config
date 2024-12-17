local venv_selector = require("venv-selector")
local job_django = nil
local job_ng = nil
local title = 'Django'

vim.api.nvim_create_user_command('DjangoServerStart', function()
  local venv = venv_selector.get_active_venv()
  local pattern = "(v?env/?)?(bin/?)?(activate?)?"
  -- if the venv has been activated
  if venv == nil then
    vim.notify("There isn´t any venv actived yet", vim.log.levels.WARN, {
      title = title
    })
    return 0
  end

  local base_path = string.gsub(venv, pattern, '')
  base_path = string.gsub(base_path, '(v?env/?)', 'manage.py')

  vim.notify('Server runs in the http://localhost:8000', vim.log.levels.INFO, {
    title = title .. 'running'
  })
  job_django = vim.system({ 'python3', base_path, 'runserver' }, {}, function()
    vim.notify('Server stopped in http:localhost:8000', vim.log.levels.INFO, {
      title = title .. 'stopped'
    })
  end)
end, {})


vim.api.nvim_create_user_command('DjangoServerStop', function()
  if job_django ~= nil then
    job_django:kill(15)
  end
end, {})

vim.api.nvim_create_user_command('')

vim.keymap.set({ 'n' }, '<leader><leader>dr', ':DjangoServerStart<cr>', {})
vim.keymap.set({ 'n' }, '<leader><leader>ds', ':DjangoServerStop<cr>', {})

vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
  callback = function()
    if job_django ~= nil then
      job_django:kill(15)
    end
  end
})
