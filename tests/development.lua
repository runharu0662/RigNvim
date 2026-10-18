-- Run in a disposable state directory with existing plugins; no downloads or installs.
local root = vim.fn.getcwd()
local plugin_root = assert(vim.env.NVIM_TEST_PLUGINS, "Set NVIM_TEST_PLUGINS to the existing lazy plugin directory")
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(root .. "/after")
for _, dir in ipairs(vim.fn.glob(plugin_root .. "/*", false, true)) do
	vim.opt.rtp:append(dir)
end
vim.g.mapleader = " "
require("mason").setup({ install_root_dir = vim.fn.stdpath("data") .. "/mason" })
dofile("lua/plugins/edit/cmp.lua").config()
dofile("lua/plugins/lsp/nvim-lspconfig.lua").config()
dofile("lua/plugins/lsp/none-ls.lua").config()
require("telescope").setup(dofile("lua/plugins/tools/telescope.lua").opts)
dofile("lua/mappings.lua")
dofile("lua/func/functions.lua")

-- Bundled dictionary lookup must work outside the config directory.
local original_config, original_keymap = vim.fn["skkeleton#config"], vim.fn["skkeleton#register_keymap"]
local dictionary_config
vim.fn["skkeleton#config"] = function(opts)
	dictionary_config = opts
end
vim.fn["skkeleton#register_keymap"] = function() end
local skk = dofile(root .. "/lua/plugins/edit/skkeleton.lua")
skk.init()
vim.cmd("cd /tmp")
vim.api.nvim_exec_autocmds("User", { pattern = "skkeleton-initialize-pre" })
assert(dictionary_config.globalDictionaries[1] == root .. "/dictionaries/SKK-JISYO.L")
assert(vim.fn.filereadable(dictionary_config.globalDictionaries[1]) == 1)
vim.g.skk_dictionary_path = root .. "/dictionaries/SKK-JISYO.L"
vim.api.nvim_exec_autocmds("User", { pattern = "skkeleton-initialize-pre" })
assert(dictionary_config.globalDictionaries[1] == vim.g.skk_dictionary_path)
vim.g.skk_dictionary_path = nil
vim.cmd("cd " .. vim.fn.fnameescape(root))
vim.fn["skkeleton#config"], vim.fn["skkeleton#register_keymap"] = original_config, original_keymap

