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
    let [opts.width, opts.height, opts.row, opts.col] = s:get_geometry()
    let border = s:get_border(opts.width, opts.height)
    let _opts = extend(deepcopy(opts), {'highlight': s:OPTS.highlight, 'focusable': v:false})
    let border_bufnr = s:float(border, _opts)
    call extend(opts, {
        \ 'width': opts.width - 4,
        \ 'height': opts.height - 2,
        \ 'row': opts.row + 1,
        \ 'col': opts.col + 2,
        \ })
    let term_bufnr = s:float([], opts)
    call s:wipe_border_when_closing_float(border_bufnr, term_bufnr)
    setl nomod | call termopen(&shell)
endfu

fu s:float(what, opts) abort "{{{1
    let [what, opts] = [a:what, a:opts]
    let bufnr = nvim_create_buf(v:false, v:true)
    if what != []
        call nvim_buf_set_lines(bufnr, 0, -1, v:true, what)
    endif
    call extend(opts, {
        \ 'row': opts.row - 1,
        \ 'col': opts.col - 1,
        \ 'relative': 'editor',
        \ 'style': 'minimal',
        \ })
    let highlight = has_key(opts, 'highlight') ? remove(opts, 'highlight') : 'Normal'
    let winid = nvim_open_win(bufnr, v:true, opts)
    call nvim_win_set_option(winid, 'winhl', 'NormalFloat:'..highlight)
    return bufnr
endfu

fu s:wipe_border_when_closing_float(border, term) abort "{{{1
    augroup wipe_border
        exe 'au! * <buffer='..a:term..'>'
        exe 'au BufHidden,BufWipeout <buffer='..a:term..'> '
            \ ..'exe "au! wipe_border * <buffer>" | bw '..a:border
    augroup END
endfu

fu s:get_geometry() abort "{{{1
    let width = float2nr(&columns * s:OPTS.width)
    let height = float2nr(&lines * s:OPTS.height)

    let row = float2nr(s:OPTS.yoffset * (&lines - height)) + 1
    let col = float2nr(s:OPTS.xoffset * (&columns - width)) + 1

    return [width, height, row, col]
endfu

fu s:get_border(width, height) abort "{{{1
    let [t, r, b, l, tl, tr, br, bl] = s:OPTS.borderchars
    let top = tl..repeat(t, a:width - 2)..tr
    let mid = l..repeat(' ', a:width - 2)..r
    let bot = bl..repeat(b, a:width - 2)..br
    let border = [top] + repeat([mid], a:height - 2) + [bot]
    return border
endfu

