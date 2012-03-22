" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Contributor: camthompson
" Last Change:  2012-03-22
" Version: 1.1.6
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
  let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`'}
end

if !exists('g:AutoPairsParens')
  let g:AutoPairsParens = {'(':')', '[':']', '{':'}'}
end

let g:AutoExtraPairs = copy(g:AutoPairs)
let g:AutoExtraPairs['<'] = '>'

if !exists('g:AutoPairsMapBS')
  let g:AutoPairsMapBS = 1
end

if !exists('g:AutoPairsMapCR')
  let g:AutoPairsMapCR = 1
end

if !exists('g:AutoPairsMapSpace')
  let g:AutoPairsMapSpace = 1
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

if !exists('g:AutoPairsShortcutJump')
  let g:AutoPairsShortcutJump = '<M-n>'
endif

let g:AutoPairsClosedPairs = {}



function! AutoPairsInsert(key)
  if !b:autopairs_enabled
    return a:key
  end

  let line = getline('.')
  let prev_char = line[col('.')-2]
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]

  let eol = 0
  if col('$') -  col('.') <= 1
    let eol = 1
  end

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  if !has_key(g:AutoPairs, a:key)
    " Skip the character if next character is space
    if current_char == ' ' && next_char == a:key
      return "\<Right>\<Right>"
    end

    " Skip the character if closed pair is next character
    if current_char == ''
      let next_lineno = line('.')+1
      let next_line = getline(nextnonblank(next_lineno))
      let next_char = matchstr(next_line, '\s*\zs.')
      if next_char == a:key
        return "\<ESC>e^a"
      endif
    endif

    " Skip the character if current character is the same as input
    if current_char == a:key
      return "\<Right>"
    end

    " Input directly if the key is not an open key
    return a:key
  end

  let open = a:key
  let close = g:AutoPairs[open]

  if current_char == close && open == close
    return "\<Right>"
  end

  " Ignore auto close ' if follows a word
  " MUST after closed check. 'hello|'
  if a:key == "'" && prev_char =~ '\v\w'
    return a:key
  end

  " support for ''' ``` and """
  if open == close
    " The key must be ' " `
    let pprev_char = line[col('.')-3]
    if pprev_char == open && prev_char == open
      " Double pair found
      return a:key
    end
  end

  return open.close."\<Left>"
endfunction

function! AutoPairsDelete()
  let line = getline('.')
  let current_char = line[col('.')-1]
  let prev_char = line[col('.')-2]
  let pprev_char = line[col('.')-3]

  if pprev_char == '\'
    return "\<BS>"
  end

  " Delete last two spaces in parens, work with MapSpace
  if has_key(g:AutoPairs, pprev_char) && prev_char == ' ' && current_char == ' '
    return "\<BS>\<DEL>"
  endif

  if has_key(g:AutoPairs, prev_char) 
    let close = g:AutoPairs[prev_char]
    if match(line,'^\s*'.close, col('.')-1) != -1
      let space = matchstr(line, '^\s*', col('.')-1)
      return "\<BS>". repeat("\<DEL>", len(space)+1)
    else
      let nline = getline(line('.')+1)
      if nline =~ '^\s*'.close
        let space = matchstr(nline, '^\s*')
        return "\<BS>\<DEL>". repeat("\<DEL>", len(space)+1)
      end
    end
  end

  return "\<BS>"
endfunction

function! AutoPairsJump()
  call search('["\]'')}]','W')
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
  let escaped_key = substitute(a:key, "'", "''", 'g')
  execute 'inoremap <buffer> <silent> '.a:key." <C-R>=AutoPairsInsert('".escaped_key."')<CR>"
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
  let pline = getline(line('.')-1)
  let prev_char = pline[strlen(pline)-1]
  let cmd = ''
  let cur_char = line[col('.')-1]
  if has_key(g:AutoPairs, prev_char) && g:AutoPairs[prev_char] == cur_char
    if g:AutoPairsCenterLine && winline() * 1.5 >= winheight(0)
      let cmd = " \<C-O>zz\<ESC>cl"
    end
    " conflict with javascript and coffee
    " javascript   need   indent new line
    " coffeescript forbid indent new line
    if &filetype == 'coffeescript'
      return "\<ESC>k==o".cmd
    else
      return "\<ESC>=ko".cmd
    endif
  end
  return ''
endfunction

function! AutoPairsSpace()
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let cmd = ''
  let cur_char =line[col('.')-1]
  if has_key(g:AutoPairsParens, prev_char) && g:AutoPairsParens[prev_char] == cur_char
    let cmd = "\<SPACE>\<LEFT>"
  endif
  return "\<SPACE>".cmd
endfunction

function! AutoPairsInit()
  let b:autopairs_loaded  = 1
  let b:autopairs_enabled = 1

  " buffer level map pairs keys
  for [open, close] in items(g:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
    let g:AutoPairsClosedPairs[close] = 1
  endfor

  " Still use <buffer> level mapping for <BS> <SPACE>
  if g:AutoPairsMapBS
    execute 'inoremap <buffer> <silent> <expr> <BS> AutoPairsDelete()'
  end

  if g:AutoPairsMapSpace
    execute 'inoremap <buffer> <silent> <expr> <SPACE> AutoPairsSpace()'
  end

  if g:AutoPairsShortcutFastWrap != ''
    execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutFastWrap.' <C-R>=AutoPairsFastWrap()<CR>'
  end

  if g:AutoPairsShortcutToggle != ''
    " use <expr> to ensure showing the status when toggle
    execute 'inoremap <buffer> <silent> <expr> '.g:AutoPairsShortcutToggle.' AutoPairsToggle()'
    execute 'noremap <buffer> <silent> '.g:AutoPairsShortcutToggle.' :call AutoPairsToggle()<CR>'
  end

  if g:AutoPairsShortcutJump != ''
    execute 'inoremap <buffer> <silent> ' . g:AutoPairsShortcutJump. ' <ESC>:call AutoPairsJump()<CR>a'
    execute 'noremap <buffer> <silent> ' . g:AutoPairsShortcutJump. ' :call AutoPairsJump()<CR>'
  end

endfunction

function! AutoPairsForceInit()
  if exists('b:autopairs_loaded')
    return
  else
    call AutoPairsInit()
  endif
endfunction

" Always silent the command
inoremap <silent> <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>

" Global keys mapping
" comptible with other plugin
if g:AutoPairsMapCR
  let old_cr = maparg('<CR>', 'i')
  if old_cr == ''
    let old_cr = '<CR>'
  endif

  if old_cr !~ 'AutoPairsReturn'
    execute 'imap <CR> '.old_cr.'<SID>AutoPairsReturn'
  end
endif

au BufEnter * :call AutoPairsForceInit()
