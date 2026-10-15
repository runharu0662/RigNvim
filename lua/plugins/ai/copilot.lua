-- ~/.config/RigNvim/lua/plugins/ai/copilot.lua
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		suggestion = {
			enabled = true,
			auto_trigger = true,
			hide_during_completion = false,
			keymap = {
				accept = "<C-l>",
				accept_word = "<C-;>",
				accept_line = "<C-'>",
				dismiss = "<C-x>",
			},
		},
		panel = { enabled = false },
		filetypes = { markdown = true, mdx = true, text = false, ["*"] = true },
	},
}
