return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>l", group = "Copilot" }, -- group
			{ "<leader>f", group = "telescope" }, -- group
			{ "<leader>g", group = "Git" },
			{ "<leader>h", group = "hop" },
			{ "<leader>r", group = "rename" },
			{ "<leader>c", group = "Code actions / diagnostics" },
			-- { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
			{ "<leader>u", group = "Display / formatting toggles" },
			{
				"<leader>b",
				group = "buffers",
				expand = function()
					return require("which-key.extras").expand.buf()
				end,
			},
			{
				-- Nested mappings are allowed and can be added in any order
				-- Most attributes can be inherited or overridden on any level
				-- There's no limit to the depth of nesting
				mode = { "n", "v" }, -- NORMAL and VISUAL mode
				{ "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
				{ "<leader>w", "<cmd>w<cr>", desc = "Save" },
				{ "<leader>Q", "<cmd>wqa<cr>", desc = "Quit All" },
			},
		})
	end,
}
