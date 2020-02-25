if exists('g:test_lua_loaded')
    finish
endif
let g:test_lua_loaded = 1

com TestLua call test#func()
