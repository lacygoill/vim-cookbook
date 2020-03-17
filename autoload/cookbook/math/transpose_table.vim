fu cookbook#math#transpose_table#main() abort "{{{1
    " Purpose: convert lists of identical size, forming a table, into the list of columns of the latter.{{{
    "
    " You can imagine the lists piled up, forming a table.
    " The function should return a single list of lists, whose items are the
    " columns of this table.
    " This is similar to what is called, in math, a transposition:
    " https://en.wikipedia.org/wiki/Transpose
    "
    " That is, reading  the lines in a  transposed table is the  same as reading
    " the columns in the original one.
    "}}}
    let lists = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    let msg = printf("the transposition of:\n    %s\nis:\n    %s", lists, call('s:transpose_table', lists))
    call cookbook#notify(msg, {'time': 5000})
endfu

fu s:transpose_table(...) abort
    " handle special case where only 1 list was received (instead of 2)
    if a:0 == 1
        return map(range(len(a:1)), {i -> [a:1[i]]})
    endif

    " Check that all the arguments are lists and have the same size.
    let size = len(a:1)
    for list in a:000
        if type(list) != type([]) || len(list) != size
            return -1
        endif
    endfor

    " Initialize a list of empty lists (whose number is `size`).{{{
    "
    " We can't use `repeat()`:
    "
    "     repeat([[]], size)
    "
    " ... doesn't work as expected.
    " So we create a list of numbers with the same size (`range(size)`),
    " and then converts each number into `[]`.
    "}}}
    let transposed = map(range(size), '[]')

    " First, iterate over lines (there're `a:0` lines), then over columns (there're `size` columns).{{{
    "
    " With these nested for loops, we can reach any cell in the table.
    " `a:000[i][j]` is the cell of coords `[i,j]`.
    "
    " Imagine the upper-left corner is the origin of a coordinate system,
    "
    "     x axis goes down  = lines
    "     y axis goes right = columns
    "
    " The cell of coords `[i, j]` must be added to a list of `transposed`. Which one?
    " Well, it's in the `j`-th column, so it must be added to the `j`-th list.
    "}}}
    for i in range(a:0)
        for j in range(size)
            call add(transposed[j], a:000[i][j])
        endfor
    endfor

    return transposed
endfu

