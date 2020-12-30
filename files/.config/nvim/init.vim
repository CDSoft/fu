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

lua require'nvim-colorizer'

" nvim startup may be too long to catch the initial SIGWINCH and resize the window
autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"
