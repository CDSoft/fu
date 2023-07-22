" https://github.com/vim-pandoc/vim-pandoc-syntax

let g:pandoc#modules#disabled = ["folding"]

let g:pandoc#syntax#conceal#use=0

let g:pandoc#syntax#codeblocks#embeds#langs = ["c", "lua", "python", "haskell", "literatehaskell=lhaskell", "bash=sh", "dot"]

hi Title term=bold ctermfg=Red guifg=Red gui=bold

augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md      set filetype=markdown.pandoc
    au! BufNewFile,BufFilePre,BufRead *.rst     set filetype=rst
    au! BufNewFile,BufFilePre,BufRead *.rst.inc set filetype=rst
augroup END
