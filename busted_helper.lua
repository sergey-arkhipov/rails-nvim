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
