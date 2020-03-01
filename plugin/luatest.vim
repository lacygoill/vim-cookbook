if exists('g:luatest_loaded') || !has('nvim')
    finish
endif
let g:luatest_loaded = 1

com -bar LuaTestRequireExample call luatest#substitute()
com -bar LuaTestFloatWindowRelative call luatest#float_window_relative()
com -bar LuaTestFloatBufferRelative call luatest#float_buffer_relative()
