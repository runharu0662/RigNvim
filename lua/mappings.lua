-- Copilot
vim.api.nvim_create_user_command("CopilotToggle", function()
	require("lazy").load({ plugins = { "copilot.lua" } })
	local ok, copilot = pcall(require, "copilot.client")
	if not ok then
		vim.notify("Copilot is not loaded yet", vim.log.levels.WARN)
		return
	end

	if copilot.is_disabled() then
		vim.cmd("Copilot enable")
		vim.notify("Copilot: enabled")
	else
		vim.cmd("Copilot disable")
		vim.notify("Copilot: disabled")
	end
end, {})
vim.keymap.set("n", "<leader>lt", "<cmd>CopilotToggle<CR>", { desc = "Toggle Copilot" })

-- Window splits
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", {
	noremap = true,
	silent = true,
	desc = "Split window vertically (right)",
})

-- LSP code actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Show diagnostics explicitly
vim.keymap.set("n", "<leader>cd", function()
	vim.diagnostic.open_float(nil, { focus = false, border = "rounded" })
end, { desc = "Show line diagnostics" })

-- Notification history
local telescope = require("telescope")
telescope.load_extension("notify")
vim.keymap.set("n", "<leader>fn", function()
	telescope.extensions.notify.notify()
end, {
	desc = "Find Notify Logs",
})

-- LSP rename
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol (LSP)" })

-- Move between windows
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- File tree
vim.keymap.set("n", "<space>e", "<cmd>Neotree toggle<CR>", { desc = "Neo-tree toggle" })

-- Telescope search
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

-- LSP formatting
vim.keymap.set("n", "<leader>n", function()
	require("config.development").format({ async = true })
end, { desc = "Format with LSP" })

-- Close buffer
vim.keymap.set("n", "<leader>bc", "<cmd>bdelete<CR>", { desc = "Close current buffer" })

-- Markdown links and images
vim.keymap.set("n", "<leader>pi", ":PasteClipboardImage<CR>", { desc = "Paste dropped image as Markdown" })

vim.keymap.set("n", "<leader>pc", "<cmd>CreateMdLink<CR>", { desc = "Create markdown file from [[link]]" })

vim.keymap.set("n", "<leader>po", "<cmd>OpenMdLink<CR>", { desc = "Open markdown file from [[link]]" })

-- Git inspection only; builds and operational commands stay in WezTerm / Zsh.
vim.keymap.set("n", "<leader>gd", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview Git diff hunk" })
vim.keymap.set("n", "<leader>gl", function()
	require("gitsigns").diffthis()
end, { desc = "Compare buffer with Git index" })

-- Diagnostics: project list, buffer list, and current-line detail toggle.
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find workspace diagnostics" })
vim.keymap.set("n", "<leader>cl", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>ud", function()
	local enabled = vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = not enabled and { current_line = true } or false })
end, { desc = "Toggle diagnostic details" })
vim.keymap.set("n", "<leader>ci", "<cmd>LanguageStatus<CR>", { desc = "Language server status" })
