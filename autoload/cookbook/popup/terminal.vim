const s:OPTS = {
    \ 'width': 0.9,
    \ 'height': 0.6,
    \ 'xoffset': 0.5,
    \ 'yoffset': 0.5,
    \ 'highlight': 'WarningMsg',
    \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    \ }

fu cookbook#popup#terminal#main() abort "{{{1
    " set options
    let opts = {}
    let [opts.line, opts.col, opts.minwidth, opts.minheight] = s:get_geometry()
    call extend(opts, #{
        \ maxwidth: opts.minwidth,
        \ maxheight: opts.minheight,
        "\ in Terminal-Normal mode, don't highlight empty cells with `Pmenu` (same thing for padding cells)
        \ highlight: 'Normal',
        \ border: [],
        \ borderchars: s:OPTS.borderchars,
        \ borderhighlight: [s:OPTS.highlight],
        \ padding: [0,1,0,1],
        "\ get the lowest `zindex` possible to be able to see the popup;
        "\ if it's too low, it may be hidden by an existing popup,
        "\ and if it's too high, it may hide future popups
        \ zindex: s:get_zindex(),
        \ })

    " create terminal buffer
    let bufnr = term_start(&shell, #{hidden: v:true, term_kill: 'hup'})
    " display it in popup window
    call popup_create(bufnr, opts)

    call s:fire_terminal_events()
endfu

fu s:get_geometry() abort "{{{1
    " `-4` and `-2` to take into account the border and the padding.{{{
    "
    " 2 lines are taken  by the top/bottom segments, and 4  columns are taken by
    " the right/left segments+paddings.
    "}}}
    let width = float2nr(&columns * s:OPTS.width) - 4
    let height = float2nr(&lines * s:OPTS.height) - 2

    let row = float2nr(s:OPTS.yoffset * (&lines - height))
    " `-1` so that the position is identical as the floating terminal created by our Nvim recipe
    let col = float2nr(s:OPTS.xoffset * (&columns - width)) - 1

    return [row, col, width, height]
endfu

fu s:get_zindex() abort "{{{1
    " get screen position of the cursor
    let screenpos = screenpos(win_getid(), line('.'), col('.'))
    " use it to get the id of the popup at the cursor, then the options of the latter
    let opts = popup_locate(screenpos.row, screenpos.col)->popup_getoptions()
    " return the `zindex` value of the popup at the cursor, plus one so that our
    " popup terminal barely wins
    return get(opts, 'zindex', 0) + 1
endfu

fu s:fire_terminal_events() abort "{{{1
    " Install our custom terminal settings.
    if exists('#TerminalWinOpen') | do <nomodeline> TerminalWinOpen | endif
    " Vim makes us enter Terminal-Job mode immediately.{{{
    "
    " And Vim doesn't support `TermEnter` (nor `TermLeave`).
    " Nevertheless, if  you emulate it  via `User`,  and you have  some settings
    " which are applied on `User TermEnter`, you want to fire it now.
    "}}}
    if exists('#User#TermEnter') | do <nomodeline> User TermEnter | endif
endfu

