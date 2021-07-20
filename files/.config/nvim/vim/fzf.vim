nnoremap <silent> <Leader>b :Buffers!<CR>
nnoremap <silent> <Leader>f :Rg!<CR>
nnoremap <silent> <Leader>t :Tags!<CR>
if system("git rev-parse --is-inside-work-tree 2>/dev/null") == ""
    "nnoremap <silent> <C-f> :Files<CR>
    nnoremap <silent> <Leader>o :Files!<CR>
else
    "nnoremap <silent> <C-f> :GFiles<CR>
    nnoremap <silent> <Leader>o :GFiles!<CR>
endif
nnoremap <silent> <Leader>O :Files!<CR>

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R ; hasktags --ctags . -o tags-hs'

" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'
