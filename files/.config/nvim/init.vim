" Nvim configuration

runtime vim/plugins.vim

runtime vim/config.vim

runtime vim/netrw.vim
runtime vim/tags.vim
%( cfg_yesno("nvim-fzf", "Use FZF with Neovim?") and "runtime vim/fzf.vim" or "" )
%( cfg_yesno("nvim-telescope", "Use Telescope with Neovim?") and "runtime vim/telescope.vim" or "" )
runtime vim/make.vim
runtime vim/grep.vim
runtime vim/html-export.vim
"runtime vim/ale.vim
runtime vim/display.vim
runtime vim/vim-pandoc.vim " shall be loaded after display.vim to overload title colors
runtime vim/rainbow.vim
runtime vim/autoreload.vim
runtime vim/terminal.vim
runtime vim/vim-gitgutter.vim
"runtime vim/vim-bubbles.vim
runtime vim/neoformat.vim
runtime vim/vim-rooter.vim
runtime vim/vimwiki.vim
runtime vim/lac.vim
runtime vim/completion.vim

if exists('g:started_by_firenvim')
    runtime vim/firenvim.vim " must be run after display.vim
endif

lua require'nvim-colorizer'
lua require'lsp'
lua require'lualine-setup'

" nvim startup may be too long to catch the initial SIGWINCH and resize the window
autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"
