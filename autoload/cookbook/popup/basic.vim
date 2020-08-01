fu cookbook#popup#basic#main() abort
    " `what` could also be set to:{{{
    "
    "    - a string
    "    - a buffer number
    "    - a list of text lines with text properties
    "}}}
    let what = ['foo', 'bar', 'baz']
    let opts = #{
        "\ position of the top-right corner (the tabline and the sign column are taken into account);
        "\ to check how the values are applied, enter tmux copy mode which lets you move the cursor anywhere
        \ line: 5,
        \ col: 10,
        "\ the window's width is normally set to the number of characters on the longest line;
        "\ it can be increased with `minwidth`, and limited with `maxwidth`
        \ minwidth: 20,
        \ maxwidth: 20,
        "\ the window's height is normally set to the number of lines in the buffer;
        "\ it can be increased with `minheight`, and limited with `maxheight`
        \ minheight: 15,
        \ maxheight: 15,
        \ highlight: 'Visual',
        \ }
    call popup_create(what, opts)
endfu

