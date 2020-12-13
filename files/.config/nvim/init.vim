" Nvim configuration

" Plugins {{{
call plug#begin()

Plug 'git@github.com:CDSoft/pwd.git'
Plug 'git@github.com:CDSoft/todo.git'
Plug 'https://github.com/thinca/vim-localrc.git'
Plug 'https://github.com/w0rp/ale.git'
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

call plug#end()
" }}}

" Startup {{{
syntax on
set nocompatible " use vim power
set loadplugins
filetype plugin on
filetype indent on
filetype on
" }}}

" File types {{{
au BufRead,BufNewFile *.md,*.i set filetype=markdown
autocmd Filetype markdown setlocal spell
autocmd Filetype markdown set spelllang=en,fr

au BufRead,BufNewFile *.rst set filetype=rst
autocmd Filetype rst setlocal spell
autocmd Filetype rst set spelllang=en,fr

au BufRead,BufNewFile *.pl set filetype=prolog
" }}}

" Keyboard {{{
let mapleader = "²"
let g:mapleader = "²"
" }}}

" Firefox like tab navigation {{{
" (https://vim.fandom.com/wiki/Alternative_tab_navigation)
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>
" }}}

" Windows navigation {{{
"map <C-Left>  <C-w>h
"map <C-Down>  <C-w>j
"map <C-Up>    <C-w>k
"map <C-Right> <C-w>l
" }}}

" Automatic layout {{{
set autoindent
set backspace=indent,eol,start
set expandtab
set shiftround " round indent to multiple of shiftwidth
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4
set tabstop=4
" }}}

" Selection {{{
set clipboard+=unnamed
set clipboard+=unnamedplus
if !has('nvim')
    set clipboard+=autoselect
endif
set mouse=a
" }}}

" Search {{{
set hlsearch
" set ignorecase
set incsearch
set infercase " when ignorecase, the completion also modifies the case
set magic
set showmatch
set smartcase
" }}}

" Netrw {{{
"let g:netrw_liststyle= 4 " tree style
" Tweaks for browsing
"let g:netrw_banner=0        " disable annoying banner
"let g:netrw_browse_split=4  " open in prior window
"let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
" }}}

" Directories {{{
"set autochdir " the current directory is the directory of the current file
set browsedir=buffer " browse the directory of the buffer
set path+=** " do not use with autochdir
" }}}

" Files {{{
set nobomb " add a BOM when writing a UTF-8 file
set encoding=utf-8
set fileencoding=utf-8
set fsync
" }}}

" ctags / hasktags {{{
" Create the `tags` file (may need to install ctags first)
command! CTags !ctags -R .
command! HTags !hasktags --ignore-close-implementation --ctags .
" }}}

" fzf {{{
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>f :Rg<CR>
if system("git rev-parse --is-inside-work-tree 2>/dev/null") == ""
    nnoremap <silent> <C-f> :Files<CR>
else
    nnoremap <silent> <C-f> :GFiles<CR>
endif

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'

" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'
" }}}

" Make {{{
set makeprg=make " '%' '#' : current and alternate file name
" }}}

" Vimgrep {{{

