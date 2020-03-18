const s:OPTS = {
    \ 'width': 0.9,
    \ 'height': 0.6,
    \ 'xoffset': 0.5,
    \ 'yoffset': 0.5,
    \ 'borderhighlight': 'WarningMsg',
    \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    \ }

fu cookbook#float#terminal#main() abort "{{{1
    let opts = {'anchor': 'NW'}
    let [opts.row, opts.col, opts.width, opts.height] = s:get_geometry()

    " create border float
    let border = s:get_border(opts.width, opts.height)
    let _opts = extend(deepcopy(opts), {
        \ 'highlight': s:OPTS.borderhighlight,
        \ 'focusable': v:false,
        \ })
    let border_winid = s:float_create(border, _opts)

    " create terminal float
    call extend(opts, {
        \ 'row': opts.row + 1,
        \ 'col': opts.col + 2,
        \ 'width': opts.width - 4,
        \ 'height': opts.height - 2,
        \ })
    let term_winid = s:float_create([], opts)
    " `setl nomod` may suppress an error: https://github.com/neovim/neovim/issues/11962
    setl nomod | call termopen(&shell)

    call s:close_border_automatically(border_winid, term_winid)
endfu

fu s:get_geometry() abort "{{{1
    let width = float2nr(&columns * s:OPTS.width)
    let height = float2nr(&lines * s:OPTS.height)

    " `+1` so that the geometry is identical as the popup terminal created by our Vim recipe.
    let row = float2nr(s:OPTS.yoffset * (&lines - height)) + 1
    let col = float2nr(s:OPTS.xoffset * (&columns - width)) + 1

    return [row, col, width, height]
endfu

fu s:get_border(width, height) abort "{{{1
    let [t, r, b, l, tl, tr, br, bl] = s:OPTS.borderchars
    let top = tl..repeat(t, a:width - 2)..tr
    let mid = l..repeat(' ', a:width - 2)..r
    let bot = bl..repeat(b, a:width - 2)..br
    let border = [top] + repeat([mid], a:height - 2) + [bot]
    return border
endfu

fu s:float_create(what, opts) abort "{{{1
    let [what, opts] = [a:what, a:opts]
    let bufnr = nvim_create_buf(v:false, v:true)
    if what != []
        " write the border
        call nvim_buf_set_lines(bufnr, 0, -1, v:true, what)
        call nvim_buf_set_option(bufnr, 'bh', 'wipe')
    endif
    call extend(opts, {
        \ 'row': opts.row - 1,
        \ 'col': opts.col - 1,
        \ 'relative': 'editor',
        \ 'style': 'minimal',
        \ })
    let highlight = has_key(opts, 'highlight') ? remove(opts, 'highlight') : 'Normal'
    " open the float
    let winid = nvim_open_win(bufnr, v:true, opts)
    "                                │{{{
    "                                └ focus the float immediately
    "
    " The  floating   border  will  be   focused  even  though   we've  included
    " `'focusable': v:false` in the options; but it doesn't matter.
    " When the  floating terminal will be  opened, the focus will  switch to the
    " latter,  then  it  will  be  impossible to  focus  the  border  thanks  to
    " `'focusable': v:false`.
    "}}}
    call nvim_win_set_option(winid, 'winhl', 'NormalFloat:'..highlight)
    return winid
endfu

fu s:close_border_automatically(border, text, ...) abort "{{{1
    if !a:0
        exe 'augroup close_border_'..a:border
            au!
            " when the text float is closed, close the border too
            exe 'au WinClosed * call s:close_border_automatically('..a:border..', '..a:text..', 1)'
        augroup END
    else
        if win_getid() == a:text
            call nvim_win_close(a:border, 1)
            exe 'au! close_border_'..a:border
            exe 'aug! close_border_'..a:border
        endif
    endif
endfu

