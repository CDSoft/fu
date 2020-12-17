" Debug terminal

    packadd termdebug
    let g:termdebug_wide=1

" Terminal setup

    tnoremap <Esc> <C-\><C-n>
    autocmd TermOpen * startinsert
