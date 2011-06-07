Auto Pairs
==========
Insert or delete brackets, parens, quotes in pair.

Installation
------------
copy plugin/auto-pairs.vim to ~/.vim/plugin

Features
--------
### Insert in pair
     
    input: [
    output: [|]

### Delete in pair
     
    input: foo[<BS>
    output: foo

### Insert new indented line after Return

    input: {|} (press <CR> at |)
    output: {
        |
    }

### Skip closed bracket.

    input: []
    output: []

### Ignore auto pair when previous character is \

    input: "\'
    output: "\'"


Shortcuts
---------

    System Shortcuts:
        <CR>  : Insert new indented line after return if cursor in blank brackets or quotes.
        <BS>  : Delete brackets in pair
        <M-p> : Toggle Autopairs

    Optional Shortcuts:
    could be turn off by let g:AutoPairsShortcuts = 0
        <M-n> jump to next closed bracket.
        <M-a> jump to end of line.
        <M-o> jump to newline with indented.

Options
-------
*   g:AutoPairs

        Default: {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}

*   g:AutoPairsShortcutToggle

        Default: '<M-p>'

        The shortcut to toggle autopairs.

*   g:AutoPairsShortcuts 

        Default: 1 

        imap 3 shortcuts
        <M-n> jump to next closed bracket.
        <M-a> jump to end of line.
        <M-o> jump to newline with indented.

*   g:AutoPairsMapBS

        Default : 1

        Map <BS> to delete brackets, quotes in pair
        execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'

*   g:AutoPairsMapCR

        Default : 1

        Map <CR> to insert a new indented line if cursor in (|), {|} [|], '|', "|"
        execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairsReturn()<CR>'

*   g:AutoPairsCenterLine

        Default : 1

        When g:AutoPairsMapCR is on, center current line after return if the line is at the bottom 1/3 of the window.

TroubleShooting
---------------
    The script will remap keys ([{'"}]) <BS>, 
    If auto pairs cannot work, use :imap ( to check if the map is corrected.
    The correct map should be <C-R>=AutoPairsInsert("\(")<CR>
    Or the plugin conflict with some other plugins.
    use command :call AutoPairsInit() to remap the keys.

