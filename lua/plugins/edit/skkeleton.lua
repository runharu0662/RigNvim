-- Resolve the bundled dictionary from this file, independent of cwd or NVIM_APPNAME.
local config_root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))))
local bundled_dictionary = config_root .. "/dictionaries/SKK-JISYO.L"

return {
	"vim-skk/skkeleton",
	cond = function()
		return require("config.preferences").japanese_input and vim.fn.executable("deno") == 1
	end,
	dependencies = { "vim-denops/denops.vim" },
	init = function()
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("simple_skkeleton", { clear = true }),
			pattern = "skkeleton-initialize-pre",
			callback = function()
				local dictionary = vim.fn.expand(vim.g.skk_dictionary_path or bundled_dictionary)
				local dictionaries = {}
				if vim.fn.filereadable(dictionary) == 1 then
					dictionaries = { dictionary }
				else
					vim.notify("SKK dictionary not found: " .. dictionary, vim.log.levels.WARN)
				end
				vim.fn["skkeleton#config"]({ globalDictionaries = dictionaries, eggLikeNewline = true })
				vim.fn["skkeleton#register_keymap"]("henkan", "<C-n>", "henkanForward")
				vim.fn["skkeleton#register_keymap"]("henkan", "<C-p>", "henkanBackward")
				vim.fn["skkeleton#register_keymap"]("henkan", "<C-y>", "kakutei")
				vim.fn["skkeleton#register_keymap"]("henkan", "<C-e>", "cancel")
			end,
		})
	end,
	config = function()
		vim.keymap.set(
			{ "i", "c" },
			"<C-j>",
			"<Plug>(skkeleton-toggle)",
			{ remap = true, desc = "Toggle Japanese input" }
		)
	end,
}
