" Startup
"""""""""

    syntax on
    set nocompatible " use vim power
    set loadplugins
    set shortmess+=mrI

" File types / file formats
"""""""""""""""""""""""""""

    filetype plugin on
    filetype indent on
    filetype on

    au BufRead,BufNewFile *.md,*.i set filetype=markdown
    autocmd Filetype markdown setlocal spell
    autocmd Filetype markdown set spelllang=en,fr

    au BufRead,BufNewFile *.rst set filetype=rst
    autocmd Filetype rst setlocal spell
    autocmd Filetype rst set spelllang=en,fr

    au BufRead,BufNewFile *.pl set filetype=prolog

    set nobomb " add a BOM when writing a UTF-8 file
    set encoding=utf-8
    set fileencoding=utf-8
    set fsync

" Directories
"""""""""""""

    "set autochdir " the current directory is the directory of the current file
    set browsedir=buffer " browse the directory of the buffer
    set path+=** " do not use with autochdir

" Keyboard
""""""""""

    let mapleader = ","
    let g:mapleader = ","

" Navigation
""""""""""""

    " Firefox like tab navigation
    " (https://vim.fandom.com/wiki/Alternative_tab_navigation)
    nnoremap <C-S-tab> :tabprevious<CR>
    nnoremap <C-tab>   :tabnext<CR>
    nnoremap <C-t>     :tabnew<CR>
    inoremap <C-S-tab> <Esc>:tabprevious<CR>i
    inoremap <C-tab>   <Esc>:tabnext<CR>i
    inoremap <C-t>     <Esc>:tabnew<CR>

    " Windows navigation
    "map <C-Left>  <C-w>h
    "map <C-Down>  <C-w>j
    "map <C-Up>    <C-w>k
    "map <C-Right> <C-w>l

" Shortcuts
"""""""""""

    " Non breakable spaces
    inoremap <A-space> <C-v>xa0

" Automatic layout
""""""""""""""""""

    set autoindent
    set backspace=indent,eol,start
    set expandtab
    set shiftround " round indent to multiple of shiftwidth
    set shiftwidth=4
    set smartindent
    set smarttab
    set softtabstop=4
    set tabstop=4

" Mouse and clipboard
"""""""""""""""""""""

    set clipboard+=unnamed
    set clipboard+=unnamedplus
    if !has('nvim')
        set clipboard+=autoselect
    endif
    set mouse=a

" Search
""""""""

    set hlsearch
    " set ignorecase
    set incsearch
    set infercase " when ignorecase, the completion also modifies the case
    set magic
    set showmatch
    set smartcase

" Substitutions
"""""""""""""""

    set inccommand=split
