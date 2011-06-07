" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Last Change:  2011-06-07
" Version: 1.0.2
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
      return "\<Left>\<C-O>cf".close
    end
  end

  return "\<BS>"
endfunction

function! AutoPairsJump()
  call search('[{("\[\]'')}]','W')
endfunction

" Fast wrap the word in brackets
" Haven't finished yet
function! AutoPairsExtend()
  let line = getline('.')
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]


  if has_key(g:AutoPairsClosedPairs, current_char)
    if has_key(g:AutoPairs, next_char)
      let open = next_char
      let close = g:AutoPairs[next_char]
      let quote_pattern = '(?:\\\|\"\|[^"])*'
      echoe 'search pair '.open.' '.close
      call searchpair(open, '', close, 'W')
    end
    execute "normal! a".current_char."\<LEFT>"
    return ''
  end

  return ''
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
      let cmd = ";\<C-O>zz\<DEL>"
    end
    return "\<CR>\<C-O>O".cmd
  end
  return "\<CR>"
endfunction

function! AutoPairsInit()
  let b:autopairs_enabled = 1
  for [open, close] in items(g:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
    let g:AutoPairsClosedPairs[close] = 1
  endfor

  if g:AutoPairsMapBS
    execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'
  end

  if g:AutoPairsMapCR
    execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairsReturn()<CR>'
  end

  execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutToggle.' <C-R>=AutoPairsToggle()<CR>'
  execute 'noremap <buffer> <silent> '.g:AutoPairsShortcutToggle.' :call AutoPairsToggle()<CR>'
  " If the keys map conflict with your own settings, delete or change them
  if g:AutoPairsShortcuts
    execute 'inoremap <buffer> <silent> <M-n> <ESC>:call AutoPairsJump()<CR>a'
    execute 'inoremap <buffer> <silent> <M-a> <END>'
    execute 'inoremap <buffer> <silent> <M-o> <END><CR>'
    execute 'inoremap <buffer> <silent> <M-e> <C-R>=AutoPairsExtend()<CR>'
  end
endfunction

au BufRead,BufNewFile,BufCreate * :call AutoPairsInit()
