import Popup_notification from 'lg/popup.vim'

" Interface {{{1
fu cookbook#fzf#basic() abort "{{{2
    " Purpose: filter a list of lines with fzf
    let source = ['foo', 'bar', 'baz', 'qux', 'norf']
    call fzf#wrap({
        \ 'source': source,
        \ 'sink': function('s:echo_choice'),
        \ })
        \ ->fzf#run()
endfu

fu cookbook#fzf#color() abort "{{{2
    " Purpose: filter a list of lines with fzf; color some part of the lines
    let source = ['1. one', '2. two', '3. three', '4. four', '5. five']
    call map(source, {_, v -> substitute(v, '\d', "\x1b[38;5;30m&\x1b[0m", '')})
    "                                                        ^^
    "                                                        color number in 256-color palette
    call fzf#wrap({
        \ 'source': source,
        \ 'options': '--ansi',
        \ 'sink': function('s:echo_choice'),
        \ })
        \ ->fzf#run()
endfu
"}}}1
" Util {{{1
fu s:echo_choice(line) abort "{{{2
    let msg = 'you chose ' .. a:line
    try
        call s:Popup_notification(msg)
    catch /^Vim\%((\a\+)\)\=:E117:/
        call cookbook#error('need s:Popup_notification(); install vim-lg-lib')
    endtry
endfu

