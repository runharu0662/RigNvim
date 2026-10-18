return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
	},
	config = function()
		local cmp = require("cmp")
		local map = cmp.mapping

		cmp.setup({
			enabled = function()
				if vim.bo.filetype == "markdown" then
					return false
				end
				if vim.fn.exists("*skkeleton#is_enabled") == 0 then
					return true
				end
				local enabled = vim.fn["skkeleton#is_enabled"]()
				return enabled == false or enabled == 0
			end,
			snippet = {
				expand = function(args)
					vim.snippet.expand(args.body)
				end,
			},
			completion = {
				completeopt = "menu,menuone,noinsert",
			},
			mapping = map.preset.insert({
				["<C-p>"] = map.select_prev_item(),
				["<C-n>"] = map.select_next_item(),
				["<CR>"] = map.confirm({ select = false }),
			}),
			sources = {
				{ name = "nvim_lsp", max_item_count = 15, keyword_length = 1 },
				-- { name = "copilot", max_item_count = 15, keyword_length = 0 },
				{ name = "buffer", max_item_count = 15, keyword_length = 1 },
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
		})

		vim.lsp.config("*", {
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		})
	end,
}
