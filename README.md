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

### Double input open brackets will insert new indented line.

    input: {{
    output: {
        |
    }

### Skip closed bracket.

    input: []
    output: []

### Ignore auto pair when previous character is \

    input: "\'
    output: "\'"

Options
-------
*   g:AutoPairs

    Default: {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}

*   g:AutoPairsShortcuts 
    
    Default: 1 

        imap 3 shortcuts
        <M-n> jump to next closed bracket.
        <M-a> jump to end of line.
        <M-o> jump to newline with indented.

TroubleShooting
---------------
    The script will remap keys ([{'"}]) <BS>, 
    If auto pairs cannot work, use :imap ( to check if the map is corrected.
    The correct map should be <C-R>=AutoPairsInsert("\(")<CR>
    Or the plugin conflict with some other plugins.
    use command :call AutoPairsInit() to remap the keys.

