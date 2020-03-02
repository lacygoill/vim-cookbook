fu cookbook#lua#float#window_relative#main() abort
    " Purpose: open a window-relative float.{{{
    "
    " You can see such a float as being "attached" to a window position.
    " When you move the cursor, it never moves relative to the window.
    "}}}
    call luaeval('require("float/window_relative").main()')
endfu
