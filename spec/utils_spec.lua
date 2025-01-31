describe("utils", function()
	local utils = require("rails-nvim.utils")
	-- local utils = rails_nvim.utils
	it("return pluralize form of passed word", function()
		assert.is_equal(utils.pluralize("Article"), "Articles")
		assert.is_equal(utils.pluralize("Directory_entry"), "Directory_entries")
		assert.is_equal(utils.pluralize("Huck"), "Hucks")
	end)

	local M = require("rails-nvim.utils") -- Replace with the actual module name

	describe("M.custom_gf", function()
		-- Mock Neovim API functions
		local original_api = vim.api
		local original_fn = vim.fn
		local original_cmd = vim.cmd

		before_each(function()
			-- Mock vim.api functions
			vim.api = {
				nvim_get_current_line = function()
					return "<%= render 'test_file' %>" -- Mocked line for testing
				end,
				nvim_buf_get_name = function()
					return "/current/directory/current_file.rb" -- Mocked current buffer file path
				end,
			}

			-- Mock vim.fn functions
			vim.fn = {
				fnamemodify = function(path, modifier)
					if modifier == ":h" then
						return "/current/directory" -- Mocked current directory
					end
					return path
				end,
				expand = function(path)
					if path == "/current/directory/_test_file.erb" then
						return "/current/directory/_test_file.erb" -- Mocked expanded path
					elseif path == "/current/directory/_test_file.html.erb" then
						return "/current/directory/_test_file.html.erb" -- Mocked expanded path
					elseif path == "app/views/_test_file.erb" then
						return "app/views/_test_file.erb" -- Mocked expanded path
					elseif path == "app/views/_test_file.html.erb" then
						return "app/views/_test_file.html.erb" -- Mocked expanded path
					elseif path == "app/views/_article_tag.html.erb" then
						return "app/views/_article_tag.html.erb" -- Mocked expanded path
					end
					return path
				end,
				filereadable = function(path)
					if path == "/current/directory/_article_tag.erb" then
						return 1 -- Mocked as readable
					end
					if path == "/current/directory/_test_file.erb" then
						return 1 -- Mocked as readable
					end
					return 0 -- Mocked as not readable
				end,
			}

			-- Mock vim.cmd
			vim.cmd = function(command)
				-- Mocked vim.cmd behavior
				print("Executed command: " .. command)
			end
		end)

		after_each(function()
			-- Restore original functions
			vim.api = original_api
			vim.fn = original_fn
			vim.cmd = original_cmd
		end)

		it("should open the correct file when a valid filename is found", function()
			-- Spy on vim.cmd to verify it was called with the correct command
			local spy_cmd = spy.on(vim, "cmd")

			-- Call the function
			M.custom_gf()

			-- Assert that vim.cmd was called with the correct edit command
			assert.spy(spy_cmd).was_called_with("edit /current/directory/_test_file.erb")
		end)

		it("should fallback to default gf behavior when no file is found", function()
			-- Update the mock to simulate no readable file
			vim.fn.filereadable = function()
				return 0 -- All files are unreadable
			end

			-- Spy on vim.cmd to verify it was called with the fallback command
			local spy_cmd = spy.on(vim, "cmd")

			-- Call the function
			M.custom_gf()

			-- Assert that vim.cmd was called with the fallback gf command
			assert.spy(spy_cmd).was_called_with("normal! gf")
		end)

		it("should handle @article_tags pattern correctly", function()
			-- Update the mock to simulate a line with @article_tags
			vim.api.nvim_get_current_line = function()
				return "<%= render @article_tags %>" -- Mocked line for testing
			end

			-- Spy on vim.cmd to verify it was called with the correct command
			local spy_cmd = spy.on(vim, "cmd")

			-- Call the function
			M.custom_gf()

			-- Assert that vim.cmd was called with the correct edit command
			assert.spy(spy_cmd).was_called_with("edit /current/directory/_article_tag.erb")
		end)
	end)
end)
