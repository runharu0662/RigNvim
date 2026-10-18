return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		opts = { ui = { border = "single", check_outdated_packages_on_open = false } },
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		opts = function()
			local servers = vim.tbl_keys(require("config.languages").servers)
			table.sort(servers)
			return { ensure_installed = servers, automatic_enable = false }
		end,
	},
}
