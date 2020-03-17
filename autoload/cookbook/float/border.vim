fu cookbook#float#border#main() abort "{{{1
    let opts = {
        \ 'row': 5-1,
        \ 'col': 10-1,
        "\ add 2 columns for the left/right borders, and 2 columsn for the left/right paddings
        \ 'width': 20+4,
        "\ add 2 lines for the top/bottom borders
        \ 'height': 15+2,
        \ 'anchor': 'NW',
        \ 'focusable': v:false,
        \ 'highlight': 'WarningMsg',
        \ }

    " create border float
    " Contrary to Vim, Nvim doesn't support a native border around a float.{{{
    "
    " We emulate the feature by creating an extra float whose sole purpose is to
    " draw a border.
    "}}}
    let border = s:get_border(opts.width, opts.height)
    let [border_bufnr, _] = s:float_create(border, opts)

    " update the geometry of the text float so that its contents fits inside the border
    call extend(opts, {
        \ 'row': opts.row + 1,
        \ 'col': opts.col + 2,
        \ 'width': opts.width - 4,
        \ 'height': opts.height - 2,
        \ 'highlight': 'Visual',
        \ })

    " create text float
    let is_not_focused = !has_key(opts, 'enter') || opts.enter == v:false
    let lines = ['foo', 'bar', 'baz']
    let [text_bufnr, text_winid] = s:float_create(lines, opts)
    " if the text float is not immediately focused, its contents is hidden by the border float;
    " it needs to be focused at least temporarily
    if is_not_focused
        call s:focus_briefly(text_winid)
    endif

    call s:wipe_border_when_closing(border_bufnr, text_bufnr)
endfu

fu s:float_create(what, opts) abort "{{{1
    let bufnr = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(bufnr, 0, -1, v:true, a:what)
    call extend(a:opts, {
        \ 'row': a:opts.row,
        \ 'col': a:opts.col,
        \ 'relative': 'editor',
        \ 'style': 'minimal',
        \ })
    let highlight = remove(a:opts, 'highlight')
    let winid = nvim_open_win(bufnr, v:false, a:opts)
    call nvim_win_set_option(winid, 'winhl', 'NormalFloat:'..highlight)
    return [bufnr, winid]
endfu

fu s:focus_briefly(text_winid) abort "{{{1
    let curwin = win_getid()
    " focus the text float
    call win_gotoid(a:text_winid)
    " get back to the original window
    call timer_start(0, {-> win_gotoid(curwin)})
    " for some reason, without a timer, the text float is still shadowed by the border float;
    " it probably needs to stay focused at least a short time for Nvim to bother to draw it
endfu

fu s:wipe_border_when_closing(border, text) abort "{{{1
    augroup wipe_border
        exe 'au! * <buffer='..a:text..'>'
        exe 'au BufHidden,BufWipeout <buffer='..a:text..'> '
            \ ..'exe "au! wipe_border * <buffer>" | bw! '..a:border
    augroup END
endfu

fu s:get_border(width, height) abort "{{{1
    let [t, r, b, l, tl, tr, br, bl] = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
    let top = tl..repeat(t, a:width - 2)..tr
    let mid = l..repeat(' ', a:width - 2)..r
    let bot = bl..repeat(b, a:width - 2)..br
    let border = [top] + repeat([mid], a:height - 2) + [bot]
    return border
endfu
