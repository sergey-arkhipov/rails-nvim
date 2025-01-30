-- lua/rails-nvim/alternate.lua
local utils = require("rails-nvim.utils")

local M = {}

function M.open_alternate_file()
	local current_file = vim.api.nvim_buf_get_name(0)
	local alternate_file = nil

	-- Model <-> Spec
	if string.match(current_file, utils.config.model_dir .. "/.*%.rb$") then
		alternate_file = string.gsub(current_file, utils.config.model_dir, utils.config.spec_dir)
	elseif string.match(current_file, utils.config.spec_dir .. "/.*%.rb$") then
		alternate_file = string.gsub(current_file, utils.config.spec_dir, utils.config.model_dir)
	end

	-- Controller <-> View
	if string.match(current_file, utils.config.controller_dir .. "/.*%.rb$") then
		alternate_file = string.gsub(current_file, utils.config.controller_dir, utils.config.view_dir)
		alternate_file = string.gsub(alternate_file, "_controller%.rb$", "")
	elseif string.match(current_file, utils.config.view_dir .. "/.*%.html%.erb$") then
		alternate_file = string.gsub(current_file, utils.config.view_dir, utils.config.controller_dir)
		alternate_file = string.gsub(alternate_file, "%.html%.erb$", "_controller.rb")
	end

	if alternate_file and vim.fn.filereadable(alternate_file) == 1 then
		vim.cmd("edit " .. alternate_file)
	else
		print("Alternate file not found: " .. (alternate_file or "N/A"))
	end
end

return M
