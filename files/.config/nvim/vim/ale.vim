let g:ale_sh_shellcheck_options = "-x"
let g:ale_sh_shellcheck_exclusions = 'SC1090,SC2029'

let g:ale_linters = {
    \ 'c': ["gcc", "clang", "clang-tidy", "cppcheck"],
    \ 'h': [],
    \ 'cpp': ["gcc", "clang", "clang-tidy", "cppcheck"],
    \ 'haskell': ["stack-ghc", "hlint"],
    \ 'rust': ["cargo", "rls"],
    \ 'shell': ["shellcheck"],
    \ }

let g:ale_linters_explicit = 1

let g:ale_haskell_hdevtools_options = '-g -Wall'

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
