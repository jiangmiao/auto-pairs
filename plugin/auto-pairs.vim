" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Last Change:  2011-09-06
" Version: 1.1.1
" Homepage: http://www.vim.org/scripts/script.php?script_id=3599
" Repository: https://github.com/jiangmiao/auto-pairs

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
let g:AutoExtraPairs = copy(g:AutoPairs)
let g:AutoExtraPairs['<'] = '>'

if !exists('g:AutoPairsMapBS')
  let g:AutoPairsMapBS = 1
end

if !exists('g:AutoPairsMapCR')
  let g:AutoPairsMapCR = 1
end

if !exists('g:AutoPairsCenterLine')
  let g:AutoPairsCenterLine = 1
end

if !exists('g:AutoPairsShortcutToggle')
  let g:AutoPairsShortcutToggle = '<M-p>'
end

if !exists('g:AutoPairsShortcutFastWrap')
  let g:AutoPairsShortcutFastWrap = '<M-e>'
end

let g:AutoPairsClosedPairs = {}



function! AutoPairsInsert(key)
  if !b:autopairs_enabled
    return a:key
  end

  let line = getline('.')
  let prev_char = line[col('.')-2]
  let current_char = line[col('.')-1]

  let eol = 0
  if col('$') -  col('.') <= 1
    let eol = 1
  end

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  " Skip the character if current character is the same as input
  if current_char == a:key && !has_key(g:AutoPairs, a:key)
    return "\<Right>"
  end

  " Input directly if the key is not an open key
  if !has_key(g:AutoPairs, a:key)
    return a:key
  end

  let open = a:key
  let close = g:AutoPairs[open]

  if current_char == close && open == close
    return "\<Right>"
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
      let space = matchstr(line, '^\s*', col('.')-1)
      return "\<BS>". repeat("\<DEL>", len(space)+1)
    end
  end

  return "\<BS>"
endfunction

function! AutoPairsJump()
  call search('[{("\[\]'')}]','W')
endfunction

" Fast wrap the word in brackets
function! AutoPairsFastWrap()
  let line = getline('.')
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]

  " Ignore EOL
  if col('.') == col('$')
    return ''
  end
  
  normal! x
  if match(next_char, '\s') != -1
    call search('\S', 'W')
    let next_char = getline('.')[col('.')-1]
  end

  if has_key(g:AutoExtraPairs, next_char)
    let close = g:AutoExtraPairs[next_char]
    call search(close, 'W')
    return "\<RIGHT>".current_char."\<LEFT>"
  else
    if match(next_char, '\w') != -1
      execute "normal! he"
    end
    execute "normal! a".current_char
    return ""
  end
endfunction

function! AutoPairsMap(key)
    execute 'inoremap <buffer> <silent> '.a:key.' <C-R>=AutoPairsInsert("\'.a:key.'")<CR>'
endfunction

function! AutoPairsToggle()
  if b:autopairs_enabled
    let b:autopairs_enabled = 0
    echo 'AutoPairs Disabled.'
  else
    let b:autopairs_enabled = 1
    echo 'AutoPairs Enabled.'
  end
  return ''
endfunction

function! AutoPairsReturn()
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let cmd = ''
  let cur_char = line[col('.')-1]
  if has_key(g:AutoPairs, prev_char) && g:AutoPairs[prev_char] == cur_char
    if g:AutoPairsCenterLine && winline() * 1.5 >= winheight(0)
      let cmd = " \<C-O>zz\<ESC>cl"
    end
    return "\<DEL>\<CR>".cur_char."\<C-O>O".cmd
  end
  return "\<CR>"
endfunction

function! AutoPairsInit()
  let b:autopairs_loaded  = 1
  let b:autopairs_enabled = 1
  for [open, close] in items(g:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
    let g:AutoPairsClosedPairs[close] = 1
  endfor

  if g:AutoPairsMapBS
    execute 'inoremap <buffer> <silent> <expr> <BS> AutoPairsDelete()'
  end

  if g:AutoPairsMapCR
    execute 'inoremap <buffer> <silent> <expr> <CR> AutoPairsReturn()'
  end

  execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutFastWrap.' <C-R>=AutoPairsFastWrap()<CR>'
  execute 'inoremap <buffer> <silent> <expr> '.g:AutoPairsShortcutToggle.' AutoPairsToggle()'
  execute 'noremap <buffer> <silent> '.g:AutoPairsShortcutToggle.' :call AutoPairsToggle()<CR>'
  " If the keys map conflict with your own settings, delete or change them
  if g:AutoPairsShortcuts
    execute 'inoremap <buffer> <silent> <M-n> <ESC>:call AutoPairsJump()<CR>a'
    execute 'inoremap <buffer> <silent> <M-a> <END>'
    execute 'inoremap <buffer> <silent> <M-o> <END><CR>'
  end
endfunction

function! AutoPairsForceInit()
  if exists('b:autopairs_loaded')
    return
  else
    call AutoPairsInit()
  endif
endfunction

au BufEnter * :call AutoPairsForceInit()
