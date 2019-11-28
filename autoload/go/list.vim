" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

function! go#list#Type(for) abort
  let l:listtype = s:listtype(get(s:default_list_type_commands, a:for))
  if l:listtype == "0"
    call go#util#EchoError(printf(
          \ "unknown list type command value found ('%s'). Please open a bug report in the vim-go repo.",
          \ a:for))
    let l:listtype = "quickfix"
  endif

  return get(go#config#ListTypeCommands(), a:for, l:listtype)
endfunction 
function! s:listtype(listtype) abort
  let listtype = go#config#ListType()
  if empty(listtype)
    return a:listtype
  endif

  return listtype
endfunction

" s:default_list_type_commands is the defaults that will be used for each of
" the supported commands (see documentation for g:go_list_type_commands). When
" defining a default, quickfix should be used if the command operates on
" multiple files, while locationlist should be used if the command operates on a
" single file or buffer. Keys that begin with an underscore are not supported
" in g:go_list_type_commands.
let s:default_list_type_commands = {
      \ "GoFmt":                "locationlist",
      \ "GoInstall":            "quickfix",
      \ "GoLint":               "quickfix",
      \ "GoModFmt":             "locationlist",
  \ }

" Populate populate the list with the given items
function! go#list#Populate(listtype, items, title) abort
  if a:listtype == "locationlist"
    call setloclist(0, a:items, 'r')
    call setloclist(0, [], 'a', {'title': a:title})
  else
    call setqflist(a:items, 'r')
    call setqflist([], 'a', {'title': a:title})
  endif
endfunction

" Window opens the list with the given height up to 10 lines maximum.
" Otherwise g:go_loclist_height is used.
"
" If no or zero height is given it closes the window by default.
" To prevent this, set g:go_list_autoclose = 0
function! go#list#Window(listtype, ...) abort
  " we don't use lwindow to close the location list as we need also the
  " ability to resize the window. So, we are going to use lopen and lclose
  " for a better user experience. If the number of errors in a current
  " " location list increases/decreases, cwindow will not resize when a new
  " updated height is passed. lopen in the other hand resizes the screen.
  if !a:0 || a:1 == 0
    call go#list#Close(a:listtype)
    return
  endif

  let height = go#config#ListHeight()
  if height == 0
    " prevent creating a large location height for a large set of numbers
    if a:1 > 10
      let height = 10
    else
      let height = a:1
    endif
  endif

  if a:listtype == "locationlist"
    exe 'lopen ' . height
  else
    exe 'copen ' . height
  endif
endfunction

" Close closes the location list
function! go#list#Close(listtype) abort
  let autoclose_window = go#config#ListAutoclose()
  if !autoclose_window
    return
  endif

  if a:listtype == "locationlist"
    lclose
  else
    cclose
  endif
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save
"
" " vim: sw=2 ts=2 et
