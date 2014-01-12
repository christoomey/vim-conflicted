let s:version_map = {'upstream': 2, 'local': 3}

function! s:Conflicted()
  args `git ls-files -u \| awk '{print $4}' \| sort -u`
  Merger
endfunction

function! s:TabEdit(parent)
  Gtabedit :1
  let b:conflicted_version = 'base'
  diffthis
  execute 'Gvsplit :' . s:version_map[a:parent]
  let b:conflicted_version = a:parent
  diffthis
  wincmd r
endfunction

function! s:Merger()
  Gdiff
  call s:SetVersionStatuslines()
  call s:TabEdit('upstream')
  call s:TabEdit('local')
  tabfirst
endfunction

function! s:SetVersionStatuslines()
  let b:conflicted_version = 'working'
  wincmd h
  let b:conflicted_version = 'upstream'
  wincmd l
  wincmd l
  let b:conflicted_version = 'local'
  wincmd h
endfunction

function! ConflictedVersion()
  if exists('b:conflicted_version')
    return b:conflicted_version . ' '
  else
    return ''
  end
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

function! s:DiffgetVersion(version, ...)
  let targeted_diffget = 'diffget //' . s:version_map[a:version]
  if a:0
    execute "'<,'>" . targeted_diffget
  else
    execute targeted_diffget
  endif
  diffupdate
endfunction

nnoremap <silent> <Plug>DiffgetLocal :<C-u>call <sid>DiffgetVersion('local')<cr>
nnoremap <silent> <Plug>DiffgetUpstream :<C-u>call <sid>DiffgetVersion('upstream')<cr>
xnoremap <silent> <Plug>DiffgetLocal :<C-u>call <sid>DiffgetVersion('local', line("'<"), line("'>"))<cr>
xnoremap <silent> <Plug>DiffgetUpstream :<C-u>call <sid>DiffgetVersion('upstream', line("'<"), line("'>"))<cr>

if !hasmapto('<Plug>DiffgetLocal')
  xmap dgl <Plug>DiffgetLocal
  nmap dgl <Plug>DiffgetLocal
endif

if !hasmapto('<Plug>DiffgetUpstream')
  xmap dgu <Plug>DiffgetUpstream
  nmap dgu <Plug>DiffgetUpstream
endif

command! Conflicted call <sid>Conflicted()
command! Merger call <sid>Merger()
command! GitNextConflict call <sid>GitNextConflict()
