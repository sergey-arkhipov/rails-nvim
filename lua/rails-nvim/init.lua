local M = {}
-- Enable wildmenu and better completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

M.config = require("rails-nvim.config").config

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	-- print("Merged Config:", vim.inspect(M.config)) -- Debug log
	require("rails-nvim.commands").setup()
end

return M
