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

	-- Emodel command
	vim.api.nvim_create_user_command("Emodel", function(opts)
		if opts.args and opts.args ~= "" then
			utils.open_or_create_file("model", opts.args)
		else
			utils.list_and_open_file("model")
		end
	end, {
		nargs = "?",
		complete = function(arg_lead)
			return get_completion_candidates("model", arg_lead)
		end,
	})

	-- Econtroller command
	vim.api.nvim_create_user_command("Econtroller", function(opts)
		if opts.args and opts.args ~= "" then
			utils.open_or_create_file("controller", opts.args)
		else
			utils.list_and_open_file("controller")
		end
	end, {
		nargs = "?",
		complete = function(arg_lead)
			return get_completion_candidates("controller", arg_lead)
		end,
	})

	-- Eview command
	vim.api.nvim_create_user_command("Eview", function(opts)
		if opts.args and opts.args ~= "" then
			utils.open_or_create_file("view", opts.args)
		else
			utils.list_and_open_file("view")
		end
	end, {
		nargs = "?",
		complete = function(arg_lead)
			return get_completion_candidates("view", arg_lead)
		end,
	})

	-- Erspec command
	vim.api.nvim_create_user_command("Erspec", function(opts)
		if opts.args and opts.args ~= "" then
			utils.open_or_create_file("spec", opts.args)
		else
			utils.list_and_open_file("spec")
		end
	end, {
		nargs = "?",
		complete = function(arg_lead)
			return get_completion_candidates("spec", arg_lead)
		end,
	})

	-- Alternate command (A)
	vim.api.nvim_create_user_command("A", alternate.open_alternate_file, {})

	-- Relation command (R)
	vim.api.nvim_create_user_command("R", related.open_related_file, {})

	-- Custom go file command (custom_gf)
	vim.api.nvim_create_user_command("Railsgf", utils.custom_gf, {})
end

return M
