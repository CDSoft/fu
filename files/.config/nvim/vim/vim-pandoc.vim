" https://github.com/vim-pandoc/vim-pandoc-syntax

let g:pandoc#syntax#conceal#use=0

hi Title term=bold ctermfg=Red guifg=Red gui=bold

augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END
