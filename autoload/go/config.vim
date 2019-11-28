" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

function! go#config#VersionWarning() abort
  return get(g:, 'go_version_warning', 1)
endfunction

function! go#config#FmtCommand() abort
  return get(g:, "go_fmt_command", "gofmt")
endfunction

function! go#config#FmtExperimental() abort
  return get(g:, "go_fmt_experimental", 0 )
endfunction

function! go#config#BinPath() abort
  return get(g:, "go_bin_path", "")
endfunction

function! go#config#SearchBinPathFirst() abort
  return get(g:, 'go_search_bin_path_first', 1)
endfunction

function! go#config#FmtOptions() abort
  return get(g:, "go_fmt_options", {})
endfunction

function! go#config#Debug() abort
  return get(g:, 'go_debug', [])
endfunction

function! go#config#ListType() abort
  return get(g:, 'go_list_type', '')
endfunction

function! go#config#ListTypeCommands() abort
  return get(g:, 'go_list_type_commands', {})
endfunction

function! go#config#FmtFailSilently() abort
  return get(g:, "go_fmt_fail_silently", 0)
endfunction

function! go#config#ListHeight() abort
  return get(g:, "go_list_height", 0)
endfunction

function! go#config#ListAutoclose() abort
  return get(g:, 'go_list_autoclose', 1)
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
