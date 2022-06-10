" Nvim configuration

runtime vim/plugins.vim

runtime vim/config.vim

runtime vim/netrw.vim
runtime vim/tags.vim
%(when(cfg.nvim_fzf) "runtime vim/fzf.vim")
%(when(cfg.nvim_telescope) "runtime vim/telescope.vim")
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
"runtime vim/vim-rooter.vim
runtime vim/vimwiki.vim
runtime vim/lac.vim
runtime vim/completion.vim
runtime vim/vim-zig.vim

lua require'nvim-colorizer'
lua require 'luasnip'
lua require'lsp'
lua require'lualine-setup'
lua require'nvim-cmp'
lua require'nvim-project-setup'
lua require'nvim-tree-setup'

" nvim startup may be too long to catch the initial SIGWINCH and resize the window
autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"