local tools = require("config.development")
local mason_opts = dofile("lua/plugins/lsp/mason-nvim.lua")[2].opts()
assert(mason_opts.automatic_enable == false)
assert(#mason_opts.ensure_installed == vim.tbl_count(tools.servers))
for name in pairs(tools.servers) do
	assert(vim.lsp.config[name], name)
	assert(vim.list_contains(mason_opts.ensure_installed, name), "Missing automatic install: " .. name)
end
for _, file in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do
	assert(loadfile(file), file)
end
for _, file in ipairs(vim.fn.glob("after/**/*.lua", false, true)) do
	assert(loadfile(file), file)
end
local parsers = require("nvim-treesitter.parsers")
local ts_languages
local treesitter = require("nvim-treesitter")
local old_install = treesitter.install
treesitter.install = function(languages)
	ts_languages = languages
end
dofile("lua/plugins/edit/treesitter.lua").config()
treesitter.install = old_install
for _, name in ipairs(ts_languages) do
	assert(parsers[name], "Unknown parser " .. name)
end

for _, key in ipairs({ " lt", " v", " ca", " rn", " e", " ff", " fg", " fb", " fh", " n", " bc", " pi", " pc", " po" }) do
	assert(vim.fn.maparg(key, "n") ~= "", "Missing existing mapping: " .. key)
end
-- Native motions and retired terminal mappings must stay available / absent.
for _, mode in ipairs({ "n", "v", "o" }) do
	for _, key in ipairs({ "f", "F", "t", "T" }) do
		assert(vim.fn.maparg(key, mode) == "", "Native motion overridden: " .. key)
	end
end
for _, key in ipairs({ " tf", " tv", " th" }) do
	assert(vim.fn.maparg(key, "n") == "", "Retired terminal mapping: " .. key)
end
local old_action, old_float = vim.lsp.buf.code_action, vim.diagnostic.open_float
local action_called, diagnostic_called = false, false
vim.lsp.buf.code_action = function()
	action_called = true
end
vim.diagnostic.open_float = function(_, opts)
	diagnostic_called = opts.focus == false and opts.border == "rounded"
end
dofile("lua/mappings.lua")
for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
	if map.lhs == " ca" or map.lhs == " cd" then
		map.callback()
	end
end
assert(action_called and diagnostic_called, "Native LSP / diagnostic actions failed")
vim.lsp.buf.code_action, vim.diagnostic.open_float = old_action, old_float
dofile("lua/user/ui.lua")
dofile("lua/options.lua")
assert(vim.wo.cursorline)
assert(vim.diagnostic.config().virtual_lines.current_line)
assert(vim.diagnostic.config().update_in_insert == false)
assert(vim.diagnostic.config().severity_sort)
assert(vim.lsp.config.ts_ls.init_options.locale == "en")
assert(vim.fn.exists(":LanguageStatus") == 2)
for _, key in ipairs({ " fd", " cl", " ud", " ci" }) do
	assert(vim.fn.maparg(key, "n") ~= "", "Missing diagnostic mapping: " .. key)
end
-- Ensure a missing executable is visible instead of silently looking configured.
local saved_notify, saved_executable = vim.notify, tools.executable
local status_message
vim.notify = function(message) status_message = message end
tools.executable = function() return nil end
vim.bo.filetype = "python"
tools.language_status()
assert(status_message:find("pyright: missing", 1, true))
assert(status_message:find("ruff: missing", 1, true))
vim.notify, tools.executable = saved_notify, saved_executable
assert(#vim.api.nvim_get_autocmds({ event = "CursorHold" }) == 0, "Diagnostics should open explicitly")
for _, mapping in ipairs(dofile("lua/plugins/edit/hop.lua").keys) do
	assert(mapping[1] ~= "t" and mapping[1] ~= "T")
end

assert(vim.fn.exists(":RunInput") == 0 and vim.fn.exists(":InsTemp") == 0)
assert(vim.fn.exists(":CreateMdLink") == 2 and vim.fn.exists(":PasteClipboardImage") == 2)

for name in pairs(tools.servers) do
	vim.lsp.enable(name, false)
end

-- Verify one formatting client, provider priority, absent-tool fallback, and no ESLint formatting.
local old_clients, old_format, old_executable = vim.lsp.get_clients, vim.lsp.buf.format, tools.executable
local formatted, installed = nil, {}
vim.lsp.get_clients = function()
	return { { id = 1, name = "gopls" }, { id = 2, name = "null-ls" }, { id = 3, name = "eslint" } }
end
vim.lsp.buf.format = function(opts)
	formatted = opts
end
tools.executable = function(command)
	return installed[command] and "/test/" .. command or nil
end
vim.bo.filetype = "go"
tools.format()
assert(formatted.id == 1)
installed.goimports = true
tools.format()
assert(formatted.id == 2)
vim.bo.filetype = "typescript"
installed = { prettier = true }
tools.format({ async = true })
assert(formatted.id == 2 and formatted.async)
vim.lsp.get_clients = function()
	return { { id = 3, name = "eslint" } }
end
formatted = nil
tools.format({ quiet = true })
assert(formatted == nil)
local called = false
vim.lsp.config.gopls.root_dir(0, function()
	called = true
end)
assert(not called, "Missing server should not start")
vim.lsp.get_clients, vim.lsp.buf.format, tools.executable = old_clients, old_format, old_executable

vim.bo.filetype = "markdown"
dofile("after/ftplugin/markdown.lua")
assert(vim.wo.wrap and vim.wo.linebreak and vim.bo.textwidth == 0)
assert(not require("cmp").get_config().enabled())
local writes = vim.api.nvim_get_autocmds({ group = "web_formatting", event = "BufWritePre" })
assert(#writes == 1)
local old_helper = tools.format
called = false
tools.format = function()
	called = true
end
writes[1].callback({ buf = vim.api.nvim_get_current_buf() })
assert(not called, "Markdown must not be autoformatted")
tools.format = old_helper
local lock = vim.json.decode(table.concat(vim.fn.readfile("lazy-lock.json"), "\n"))
assert(lock.skkeleton and lock["denops.vim"] and lock["none-ls.nvim"])
assert(lock["neoscroll.nvim"] and lock["alpha-nvim"] and lock["ascii.nvim"])
for _, name in ipairs({
	"mason-null-ls.nvim",
	"fidget.nvim",
	"lspsaga.nvim",
	"toggleterm.nvim",
	"nvim-cursorline",
	"CopilotChat.nvim",
}) do
	assert(not lock[name], "Retired plugin in lockfile: " .. name)
end
-- Exercise the real none-ls -> gofmt fallback when Go is available on this machine.
if vim.fn.executable("gofmt") == 1 then
	local fixture = vim.fn.tempname() .. "-web-go"
	vim.fn.mkdir(fixture, "p")
	vim.fn.writefile({ "package main", 'func main(){println("ok")}' }, fixture .. "/main.go")
	vim.cmd("edit " .. vim.fn.fnameescape(fixture .. "/main.go"))
	vim.bo.filetype = "go"
	assert(
		vim.wait(3000, function()
			return #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" }) > 0
		end),
		"none-ls did not attach to Go fixture"
	)
	tools.format()
	assert(
		table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("func main%(%) {"),
		"Real Go formatting failed"
	)
	vim.bo.modified = false
	print("PASS: real Go formatting through none-ls")
end
print("PASS: real plugin setup, servers/parsers, existing mappings, format selection and Markdown preservation")
