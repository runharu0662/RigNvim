local profiles = require("config.profiles")

local local_path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/local.lua"
local local_options = {}
if vim.uv.fs_stat(local_path) then
	local_options = dofile(local_path)
end
assert(type(local_options) == "table", "config/local.lua must return a table")
local global_options = vim.g.rignvim or {}
local profile = vim.env.RIGNVIM_PROFILE or local_options.profile or global_options.profile or "standard"
assert(profiles[profile], "Unknown RigNvim profile: " .. profile)
local options = vim.tbl_extend("force", profiles.standard, profiles[profile], global_options, local_options)
options.profile = profile
return options
