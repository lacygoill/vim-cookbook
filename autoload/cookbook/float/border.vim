const s:OPTS = {
    \ 'row': 5,
    \ 'col': 10,
    \ 'width': 20,
    \ 'height': 15,
    \ 'highlight': 'Visual',
    \ 'borderhighlight': 'WarningMsg',
    \ }

fu cookbook#float#border#main() abort "{{{1
    let opts = {
        \ 'row': s:OPTS.row,
        "\ `+1` just to get the same position as in our equivalent Vim recipe
        \ 'col': s:OPTS.col + 1,
        \ 'width': s:OPTS.width,
        \ 'height': s:OPTS.height,
        \ 'anchor': 'NW',
        \ 'focusable': v:false,
        \ 'highlight': s:OPTS.highlight,
        \ }

    " create text float
    " Warning: Do *not* create the border float before the text float.{{{
    "
    " It would create 2 issues.
    " First, if the  text float is not  focused, its contents will  be hidden by
    " the border float.  So, you'll need to redraw it manually:
    "
    "     let curwin = win_getid()
    "     call win_gotoid(text_winid) | redraw
    "                                   ^^^^^^
    "     call win_gotoid(curwin)
    "
    " Second, if you focus a different tab  page and come back, the border float
    " will be drawn over the text float, hiding its contents.
    " To fix this manually, you would  need to temporarily focus the text float,
    " which is cumbersome  if you created the float  with `'focusable': v:false`
    " (you need to invoke `nvim_set_current_win()` in that case).
    " Automating this fix would probably be tricky.
    "}}}
    let lines = ['foo', 'bar', 'baz']
    let text_winid = s:float_create(lines, opts)

    " update the geometry of the border float so that it fits around the text
    call extend(opts, {
        \ 'row': opts.row - 1,
        "\ `-2`, and not `-1`, to take into account the left padding
        \ 'col': opts.col - 2,
        "\ add 2 columns for the left/right borders, and 2 columns for the left/right paddings
        \ 'width': opts.width + 4,
        "\ add 2 lines for the top/bottom borders
        \ 'height': opts.height + 2,
        \ 'highlight': s:OPTS.borderhighlight,
        \ })

    " create border float
    " Contrary to Vim, Nvim doesn't support a native border around a float.{{{
    "
    " We emulate the feature by creating an extra float whose sole purpose is to
    " draw a border.
    "}}}
    let border = s:get_border(opts.width, opts.height)
    let border_winid = s:float_create(border, opts)

    " when we close the text float, close the border float too
    call s:close_border_automatically(border_winid, text_winid)
endfu

fu s:float_create(what, opts) abort "{{{1
    let bufnr = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_option(bufnr, 'bh', 'wipe')
    call nvim_buf_set_lines(bufnr, 0, -1, v:true, a:what)
    call extend(a:opts, {
        \ 'row': a:opts.row,
        \ 'col': a:opts.col,
        \ 'relative': 'editor',
        \ 'style': 'minimal',
        \ })
    " Nvim doesn't recognize the `highlight` key.{{{
    "
    " Remove  it and  save its  value in  a variable  so that  we can  apply the
    " desired highlighting to the float once it will be opened.
    "}}}
    let highlight = remove(a:opts, 'highlight')
    let winid = nvim_open_win(bufnr, v:false, a:opts)
    call nvim_win_set_option(winid, 'winhl', 'NormalFloat:'..highlight)
    return winid
endfu

fu s:get_border(width, height) abort "{{{1
    let [t, r, b, l, tl, tr, br, bl] = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
    let top = tl..repeat(t, a:width - 2)..tr
    let mid = l..repeat(' ', a:width - 2)..r
    let bot = bl..repeat(b, a:width - 2)..br
    let border = [top] + repeat([mid], a:height - 2) + [bot]
    return border
endfu

fu s:close_border_automatically(border, text) abort "{{{1
    exe 'au WinClosed '..a:text..' ++once call nvim_win_close('..a:border..', 1)'
endfu

