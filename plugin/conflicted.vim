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

function! s:DiffgetRevision(revision)
  execute 'diffget //' . a:revision
  diffupdate
endfunction

function! s:DiffgetLocal()
  call s:DiffgetRevision(3)
endfunction

function! s:DiffgetUpstream()
  call s:DiffgetRevision(2)
endfunction

xnoremap <silent> <Plug>DiffgetLocal :<C-u>call <sid>DiffgetLocal()<cr>
nnoremap <silent> <Plug>DiffgetLocal :<C-u>call <sid>DiffgetLocal()<cr>
xnoremap <silent> <Plug>DiffgetUpstream :<C-u>call <sid>DiffgetUpstream()<cr>
nnoremap <silent> <Plug>DiffgetUpstream :<C-u>call <sid>DiffgetUpstream()<cr>

if !hasmapto('<Plug>DiffgetLocal')
  xmap gl  <Plug>DiffgetLocal
  nmap gl  <Plug>DiffgetLocal
endif

if !hasmapto('<Plug>DiffgetUpstream')
  xmap gu  <Plug>DiffgetUpstream
  nmap gu  <Plug>DiffgetUpstream
endif

command! Conflicted call <sid>Conflicted()
command! Merger call <sid>Merger()
command! GitNextConflict call <sid>GitNextConflict()
