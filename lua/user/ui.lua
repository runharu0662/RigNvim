-- diagnostic icons
local icons = require("user.icons")

vim.diagnostic.config({
	virtual_text = { spacing = 2, source = "if_many" },
	virtual_lines = { current_line = true },
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
