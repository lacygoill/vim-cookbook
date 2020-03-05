fu cookbook#lua#substitute() abort "{{{1
    " Purpose: replace each line in the buffer with a sentence describing the number of characters it contained
    " See: `:h lua-require-example`.
    let tempfile = tempname()
    exe 'sp '..tempfile..'.before'
    call setline(1, split('the quick brown fox jumps over the lazy dog'))
    let lines = getline(1, '$')
    exe 'vs '..tempfile..'.after'
    " What is the purpose of{{{
    "}}}
    "   `require()`?{{{
    "
    " It tells  `luaeval()` to look  into the  `substitute` module which  can be
    " found in a `lua/substitute.lua` file in any directory of the rtp.
    "}}}
    "  `.new_lines()`?{{{
    "
    " It tells `luaeval()` to get the `new_lines` field of the `substitute` module.
    "}}}
    "   `unpack()`?{{{
    "
    " It tells  `luaeval()` to unpack  the items  in its 2nd  optional argument,
    " before passing them to the function assigned to the `new_lines` field.
    "}}}
    "   `_A`?{{{
    "
    " It refers to the second optional argument of `luaeval()`.
    " Here, it's a list containing these 2 VimL expressions:
    "
    "    - the string `'there were %d characters on this line'`
    "    - the variable `lines` containing a list of strings
    "
    " It doesn't need to be a list though.
    " It can be a simple scalar too, like a string.
    " For an example, see `:h lua /Watch.*_A`:
    "
    "     command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")
    "                                                            ^^^^^^^^^^^^^^^^
    "}}}
    call setline(1, luaeval(
        \ 'require("substitute").new_lines(unpack(_A))',
        \ ['"%s" contains %d characters', lines]))
endfu

