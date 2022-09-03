" Debug terminal

    packadd termdebug
    let g:termdebug_wide=1

" Terminal setup

    " tnoremap <Esc> <C-\><C-n> prevents fzf to exit with Escape
    " (see https://github.com/junegunn/fzf.vim/issues/544)
    tnoremap <expr> <Esc> (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"

    autocmd TermOpen * setlocal noruler|setlocal noshowcmd|setlocal nonumber|startinsert

" Key bindings

    nnoremap <C-A-t>    :tabnew term://zsh<CR>
    inoremap <C-A-t>    <ESC>:tabnew term://zsh<CR>

    nnoremap <Leader>st     :tabnew term://zsh<CR>
    nnoremap <Leader>sn     :split term://zsh<CR>
    nnoremap <Leader>sv     :vsplit term://zsh<CR>
