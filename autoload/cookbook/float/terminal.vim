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

    " create terminal float
    let term_winid = s:float_create([], opts)
    " `setl nomod` may suppress an error: https://github.com/neovim/neovim/issues/11962
    " `setl bh=hide` is necessary for the terminal to be togglable{{{
    "
    " Otherwise,  it  would  be  wiped  out when  you  toggle  it  off,  because
    " `s:float_create()` has set `'bh'` to `wipe`.
    " You  could  also  simply  clear  `bh`, but  the  issue  would  persist  if
    " `'hidden'` is reset.
    "}}}
    setl nomod bh=hide | call termopen(&shell)

    " create border float
    call extend(opts, {
        \ 'row': opts.row - 1,
        \ 'col': opts.col - 2,
        \ 'width': opts.width + 4,
        \ 'height': opts.height + 2,
        \ 'highlight': s:OPTS.borderhighlight,
        \ 'focusable': v:false,
        \ })
    let border = s:get_border(opts.width, opts.height)
    let border_winid = s:float_create(border, opts)

    call win_gotoid(term_winid)

    call s:close_border_automatically(border_winid, term_winid)
endfu

fu s:get_geometry() abort "{{{1
    let width = float2nr(&columns * s:OPTS.width) - 4
    let height = float2nr(&lines * s:OPTS.height) - 2

    let row = float2nr(s:OPTS.yoffset * (&lines - height))
    let col = float2nr(s:OPTS.xoffset * (&columns - width))

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
        \ 'row': opts.row,
        \ 'col': opts.col,
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

fu s:close_border_automatically(border, term) abort "{{{1
    exe 'au WinClosed '..a:term..' ++once call nvim_win_close('..a:border..', 1)'
endfu

