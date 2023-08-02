" .domain files
autocmd BufNewFile,BufRead *.dsl setfiletype dsl
autocmd BufNewFile,BufRead *.domain setfiletype dsl

" .substance files
autocmd BufNewFile,BufRead *.sub setfiletype sub
autocmd BufNewFile,BufRead *.substance setfiletype sub

" .style files
autocmd BufNewFile,BufRead *.sty setfiletype sty
autocmd BufNewFile,BufRead *.sty set syntax=sty
autocmd BufNewFile,BufRead *.style setfiletype sty
autocmd BufNewFile,BufRead *.style set syntax=sty
