function! s:Conflicted()
  args `git ls-files -u \| awk '{print $4}' \| sort -u`
  Merger
endfunction

function! s:TabEdit(parent)
  Gtabedit :1
  diffthis
  execute 'Gvsplit :' . {'upstream': 2, 'local': 3}[a:parent]
  diffthis
  wincmd r
endfunction

function! s:Merger()
  Gdiff
  call s:TabEdit('upstream')
  call s:TabEdit('local')
  tabfirst
endfunction

function! s:GitNextConflict()
  Gwrite
  argdelete %
  call s:NextOrQuit()
endfunction

function! s:NextOrQuit()
  if empty(argv())
    quit
  else
    argument "move to the next file in the arglist
    Merger
  endif
endfunction

command! Conflicted call <sid>Conflicted()
command! Merger call <sid>Merger()
command! GitNextConflict call <sid>GitNextConflict()
