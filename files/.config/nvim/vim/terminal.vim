" Debug terminal

    packadd termdebug
    let g:termdebug_wide=1

" Terminal setup

    tnoremap <Esc> <C-\><C-n>
    autocmd TermOpen * startinsert

" Key bindings

    nnoremap <C-A-t>     :tabnew<CR>:terminal<CR>
    inoremap <C-A-t>     <ESC>:tabnew<CR>:terminal<CR>
