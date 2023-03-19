-- See `:help vim.o`

vim.opt.title = true
vim.opt.titlestring = '%t - Neovim'

vim.o.hlsearch = false -- Set highlight on search
vim.wo.number = true -- Make line numbers default
-- vim.opt.mouse = 'a'-- Enable mouse mode

vim.o.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim. (`:help 'clipboard'`)

vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history

vim.wo.signcolumn = 'yes' -- Keep signcolumn on by default

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.ignorecase = true

vim.g.copilot_no_tab_map = true

vim.keymap.set('n', '<C-Tab>', ':bn<CR>', { desc = '[N]ext [B]uffer' })
vim.keymap.set('n', '<C-S-Tab>', ':bp<CR>', { desc = '[P]revious [B]uffer' })

vim.keymap.set({ 'n', 'i' }, '<C-S>', ':update<CR>', { desc = '[S]ave File' })

vim.keymap.set('n', '<A-Down>', ':bn<CR>', { desc = '[N]ext [B]uffer' })
vim.keymap.set('n', '<A-Up>', ':bp<CR>', { desc = '[P]revious [B]uffer' })
vim.keymap.set('n', '<leader>c', ':bd<CR>', { desc = 'Buffer [D]elete' })

vim.keymap.set('n', 'Y', 'yy', { desc = '[Y]ank line' })

vim.keymap.set('n', '<C-_>', function()
  require('Comment.api').toggle.linewise.current()
end, { noremap = true, silent = true })

vim.keymap.set('n', '|', ':NeoTreeFocusToggle <cr>')

vim.keymap.set('n', '<leader>lf', function()
  vim.lsp.buf.format { timeout_ms = 2000 }
end)
