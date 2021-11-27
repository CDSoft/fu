call plug#begin()

Plug 'https://github.com/CDSoft/pwd.git'
Plug 'https://github.com/CDSoft/todo.git'
Plug 'https://github.com/thinca/vim-localrc.git'
"Plug 'https://github.com/w0rp/ale.git'
Plug 'https://github.com/ziglang/zig.vim'
Plug 'https://github.com/JuliaEditorSupport/julia-vim.git'
Plug 'https://github.com/godlygeek/tabular.git'
Plug 'https://github.com/vim-pandoc/vim-pandoc.git'
Plug 'https://github.com/vim-pandoc/vim-pandoc-syntax.git'
Plug 'nvim-lua/plenary.nvim'
%(when(cfg_yesno("nvim-telescope", "Use Telescope with Neovim?")) [[
Plug 'nvim-telescope/telescope.nvim'
]])
%(when(cfg_yesno("nvim-fzf", "Use FZF with Neovim?")) [[
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
]])
Plug 'https://github.com/NLKNguyen/papercolor-theme.git'
Plug 'https://github.com/luochen1990/rainbow.git'
"Plug 'https://github.com/jiangmiao/auto-pairs.git'
Plug 'metakirby5/codi.vim'
"Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'https://github.com/norcalli/nvim-colorizer.lua.git'
Plug 'airblade/vim-rooter'
Plug 'https://github.com/vim-scripts/DrawIt'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

"Plug 'vim-airline/vim-airline'
Plug 'hoob3rt/lualine.nvim'
"Plug 'kyazdani42/nvim-web-devicons'

"Plug 'https://github.com/frace/vim-bubbles'
Plug 'https://github.com/sbdchd/neoformat'
Plug 'monkoose/fzf-hoogle.vim'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Plug 'vimwiki/vimwiki'
Plug 'neovim/nvim-lspconfig'
"Plug 'nvim-lua/completion-nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

Plug 'ollykel/v-vim'

%(when(cfg_yesno("work", "Install work configuration?")) "Plug 'https://github.com/CDSoft/trace32-practice.vim.git'")

call plug#end()
