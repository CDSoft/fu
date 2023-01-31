let g:hoogle_path = '%(HOME)/.local/bin/hoogle'

" open :Hoogle appended with a word under the cursor with <space>hh
augroup HoogleMaps
  autocmd!
  autocmd FileType haskell nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>
augroup END
