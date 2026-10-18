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
		opts = { ensure_installed = {}, automatic_enable = false },
	},
}
