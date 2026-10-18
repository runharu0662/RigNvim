-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.g.editorconfig = true

-- Filetype defaults first; project .editorconfig always takes precedence.
local two_space = {
	javascript = true, javascriptreact = true, typescript = true, typescriptreact = true,
	html = true, css = true, scss = true, json = true, jsonc = true,
	yaml = true, markdown = true, mdx = true, terraform = true,
	["terraform-vars"] = true, hcl = true,
}
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ProjectIndentation", { clear = true }),
	callback = function(args)
		local bo = vim.bo[args.buf]
		local width = two_space[bo.filetype] and 2 or 4
		bo.expandtab = not vim.tbl_contains({ "go", "gomod", "gowork", "make" }, bo.filetype)
		bo.tabstop = width
		bo.shiftwidth = width
		bo.softtabstop = -1
		require("editorconfig").config(args.buf)
	end,
})

-- Line numbers and scrolling
vim.opt.number = true
vim.api.nvim_set_option("scrolloff", 4)

-- Open new splits to the right and below
vim.o.splitright = true
vim.o.splitbelow = true

-- Use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- Hide end-of-buffer markers
vim.opt.fillchars:append({ eob = " " })

-- Command line, status line, and tab line
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.showtabline = 0

-- Keep the sign column visible
vim.opt.signcolumn = "yes"

-- Highlight the current line with Neovim's built-in UI
vim.opt.cursorline = true
