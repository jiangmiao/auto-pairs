" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Contributor: camthompson
" Last Change:  2013-07-13
" Version: 1.3.2
" Homepage: http://www.vim.org/scripts/script.php?script_id=3599
" Repository: https://github.com/jiangmiao/auto-pairs
" License: MIT

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

if !exists('g:AutoPairsMapBS')
  let g:AutoPairsMapBS = 1
end

" Map <C-h> as the same BS
if !exists('g:AutoPairsMapCh')
  let g:AutoPairsMapCh = 1
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

" When skipping the closed pair, look at the current and
" next line as well.
if !exists('g:AutoPairsMultilineClose')
  let g:AutoPairsMultilineClose = 0
endif

" Work with Fly Mode, insert pair where jumped
if !exists('g:AutoPairsShortcutBackInsert')
  let g:AutoPairsShortcutBackInsert = '<M-b>'
endif

if !exists('g:AutoPairsSmartQuotes')
  let g:AutoPairsSmartQuotes = 1
endif

" Only add a pair if there is nothing to the right
if !exists('g:AutoPairsOnlyAtEOL')
  let g:AutoPairsOnlyAtEOL = 0
endif

" Only auto-pair if text on right is close tags
if !exists('g:AutoPairsOnlyBeforeClose')
  let g:AutoPairsOnlyBeforeClose = 0
endif

" Balance unbalanced open parens immediately
if !exists('g:AutoPairsBalanceImmediately')
  let g:AutoPairsBalanceImmediately = 0
endif

" Never Skip
if !exists('g:AutoPairsNeverSkip')
  let g:AutoPairsNeverSkip = 0
endif

" Never Jump
if !exists('g:AutoPairsNeverJumpLines')
  let g:AutoPairsNeverJumpLines = 0
endif

" Trigger abbreviations if available
if !exists('g:AutoPairsTriggerAbbrev')
  let g:AutoPairsTriggerAbbrev = 1
endif

" Auto Newline after character
if !exists('g:AutoPairsAutoNewlineAfter')
  let g:AutoPairsAutoNewlineAfter = []
endif

" Never Skip, but skip quotes (auto if NeverSkip=0)
if !exists('g:AutoPairsSkipQuotes')
  let g:AutoPairsSkipQuotes = 0
endif

" Declare all mappings without silent, alows echo(m) debugging
if !exists('g:AutoPairsDebug')
  let g:AutoPairsDebug = 0
endif


if g:AutoPairsDebug
  let g:AutoPairsSilence = ''
else
  let g:AutoPairsSilence = ' <silent> '
end

" 7.4.849 support <C-G>U to avoid breaking '.'
" Issue talk: https://github.com/jiangmiao/auto-pairs/issues/3
" Vim note: https://github.com/vim/vim/releases/tag/v7.4.849
if v:version > 704 || v:version == 704 && has("patch849")
  let s:Go = "\<C-G>U"
else
  let s:Go = ""
endif

let s:Left = s:Go."\<LEFT>"
let s:Right = s:Go."\<RIGHT>"


" Will auto generated {']' => '[', ..., '}' => '{'}in initialize.
let g:AutoPairsClosedPairs = {}

" Helper
function! s:AutoPairsCount()
  let s:matches += 1
  return submatch(0)
endfunction
function! AutoPairsCountChar(str, char)
  let re1 = '\\'.a:char
  let re2 = a:char

  let s:matches = 0
  call substitute(a:str, re1, '\=s:AutoPairsCount()', 'g')
  let escaped = s:matches

  let s:matches = 0
  call substitute(a:str, re2, '\=s:AutoPairsCount()', 'g')
  let cmatches = s:matches

  return cmatches - escaped
endfunction

