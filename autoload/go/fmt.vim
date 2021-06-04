" Copyright 2011 The Go Authors. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.
"
" fmt.vim: Vim command to format Go files with gofmt (and gofmt compatible
" toorls, such as goimports).

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

function! go#fmt#Format(withGoimport) abort
  if go#config#FmtExperimental()
    let l:curw = {}
    try
      mkview!
    catch
      let l:curw = winsaveview()
    endtry

    " save our undo file to be restored after we are done. This is needed to
    " prevent an additional undo jump due to BufWritePre auto command and also
    " restore 'redo' history because it's getting being destroyed every
    " BufWritePre
    let tmpundofile = tempname()
    exe 'wundo! ' . tmpundofile
  else
    " Save cursor position and many other things.
    let l:curw = winsaveview()
  endif

  " Write current unsaved buffer to a temp file
  let l:tmpname = tempname() . '.go'
  call writefile(go#util#GetLines(), l:tmpname)
  if go#util#IsWin()
    let l:tmpname = tr(l:tmpname, '\', '/')
  endif

  let bin_name = go#config#FmtCommand()
  if a:withGoimport == 1
    let bin_name = "goimports"
  endif

  let current_col = col('.')
  let [l:out, l:err] = go#fmt#run(bin_name, l:tmpname, expand('%'))
  let diff_offset = len(readfile(l:tmpname)) - line('$')

  if l:err == 0
    call go#fmt#update_file(l:tmpname, a:withGoimport)
    call s:show_errors([])
  elseif !go#config#FmtFailSilently()
    let errors = s:parse_errors(expand('%'), out)
    call s:show_errors(errors)
  endif

  " We didn't use the temp file, so clean up
  call delete(l:tmpname)

  if go#config#FmtExperimental()
    " Restore our cursor/windows positions, folds, etc.
    if empty(l:curw)
      silent! loadview
    else
      call winrestview(l:curw)
    endif
  else
    " Restore our cursor/windows positions.
    call winrestview(l:curw)
  endif

  " be smart and jump to the line the new statement was added/removed
  call cursor(line('.') + diff_offset, current_col)

  " Syntax highlighting breaks less often.
  syntax sync fromstart
endfunction

" update_file updates the target file with the given formatted source
function! go#fmt#update_file(source, sort_imports)
  " Store the unnamed registry
  let prev_reg=getreg('"')
  let start_time = reltime()

  let source_content=readfile(a:source)
  let target_content=getline(1, "$")
  if source_content != target_content
    normal! ggdG
    put =source_content
    normal! ggdd

    " Restore the unnamed registry
    call setreg('"', prev_reg)

    if a:sort_imports == -1
      echom "Reformatted in" split(reltimestr(reltime(start_time)))[0]. "s."
    endif
  else
    if a:sort_imports == -1
      echom "Already well formatted, good job. (took" split(reltimestr(reltime(start_time)))[0] . "s)"
    endif
  endif
endfunction

" run runs the gofmt/goimport command for the given source file and returns
" the output of the executed command. Target is the real file to be formatted.
function! go#fmt#run(bin_name, source, target)
  let l:cmd = s:fmt_cmd(a:bin_name, a:source, a:target)
  if empty(l:cmd)
    return
  endif
  return go#util#Exec(l:cmd)
endfunction

" fmt_cmd returns the command to run as a list.
function! s:fmt_cmd(bin_name, source, target)
  let l:cmd = [a:bin_name, '-w']

  " add the options for binary (if any). go_fmt_options was by default of type
  " string, however to allow customization it's now a dictionary of binary
  " name mapping to options.
  let opts = go#config#FmtOptions()
  if type(opts) == type({})
    let opts = has_key(opts, a:bin_name) ? opts[a:bin_name] : ""
  endif
  call extend(cmd, split(opts, " "))
  if a:bin_name is# 'goimports'
    call extend(cmd, ["-srcdir", a:target])
  endif

  call add(cmd, a:source)
  return cmd
endfunction

" parse_errors parses the given errors and returns a list of parsed errors
function! s:parse_errors(filename, content) abort
  let splitted = split(a:content, '\n')

  " list of errors to be put into location list
  let errors = []
  for line in splitted
    let tokens = matchlist(line, '^\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)')
    if !empty(tokens)
      call add(errors,{
            \"filename": a:filename,
            \"lnum":     tokens[2],
            \"col":      tokens[3],
            \"text":     tokens[4],
            \ })
    endif
  endfor

  return errors
endfunction

" show_errors opens a location list and shows the given errors. If the given
" errors is empty, it closes the the location list
function! s:show_errors(errors) abort
  let l:listtype = go#list#Type("GoFmt")
  if !empty(a:errors)
    call go#list#Populate(l:listtype, a:errors, 'Format')
  endif

  " this closes the window if there are no errors or it opens
  " it if there is any
  call go#list#Window(l:listtype, len(a:errors))
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
