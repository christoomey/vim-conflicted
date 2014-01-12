let s:versions = ['working', 'upstream', 'local']

function! s:Conflicted()
  args `git ls-files -u \| awk '{print $4}' \| sort -u`
  set tabline=%!ConflictedTabline()
  set guitablabel=%{ConflictedGuiTabLabel()}
  Merger
endfunction

function ConflictedTabline()
  let s = ''
  for tabnr in range(tabpagenr('$'))
    " select the highlighting
    if tabnr + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (tabnr + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{ConflictedTabLabel(' . tabnr . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
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
