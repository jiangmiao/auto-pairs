" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Contributor: camthompson
" Last Change:  2012-05-16
" Version: 1.2.2
" Homepage: http://www.vim.org/scripts/script.php?script_id=3599
" Repository: https://github.com/jiangmiao/auto-pairs

if exists('g:AutoPairsLoaded') || &cp
  finish
end
let g:AutoPairsLoaded = 1

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

" Fly mode will for closed pair to jump to closed pair instead of insert.
" also support AutoPairsBackInsert to insert pairs where jumped.
if !exists('g:AutoPairsFlyMode')
  let g:AutoPairsFlyMode = 0
endif

" Work with Fly Mode, insert pair where jumped
if !exists('g:AutoPairsShortcutBackInsert')
  let g:AutoPairsShortcutBackInsert = '<M-b>'
endif


" Will auto generated {']' => '[', ..., '}' => '{'}in initialize.
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

  " The key is difference open-pair, then it means only for ) ] } by default
  if !has_key(g:AutoPairs, a:key)
    let b:autopairs_saved_pair = [a:key, getpos('.')]

    " Skip the character if current character is the same as input
    if current_char == a:key
      return "\<Right>"
    end

    if !g:AutoPairsFlyMode
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
    endif

    " Fly Mode, and the key is closed-pairs, search closed-pair and jump
    if g:AutoPairsFlyMode && has_key(g:AutoPairsClosedPairs, a:key)
      if search(a:key, 'W')
        return "\<Right>"
      endif
    endif

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
" string_chunk cannot use standalone
let s:string_chunk = '\v%(\\\_.|[^\1]|[\r\n]){-}'
let s:ss_pattern = '\v''' . s:string_chunk . ''''
let s:ds_pattern = '\v"'  . s:string_chunk . '"'

func! s:RegexpQuote(str)
  return substitute(a:str, '\v[\[\{\(\<\>\)\}\]]', '\\&', 'g')
endf

func! s:RegexpQuoteInSquare(str)
  return substitute(a:str, '\v[\[\]]', '\\&', 'g')
endf

" Search next open or close pair
func! s:FormatChunk(open, close)
  let open = s:RegexpQuote(a:open)
  let close = s:RegexpQuote(a:close)
  let open2 = s:RegexpQuoteInSquare(a:open)
  let close2 = s:RegexpQuoteInSquare(a:close)
  if open == close
    return '\v'.open.s:string_chunk.close
  else
    return '\v%(' . s:ss_pattern . '|' . s:ds_pattern . '|' . '[^'.open2.close2.']|[\r\n]' . '){-}(['.open2.close2.'])'
  end
endf

" Fast wrap the word in brackets
function! AutoPairsFastWrap()
  let line = getline('.')
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]
  let open_pair_pattern = '\v[({\[''"]'
  let at_end = col('.') >= col('$') - 1
  normal x
  " Skip blank
  if next_char =~ '\v\s' || at_end
    call search('\v\S', 'W')
    let line = getline('.')
    let next_char = line[col('.')-1]
  end

  if has_key(g:AutoPairs, next_char)
    let followed_open_pair = next_char
    let inputed_close_pair = current_char
    let followed_close_pair = g:AutoPairs[next_char]
    if followed_close_pair != followed_open_pair
      " TODO replace system searchpair to skip string and nested pair.
      " eg: (|){"hello}world"} will transform to ({"hello})world"}
      call searchpair('\V'.followed_open_pair, '', '\V'.followed_close_pair, 'W')
    else
      call search(s:FormatChunk(followed_open_pair, followed_close_pair), 'We')
    end
    return "\<RIGHT>".inputed_close_pair."\<LEFT>"
  else
    normal e
    return "\<RIGHT>".current_char."\<LEFT>"
  end
endfunction

function! AutoPairsMap(key)
  let escaped_key = substitute(a:key, "'", "''", 'g')
  " use expr will cause search() doesn't work
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
    if &filetype == 'coffeescript' || &filetype == 'coffee'
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

function! AutoPairsBackInsert()
  if exists('b:autopairs_saved_pair')
    let pair = b:autopairs_saved_pair[0]
    let pos  = b:autopairs_saved_pair[1]
    call setpos('.', pos)
    return pair
  endif
  return ''
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
    let g:AutoPairsClosedPairs[close] = open
  endfor

  " Still use <buffer> level mapping for <BS> <SPACE>
  if g:AutoPairsMapBS
    " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
    execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'
  end

  if g:AutoPairsMapSpace
    execute 'inoremap <buffer> <silent> <SPACE> <C-R>=AutoPairsSpace()<CR>'
  end

  if g:AutoPairsShortcutFastWrap != ''
    execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutFastWrap.' <C-R>=AutoPairsFastWrap()<CR>'
  end

  if g:AutoPairsShortcutBackInsert != ''
    execute 'inoremap <buffer> <silent> '.g:AutoPairsShortcutBackInsert.' <C-R>=AutoPairsBackInsert()<CR>'
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

function! s:ExpandMap(map)
  let map = a:map
  if map =~ '<Plug>'
    let map = substitute(map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
  endif
  return map
endfunction

function! AutoPairsForceInit()
  if exists('b:autopairs_loaded')
    return
  end
  " for auto-pairs starts with 'a', so the priority is higher than supertab and vim-endwise
  "
  " vim-endwise doesn't support <Plug>AutoPairsReturn
  " when use <Plug>AutoPairsReturn will cause <Plug> isn't expanded
  "
  " supertab doesn't support <SID>AutoPairsReturn
  " when use <SID>AutoPairsReturn  will cause Duplicated <CR>
  "
  " and when load after vim-endwise will cause unexpected endwise inserted. 
  " so always load AutoPairs at last
  
  " Buffer level keys mapping
  " comptible with other plugin
  if g:AutoPairsMapCR
    let old_cr = maparg('<CR>', 'i')
    if old_cr == ''
      let old_cr = '<CR>'
    else
      let old_cr = s:ExpandMap(old_cr)
    endif

    if old_cr !~ 'AutoPairsReturn'
      " generally speaking, <silent> should not be here because every plugin
      " has there own silent solution. but for some plugin which wasn't double silent 
      " mapping, when maparg expand the map will lose the silent info, so <silent> always.
      execute 'imap <buffer> <silent> <CR> '.old_cr.'<SID>AutoPairsReturn'
    end
  endif
  call AutoPairsInit()
endfunction

" Always silent the command
inoremap <silent> <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>
imap <script> <Plug>AutoPairsReturn <SID>AutoPairsReturn


au BufEnter * :call AutoPairsForceInit()
