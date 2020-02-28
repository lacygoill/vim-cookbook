if exists('g:test_lua_loaded')
    finish
endif
let g:test_lua_loaded = 1

com TestLuaRequireExample call test#substitute()
com TestLuaFloatWindowRelative call test#float_window_relative()
com TestLuaFloatBufferRelative call test#float_buffer_relative()
