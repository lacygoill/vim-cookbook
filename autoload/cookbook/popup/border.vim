def cookbook#popup#border#main()
    var what: list<string> = ['foo', 'bar', 'baz']
    var opts: dict<any> = {
        line: 5,
        col: 10,
        minwidth: 20,
        maxwidth: 20,
        minheight: 15,
        maxheight: 15,
        highlight: 'Visual',
        # if you don't set `borderhighlight`, Vim sets it for you with the value associated to `highlight`;
        # it must be set to a list of HGs (one per segment of the border);
        # it can be set to a list with only 1 HG name, in which case the latter is used for the 4 segments
        borderhighlight: ['WarningMsg'],
        # `border` must be set to a list of boolean flags;
        # each flag is associated to a segment (top, right, bottom, left);
        # 0 = do *not* draw the segment, 1 = draw the segment;
        # an empty list is equivalent to `[1, 1, 1, 1]`
        border: [],
        # `borderchars` must be set to a list of characters;
        # the first 4 characters are associated to a segment (top, right, bottom, left),
        # the last 4 characters are associated to a corner (top-left, top-right, bottom-right, bottom-left)
        borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        # it's aesthetically pleasing to have 2 padding columns on the left/right, but no padding lines above/below;
        # the padding is highlighted according to `highlight`, not `borderhighlight`
        padding: [0, 1, 0, 1],
    }
    popup_create(what, opts)
enddef

