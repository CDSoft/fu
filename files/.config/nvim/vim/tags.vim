" Create the `tags` file (may need to install ctags and hasktags first)
command! CTags !ctags -R ; hasktags --ctags . -o tags-hs

set tags=./tags,tags,./tags-hs,tags-hs
