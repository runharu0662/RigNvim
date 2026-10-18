-- ~/.config/RigNvim/lua/plugins/ai/copilot.lua
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = require("config.preferences").copilot and "InsertEnter" or nil,
	opts = {
		suggestion = {
			enabled = true,
			auto_trigger = true,
			hide_during_completion = true,
			keymap = {
				accept = "<C-l>",
				accept_word = false,
				accept_line = false,
				dismiss = false,
			},
		},
		panel = { enabled = false },
		filetypes = { markdown = true, mdx = true, text = false, ["*"] = true },
	},
}
