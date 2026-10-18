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
			-- Install only explicitly requested tools through :Mason / :LspInstall.
			return { ensure_installed = {}, automatic_enable = false }
		end,
	},
}
