local M = {}

function M.setup_tabstop (tabstop, shiftwidth, expandtab) 
	vim.bo.tabstop = tabstop
	vim.bo.shiftwidth = shiftwidth
	vim.bo.expandtab = expandtab
end 

return M 