function! AutoPairsInsert(key)
  if !b:autopairs_enabled
    return a:key
  end

  let line = getline('.')
  let pos = col('.') - 1
  let before = strpart(line, 0, pos)
  let after = strpart(line, pos)
  let next_chars = split(after, '\zs')
  let current_char = get(next_chars, 0, '')
  let next_char = get(next_chars, 1, '')
  let prev_chars = split(before, '\zs')
  let prev_char = get(prev_chars, -1, '')
  let reclose = '\v^\s*[ '.escape(join(values(g:AutoPairs)),'})]').']*\s*$'

  let eol = 0
  if col('$') ==  col('.')
    let eol = 1
  end

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  " The key is difference open-pair, then it means only for ) ] } by default
  if !has_key(b:AutoPairs, a:key)
    let b:autopairs_saved_pair = [a:key, getpos('.')]

    " Skip the character if current character is the same as input
    if !g:AutoPairsNeverSkip && current_char == a:key
      if g:AutoPairsBalanceImmediately

        let open_key = b:AutoPairsClosedPairs[a:key]

        let c_open = AutoPairsCountChar(line,open_key)
        let c_close = AutoPairsCountChar(line,a:key)

        if c_open > c_close
          return a:key
        endif
      endif
      return s:Right
    endif

    " TODO apply BalanceImmediately
    if !g:AutoPairsFlyMode && !g:AutoPairsNeverSkip
      " Skip the character if next character is space
      if current_char == ' ' && next_char == a:key
        return s:Right.s:Right
      end
    endif

    if !g:AutoPairsFlyMode && !g:AutoPairsNeverSkip && !g:AutoPairsNeverJumpLines
      " Skip the character if closed pair is next character
      if current_char == ''
        if g:AutoPairsMultilineClose
          let next_lineno = line('.')+1
          let next_line = getline(nextnonblank(next_lineno))
          let next_char = matchstr(next_line, '\s*\zs.')
        else
          let next_char = matchstr(line, '\s*\zs.')
        end
        if next_char == a:key
          return "\<ESC>e^a"
        endif
      endif
    endif

    " Fly Mode, and the key is closed-pairs, search closed-pair and jump
    if !g:AutoPairsNeverSkip && g:AutoPairsFlyMode && has_key(b:AutoPairsClosedPairs, a:key)
      if g:AutoPairsBalanceImmediately
          let c_open = AutoPairsCountChar(line,b:AutoPairsClosedPairs[a:key])
          let c_close = AutoPairsCountChar(line,a:key)
          if c_open > c_close
            return a:key
          endif
      end
      let n = stridx(after, a:key)
      if n != -1
        return repeat(s:Right, n+1)
      end
      if !g:AutoPairsNeverJumpLines && search(a:key, 'W')
        " force break the '.' when jump to different line
        return "\<Right>"
      endif
      if g:AutoPairsNeverJumpLines && search(a:key, 'W', line('.'))
        " force break the '.' when jump to different line
        return "\<Right>"
      endif
    endif

    " Insert directly if the key is not an open key
    return a:key
  end

  let open = a:key
  let close = b:AutoPairs[open]

  if (!g:AutoPairsNeverSkip || g:AutoPairsSkipQuotes) && current_char == close && open == close
    return s:Right
  end

  " Ignore auto close ' if follows a word
  " MUST after closed check. 'hello|'
  if a:key == "'" && prev_char =~? '\v\w'
    return a:key
  end

  " support for ''' ``` and """
  if open == close
    " The key must be ' " `
    let pprev_char = line[col('.')-3]
    if pprev_char == open && prev_char == open
      " Double pair found
      if g:AutoPairsOnlyAtEOL && eol==0
        return a:key
      end
      "if g:AutoPairsOnlyBeforeClose && after!='' && (match(after,reclose)<0)
      if g:AutoPairsOnlyBeforeClose && (match(after,reclose)<0)
        return a:key
      end
      return repeat(a:key, 4) . repeat(s:Left, 3)
    end
    if g:AutoPairsBalanceImmediately
        let quotes = AutoPairsCountChar(line,open)
        if quotes%2
          return a:key
        endif
    end
  end

  let quotes_num = 0
  " Ignore comment line for vim file
  if &filetype == 'vim' && a:key == '"'
    if before =~? '^\s*$'
      return a:key
    end
    if before =~? '^\s*"'
      let quotes_num = -1
    end
  end

  " Keep quote number is odd.
  " Because quotes should be matched in the same line in most of situation
  if g:AutoPairsSmartQuotes && open == close
    " Remove \\ \" \'
    let cleaned_line = substitute(line, '\v(\\.)', '', 'g')
    let n = quotes_num
    let pos = 0
    while 1
      let pos = stridx(cleaned_line, open, pos)
      if pos == -1
        break
      end
      let n = n + 1
      let pos = pos + 1
    endwhile
    if n % 2 == 1
      return a:key
    endif
  endif

  if g:AutoPairsOnlyAtEOL && eol==0
    return a:key
  end

  if g:AutoPairsOnlyBeforeClose && (match(after,reclose)<0)
    return a:key
  end

  if index(g:AutoPairsAutoNewlineAfter, open) >= 0
    return open.close.s:Left."\<CR>\<C-R>=AutoPairsReturn()\<CR>"
  else
    return open.close.s:Left
  endif

  return open.close.s:Left
endfunction

function! AutoPairsDelete()
  if !b:autopairs_enabled
    return "\<BS>"
  end

  let line = getline('.')
  let pos = col('.') - 1
  let current_char = get(split(strpart(line, pos), '\zs'), 0, '')
  let prev_chars = split(strpart(line, 0, pos), '\zs')
  let prev_char = get(prev_chars, -1, '')
  let pprev_char = get(prev_chars, -2, '')

  if pprev_char == '\'
    return "\<BS>"
  end

  " Delete last two spaces in parens, work with MapSpace
  if has_key(b:AutoPairs, pprev_char) && prev_char == ' ' && current_char == ' '
    return "\<BS>\<DEL>"
  endif

  " Delete Repeated Pair eg: '''|''' [[|]] {{|}}
  if has_key(b:AutoPairs, prev_char)
    let times = 0
    let p = -1
    while get(prev_chars, p, '') == prev_char
      let p = p - 1
      let times = times + 1
    endwhile

    let close = b:AutoPairs[prev_char]
    let left = repeat(prev_char, times)
    let right = repeat(close, times)

    let before = strpart(line, pos-times, times)
    let after  = strpart(line, pos, times)
    if left == before && right == after
      return repeat("\<BS>\<DEL>", times)
    end
  end


  if has_key(b:AutoPairs, prev_char)
    let close = b:AutoPairs[prev_char]
    if match(line,'^\s*'.close, col('.')-1) != -1
      " Delete (|___)
      let space = matchstr(line, '^\s*', col('.')-1)
      return "\<BS>". repeat("\<DEL>", len(space)+1)
    elseif match(line, '^\s*$', col('.')-1) != -1
      " Delete (|__\n___)
      let nline = getline(line('.')+1)
      if nline =~? '^\s*'.close
        if &filetype == 'vim' && prev_char == '"'
          " Keep next line's comment
          return "\<BS>"
        end

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
  normal! x
  " Skip blank
  if next_char =~? '\v\s' || at_end
    call search('\v\S', 'W')
    let line = getline('.')
    let next_char = line[col('.')-1]
  end

  if has_key(b:AutoPairs, next_char)
    let followed_open_pair = next_char
    let inputed_close_pair = current_char
    let followed_close_pair = b:AutoPairs[next_char]
    if followed_close_pair != followed_open_pair
      " TODO replace system searchpair to skip string and nested pair.
      " eg: (|){"hello}world"} will transform to ({"hello})world"}
      call searchpair('\V'.followed_open_pair, '', '\V'.followed_close_pair, 'W')
    else
      call search(s:FormatChunk(followed_open_pair, followed_close_pair), 'We')
    end
    return s:Right.inputed_close_pair.s:Left
  else
    normal! he
    return s:Right.current_char.s:Left
  end
endfunction

function! AutoPairsMap(key)
  " | is special key which separate map command from text
  let key = a:key
  if key == '|'
    let key = '<BAR>'
  end
  let escaped_key = substitute(key, "'", "''", 'g')
  " use expr will cause search() doesn't work
  if g:AutoPairsTriggerAbbrev
    execute 'inoremap <buffer> '.g:AutoPairsSilence.' '.key." <C-]><C-R>=AutoPairsInsert('".escaped_key."')<CR>"
  else
    execute 'inoremap <buffer> '.g:AutoPairsSilence.' '.key." <C-R>=AutoPairsInsert('".escaped_key."')<CR>"
  endif
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
  if b:autopairs_enabled == 0
    return ''
  end
  let line = getline('.')
  let pline = getline(line('.')-1)
  let prev_char = pline[strlen(pline)-1]
  let cmd = ''
  let cur_char = line[col('.')-1]
  if has_key(b:AutoPairs, prev_char) && b:AutoPairs[prev_char] == cur_char
    if g:AutoPairsCenterLine && winline() * 3 >= winheight(0) * 2
      " Recenter before adding new line to avoid replacing line content
      let cmd = "zz"
    end

    " If equalprg has been set, then avoid call =
    " https://github.com/jiangmiao/auto-pairs/issues/24
    if &equalprg != ''
      return "\<ESC>".cmd."O"
    endif

    " conflict with javascript and coffee
    " javascript   need   indent new line
    " coffeescript forbid indent new line
    if &filetype == 'coffeescript' || &filetype == 'coffee'
      return "\<ESC>".cmd."k==o"
    else
      return "\<ESC>".cmd."=ko"
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
    let cmd = "\<SPACE>".s:Left
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
  let b:AutoPairsClosedPairs = {}

  if !exists('b:AutoPairs')
    let b:AutoPairs = g:AutoPairs
  end

  " buffer level map pairs keys
  for [open, close] in items(b:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
    let b:AutoPairsClosedPairs[close] = open
  endfor

  " Still use <buffer> level mapping for <BS> <SPACE>
  if g:AutoPairsMapBS
    " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
    execute 'inoremap <buffer> '.g:AutoPairsSilence.' <BS> <C-R>=AutoPairsDelete()<CR>'
  end

  if g:AutoPairsMapCh
      execute 'inoremap <buffer> '.g:AutoPairsSilence.' <C-h> <C-R>=AutoPairsDelete()<CR>'
  endif

  if g:AutoPairsMapSpace
    " Try to respect abbreviations on a <SPACE>
    let do_abbrev = ""
    if v:version == 703 && has("patch489") || v:version > 703
      let do_abbrev = "<C-]>"
    endif
      execute 'inoremap <buffer> '.g:AutoPairsSilence.' <SPACE> '.do_abbrev.'<C-R>=AutoPairsSpace()<CR>'
  end

  if g:AutoPairsShortcutFastWrap != ''
      execute 'inoremap <buffer> '.g:AutoPairsSilence.' '.g:AutoPairsShortcutFastWrap.' <C-R>=AutoPairsFastWrap()<CR>'
  end

  if g:AutoPairsShortcutBackInsert != ''
      execute 'inoremap <buffer> '.g:AutoPairsSilence.' '.g:AutoPairsShortcutBackInsert.' <C-R>=AutoPairsBackInsert()<CR>'
  end

  if g:AutoPairsShortcutToggle != ''
    " use <expr> to ensure showing the status when toggle
      execute 'inoremap <buffer> '.g:AutoPairsSilence.' <expr> '.g:AutoPairsShortcutToggle.' AutoPairsToggle()'
      execute 'noremap <buffer> '.g:AutoPairsSilence.' '.g:AutoPairsShortcutToggle.' :call AutoPairsToggle()<CR>'
  end

  if g:AutoPairsShortcutJump != ''
      execute 'inoremap <buffer> '.g:AutoPairsSilence.' ' . g:AutoPairsShortcutJump. ' <ESC>:call AutoPairsJump()<CR>a'
      execute 'noremap <buffer> '.g:AutoPairsSilence.' ' . g:AutoPairsShortcutJump. ' :call AutoPairsJump()<CR>'
  end

endfunction

function! s:ExpandMap(map)
  let map = a:map
  let map = substitute(map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
  return map
endfunction

function! AutoPairsTryInit()
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
    if v:version == 703 && has('patch32') || v:version > 703
      " VIM 7.3 supports advancer maparg which could get <expr> info
      " then auto-pairs could remap <CR> in any case.
      let info = maparg('<CR>', 'i', 0, 1)
      if empty(info)
        let old_cr = '<CR>'
        let is_expr = 0
      else
        let old_cr = info['rhs']
        let old_cr = s:ExpandMap(old_cr)
        let old_cr = substitute(old_cr, '<SID>', '<SNR>' . info['sid'] . '_', 'g')
        let is_expr = info['expr']
        let wrapper_name = '<SID>AutoPairsOldCRWrapper73'
      endif
    else
      " VIM version less than 7.3
      " the mapping's <expr> info is lost, so guess it is expr or not, it's
      " not accurate.
      let old_cr = maparg('<CR>', 'i')
      if old_cr == ''
        let old_cr = '<CR>'
        let is_expr = 0
      else
        let old_cr = s:ExpandMap(old_cr)
        " old_cr contain (, I guess the old cr is in expr mode
        let is_expr = old_cr =~? '\V(' && toupper(old_cr) !~ '\V<C-R>'

        " The old_cr start with " it must be in expr mode
        let is_expr = is_expr || old_cr =~? '\v^"'
        let wrapper_name = '<SID>AutoPairsOldCRWrapper'
      end
    end

    if old_cr !~ 'AutoPairsReturn'
      if is_expr
        " remap <expr> to `name` to avoid mix expr and non-expr mode
        execute 'inoremap <buffer> <expr> <script> '. wrapper_name . ' ' . old_cr
        let old_cr = wrapper_name
      end
      " Always silent mapping
        execute 'inoremap <script> <buffer> '.g:AutoPairsSilence.' <CR> '.old_cr.'<SID>AutoPairsReturn'
    end
  endif
  call AutoPairsInit()
endfunction

" Always silent the command
if g:AutoPairsDebug
  inoremap <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>
  imap <script> <Plug>AutoPairsReturn <SID>AutoPairsReturn
else
  inoremap <silent> <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>
  imap <script> <Plug>AutoPairsReturn <SID>AutoPairsReturn
endif


au BufEnter * :call AutoPairsTryInit()
