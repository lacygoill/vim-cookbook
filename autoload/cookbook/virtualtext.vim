vim9

def cookbook#virtualtext#main()
    var lines: list<string> =<< trim END
        the quick brown
        fox jumps over
        the lazy dog
    END
    new
    lines->setline(1)

    var buf: number = bufnr('%')
    var lnum: number
    var col: number
    var word: string = 'jumps'
    [lnum, col] = searchpos(word)
    var length: number = strlen(word)
    prop_type_add('textprop', {bufnr: buf})
    prop_add(lnum, col, {
        type: 'textprop',
        length: length,
        bufnr: buf,
        })

    var left_padding: number = col([lnum, '$']) - length - col + 1
    var id: number = popup_create('attached to "jumps"', {
        textprop: 'textprop',
        highlight: 'ErrorMsg',
        line: -1,
        padding: [0, 0, 0, left_padding],
        mask: [[1, left_padding, 1, 1]],
        })
enddef

