vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'
  
  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- File Explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
        'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
  }	

  -- Buffers line
  use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}
  

  -- Syntax highlight
  use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
  }

  -- Color schemes
  use { "ellisonleao/gruvbox.nvim" }
  
  -- Languages support
  use { 'neoclide/coc.nvim', branch='release' } 

  
  -- Easy motion
  use {
    "ggandor/leap.nvim",
    config = function() require("leap").set_default_keymaps() end
  }
  use {
    'unblevable/quick-scope'
  }

end)

