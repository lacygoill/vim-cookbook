fu cookbook#popup#with_border#main() abort
    let what = ['foo', 'bar', 'baz']
    let opts = #{
        \ line: 5,
        \ col: 40,
        \ minwidth: 30,
        \ maxwidth: 30,
        \ minheight: 10,
        \ maxheight: 10,
        "\ if you don't set `borderhighlight`, Vim sets it for you with the value associated to `highlight`
        \ highlight: 'Visual',
        \ border: [],
        \ borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ padding: [0,1,0,1],
        \ }
    call popup_create(what, opts)
endfu

