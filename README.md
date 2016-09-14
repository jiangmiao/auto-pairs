Auto Pairs
==========
Insert or delete brackets, parens, quotes in pair.

Installation
------------
copy plugin/auto-pairs.vim to ~/.vim/plugin

or if you are using `pathogen`:

```git clone git://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs```

Features
--------
*   Insert in pair

        input: [
        output: [|]

*   Delete in pair

        input: foo[<BS>]
        output: foo

*   Insert new indented line after Return

        input: {|} (press <CR> at |)
        output: {
            |
        }

*   Insert spaces before closing characters, only for [], (), {}

        input: {|} (press <SPACE> at |)
        output: { | }

        input: {|} (press <SPACE>foo} at |)
        output: { foo }|

        input: '|' (press <SPACE> at |)
        output: ' |'

*   Skip ' when inside a word

        input: foo| (press ' at |)
        output: foo'

*   Skip closed bracket.

        input: []
        output: []

*   Ignore auto pair when previous character is \

        input: "\'
        output: "\'"

*   Fast Wrap

        input: |'hello' (press (<M-e> at |)
        output: ('hello')

        wrap string, only support c style string
        input: |'h\\el\'lo' (press (<M-e> at |)
        output ('h\\ello\'')

        input: |[foo, bar()] (press (<M-e> at |)
        output: ([foo, bar()])

*   Quick jump to closed pair.

        input:
        {
            something;|
        }

        (press } at |)

        output:
        {

        }|

*   Support ``` ''' and """

        input:
            '''

        output:
            '''|'''

*   Delete Repeated Pairs in one time

        input: """|""" (press <BS> at |)
        output: |

        input: {{|}} (press <BS> at |)
        output: |

        input: [[[[[[|]]]]]] (press <BS> at |)
        output: |

*  Fly Mode

        input: if(a[3)
        output: if(a[3])| (In Fly Mode)
        output: if(a[3)]) (Without Fly Mode)

        input:
        {
            hello();|
            world();
        }

        (press } at |)

        output:
        {
            hello();
            world();
        }|

        (then press <M-b> at | to do backinsert)
        output:
        {
            hello();}|
            world();
        }

        See Fly Mode section for details

Fly Mode
--------
Fly Mode will always force closed-pair jumping instead of inserting. only for ")", "}", "]"

If jumps in mistake, could use AutoPairsBackInsert(Default Key: `<M-b>`) to jump back and insert closed pair.

the most situation maybe want to insert single closed pair in the string, eg ")"

Fly Mode is DISABLED by default.

add **let g:AutoPairsFlyMode = 1** .vimrc to turn it on

Default Options:

    let g:AutoPairsFlyMode = 0
    let g:AutoPairsShortcutBackInsert = '<M-b>'

Shortcuts
---------

    System Shortcuts:
        <CR>  : Insert new indented line after return if cursor in blank brackets or quotes.
        <BS>  : Delete brackets in pair
        <M-p> : Toggle Autopairs (g:AutoPairsShortcutToggle)
        <M-e> : Fast Wrap (g:AutoPairsShortcutFastWrap)
        <M-n> : Jump to next closed pair (g:AutoPairsShortcutJump)
        <M-b> : BackInsert (g:AutoPairsShortcutBackInsert)

    If <M-p> <M-e> or <M-n> conflict with another keys or want to bind to another keys, add

        let g:AutoPairsShortcutToggle = '<another key>'

    to .vimrc, if the key is empty string '', then the shortcut will be disabled.

Options
-------
*   g:AutoPairs

        Default: {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`'}

*   b:AutoPairs

        Default: g:AutoPairs

        Buffer level pairs set.

*   g:AutoPairsShortcutToggle

        Default: '<M-p>'

        The shortcut to toggle autopairs.

*   g:AutoPairsShortcutFastWrap

        Default: '<M-e>'

        Fast wrap the word. all pairs will be consider as a block (include <>).
        (|)'hello' after fast wrap at |, the word will be ('hello')
        (|)<hello> after fast wrap at |, the word will be (<hello>)

*   g:AutoPairsShortcutJump

        Default: '<M-n>'

        Jump to the next closed pair

*   g:AutoPairsMapBS

        Default : 1

        Map <BS> to delete brackets, quotes in pair
        execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'

*   g:AutoPairsMapCh

        Default : 1

        Map <C-h> to delete brackets, quotes in pair

*   g:AutoPairsMapCR

        Default : 1

        Map <CR> to insert a new indented line if cursor in (|), {|} [|], '|', "|"
        execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairsReturn()<CR>'

*   g:AutoPairsCenterLine

        Default : 1

        When g:AutoPairsMapCR is on, center current line after return if the line is at the bottom 1/3 of the window.

*   g:AutoPairsMapSpace

        Default : 1

        Map <space> to insert a space after the opening character and before the closing one.
        execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairsSpace()<CR>'

*   g:AutoPairsFlyMode

        Default : 0

        set it to 1 to enable FlyMode.
        see FlyMode section for details.

*   g:AutoPairsMultilineClose

        Default : 1

        When you press the key for the closing pair (e.g. `)`) it jumps past it.
        If set to 1, then it'll jump to the next line, if there is only whitespace.
        If set to 0, then it'll only jump to a closing pair on the same line.

*   g:AutoPairsShortcutBackInsert

        Default : <M-b>

        Work with FlyMode, insert the key at the Fly Mode jumped postion

*    g:AutoPairsOnlyAtEOL

        Default: 0

        Only add an auto-pair if the right-text is only whitespace

*    g:AutoPairsOnlyBeforeClose

        Default: 0

        Only add an auto-pair if right-text is all whitespace and close tags

*    g:AutoPairsBalanceImmediately

        Default: 0

        If the line contains an imbalance, fix the imbalance before skipping (WIP)

        input: foo(bar(|) (press ) at |)

        output: foo(bar()|)

*    g:AutoPairsNeverSkip

        Default: 0

        Never skip over pairs

*    g:AutoPairsNeverJumpLines

        Default: 0

        Never jump to another line

*    g:AutoPairsTriggerAbbrev

        Default: 1

        Trigger abbreviations as expected

*   g:AutoPairsAutoNewlineAfter

        Default: []

        Automatically add a newline after this opening character(s)

        let g:AutoPairsAutoNewlineAfter = ['{'] will act as though you pressed <CR> after {

        NOTE: single quotes must be escaped (with a quote), use <BAR> for |




*    g:AutoPairsSkipQuotes

        Default: 0

        Only when g:AutoPairsNeverSkip=1, allow skipping quotes

*    g:AutoPairsDebug

        Default: 0

        Turn off silent mappings, allow debug messages (there are none)

Minimal Annoyance Settings
--------------------------

If you dislike the cursor moving unexpectedly, and only wish of autopairs to close near
the end of the line, add these settings to your vimrc.

    let g:AutoPairsMultilineClose=0
    let g:AutoPairsOnlyBeforeClose=1
    let g:AutoPairsBalanceImmediately=1
    let g:AutoPairsNeverJumpLines=1


Buffer Level Pairs Setting
--------------------------

Set b:AutoPairs before BufEnter

eg:

    " When the filetype is FILETYPE then make AutoPairs only match for parenthesis
    au Filetype FILETYPE let b:AutoPairs = {"(": ")"}

TroubleShooting
---------------
    The script will remap keys ([{'"}]) <BS>,
    If auto pairs cannot work, use :imap ( to check if the map is corrected.
    The correct map should be <C-R>=AutoPairsInsert("\(")<CR>
    Or the plugin conflict with some other plugins.
    use command :call AutoPairsInit() to remap the keys.


* How to insert parens purely

    There are 3 ways

    1. use Ctrl-V ) to insert paren without trigger the plugin.

    2. use Alt-P to turn off the plugin.

    3. use DEL or <C-O>x to delete the character insert by plugin.

* Swedish Character Conflict

    Because AutoPairs uses Meta(Alt) key as shortcut, it is conflict with some Swedish character such as å.
    To fix the issue, you need remap or disable the related shortcut.

Known Issues
-----------------------
Breaks '.' - [issue #3](https://github.com/jiangmiao/auto-pairs/issues/3)

    Description: After entering insert mode and inputing `[hello` then leave insert
                 mode by `<ESC>`. press '.' will insert 'hello' instead of '[hello]'.
    Reason: `[` actually equals `[]\<LEFT>` and \<LEFT> will break '.'.
            After version 7.4.849, Vim implements new keyword <C-G>U to avoid the break
    Solution: Update Vim to 7.4.849+

Contributors
------------
* [camthompson](https://github.com/camthompson)


License
-------

Copyright (C) 2011-2013 Miao Jiang

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
