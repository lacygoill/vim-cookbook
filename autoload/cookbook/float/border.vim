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
        \ 'row': s:OPTS.row - 1,
        \ 'col': s:OPTS.col - 1,
        "\ add 2 columns for the left/right borders, and 2 columsn for the left/right paddings
        \ 'width': s:OPTS.width + 4,
        "\ add 2 lines for the top/bottom borders
        \ 'height': s:OPTS.height + 2,
        \ 'anchor': 'NW',
        \ 'focusable': v:false,
        \ 'highlight': s:OPTS.borderhighlight,
        \ }

    " create border float
    " Contrary to Vim, Nvim doesn't support a native border around a float.{{{
    "
    " We emulate the feature by creating an extra float whose sole purpose is to
    " draw a border.
    "}}}
    let border = s:get_border(opts.width, opts.height)
    call s:float_create(border, opts)

    " update the geometry of the text float so that its contents fits inside the border
    call extend(opts, {
        \ 'row': opts.row + 1,
        \ 'col': opts.col + 2,
        \ 'width': opts.width - 4,
        \ 'height': opts.height - 2,
        \ 'highlight': s:OPTS.highlight,
        \ })

    " create text float
    let lines = ['foo', 'bar', 'baz']
    let text_winid = s:float_create(lines, opts)
    " since the text float is not focused, its contents is hidden by the border float
    call s:redraw_text_float(text_winid)
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

fu s:redraw_text_float(text_winid) abort "{{{1
    let curwin = win_getid()
    " redraw the screen while the text float is focused
    call win_gotoid(a:text_winid) | redraw
    " get back to the original window
    call win_gotoid(curwin)
endfu

fu s:get_border(width, height) abort "{{{1
    let [t, r, b, l, tl, tr, br, bl] = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
    let top = tl..repeat(t, a:width - 2)..tr
    let mid = l..repeat(' ', a:width - 2)..r
    let bot = bl..repeat(b, a:width - 2)..br
    let border = [top] + repeat([mid], a:height - 2) + [bot]
    return border
endfu

