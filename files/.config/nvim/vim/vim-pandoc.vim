" https://github.com/vim-pandoc/vim-pandoc-syntax

let g:pandoc#syntax#conceal#use=0
hi link pandocAtxHeader Directory
hi link pandocSetexHeader Directory
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END
