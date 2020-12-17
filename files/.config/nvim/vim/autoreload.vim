" reload files if they were modified

set autoread

autocmd BufEnter,FocusGained * checktime
