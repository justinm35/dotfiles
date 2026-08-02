return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" }, -- Ensures dependency is installed
		config = function()
			-- Set folding options
			vim.o.foldcolumn = '0' -- Display fold column
			vim.o.foldlevel = 99 -- High value for ufo provider
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Key mappings for opening/closing folds
			local ufo = require('ufo')
			vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = "Open all folds" })
			vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set('n', 'zC', function() require('ufo').closeFoldsWith(1) end, { desc = "Close current block" })
			-- vim.keymap.set('n', 'zp', function()
			-- 	require('ufo').peekFoldedLinesUnderCursor()
			-- end, { desc = "Peek folded content" })

			-- Configure ufo to use Treesitter as the main provider
			ufo.setup({
				fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
					local newVirtText = {}
					local suffix = (' 󰁂 %d '):format(endLnum - lnum)
					local sufWidth = vim.fn.strdisplaywidth(suffix)
					local targetWidth = width - sufWidth
					local curWidth = 0
					for _, chunk in ipairs(virtText) do
						local chunkText = chunk[1]
						local chunkWidth = vim.fn.strdisplaywidth(chunkText)
						if targetWidth > curWidth + chunkWidth then
							table.insert(newVirtText, chunk)
						else
							chunkText = truncate(chunkText, targetWidth - curWidth)
							local hlGroup = chunk[2]
							table.insert(newVirtText, { chunkText, hlGroup })
							chunkWidth = vim.fn.strdisplaywidth(chunkText)
							-- str width returned from truncate() may less than 2nd argument, need padding
							if curWidth + chunkWidth < targetWidth then
								suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
							end
							break
						end
						curWidth = curWidth + chunkWidth
					end
					table.insert(newVirtText, { suffix, 'MoreMsg' })
					return newVirtText
				end,
				provider_selector = function(_, _, _)
					return { 'treesitter', 'indent' }
				end
			})
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	},
	{
		"kevinhwang91/promise-async" -- Ensures promise-async is available
	}
}
