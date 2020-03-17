fu cookbook#float#basic#main() abort
    " you can't open a float without a buffer to display; create one
    let bufnr = nvim_create_buf(v:false, v:true)
    "                           │        │{{{
    "                           │        └ scratch buffer
    "                           └ don't list the buffer
    "}}}
    let lines = ['foo', 'bar', 'baz']
    " write the lines
    call nvim_buf_set_lines(bufnr, 0, -1, v:true, lines)
    "                              │   │  │{{{
    "                              │   │  └ consider an out-of-bound index as an error
    "                              │   └ up to the last line
    "                              └ from the first line in the buffer
    "}}}
    let opts = {
        "\ `row` and `col` are 0-indexed in Nvim;
        "\ so, 4 and 9 describe the cell on the 5th line and 10th column;
        "\ in Vim, the equivalent keys (`line` and `col`) are 1-indexed
        \ 'row': 5-1,
        \ 'col': 10-1,
        \ 'width': 20,
        \ 'height': 15,
        "\ we want `row` and `col` to describe the position of the upper-left corner of the float
        \ 'anchor': 'NW',
        "\ you probably don't want the float to be focusable
        \ 'focusable': v:false,
        "\ this key is necessary to make the window a float;
        "\ 'editor' means that `row` and `col` are counted from the upper-left screen cell of the editor
        \ 'relative': 'editor',
        "\ disable various visual features (`EndOfBuffer`, sign column, `'number'`, `'cursorline'`, ...)
        \ 'style': 'minimal',
        \ }
    let winid = nvim_open_win(bufnr, v:false, opts)
    "                                │{{{
    "                                └ don't focus the float on creation
    "
    " `v:true` would override `'focusable': v:false`;  but only on creation, not
    " afterward; i.e.  after focusing another window,  you would not be  able to
    " focus the float again, unless you used `nvim_set_current_win()`.
    "}}}

    " highlight the float as desired{{{
    "
    " This works by overriding the HG `NormalFloat` locally to the float.
    "}}}
    call nvim_win_set_option(winid, 'winhl', 'NormalFloat:Visual')
endfu

