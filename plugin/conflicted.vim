if exists('g:loaded_conflicted') || &cp
  finish
endif
let g:loaded_conflicted = 1

let s:versions = ['working', 'upstream', 'local']
let s:diffget_local_map = 'dgl'
let s:diffget_upstream_map = 'dgu'

function! s:Conflicted()
  args `git diff --name-only --diff-filter=U`
  set tabline=%!ConflictedTabline()
  set guitablabel=%{ConflictedGuiTabLabel()}
  Merger
endfunction

function! s:Merger()
  " Shim to support Fugitive 3.0 and prior versions
  if exists(':Gvdiffsplit')
    Gvdiffsplit!
  else
    Gdiff
  endif

  call s:MapTargetedDiffgets()
  call s:SetVersionStatuslines()
  call s:TabEdit('upstream')
  call s:TabEdit('local')
  tabfirst
endfunction

function! ConflictedTabline()
  let s = ''
  for tabnr in range(tabpagenr('$'))
    if tabnr + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= '%' . (tabnr + 1) . 'T'
    let s .= ' %{ConflictedTabLabel(' . tabnr . ')} '
  endfor
  let s .= '%#TabLineFill#%T'
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999X'
  endif
  return s
endfunction

function! ConflictedGuiTabLabel()
  return ConflictedTabLabel(tabpagenr() - 1)
endfunction

function! ConflictedTabLabel(tabnr)
  return (a:tabnr + 1) . ': [' . s:versions[a:tabnr] . ']'
endfunction

function! s:TabEdit(parent)
  Gtabedit :1
  let b:conflicted_version = 'base'
  diffthis
  execute 'Gvsplit :' . s:VersionNumber(a:parent)
  let b:conflicted_version = a:parent
  diffthis
  wincmd r
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
    bdelete
    argument "move to the next file in the arglist
    Merger
  endif
endfunction

function! s:VersionNumber(version)
  return index(s:versions, a:version) + 1
endfunction

function! s:DiffgetVersion(version, ...)
  let targeted_diffget = 'diffget //' . s:VersionNumber(a:version)
  if a:0
    execute "'<,'>" . targeted_diffget
  else
    execute targeted_diffget
  endif
  diffupdate
endfunction

function! s:DesiredDiffgetMap(version)
  let user_map = 'g:diffget_' . a:version . '_map'
  let script_map = 's:diffget_' . a:version . '_map'
  if exists(user_map)
    execute 'return ' . user_map
  else
    execute 'return ' . script_map
  endif
endfunction

function! s:ConfigureRepeat(command)
  silent! call repeat#set("\<Plug>" . a:command)
endfunction

nnoremap <silent> <Plug>DiffgetLocal :<C-u>call <sid>DiffgetVersion('local')<cr>:call <sid>ConfigureRepeat('DiffgetLocal')<cr>
nnoremap <silent> <Plug>DiffgetUpstream :<C-u>call <sid>DiffgetVersion('upstream')<cr>:call <sid>ConfigureRepeat('DiffgetUpstream')<cr>
xnoremap <silent> <Plug>DiffgetLocal :<C-u>call <sid>DiffgetVersion('local', line("'<"), line("'>"))<cr>
xnoremap <silent> <Plug>DiffgetUpstream :<C-u>call <sid>DiffgetVersion('upstream', line("'<"), line("'>"))<cr>

function! s:MapTargetedDiffgets()
  execute 'xmap <buffer> ' . s:DesiredDiffgetMap('local') . ' <Plug>DiffgetLocal'
  execute 'nmap <buffer> ' . s:DesiredDiffgetMap('local') . ' <Plug>DiffgetLocal'

  execute 'xmap <buffer> ' . s:DesiredDiffgetMap('upstream') . ' <Plug>DiffgetUpstream'
  execute 'nmap <buffer> ' . s:DesiredDiffgetMap('upstream') . ' <Plug>DiffgetUpstream'
endfunction

command! Conflicted call <sid>Conflicted()
command! Merger call <sid>Merger()
command! GitNextConflict call <sid>GitNextConflict()
