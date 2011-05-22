" Language:	JavaScript
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Last Change:  2011-05-22
" Version: 1.0
" Repository: https://github.com/jiangmiao/auto-pairs
"
" Insert or delete brackets, parens, quotes in pairs.

if exists('g:AutoPairsLoaded') || &cp
  finish
end
let g:AutoPairsLoaded = 1

" Shortcurs for 
" <M-o> newline with indetation
" <M-a> jump to of line
" <M-n> jmup to next pairs
if !exists('g:AutoPairsShortcuts')
  let g:AutoPairsShortcuts = 1
end

if !exists('g:AutoPairs')
  let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}
end


function! AutoPairsInsert(key)
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let current_char = line[col('.')-1]

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  " Skip the character if current character is the same as input
  if current_char == a:key
    return "\<Right>"
  end

  " Input directly if the key is not an open key
  if !has_key(g:AutoPairs, a:key)
    return a:key
  end

  let open = a:key
  let close = g:AutoPairs[open]


  " Auto return only if open and close is same
  if prev_char == open && open != close
    return "\<CR>\<ESC>==O"
  end

  return open.close."\<Left>"
endfunction



function! AutoPairsDelete()
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let pprev_char = line[col('.')-3]

  if pprev_char == '\'
    return "\<BS>"
  end

  if has_key(g:AutoPairs, prev_char)
    let close = g:AutoPairs[prev_char]
    if match(line,'^\s*'.close, col('.')-1) != -1
      return "\<Left>\<C-O>cf".close
    end
  end

  return "\<BS>"
endfunction

function! AutoPairsJump()
  call search('[{("\[\]'')}]','W')
endfunction

function! AutoPairsMap(key)
    execute 'inoremap <silent> '.a:key.' <C-R>=AutoPairsInsert("\'.a:key.'")<CR>'
endfunction

function! AutoPairsInit()
  for [open, close] in items(g:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
  endfor
  execute 'inoremap <silent> <BS> <C-R>=AutoPairsDelete()<CR>'

  " If the keys map conflict with your own settings, delete or change them
  if g:AutoPairsShortcuts
    execute 'inoremap <silent> <M-n> <ESC>:call AutoPairsJump()<CR>a'
    execute 'inoremap <silent> <M-a> <END>'
    execute 'inoremap <silent> <M-o> <END><CR>'
  end
endfunction

call AutoPairsInit()
