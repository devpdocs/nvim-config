return {

	{

		'stevearc/oil.nvim',
		---@module 'oil'
		---@type oil.SetupOpts
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		config = function()
			require("oil").setup({
				columns = {"icon"},
				view_options = {
					show_hidden = true,
				},
			})
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
			vim.keymap.set("n", "<Space>-", require("oil").toggle_float)
		end,
	},
}
