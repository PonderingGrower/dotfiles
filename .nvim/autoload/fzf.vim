command! FZFMix call s:fzf_wrap({
    \'source':  'bash -c "'.
    \               'echo -e \"'.s:old_files().'\";'.
    \               'ag -l -g \"\"'.
    \           '"',
    \})

command! FZFBuffer call s:fzf_wrap({
    \'source':  reverse(<sid>buflist()),
    \'sink':    function('<sid>bufopen'),
    \})

command! FZFMru call s:fzf_wrap({
    \'source': v:oldfiles,
    \})

command! -nargs=? FZFFile call s:fzf_wrap({
    \ 'source':  'ag -l -g ""',
    \ 'dir': <f-args>,
    \ 'sink*':    function('<sid>ag_handler'),
    \ })

function! s:fzf_wrap(dict)
    let defaults = {
    \    'options' : '+s -e -m --reverse',
    \    'dir' : g:projectroot,
    \    'window' : 'enew',
    \    'sink' : 'e ',
    \}
    call extend(a:dict, defaults, 'keep')
    call fzf#run(a:dict)
endfunction

function! s:old_files()
    let oldfiles = filter(copy(v:oldfiles), 'v:val !~ "[[unite]]"')
    return join(oldfiles, '\n')
endfunction

function! s:ag_handler(lines)
  if len(a:lines) < 2 | return | endif

  let [key, line] = a:lines[0:1]
  let [file, line, col] = split(line, ':')[0:2]
  let cmd = get({'ctrl-x': 'split', 'ctrl-v': 'vertical split', 'ctrl-t': 'tabe'}, key, 'e')
  execute cmd escape(file, ' %#\')
  execute line
  execute 'normal!' col.'|zz'
endfunction

function! s:buflist()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! s:bufopen(e)
  execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction