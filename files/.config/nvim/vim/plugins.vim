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
Plug 'https://github.com/junegunn/fzf.vim.git'
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

Plug 'https://github.com/vifm/vifm.vim.git'
"Plug 'https://github.com/frace/vim-bubbles'
Plug 'https://github.com/sbdchd/neoformat'
Plug 'monkoose/fzf-hoogle.vim'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Plug 'vimwiki/vimwiki'
Plug 'neovim/nvim-lspconfig'

" firenvim requires
" - https://addons.mozilla.org/en-US/firefox/addon/firenvim/
" - https://chrome.google.com/webstore/detail/firenvim/egpjdkipkomnmjhjmdamaniclmdlobbo
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

%( cfg_yesno("work", "Install work configuration?") and "Plug 'https://github.com/CDSoft/trace32-practice.vim.git'" or "" )

call plug#end()
