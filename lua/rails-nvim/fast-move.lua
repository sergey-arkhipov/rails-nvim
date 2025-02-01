local util = require("rails-nvim.utils")
local M = {}

-- Helper function to open a file in Neovim
local function open_file(file_path)
	if vim.fn.filereadable(file_path) == 1 then
		vim.cmd("e " .. file_path)
	else
		print("File not found: " .. file_path)
	end
end

local function get_base_name()
	local file_path = vim.fn.expand("%:p") -- Get the full absolute path of the current buffer
	local base_name

	-- Check if the file is a model
	if file_path:match("app/models/") then
		base_name = file_path:match("([^/]+)%.rb$") -- Extract "article" from "article.rb"

	-- Check if the file is a controller
	elseif file_path:match("app/controllers/") then
		base_name = file_path:match("([^/]+)_controller%.rb$") -- Extract "articles" from "articles_controller.rb"
		base_name = util.singularize(base_name) -- Singularize to "article"

	-- Check if the file is a spec
	elseif file_path:match("spec/models/") then
		base_name = file_path:match("([^/]+)_spec%.rb$") -- Extract "article" from "article_spec.rb"

	-- Check if the file is a view
	elseif file_path:match("app/views/") then
		base_name = file_path:match("app/views/([^/]+)/") -- Extract "articles" from "app/views/articles/index.html.erb"
		base_name = util.singularize(base_name) -- Singularize to "article"
	else
		print("Unsupported file type. Please open a model, controller, spec, or view.")
		return nil
	end
	print(base_name)
	return base_name
end

local function find_file_in_directory(directory, base_name)
	-- Use `vim.fn.glob` to search for files matching the base name in the directory
	local pattern = directory .. "/" .. base_name .. "*"
	local files = vim.fn.glob(pattern, true, true) -- Returns a list of matching files

	-- Return the first matching file (or nil if no matches)
	return files[1]
end

-- Find and open a file in a directory based on the base name
local function find_and_open(directory, base_name)
	local file_path = find_file_in_directory(directory, base_name)
	open_file(file_path)
end

-- Go to Controller
function M.go_controller()
	local base_name = get_base_name()
	if not base_name then
		return
	end
	find_and_open("app/controllers", base_name)
end

-- Go to View
function M.go_view()
	local base_name = get_base_name()
	if not base_name then
		return
	end
	local action_name = vim.fn.input("Action name (e.g., index): ")
	local view_path = "app/views/" .. util.pluralize(base_name:lower()) .. "/" .. action_name .. ".html.erb"
	open_file(view_path)
end

-- Go to Model
function M.go_model()
	local base_name = get_base_name()
	if not base_name then
		return
	end
	find_and_open("app/models", base_name)
end

-- Go to Spec
function M.go_spec()
	local base_name = get_base_name()
	if not base_name then
		return
	end
	find_and_open("spec/models", base_name)
end

-- Go to Route
function M.go_route()
	local route_path = "config/routes.rb"
	local base_name = get_base_name()
	open_file(route_path)
	-- Search for the route definition
	if base_name then
		vim.cmd("/resources :" .. base_name:lower())
	end
end

-- Go to Helper
function M.go_helper()
	local base_name = get_base_name()
	if not base_name then
		return
	end
	find_and_open("app/helpers", base_name)
end

return M
