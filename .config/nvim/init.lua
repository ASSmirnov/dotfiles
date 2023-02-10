vim.g.mapleader = " "
require("plugins")
require("lualine").setup()

-- disable builtin file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- highlight yank
vim.cmd[[
    augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=200})
    augroup END
]]

-- Configure plugins
require("nvim-tree").setup{
    view = {
        mappings = {
            list = {
                { key = "l", action = "edit"},
                { key = "h", action = "close_node"},
                { key = "u", action = "dir_up"},
            },
        },
    },
}

require("bufferline").setup{
     options = {
        offsets = {
             {
                 filetype = "NvimTree",
                 text = "File Explorer",
                 highlight = "Directory",
                 separator = true -- use a "true" to enable the default, or set your own character
             },
         }
    }
}

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the four listed parsers should always be installed)
  ensure_installed = { "lua", "vim", "help", "python", "rust" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}


-- Configure COC
require("coc_config")


-- Color scheme
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

-- Key bindings
vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<cr>") -- toggle File Explorer
vim.keymap.set("n", "<C-h>", "<C-w>h") -- focus on left window
vim.keymap.set("n", "<C-j>", "<C-w>j") -- focus on bottom window
vim.keymap.set("n", "<C-k>", "<C-w>k") -- focus on upper window
vim.keymap.set("n", "<C-l>", "<C-w>l") -- focus on right window
vim.keymap.set("n", "<C-q>", ":bd | bn<cr>") -- close focused buffer and focus on the next buffer
vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<cr>") -- focus on the previos tab
vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<cr>") -- focus on the next tab
vim.keymap.set("n", "<Leader>gf", ":NvimTreeFindFile<cr>") -- focus on file line in File Explore
-- vim.keymap.set({"n", "v"}, "<C-s>", ":wa<cr>") -- save all buffers
vim.keymap.set("n", "<Leader>c", ":q<cr>") -- close window
vim.keymap.set("n", "<Leader>h", ":noh<cr>") -- save all buffers

