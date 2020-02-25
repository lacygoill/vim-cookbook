fu test#replace_lines() abort
    " replace each line in the buffer with a sentence describing the number of characters it contained
    " Inspiration: `:h lua-require-example`.
    " What is the purpose of{{{
    "}}}
    "   `require()`?{{{
    "
    " It tells  `luaeval()` to look  into the  `substitute` module which  can be
    " found in a `lua/substitute.lua` file in any directory of the rtp.
    "}}}
    "  `.field()`?{{{
    "
    " It tells `luaeval()` to get the `new_lines` field of the `substitute` module.
    "}}}
    "   `unpack()`?{{{
    "
    " It tells `luaeval()` to unpack its optional list of arguments (2nd argument),
    " before passing them to the function assigned to the `new_lines` field.
    "}}}
    "   `_A`?{{{
    "
    " It refers to the second optional argument of `luaeval()`.
    " The latter is always a list.
    " Here, it contains these 2 VimL expressions:
    "
    "    - `'there were %d characters on this line'`
    "    - `getline(1, '$')`
    "}}}
    call setline(1, luaeval(
        \ 'require("substitute").new_lines(unpack(_A))',
        \ ['there were %d characters on this line', getline(1, '$')]))
endfu

fu test#open_win()
    " Inspiration: `:h nvim_open_win`.
    call luaeval('require("open_win")')
endfu

