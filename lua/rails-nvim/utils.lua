local rails_nvim = require("rails-nvim")
local config = rails_nvim.config

local M = {}
M.config = config -- Expose the config table

function M.list_files(directory, pattern)
	-- Validate directory
	if not directory or vim.fn.isdirectory(directory) == 0 then
		print("Directory does not exist: " .. (directory or "nil"))
		return {}
	end

	local files = {}
	local handle = vim.loop.fs_scandir(directory)
	if handle then
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end
			if type == "file" and (not pattern or string.match(name, pattern)) then
				table.insert(files, name)
			end
		end
	end
	return files
end

function M.open_or_create_file(type, filename)
	local directory = config[type .. "_dir"]

	if not directory then
		print("Error: Directory not found for type: " .. type)
		return
	end

	local full_path = directory .. "/" .. filename
	if vim.fn.filereadable(full_path) == 1 then
		vim.cmd("edit " .. full_path)
	else
		vim.cmd("edit " .. full_path)
		print("Created new file: " .. full_path)
	end
end

function M.list_and_open_file(type)
	-- print("Config:", vim.inspect(config)) -- Debug log
	local directory = config[type .. "_dir"]
	-- print("Directory for " .. type .. ": " .. (directory or "nil")) -- Debug log
	local pattern = type == "view" and "%.html%.erb$" or "%.rb$"
	local files = M.list_files(directory, pattern)

	if #files == 0 then
		print("No " .. type .. " files found in " .. directory)
		return
	end

	vim.ui.select(files, {
		prompt = "Select a " .. type .. ":",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if choice then
			M.open_or_create_file(directory, choice)
		end
	end)
end

-- Open alternate file (e.g., model <-> spec, controller <-> view)
function M.open_alternate_file()
	local current_file = vim.api.nvim_buf_get_name(0)
	local alternate_file = nil

	-- Model <-> Spec
	if string.match(current_file, config.model_dir .. "/.*%.rb$") then
		alternate_file = string.gsub(current_file, config.model_dir, config.spec_dir)
	elseif string.match(current_file, config.spec_dir .. "/.*%.rb$") then
		alternate_file = string.gsub(current_file, config.spec_dir, config.model_dir)
	end

	-- Controller <-> View
	if string.match(current_file, config.controller_dir .. "/.*%.rb$") then
		alternate_file = string.gsub(current_file, config.controller_dir, config.view_dir)
		alternate_file = string.gsub(alternate_file, "_controller%.rb$", "")
	elseif string.match(current_file, config.view_dir .. "/.*%.html%.erb$") then
		alternate_file = string.gsub(current_file, config.view_dir, config.controller_dir)
		alternate_file = string.gsub(alternate_file, "%.html%.erb$", "_controller.rb")
	end

	if alternate_file and vim.fn.filereadable(alternate_file) == 1 then
		vim.cmd("edit " .. alternate_file)
	else
		print("Alternate file not found: " .. (alternate_file or "N/A"))
	end
end

-- helper function to pluralize a word (basic implementation)
function M.pluralize(word)
	-- basic pluralization rules (can be expanded as needed)
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
	if string.match(current_file, config.model_dir .. "/.*%.rb$") then
		local model_name = string.match(current_file, config.model_dir .. "/(.*)%.rb$")
		local controller_name = M.pluralize(model_name) .. "_controller.rb"
		related_file = config.controller_dir .. "/" .. controller_name
	end

	-- Controller -> View
	if string.match(current_file, config.controller_dir .. "/.*%.rb$") then
		local controller_name = string.match(current_file, config.controller_dir .. "/(.*)_controller%.rb$")
		related_file = config.view_dir .. "/" .. controller_name
	end

	if related_file and vim.fn.filereadable(related_file) == 1 then
		vim.cmd("edit " .. related_file)
	else
		print("Related file not found: " .. (related_file or "N/A"))
	end
end
-- Define the custom gf function
function M.custom_gf()
	-- Get the current filetype
	local filetype = vim.bo.filetype

	-- Only proceed if the filetype is erb or html.erb
	if filetype == "eruby" or filetype == "html.erb" then
		-- Get the current line under the cursor
		local line = vim.api.nvim_get_current_line()

		-- Extract the file name from the line using a pattern
		local filename = string.match(line, "<%%=.*render%s+['\"]([^'\"]+)['\"]")

		-- If no filename is found, try matching the @article_tags pattern
		if not filename then
			filename = string.match(line, "<%%=.*render%s+@([%w_]+)")
			if filename then
				-- Transform @article_tags to _article_tag (drop 's' and add '_')
				filename = "_" .. string.gsub(filename, "s$", "")
			end
		end

		-- If a filename is found, proceed with custom logic
		if filename then
			-- Add an underscore to the filename if it doesn't already start with one
			local dir, file = string.match(filename, "(.-)([^/]+)$")
			if not dir then
				dir = ""
				file = filename
			end
			if not string.match(file, "^_") then
				file = "_" .. file
			end
			filename = dir .. file

			-- Get the directory of the current buffer
			local current_file = vim.api.nvim_buf_get_name(0)
			local current_dir = vim.fn.fnamemodify(current_file, ":h")

			-- Use vim.fn.expand to find the file with the correct extension
			local full_path

			-- First, check in the current directory
			full_path = vim.fn.expand(current_dir .. "/" .. file .. ".erb")
			if vim.fn.filereadable(full_path) == 0 then
				full_path = vim.fn.expand(current_dir .. "/" .. file .. ".html.erb")
			end

			-- If not found, check in app/views/
			if vim.fn.filereadable(full_path) == 0 then
				full_path = vim.fn.expand("app/views/" .. filename .. ".erb")
				if vim.fn.filereadable(full_path) == 0 then
					full_path = vim.fn.expand("app/views/" .. filename .. ".html.erb")
				end
			end

			-- If the file exists, open it in a buffer
			if vim.fn.filereadable(full_path) == 1 then
				vim.cmd("edit " .. full_path)
				return
			end
		end
	end

	-- Fallback to default gf behavior
	vim.cmd("normal! gf")
end

return M
