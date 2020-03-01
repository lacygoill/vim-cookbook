fu cookbook#lua#substitute(lnum1, lnum2) abort "{{{1
    " Purpose: replace each line in the buffer with a sentence describing the number of characters it contained
    " See: `:h lua-require-example`.
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
    "    - `'there were %d characters on this line'`
    "    - `getline(1, '$')`
    "
    " It doesn't need to be a list though.
    " It can be a simple scalar too, like a string.
    " For an example, see `:h lua /Watch.*_A`:
    "
    "     command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")
    "                                                            ^^^^^^^^^^^^^^^^
    "}}}
    call setline(a:lnum1, luaeval(
        \ 'require("substitute").new_lines(unpack(_A))',
        \ ['there were %d characters on this line', getline(a:lnum1, a:lnum2)]))
endfu

fu cookbook#lua#float_window_relative() "{{{1
    " Purpose: open a window-relative float.{{{
    "
    " You can see such a float as being "attached" to a window position.
    " When you move the cursor, it never moves relative to the window.
    "}}}
    call luaeval('require("float/window_relative").main()')
endfu

fu cookbook#lua#float_buffer_relative() "{{{1
    " Purpose: open a buffer-relative float.{{{
    "
    " You can see such a float as being "attached" to a buffer position.
    " When you move the cursor, it may move relative to the window.
    "
    " In  theory, the  float should  not  move relative  to the  buffer; but  in
    " practice, it would  mean that it could become invisible  once you move too
    " far away from the text position where it's attached.
    "
    " To avoid that, the float never moves  above the topline of the window, nor
    " below its bottomline.  It's a design choice; but it implies that the float
    " does not always look like it's attached to the buffer.
    "}}}
    call luaeval('require("float/buffer_relative").main()')
endfu

