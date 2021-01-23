" Nvim configuration

runtime vim/plugins.vim

runtime vim/config.vim

runtime vim/netrw.vim
runtime vim/tags.vim
runtime vim/fzf.vim
runtime vim/make.vim
runtime vim/grep.vim
runtime vim/html-export.vim
runtime vim/ale.vim
runtime vim/vim-pandoc.vim
runtime vim/display.vim
runtime vim/rainbow.vim
runtime vim/autoreload.vim
runtime vim/terminal.vim
runtime vim/vim-gitgutter.vim
runtime vim/vim-bubbles.vim
runtime vim/neoformat.vim

if exists('g:started_by_firenvim')
    runtime vim/firenvim.vim " must be run after display.vim
endif

lua require'nvim-colorizer'

" nvim startup may be too long to catch the initial SIGWINCH and resize the window
autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"
