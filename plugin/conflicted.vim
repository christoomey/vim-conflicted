if exists('g:loaded_conflicted') || &cp
  finish
endif
let g:loaded_conflicted = 1

let s:versions = ['working', 'upstream', 'local']
let s:diffget_local_map = 'dgl'
let s:diffget_upstream_map = 'dgu'

function! s:Conflicted()
  args `git ls-files -u \| awk '{print $4}' \| sort -u`
  set tabline=%!ConflictedTabline()
  set guitablabel=%{ConflictedGuiTabLabel()}
  Merger
endfunction

function! s:Rebasing()
  return isdirectory(".git/rebase-apply")
endfunction

function! s:BranchName(version)
  if s:Rebasing()
    return s:RebaseBranchName(a:version)
  else
    return s:MergeBranchName(a:version)
  endif
endfunction

function! s:MergeBranchName(version)
  if a:version ==# 'local'
    let command = "cat .git/MERGE_MSG | head -1 | tr ' ' '\n' | tail -1 | sed \"s/'//g\""
    return 'l:('.s:ChompedSystem(command).')'
  elseif a:version ==# 'upstream'
    let command = "git rev-parse --abbrev-ref HEAD"
    return 'u:('.s:ChompedSystem(command).')'
  else
    return "branch-not-found"
  end
endfunction

function! s:RebaseBranchName(version)
  if a:version ==# 'local'
    let command = "cat .git/rebase-apply/head-name | tr '/' '\n' | tail -1"
    return 'l:('.s:ChompedSystem(command).')'
  elseif a:version ==# 'upstream'
    let command = "git reflog | grep 'rebase: checkout' | head -1 | tr ' ' '\n' | tail -1"
    return 'u:('.s:ChompedSystem(command).')'
  else
    return "branch-not-found"
  end
endfunction

function! s:ChompedSystem(command)
  let value = system(a:command)
  return substitute(value, '\n$', '', '')
endfunction

function! s:Merger()
  Gdiff
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
  let label = ""
  if a:tabnr > 0
    let label = s:BranchName(s:versions[a:tabnr])
  else
    let label = s:versions[a:tabnr]
  endif
  return (a:tabnr + 1) . ': ' . label
endfunction

function! s:TabEdit(parent)
  Gtabedit :1
  let b:conflicted_version = 'base'
  diffthis
  execute 'Gvsplit :' . s:VersionNumber(a:parent)
  let b:conflicted_version = s:BranchName(a:parent)
  diffthis
  wincmd r
endfunction

function! s:SetVersionStatuslines()
  let b:conflicted_version = 'working'
  wincmd h
  let b:conflicted_version = s:BranchName('upstream')
  wincmd l
  wincmd l
  let b:conflicted_version = s:BranchName('local')
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