set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" Search the word under the cursor in all files
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j ../**" <Bar> cw<CR>

" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv')<CR>

" Open vimgrep and put the cursor in the right position
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

" Vimgreps in the current file
map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with vimgrep, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>

function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction


function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" }}}

" HTML export {{{
let g:html_number_lines = 0
" }}}

" ALE {{{
let g:ale_sh_shellcheck_options = "-x"
let g:ale_sh_shellcheck_exclusions = 'SC1090,SC2029'

let g:ale_linters = {
    \ 'c': ["gcc", "clang", "clang-tidy", "cppcheck"],
    \ 'h': [],
    \ 'cpp': ["gcc", "clang", "clang-tidy", "cppcheck"],
    \ 'haskell': ["stack-ghc", "hlint"],
    \ 'rust': ["cargo", "rls"],
    \ 'shell': ["shellcheck"],
    \ }

let g:ale_linters_explicit = 1

let g:ale_haskell_hdevtools_options = '-g -Wall'
" }}}

" Markdown {{{

" https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled = 1

" https://github.com/vim-pandoc/vim-pandoc-syntax
let g:pandoc#syntax#conceal#use=0
hi link pandocAtxHeader Directory
hi link pandocSetexHeader Directory
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

" }}}

" ghc-mod {{{
"map <silent> tw :GhcModTypeInsert<CR>
"map <silent> ts :GhcModSplitFunCase<CR>
"map <silent> tq :GhcModType<CR>
"map <silent> te :GhcModTypeClear<CR>
" }}}

" hdevtools {{{
"let g:hdevtools_stack = 1
"let g:hdevtools_options = '-g-Wall -g-fdefer-type-errors'

"au FileType haskell nnoremap <buffer> <F1> :HdevtoolsType<CR>
"au FileType haskell nnoremap <buffer> <silent> <F2> :HdevtoolsInfo<CR>
"au FileType haskell nnoremap <buffer> <silent> <F3> :HdevtoolsClear<CR>
" }}}

" nerdtree {{{
map <Leader>n :NERDTreeToggle<CR>
" }}}

" tabularize {{{
" }}}

" Pathogen {{{
"execute pathogen#infect()
" }}}

" ALE {{{
" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
" }}}

" Display {{{
set title " enable setting title
set titlestring=%f%m
syntax enable

set t_Co=256
set termguicolors     " enable true colors support
set background=dark
colorscheme PaperColor
highlight Normal ctermbg=Black guibg=Black
highlight NonText ctermbg=Black guibg=Black
highlight StatusLine cterm=bold,reverse gui=bold,reverse guifg=#1f5757 guibg=White
highlight LineNr ctermfg=11 guifg=#686868 guibg=#1c1c1c
highlight TabLineSel guifg=Black guibg=#00afaf

"let g:molokai_original = 1
"let g:rehash256 = 1
"colorscheme molokai
"highlight Normal ctermbg=Black guibg=Black
"highlight NonText ctermbg=Black guibg=Black

if !has('nvim')
    set antialias
endif
" show the current line and column in the current window
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline nocursorcolumn
set cursorline nocursorcolumn
set noequalalways " do not resize other windows when splitting
"set foldcolumn=3
"set foldenable

"set foldmethod=syntax
"set guifont=Inconsolata\ 10
set guifont=Source\ Code\ Pro\ Medium\ 10
set guioptions+=a " autoselect
set guioptions-=m " no menu bar
set guioptions+=t " tearoff menu items
set guioptions-=T " no tool bar
set guioptions+=r " right-hand scrollbar
set guioptions+=L " left-hand scrollbar is vertical split
set guioptions+=b " bottom scrollbar
set laststatus=2
set number
set numberwidth=4
set ruler
set showcmd
set suffixes+=.pyc
set visualbell
set wildignore=*.o,*~,*.pyc,*.bak,
set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmenu
set wildmode=longest,list,full
set nowrap
set showmode
set completeopt=menuone,menu,longest
set cmdheight=1
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set list
set colorcolumn=120
set splitbelow splitright
" }}}

" Rainbow {{{
let g:rainbow_active = 1 " set to 0 if you want to enable it later via :RainbowToggle
"}}}

" Check file modifications {{{
set autoread
au BufEnter,BufWinEnter,CmdlineEnter,CmdwinEnter,CursorHold,CursorHoldI,FileChangedShell,FocusGained,WinEnter * checktime
"}}}

" Debug {{{
packadd termdebug
let g:termdebug_wide=1
"}}}

" Project specific configuration {{{
set exrc
set secure
" }}}

" neovim terminal setup
tnoremap <Esc> <C-\><C-n>
autocmd TermOpen * startinsert

" auto reload modified files
autocmd BufEnter,FocusGained * checktime

" nvim startup may be too long to catch the initial SIGWINCH and resize the window
autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"

" vim: set ts=4 sw=4 foldmethod=marker :
