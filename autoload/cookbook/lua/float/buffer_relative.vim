fu cookbook#lua#float#buffer_relative#main() abort
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

