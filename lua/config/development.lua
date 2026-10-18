local M = {}

M.servers = require("config.languages").servers

-- Prefer the project's Node tools, then Mason / the shell PATH. Never install on open.
function M.executable(command, path)
	local dir = path or vim.fn.getcwd()
	if vim.fn.isdirectory(dir) == 0 then
		dir = vim.fs.dirname(dir)
	end
	while dir do
		local candidate = dir .. "/node_modules/.bin/" .. command
		if vim.fn.executable(candidate) == 1 then
			return candidate
		end
		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
	if vim.fn.executable(command) == 1 then
		return vim.fn.exepath(command)
	end
end

-- Include missing tools: a configured server alone cannot produce diagnostics.
function M.language_status()
	local bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.bo[bufnr].filetype
	local path = vim.api.nvim_buf_get_name(bufnr)
	local lines = { "Language: " .. ft, "", "Language servers:" }
	local names = vim.tbl_keys(M.servers)
	table.sort(names)
	local count = 0
	for _, name in ipairs(names) do
		local config = vim.lsp.config[name]
		if config and vim.list_contains(config.filetypes or {}, ft) then
			count = count + 1
			local command = M.executable(M.servers[name].command, path ~= "" and path or nil)
			local active = #vim.lsp.get_clients({ bufnr = bufnr, name = name }) > 0
			table.insert(lines, name .. ": " .. (active and "attached" or command and "installed, not attached" or "missing") )
			table.insert(lines, "  " .. (command or "Install with :LspInstall " .. name))
		end
	end
	if count == 0 then
		table.insert(lines, "No language server configured (highlighting only).")
	end
	table.insert(lines, "")
	table.insert(lines, "Installed servers may need a project root or project configuration.")
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Language status" })
end

function M.setup_lsp()
	vim.api.nvim_create_user_command("LanguageStatus", M.language_status, { desc = "Show language server availability", force = true })
	vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
	vim.lsp.config("gopls", {
		filetypes = { "go", "gomod", "gosum", "gowork", "gotmpl" },
		settings = { gopls = { staticcheck = true } },
	})
	vim.lsp.config("ts_ls", { init_options = { locale = "en" } })
	vim.lsp.config("pyright", {
		settings = { python = { analysis = { typeCheckingMode = "basic" } } },
	})
	vim.lsp.config("eslint", { settings = { format = false } })
	vim.lsp.config("lua_ls", {
		settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("web_lsp_navigation", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client or client.name == "null-ls" then
				return
			end
			-- Preserve Neovim's gr-prefixed LSP mappings (grr, grn, gra, ...).
			for key, fn in pairs({ gd = vim.lsp.buf.definition }) do
				if vim.fn.maparg(key, "n") == "" then
					vim.keymap.set(
						"n",
						key,
						fn,
						{ buffer = args.buf, desc = key == "gd" and "LSP definition" or "LSP references" }
					)
				end
			end
			if client.name == "gopls" or client.name == "ts_ls" then
				vim.api.nvim_buf_create_user_command(args.buf, "OrganizeImports", function()
					vim.lsp.buf.code_action({
						context = { only = { "source.organizeImports" }, diagnostics = {} },
						apply = true,
					})
				end, { desc = "Organize imports through LSP", force = true })
			end
		end,
	})
	for name, spec in pairs(M.servers) do
		local base = vim.lsp.config[name]
		assert(base, "Missing lspconfig configuration: " .. name)
		vim.lsp.config(name, {
			cmd = function(dispatchers, config)
				local command = assert(M.executable(spec.command, config.root_dir), spec.command .. " is unavailable")
				return vim.lsp.rpc.start(vim.list_extend({ command }, spec.args or {}), dispatchers, {
					cwd = config.root_dir,
					env = { LANG = "en_US.UTF-8", LC_ALL = "en_US.UTF-8", LANGUAGE = "en" },
				})
			end,
			root_dir = function(bufnr, on_dir)
				local path = vim.api.nvim_buf_get_name(bufnr)
				if not M.executable(spec.command, path ~= "" and path or nil) then
					return
				end
				if type(base.root_dir) == "function" then
					base.root_dir(bufnr, on_dir)
				else
					local root = vim.fs.root(bufnr, base.root_markers or { ".git" })
					if root or not base.workspace_required then
						on_dir(root or vim.fs.dirname(path) or vim.fn.getcwd())
					end
				end
			end,
		})
		vim.lsp.enable(name)
	end
end

local formatters = require("config.languages").formatters

function M.format(opts)
	opts = opts or {}
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" })
	local chosen
	for _, command in ipairs(formatters[vim.bo[bufnr].filetype] or {}) do
		if M.executable(command, vim.api.nvim_buf_get_name(bufnr)) then
			for _, client in ipairs(clients) do
				if client.name == "null-ls" then
					chosen = client
				end
			end
			if chosen then
				break
			end
		end
	end
	if not chosen then
		for _, client in ipairs(clients) do
			if client.name ~= "null-ls" and client.name ~= "eslint" then
				if not chosen or client.id < chosen.id then
					chosen = client
				end
			end
		end
	end
	if not chosen then
		if not opts.quiet then
			vim.notify("No formatter available for this buffer", vim.log.levels.INFO)
		end
		return
	end
	vim.lsp.buf.format({ bufnr = bufnr, id = chosen.id, async = opts.async or false, timeout_ms = 3000 })
end

function M.autoformat_enabled(bufnr)
	local disabled = vim.b[bufnr or 0].disable_autoformat
	if disabled ~= nil then
		return not disabled
	end
	return require("config.preferences").autoformat
end

function M.toggle_autoformat()
	local disabled = M.autoformat_enabled()
	vim.b.disable_autoformat = disabled
	vim.notify("Format on save: " .. (disabled and "OFF" or "ON") .. " (current buffer)")
end

function M.setup_formatting()
	local group = vim.api.nvim_create_augroup("web_formatting", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function(args)
			-- Keep article whitespace intact on save; explicit <leader>n still formats Markdown.
			if
				M.autoformat_enabled(args.buf)
				and not vim.tbl_contains({ "markdown", "mdx" }, vim.bo[args.buf].filetype)
				and vim.bo[args.buf].buftype == ""
			then
				M.format({ bufnr = args.buf, quiet = true })
			end
		end,
	})
end

return M
