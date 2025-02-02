describe("utils", function()
	local utils = require("rails-nvim.utils")

	it("return pluralize form of passed word", function()
		assert.is_equal(utils.pluralize("Article"), "Articles")
		assert.is_equal(utils.pluralize("Directory_entry"), "Directory_entries")
		assert.is_equal(utils.pluralize("Huck"), "Hucks")
		return print("return pluralize form of passed word - OK")
	end)

	describe("utils.custom_gf", function()
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
					-- Define a mapping of paths to their expanded versions
					local expanded_paths = {
						["/current/directory/_test_file_erb.erb"] = "/current/directory/_test_file_erb.erb",
						["/current/directory/_test_file.html.erb"] = "/current/directory/_test_file.html.erb",
						["app/views/_test_file.erb"] = "app/views/_test_file.erb",
						["app/views/_test_file.html.erb"] = "app/views/_test_file.html.erb",
						["app/views/_article_tag.html.erb"] = "app/views/_article_tag.html.erb",
						["app/views/_directory_entry.html.erb"] = "app/views/_directory_entry.html.erb",
					}

					-- Return the expanded path if it exists in the mapping, otherwise return the original path
					return expanded_paths[path] or path
				end,
				filereadable = function(path)
					-- Define a set of readable files
					local readable_files = {
						["/current/directory/_directory_entry.html.erb"] = true,
						["/current/directory/_article_tag.html.erb"] = true,
						["/current/directory/_test_file.html.erb"] = true,
						["/current/directory/_test_file_erb.erb"] = true,
					}

					-- Check if the path exists in the set
					return readable_files[path] and 1 or 0
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

		-- Helper function to test custom_gf behavior
		local function test_custom_gf(mocked_line, expected_command)
			-- Update the mock to simulate a line
			---@diagnostic disable-next-line
			vim.api.nvim_get_current_line = function()
				return mocked_line
			end

			-- Spy on vim.cmd to verify it was called with the correct command
			local spy_cmd = spy.on(vim, "cmd")

			-- Call the function
			utils.custom_gf()

			-- Assert that vim.cmd was called with the correct edit command
			---@diagnostic disable-next-line: undefined-field
			assert.spy(spy_cmd).was_called_with(expected_command)
		end

		it("open the correct file when a valid filename is found", function()
			test_custom_gf("<%= render 'test_file'  %>", "edit /current/directory/_test_file.html.erb")
		end)
		it("open the correct file when a valid filename is found and ext is erb only", function()
			test_custom_gf("<%= render 'test_file_erb'  %>", "edit /current/directory/_test_file_erb.erb")
		end)
		it("fallback to default gf behavior when no file is found", function()
			test_custom_gf("<%= render 'no_file'  %>", "normal! gf")
		end)
		it("handle @article_tags pattern correctly for plural s", function()
			test_custom_gf("<%= render @article_tags %>", "edit /current/directory/_article_tag.html.erb")
		end)

		it("handle @directory_entries pattern correctly for plural ies", function()
			test_custom_gf("<%= render @directory_entries %>", "edit /current/directory/_directory_entry.html.erb")
		end)
	end)

	-- test_list_files.lua

	-- test_list_files.lua

	-- Import the module containing the list_files function
	local M = require("rails-nvim.utils") -- Replace with the actual module name

	describe("list_files", function()
		-- Mock vim.fn and vim.uv
		local vim_mock

		before_each(function()
			-- Create a mock of vim
			vim_mock = {
				fn = {
					isdirectory = function(dir)
						return dir == "test/test_dir" and 1 or 0
					end,
				},
				uv = {
					fs_scandir = function(dir)
						-- Simulate a directory with files and subdirectories
						if dir == "test/test_dir" then
							local files = {
								{ name = "file1.txt", type = "file" },
								{ name = "file2.lua", type = "file" },
								{ name = "subdir", type = "directory" },
								{ name = "file3.md", type = "file" },
							}
							local index = 0
							return function()
								index = index + 1
								return files[index] and files[index].name, files[index] and files[index].type
							end
						elseif dir == "test/test_dir/subdir" then
							local files = {
								{ name = "file4.txt", type = "file" },
								{ name = "file5.rb", type = "file" },
							}
							local index = 0
							return function()
								index = index + 1
								return files[index] and files[index].name, files[index] and files[index].type
							end
						else
							return function() end -- No files in other directories
						end
					end,
					fs_scandir_next = function(handle)
						return handle()
					end,
				},
			}

			-- Replace the global vim with the mock
			_G.vim = vim_mock
		end)

		after_each(function()
			-- Restore the original vim (if any)
			_G.vim = nil
		end)

		it("lists all files in a directory", function()
			-- Mock fs_scandir to return only files in the root directory
			vim_mock.uv.fs_scandir = function(dir)
				if dir == "test/test_dir" then
					local files = {
						{ name = "file1.txt", type = "file" },
						{ name = "file2.lua", type = "file" },
						{ name = "file3.md", type = "file" },
					}
					local index = 0
					return function()
						index = index + 1
						return files[index] and files[index].name, files[index] and files[index].type
					end
				else
					return function() end -- No files in subdirectories
				end
			end

			local files = M.list_files("test/test_dir")
			table.sort(files) -- Sort for consistent comparison
			assert.are.same({ "file1.txt", "file2.lua", "file3.md" }, files)
		end)

		it("lists all files recursively in subdirectories", function()
			local files = M.list_files("test/test_dir")
			table.sort(files) -- Sort for consistent comparison
			assert.are.same({
				"file1.txt",
				"file2.lua",
				"file3.md",
				"subdir/file4.txt",
				"subdir/file5.rb",
			}, files)
		end)

		it("filters files by pattern", function()
			local files = M.list_files("test/test_dir", "%.txt$") -- Match .txt files
			table.sort(files)
			assert.are.same({ "file1.txt", "subdir/file4.txt" }, files)
		end)

		it("returns an empty list for a non-existent directory", function()
			vim_mock.fn.isdirectory = function()
				return 0 -- Directory does not exist
			end

			local files = M.list_files("non_existent_directory")
			assert.are.same({}, files)
		end)

		it("handle an empty directory", function()
			-- Mock an empty directory
			vim_mock.uv.fs_scandir = function()
				return function() end -- No files
			end

			local files = M.list_files("test/test_dir")
			assert.are.same({}, files)
		end)
	end)
end)
