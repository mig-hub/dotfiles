vim.filetype.add({
    extension = {
        nu = "nu"
    }
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'nu' },
  callback = function() vim.treesitter.start() end,
})

require('setuporgmode')

require("CopilotChat").setup()

