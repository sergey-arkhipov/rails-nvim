describe("utils", function()
	local utils = require("rails-nvim.utils")
	-- local utils = rails_nvim.utils
	it("return pluralize form of passed word", function()
		assert.is_equal(utils.pluralize("Article"), "Articles")
		assert.is_equal(utils.pluralize("Directory_entry"), "Directory_entries")
		assert.is_equal(utils.pluralize("Huck"), "Hucks")
	end)
end)
