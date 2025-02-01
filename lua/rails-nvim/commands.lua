-- lua/rails-nvim/commands.lua
local utils = require("rails-nvim.utils")
local alternate = require("rails-nvim.alternate")
local related = require("rails-nvim.related")
local config = require("rails-nvim.config").config
local fast_move = require("rails-nvim.fast-move")

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
	local function create_rails_command(command_name, file_type, command)
		command = command or "edit"
		vim.api.nvim_create_user_command(command_name, function(opts)
			if not utils.open_or_create_file or not utils.list_and_open_file then
				vim.notify("Utils functions are not available", vim.log.levels.ERROR)
				return
			end
			if opts.args and opts.args ~= "" then
				utils.open_or_create_file(file_type, opts.args, command)
			else
				utils.list_and_open_file(file_type, command)
			end
		end, {
			nargs = "?",
			complete = function(arg_lead)
				return get_completion_candidates(file_type, arg_lead)
			end,
		})
	end

	-- Create commands for each item in config
	for type, _ in pairs(config) do
		-- Extract the base name (e.g., "model" from "model_dir")
		local base_name = type:gsub("_dir", "")

		-- Create commands with E, S, V prefixes
		create_rails_command("E" .. base_name, base_name, "edit")
		create_rails_command("S" .. base_name, base_name, "split")
		create_rails_command("V" .. base_name, base_name, "vsplit")
	end
	--Fast move command

	-- Register custom commands
	vim.api.nvim_create_user_command("GC", fast_move.go_controller, {})
	vim.api.nvim_create_user_command("GV", fast_move.go_view, {})
	vim.api.nvim_create_user_command("GM", fast_move.go_model, {})
	vim.api.nvim_create_user_command("GS", fast_move.go_spec, {})
	vim.api.nvim_create_user_command("GR", fast_move.go_route, {})
	vim.api.nvim_create_user_command("GH", fast_move.go_helper, {})

	-- Alternate command (A)
	vim.api.nvim_create_user_command("A", alternate.open_alternate_file, {})

	-- Relation command (R)
	vim.api.nvim_create_user_command("R", related.open_related_file, {})

	-- Custom go file command (custom_gf)
	vim.api.nvim_create_user_command("Railsgf", utils.custom_gf, {})
end

return M
