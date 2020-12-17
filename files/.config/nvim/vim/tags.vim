" Create the `tags` file (may need to install ctags first)
command! CTags !fd --print0 | xargs -0 ctags
command! HTags !hasktags --ignore-close-implementation --ctags .
