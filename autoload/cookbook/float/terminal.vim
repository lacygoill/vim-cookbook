const s:OPTS = {
    \ 'width': 0.9,
    \ 'height': 0.6,
    \ 'xoffset': 0.5,
    \ 'yoffset': 0.5,
    \ 'highlight': 'WarningMsg',
    \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    \ }

fu cookbook#float#terminal#main() abort "{{{1
    let opts = {'anchor': 'NW'}
    let [opts.row, opts.col, opts.width, opts.height] = s:get_geometry()

    " create border float
    let border = s:get_border(opts.width, opts.height)
    let _opts = extend(deepcopy(opts), {
        \ 'highlight': s:OPTS.highlight,
        \ 'focusable': v:false,
        \ })
    let border_bufnr = s:float_create(border, _opts)

    " create terminal float
    call extend(opts, {
        \ 'row': opts.row + 1,
        \ 'col': opts.col + 2,
        \ 'width': opts.width - 4,
        \ 'height': opts.height - 2,
        \ })
    let term_bufnr = s:float_create([], opts)
    " `setl nomod` may suppress an error: https://github.com/neovim/neovim/issues/11962
    setl nomod | call termopen(&shell)

    call s:wipe_border_when_closing(border_bufnr, term_bufnr)
endfu

fu s:float_create(what, opts) abort "{{{1
    let [what, opts] = [a:what, a:opts]
    let bufnr = nvim_create_buf(v:false, v:true)
    if what != []
        " write the border
        call nvim_buf_set_lines(bufnr, 0, -1, v:true, what)
    endif
    call extend(opts, {
        \ 'row': opts.row - 1,
        \ 'col': opts.col - 1,
        \ 'relative': 'editor',
        \ 'style': 'minimal',
        \ })
    " Nvim doesn't recognize the `highlight` key; remove it if it's present.{{{
    "
    " And  save its  value  in a  variable  so  that we  can  apply the  desired
    " highlighting to the float once it will be opened.
    "}}}
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
    return bufnr
endfu

fu s:wipe_border_when_closing(border, term) abort "{{{1
    augroup wipe_border
        exe 'au! * <buffer='..a:term..'>'
        exe 'au BufHidden,BufWipeout <buffer='..a:term..'> '
            \ ..'exe "au! wipe_border * <buffer>" | bw! '..a:border
    augroup END
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

