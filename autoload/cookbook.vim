if exists('g:autoloaded_cookbook')
    finish
endif
let g:autoloaded_cookbook = 1

" Init {{{1

const s:RECIPE2CMD = {
    \ 'LuaRequireExample': {'funcname': 'lua#substitute', 'args': 'range', 'env': 'both'},
    \ 'LuaFloatWindowRelative': {'funcname': 'lua#float_window_relative', 'args': [], 'env': 'Nvim'},
    \ 'LuaFloatBufferRelative': {'funcname': 'lua#float_buffer_relative', 'args': [], 'env': 'Nvim'},
    \ }

" Interface {{{1
fu cookbook#main(recipe, lnum1, lnum2) abort "{{{2
    if !has_key(s:RECIPE2CMD, a:recipe)
        return s:error(a:recipe..' is not a known recipe')
    elseif s:RECIPE2CMD[a:recipe].env is# 'Vim' && has('nvim')
        return s:error('this recipe only works in Vim')
    elseif s:RECIPE2CMD[a:recipe].env is# 'Nvim' && !has('nvim')
        return s:error('this recipe only works in Neovim')
    endif
    let args = s:RECIPE2CMD[a:recipe].args
    if args is# 'range' | let args = [a:lnum1, a:lnum2] | endif
    call call('cookbook#'..s:RECIPE2CMD[a:recipe].funcname, args)
endfu

fu s:error(msg) abort
    echohl ErrorMsg
    echo a:msg
    echohl NONE
endfu

fu cookbook#complete(_a, _l, _p) abort "{{{2
    return join(keys(s:RECIPE2CMD), "\n")
endfu
