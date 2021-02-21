vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import Popup_notification from 'lg/popup.vim'

# color number in 256-color palette
const MYCOLOR: number = 30

# Interface {{{1
def cookbook#fzf#basic() #{{{2
    # Purpose: filter a list of lines with fzf
    var source: list<string> = ['foo', 'bar', 'baz', 'qux', 'norf']
    fzf#wrap({
        source: source,
        sink: EchoChoice,
        })
        ->fzf#run()
enddef

def cookbook#fzf#color() #{{{2
    # Purpose: filter a list of lines with fzf; color some part of the lines
    var source: list<string> = ['1. one', '2. two', '3. three', '4. four', '5. five']
        ->map((_, v: string): string =>
            substitute(v, '\d', "\x1b[38;5;" .. MYCOLOR .. "m&\x1b[0m", '')
            )
    fzf#wrap({
        source: source,
        options: '--ansi',
        sink: EchoChoice,
        })
        ->fzf#run()
enddef
#}}}1
# Util {{{1
def EchoChoice(line: string) #{{{2
    var msg: string = 'you chose ' .. line
    try
        Popup_notification(msg)
    catch /^Vim\%((\a\+)\)\=:E117:/
        call cookbook#error('need Popup_notification(); install vim-lg-lib')
    endtry
enddef

