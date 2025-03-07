--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used) (`:help mapleader`)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugin manager: https://github.com/folke/lazy.nvim (`:help lazy.nvim.txt`)
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Delete/change/add parenthesis/quotes etc: https://github.com/tpope/vim-surround
  'tpope/vim-surround',

  -- Pastel theme: https://github.com/catppuccin/nvim
  {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd 'colorscheme catppuccin-macchiato'
    end,
  },

  -- Cursor navigation: https://github.com/ggandor/leap.nvim
  {
    'ggandor/leap.nvim',
    config = function()
      require('leap').add_default_mappings()
    end,
  },

  -- AI based completion: https://github.com/github/copilot.vim
  'github/copilot.vim',

  {
    'akinsho/bufferline.nvim',
    -- tag = 'v3.*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {
        options = {
          diagnostics = 'nvim_lsp',
          diagnostics_indicator = function(count, level)
            local icon = level:match 'error' and ' ' or ' '
            return ' ' .. icon .. count
          end,
          separator_style = 'slant',
        },
      }
    end,
  },

  -- TODO comments: https://github.com/folke/todo-comments.nvig
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {}
    end,
  },

  -- Better % navigation: https://github.com/andymass/vim-matchup#installation
  'andymass/vim-matchup',

  -- Interact with registers: https://github.com/gennaro-tedesco/nvim-peekup
  'gennaro-tedesco/nvim-peekup',

  -- Smooth scrolling: https://github.com/karb94/neoscroll.nvim
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup()
    end,
  },

  -- File tree: https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        window = {
          width = 30,
          position = 'right',
        },
      }
    end,
  },

  -- Per directory sessions: https://github.com/rmagatti/auto-session
  {
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup {
        log_level = 'error',
        auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      }
    end,
  },

  -- Auto-save: https://github.com/Pocco81/auto-save.nvim
  {
    'pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup {}
    end,
  },

  -- Intelligently opem files in the last place you left them: https://github.com/ethanholz/nvim-lastplace
  {
    'ethanholz/nvim-lastplace',
    config = function()
      require('nvim-lastplace').setup {}
    end,
  },

  -- Pop-up/notify UI: https://github.com/folke/noice.nvim
  {
    'folke/noice.nvim',
    config = function()
      require('noice').setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        presets = {
          -- bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        routes = {
          {
            filter = { event = 'msg_show', find = 'AutoSave: saved at' },
            opts = { skip = true },
          },
        },
      }
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
  },

  {
    'axelvc/template-string.nvim',
    config = function()
      require('template-string').setup {
        filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'python' },
        jsx_brackets = true,
        remove_template_string = false,
        restore_quotes = {
          normal = [[']],
          jsx = [["]],
        },
      }
    end,
  },

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    config = function()
      local null_ls = require 'null-ls'

      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
      local lsp_formatting = function(bufnr)
        vim.lsp.buf.format {
          filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == 'null-ls'
          end,
          bufnr = bufnr,
        }
      end

      null_ls.setup {
        sources = {
          null_ls.builtins.formatting.eslint,
          null_ls.builtins.formatting.stylua,
        },
        debug = true,
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = augroup,
              buffer = bufnr,
              callback = function()
                lsp_formatting(bufnr)
              end,
            })
          end
        end,
      }
    end,
  },
  -- {
  --     "jay-babu/mason-null-ls.nvim",
  --     event = { "BufReadPre", "BufNewFile" },
  --     dependencies = {
  --       "williamboman/mason.nvim",
  --       "jose-elias-alvarez/null-ls.nvim",
  --     },
  --     config = function()
  --       require("mason").setup()
  --       require("mason-null-ls").setup({
  --         automatic_setup = true
  --       })
  --     end,
  -- },

  {
    -- Autocompletion: https://github.com/hrsh7th/nvim-cmp
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  'hrsh7th/cmp-buffer', -- complete from known
  'hrsh7th/cmp-path', -- complete from paths
  {
    'hrsh7th/cmp-cmdline', -- completions for search from current buffer
    config = function()
      local cmp = require 'cmp'

      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })
    end,
  },

  -- Show contextual keybindings: https://github.com/folke/which-key.nvim
  {
    'folke/which-key.nvim',
    opts = {},
  },

  {
    -- Git gutter indications and commands: https://github.com/lewis6991/gits
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '┃', hl = 'GitSignsAdd', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change = { text = '┃', hl = 'GitSignsChange', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete = { text = '_', hl = 'GitSignsDelete', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        untracked = { text = '┃', hl = 'GitSignsAdd', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Highlight current word instances: https://github.com/RRethy/vim-illuminate
  'RRethy/vim-illuminate',

  -- Status line: https://github.com/nvim-lualine/lualine.nvim (`:help lualine.txt`)
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_b = { 'branch', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'filetype' },
        lualine_y = {},
      },
    },
  },

  -- Startup greeter: https://github.com/goolord/alpha-nvim
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('alpha').setup(require('alpha.themes.startify').config)
    end,
  },

  -- Indentation guides: https://github.com/lukas-reineke/indent-blankline.nvim (`:help indent_blankline.txt`)
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      char = '▏',
      space_char_blankline = ' ',
      show_trailing_blankline_indent = false,
      show_current_context = true,
    },
  },
  -- 'lukas-reineke/lsp-format.nvim',

  -- Rainbox parenthesis: https://github.com/mrjones2014/nvim-ts-rainbow
  'mrjones2014/nvim-ts-rainbow',

  -- Terminal window: https://github.com/akinsho/toggleterm.nvim
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        open_mapping = '<C-\\>',
        direction = 'float',
        shade_terminals = true,
      }
    end,
  },

  -- Comment lines and regions (gcc): https://github.com/numToStr/Comment.nvim
  {
    'numToStr/Comment.nvim',
    opts = {},
  },

  'MattesGroeger/vim-bookmarks',
  'tom-anders/telescope-vim-bookmarks.nvim',

  -- Fuzzy Finder: https://github.com/nvim-telescope/telescope.nvim
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- Highlight, edit, and navigate code: https://github.com/nvim-treesitter/nvim-treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  },

  -- Pretty diagnostics: https://github.com/folke/trouble.nvim
  {
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('trouble').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  },

  { import = 'custom.plugins' },
}, {})

-- [[ Basic Keymaps ]]

vim.keymap.set('n', '<leader>tr', ':TroubleToggle<cr>', { desc = '[TR]ouble' })
vim.keymap.set('n', '<leader>pp', ':Gitsigns preview_hunk_inline<cr>', { desc = '[P]review hunk' })

-- Keymaps for better default experience (`:help vim.keymap.set()`)
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'help', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
  matchup = {
    enable = true,
    -- [options]
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  tsserver = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      window = {
        progressBar = false,
      },
    },
  },
}

-- require("lsp-format").setup()

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

vim.diagnostic.config {
  float = { border = 'rounded' },
}

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
