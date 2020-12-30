let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0

nmap ) <Plug>(GitGutterNextHunk)
nmap ( <Plug>(GitGutterPrevHunk)

" Update gitgutter when a file is changed
:au InsertLeave * call gitgutter#process_buffer(bufnr(''), 0)
" the following is specific to neovim
:au TextChanged * call gitgutter#process_buffer(bufnr(''), 0)
