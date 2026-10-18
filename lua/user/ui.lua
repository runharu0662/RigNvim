-- diagnostic icons
local icons = require("user.icons")

vim.diagnostic.config({
	-- Show messages below the current line without repeating them at the line end.
	virtual_text = false,
	virtual_lines = require("config.preferences").diagnostic_details and { current_line = true } or false,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = true, header = "Diagnostics" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.error_icon,
			[vim.diagnostic.severity.WARN] = icons.warn_icon,
			[vim.diagnostic.severity.HINT] = icons.hint_icon,
			[vim.diagnostic.severity.INFO] = icons.info_icon,
		},
	},
})

-- comment style
vim.api.nvim_set_hl(0, "Comment", { fg = "#9ec6ff", italic = true })
