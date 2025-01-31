-- busted_helper.lua
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path
-- Mock the `vim` global
_G.vim = {
	api = {
		nvim_set_var = function() end,
		nvim_get_var = function()
			return nil
		end,
		nvim_command = function() end,
	},
	fn = {},
	g = {},
	o = {},
	opt = {},
	keymap = {},
}

-- Suppress unnecessary logs
local original_print = print
print = function(...) -- luacheck: ignore 121
	-- Suppress logs unless they are from busted
	if not string.match(debug.traceback(), "busted") then
		original_print(...)
	end
end

-- Ensure busted is available before using it
local busted = require("busted")

-- Enable verbose output
local verbose = os.getenv("BUSTED_VERBOSE") == "1"

-- Custom output formatting
busted.subscribe({ "test", "end" }, function(element, _, status) -- luacheck: ignore 212
	if verbose then
		io.write(string.format("[%s] ", status:upper()))
	end
	if status == "success" then
		io.write("✓ ")
	elseif status == "failure" then
		io.write("✗ ")
	elseif status == "error" then
		io.write("⚠ ")
	end
	io.write(element.name .. "\n")
end)
