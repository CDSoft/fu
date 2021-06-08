" Debug terminal

    packadd termdebug
    let g:termdebug_wide=1

" Terminal setup

    tnoremap <Esc> <C-\><C-n>
    autocmd TermOpen * setlocal noruler|setlocal noshowcmd|setlocal nonumber|startinsert

" Key bindings

    nnoremap <C-A-t>    :tabnew term://zsh<CR>
    inoremap <C-A-t>    <ESC>:tabnew term://zsh<CR>

    nnoremap <Leader>st     :tabnew term://zsh<CR>
    nnoremap <Leader>sn     :split term://zsh<CR>
    nnoremap <Leader>sv     :vsplit term://zsh<CR>
