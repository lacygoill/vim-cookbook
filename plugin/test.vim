" if exists('g:test_lua_loaded')
    finish
" endif
let g:test_lua_loaded = 1

com TestLuaRequireExample call test#replace_lines()
com TestLuaOpenWin call test#open_win()
