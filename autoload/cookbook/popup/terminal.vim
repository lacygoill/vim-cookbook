const s:OPTS = {
    \ 'width': 0.9,
    \ 'height': 0.6,
    \ 'xoffset': 0.5,
    \ 'yoffset': 0.5,
    \ 'highlight': 'WarningMsg',
    \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    \ }

fu cookbook#popup#terminal#main() abort "{{{1
    " get options
    let opts = {}
    let [opts.line, opts.col, opts.minwidth, opts.minheight] = s:get_geometry()
    call extend(opts, #{
        \ maxwidth: opts.minwidth,
        \ maxheight: opts.minheight,
        \ highlight: 'Normal',
        \ border: [],
        \ borderchars: s:OPTS.borderchars,
        \ borderhighlight: [s:OPTS.highlight],
        \ padding: [0,1,0,1],
        \ zindex: s:get_zindex(),
        \ })

    " create terminal buffer
    let bufnr = term_start(&shell, #{hidden: v:true, term_kill: 'hup'})
    " display it in popup window
    call popup_create(bufnr, opts)

    call s:fire_terminal_events()
endfu

fu s:get_geometry() abort "{{{1
    let width = float2nr(&columns * s:OPTS.width) - 4
    let height = float2nr(&lines * s:OPTS.height) - 2

    let row = float2nr(s:OPTS.yoffset * (&lines - height))
    let col = float2nr(s:OPTS.xoffset * (&columns - width)) - 1

    return [row, col, width, height]
endfu

fu s:get_zindex() abort "{{{1
    let screenpos = screenpos(win_getid(), line('.'), col('.'))
    let opts = popup_locate(screenpos.row, screenpos.col)->popup_getoptions()
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

