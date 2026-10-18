return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
		vim.treesitter.language.register("json", "jsonc")
		vim.filetype.add({ extension = { mdx = "mdx" } })
		vim.treesitter.language.register("markdown", "mdx")

		local languages = require("config.languages").parsers
		treesitter.install(languages)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
			callback = function(event)
				local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
				if not lang or not vim.list_contains(languages, lang) then
					return
				end
				-- 初回インストール中は parser がまだないため、通常の表示を使う。
				if pcall(vim.treesitter.start, event.buf, lang) then
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
