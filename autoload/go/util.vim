" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

" Get all lines in the buffer as a a list.
function! go#util#GetLines()
  let buf = getline(1, '$')
  if &encoding != 'utf-8'
    let buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
  endif
  if &l:fileformat == 'dos'
    " XXX: line2byte() depend on 'fileformat' option.
    " so if fileformat is 'dos', 'buf' must include '\r'.
    let buf = map(buf, 'v:val."\r"')
  endif
  return buf
endfunction

" IsWin returns 1 if current OS is Windows or 0 otherwise
" Note that has('win32') is always 1 when has('win64') is 1, so has('win32') is enough.
function! go#util#IsWin() abort
  return has('win32')
endfunction

" Exec runs a shell command "cmd", which must be a list, one argument per item.
" Every list entry will be automatically shell-escaped
" Every other argument is passed to stdin.
function! go#util#Exec(cmd, ...) abort
  if len(a:cmd) == 0
    call go#util#EchoError("go#util#Exec() called with empty a:cmd")
    return ['', 1]
  endif

  let l:bin = a:cmd[0]

  " Lookup the full path, respecting settings such as 'go_bin_path'. On errors,
  " CheckBinPath will show a warning for us.
  let l:bin = go#path#CheckBinPath(l:bin)
  if empty(l:bin)
    return ['', 1]
  endif

  " Finally execute the command using the full, resolved path. Do not pass the
  " unmodified command as the correct program might not exist in $PATH.
  return call('s:exec', [[l:bin] + a:cmd[1:]] + a:000)
endfunction

" PathListSep returns the appropriate OS specific path list separator.
function! go#util#PathListSep() abort
  if go#util#IsWin()
    return ";"
  endif
  return ":"
endfunction

" IsWin returns 1 if current OS is Windows or 0 otherwise
" Note that has('win32') is always 1 when has('win64') is 1, so has('win32') is enough.
function! go#util#IsWin() abort
  return has('win32')
endfunction

" IsMac returns 1 if current OS is macOS or 0 otherwise.
function! go#util#IsMac() abort
  return has('mac') ||
        \ has('macunix') ||
        \ has('gui_macvim') ||
        \ go#util#Exec(['uname'])[0] =~? '^darwin'
endfunction

 " Checks if using:
 " 1) Windows system,
 " 2) And has cygpath executable,
 " 3) And uses *sh* as 'shell'
function! go#util#IsUsingCygwinShell()
  return go#util#IsWin() && executable('cygpath') && &shell =~ '.*sh.*'
endfunction

