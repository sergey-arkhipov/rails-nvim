-- lua/rails-nvim/commands.lua
local utils = require("rails-nvim.utils")
local alternate = require("rails-nvim.alternate")
local related = require("rails-nvim.related")

local M = {}

function M.setup()
	-- Helper function to get completion candidates
	local function get_completion_candidates(type, arg_lead)
		local directory = utils.config[type .. "_dir"]
		local pattern = type == "view" and "%.html%.erb$" or "%.rb$"
		local files = utils.list_files(directory, pattern)

		-- Filter files based on the current input (arg_lead)
		if arg_lead and arg_lead ~= "" then
			files = vim.tbl_filter(function(file)
				return string.find(file, arg_lead, 1, true) ~= nil
			end, files)
		end

		return files
	end

	-- Function to create a Rails command
	local function create_rails_command(command_name, file_type)
		vim.api.nvim_create_user_command(command_name, function(opts)
			if not utils.open_or_create_file or not utils.list_and_open_file then
				vim.notify("Utils functions are not available", vim.log.levels.ERROR)
				return
			end
			if opts.args and opts.args ~= "" then
				utils.open_or_create_file(file_type, opts.args)
			else
				utils.list_and_open_file(file_type)
			end
		end, {
			nargs = "?",
			complete = function(arg_lead)
				return get_completion_candidates(file_type, arg_lead)
			end,
		})
	end

	-- Create commands using the function
	create_rails_command("Emodel", "model")
	create_rails_command("Econtroller", "controller")
	create_rails_command("Eview", "view")
	create_rails_command("Espec", "spec")
	create_rails_command("Ehelper", "helper")
	create_rails_command("Eservice", "service")
	-- Alternate command (A)
	vim.api.nvim_create_user_command("A", alternate.open_alternate_file, {})

	-- Relation command (R)
	vim.api.nvim_create_user_command("R", related.open_related_file, {})

	-- Custom go file command (custom_gf)
	vim.api.nvim_create_user_command("Railsgf", utils.custom_gf, {})
end

return M
