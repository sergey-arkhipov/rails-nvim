-- lua/rails-nvim/related.lua
local utils = require("rails-nvim.utils")

local M = {}

-- Helper function to pluralize a word (basic implementation)
local function pluralize(word)
	-- Basic pluralization rules (can be expanded as needed)
	if string.match(word, "y$") then
		return string.gsub(word, "y$", "ies")
	elseif
		string.match(word, "s$")
		or string.match(word, "sh$")
		or string.match(word, "ch$")
		or string.match(word, "x$")
	then
		return word .. "es"
	else
		return word .. "s"
	end
end

function M.open_related_file()
	local current_file = vim.api.nvim_buf_get_name(0)
	local related_file = nil

	-- Model -> Controller
	if string.match(current_file, utils.config.model_dir .. "/.*%.rb$") then
		local model_name = string.match(current_file, utils.config.model_dir .. "/(.*)%.rb$")
		local controller_name = pluralize(model_name) .. "_controller.rb"
		related_file = utils.config.controller_dir .. "/" .. controller_name
	end

	-- Controller -> View
	if string.match(current_file, utils.config.controller_dir .. "/.*%.rb$") then
		local controller_name = string.match(current_file, utils.config.controller_dir .. "/(.*)_controller%.rb$")
		related_file = utils.config.view_dir .. "/" .. controller_name
	end

	if related_file and vim.fn.filereadable(related_file) == 1 then
		vim.cmd("edit " .. related_file)
	else
		print("Related file not found: " .. (related_file or "N/A"))
	end
end

return M