function! s:exec(cmd, ...) abort
  let l:bin = a:cmd[0]
  let l:cmd = go#util#Shelljoin([l:bin] + a:cmd[1:])
  if go#util#HasDebug('shell-commands')
    call go#util#EchoInfo('shell command: ' . l:cmd)
  endif

  let l:out = call('s:system', [l:cmd] + a:000)
  return [l:out, go#util#ShellError()]
endfunction

" Shelljoin returns a shell-safe string representation of arglist. The
" {special} argument of shellescape() may optionally be passed.
function! go#util#Shelljoin(arglist, ...) abort
  try
    let ssl_save = &shellslash
    set noshellslash
    if a:0
      return join(map(copy(a:arglist), 'shellescape(v:val, ' . a:1 . ')'), ' ')
    endif

    return join(map(copy(a:arglist), 'shellescape(v:val)'), ' ')
  finally
    let &shellslash = ssl_save
  endtry
endfunction

" Report if the user enabled a debug flag in g:go_debug.
function! go#util#HasDebug(flag)
  return index(go#config#Debug(), a:flag) >= 0
endfunction

" Run a shell command.
"
" It will temporary set the shell to /bin/sh for Unix-like systems if possible,
" so that we always use a standard POSIX-compatible Bourne shell (and not e.g.
" csh, fish, etc.) See #988 and #1276.
function! s:system(cmd, ...) abort
  " Preserve original shell, shellredir and shellcmdflag values
  let l:shell = &shell
  let l:shellredir = &shellredir
  let l:shellcmdflag = &shellcmdflag

  if !go#util#IsWin() && executable('/bin/sh')
      set shell=/bin/sh shellredir=>%s\ 2>&1 shellcmdflag=-c
  endif

  try
    return call('system', [a:cmd] + a:000)
  finally
    " Restore original values
    let &shell = l:shell
    let &shellredir = l:shellredir
    let &shellcmdflag = l:shellcmdflag
  endtry
endfunction

function! go#util#ShellError() abort
  return v:shell_error
endfunction

" StripPath strips the path's last character if it's a path separator.
" example: '/foo/bar/'  -> '/foo/bar'
function! go#util#StripPathSep(path) abort
  let last_char = strlen(a:path) - 1
  if a:path[last_char] == go#util#PathSep()
    return strpart(a:path, 0, last_char)
  endif

  return a:path
endfunction

" go#util#SetEnv takes the name of an environment variable and what its value
" should be and returns a function that will restore it to its original value.
function! go#util#SetEnv(name, value) abort
  let l:state = {}

  if len(a:name) == 0
    return function('s:noop', [], l:state)
  endif

  let l:remove = 0
  if exists('$' . a:name)
    let l:oldvalue = eval('$' . a:name)
  else
    let l:remove = 1
  endif

  " wrap the value in single quotes so that it will work on windows when there
  " are backslashes present in the value (e.g. $PATH).
  call execute('let $' . a:name . " = '" . a:value . "'")

  if l:remove
    return function('s:unset', [a:name], l:state)
  endif

  return function('go#util#SetEnv', [a:name, l:oldvalue], l:state)
endfunction

function! go#util#EchoInfo(msg)
  call s:echo(a:msg, 'Debug')
endfunction

" Echo a message to the screen and highlight it with the group in a:hi.
"
" The message can be a list or string; every line with be :echomsg'd separately.
function! s:echo(msg, hi)
  let l:msg = []
  if type(a:msg) != type([])
    let l:msg = split(a:msg, "\n")
  else
    let l:msg = a:msg
  endif

  " Tabs display as ^I or <09>, so manually expand them.
  let l:msg = map(l:msg, 'substitute(v:val, "\t", "        ", "")')

  exe 'echohl ' . a:hi
  for line in l:msg
    echom "vim-go: " . line
  endfor
  echohl None
endfunction

function! s:unset(name) abort
  try
    " unlet $VAR was introducted in Vim 8.0.1832, which is newer than the
    " minimal version that vim-go supports. Set the environment variable to
    " the empty string in that case. It's not perfect, but it will work fine
    " for most things, and is really the best alternative that's available.
    if !has('patch-8.0.1832')
      call go#util#SetEnv(a:name, '')
      return
    endif

    call execute('unlet $' . a:name)
  catch
    call go#util#EchoError(printf('could not unset $%s: %s', a:name, v:exception))
  endtry
endfunction

" Make a named temporary directory which starts with "prefix".
"
" Unfortunately Vim's tempname() is not portable enough across various systems;
" see: https://github.com/mattn/vim-go/pull/3#discussion_r138084911
function! go#util#tempdir(prefix) abort
  " See :help tempfile
  if go#util#IsWin()
    let l:dirs = [$TMP, $TEMP, 'c:\tmp', 'c:\temp']
  else
    let l:dirs = [$TMPDIR, '/tmp', './', $HOME]
  endif

  let l:dir = ''
  for l:d in dirs
    if !empty(l:d) && filewritable(l:d) == 2
      let l:dir = l:d
      break
    endif
  endfor

  if l:dir == ''
    call go#util#EchoError('Unable to find directory to store temporary directory in')
    return
  endif

  " Not great randomness, but "good enough" for our purpose here.
  let l:rnd = sha256(printf('%s%s', reltimestr(reltime()), fnamemodify(bufname(''), ":p")))
  let l:tmp = printf("%s/%s%s", l:dir, a:prefix, l:rnd)
  call mkdir(l:tmp, 'p', 0700)
  return l:tmp
endfunction

function! go#util#EchoError(msg)
  call s:echo(a:msg, 'ErrorMsg')
endfunction

let s:env_cache = {}

" env returns the go environment variable for the given key. Where key can be
" GOARCH, GOOS, GOROOT, etc... It caches the result and returns the cached
" version.
function! go#util#env(key) abort
  let l:key = tolower(a:key)
  if has_key(s:env_cache, l:key)
    return s:env_cache[l:key]
  endif

  if executable('go')
    let l:var = call('go#util#'.l:key, [])
    if go#util#ShellError() != 0
      call go#util#EchoError(printf("'go env %s' failed", toupper(l:key)))
      return ''
    endif
  else
    let l:var = eval("$".toupper(a:key))
  endif

  let s:env_cache[l:key] = l:var
  return l:var
endfunction

" gopath returns 'go env GOPATH'. This is an internal function and shouldn't
" be used. Instead use 'go#util#env("gopath")'
function! go#util#gopath() abort
  return substitute(s:exec(['go', 'env', 'GOPATH'])[0], '\n', '', 'g')
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
