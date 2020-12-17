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
