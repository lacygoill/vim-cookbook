fu cookbook#popup#basic#main() abort
    " `what` could also be set to:{{{
    "
    "    - a string
    "    - a buffer number
    "    - a list of text lines with text properties
    "}}}
    let what = ['foo', 'bar', 'baz']
    let opts = #{
        \ line: 5,
        \ col: 40,
        "\ the window's width is normally set to the number of characters on the longest line;
        "\ it can be increased with `minwidth`, and limited with `maxwidth`
        \ minwidth: 30,
        \ maxwidth: 30,
        "\ the window's height is normally set to the number of lines in the buffer;
        "\ it can be increased with `minheight`, and limited with `maxheight`
        \ minheight: 10,
        \ maxheight: 10,
        \ highlight: 'Visual',
        \ }
    call popup_create(what, opts)
endfu

