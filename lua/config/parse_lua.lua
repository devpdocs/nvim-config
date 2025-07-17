vim.filetype.add {
  extension = { conf = "dosini" },
  pattern = {
    ['.*/server/.*%.conf$'] = "dosini",  -- si es necesario un patrón más específico
  },
}
