if exists('g:autoloaded_cookbook')
    finish
endif
let g:autoloaded_cookbook = 1

" Init {{{1

" TODO: support other filetypes;
" the filetype could be passed as an argument;
" without an explicit filetype, inspect the filetype of the current buffer;
" fall back on Vim when the filetype is empty

" TODO: incorporate recipes from `vim-lg-lib`
const s:RECIPE2CMD = {
    \ 'MathReadNumber': {'funcname': 'math#read_number', 'args': 'all', 'env': 'both'},
    \ 'LuaRequireExample': {'funcname': 'lua#substitute', 'args': 'range', 'env': 'Nvim'},
    \ 'LuaFloatWindowRelative': {'funcname': 'lua#float#window_relative#main', 'args': '', 'env': 'Nvim'},
    \ 'LuaFloatBufferRelative': {'funcname': 'lua#float#buffer_relative#main', 'args': '', 'env': 'Nvim'},
    \ }

const s:SFILE = expand('<sfile>:p')

" Interface {{{1
fu cookbook#main(cmdargs, lnum1, lnum2) abort "{{{2
    let args = split(a:cmdargs)
    let recipe = args[0]
    if s:is_invalid(recipe) | return | endif
    let funcargs = len(args) > 1 ? args[1:] : []
    let funcargs = s:get_funcargs(
        \ recipe,
        \ a:lnum1, a:lnum2,
        \ funcargs
        \ )
    let funcname = 'cookbook#'..s:RECIPE2CMD[recipe].funcname
    if s:calling_function_failed(funcname, funcargs) | return | endif
    let sourcefiles = s:get_sourcefiles(funcname)
    call s:show_me_the_code(sourcefiles)
endfu

fu cookbook#complete(_a, _l, _p) abort "{{{2
    return join(keys(s:RECIPE2CMD), "\n")
endfu
"}}}1
" Core {{{1
fu s:calling_function_failed(funcname, funcargs) abort "{{{2
    try
        call call(a:funcname, a:funcargs)
    catch /^Vim\%((\a\+)\)\=:E119:/
        echohl ErrorMsg
        echom v:exception
        echohl NONE
        return 1
    endtry
endfu

fu s:show_me_the_code(sourcefiles) abort "{{{2
    for source in a:sourcefiles
        if s:is_already_displayed(source.path) | continue | endif
        exe 'sp '..source.path
        if source.lang is# 'vim'
            let pat = 'fu\%[nction]!\=\s\+'
        elseif source.lang is# 'lua'
            let pat = 'local\s\+function\s\+'
        else
            let pat = ''
        endif
        " FIXME: the cursor line is wrong in the Vim file;
        " it's somehow reset to the last line after the second split
        exe '/^\s*'..pat..source.func..'('
        norm! zMzv
    endfor
endfu
"}}}1
" Util {{{1
fu s:error(msg) abort "{{{2
    echohl ErrorMsg
    echo a:msg
    echohl NONE
    return 1
endfu

fu s:is_invalid(recipe) abort "{{{2
    if !has_key(s:RECIPE2CMD, a:recipe)
        return s:error(a:recipe..' is not a known recipe')
    elseif s:RECIPE2CMD[a:recipe].env is# 'Vim' && has('nvim')
        return s:error('this recipe only works in Vim')
    elseif s:RECIPE2CMD[a:recipe].env is# 'Nvim' && !has('nvim')
        return s:error('this recipe only works in Neovim')
    endif
    return 0
endfu

fu s:get_funcargs(recipe, lnum1, lnum2, funcargs) abort "{{{2
    let kind_of_args = s:RECIPE2CMD[a:recipe].args
    if kind_of_args is# ''
        let funcargs = []
    elseif kind_of_args is# 'range'
        let funcargs = [a:lnum1, a:lnum2]
    elseif kind_of_args is# 'all'
        let funcargs = a:funcargs
    endif
    return funcargs
endfu

fu s:get_sourcefiles(funcname) abort "{{{2
    let file = matchstr(s:SFILE, '^.\{-}/autoload/')
        \ ..substitute(matchstr(a:funcname, '^cookbook#.*\ze#'), '#', '/', 'g')..'.vim'
    let files = [{'path': file, 'lang': 'vim', 'func': a:funcname}]
    for lang in ['lua']
        if a:funcname =~# '^\Ccookbook#'..lang..'#'
            let file = matchstr(a:funcname, '^cookbook#\zs.*\ze#.*')
            let file = substitute(file, '#', '/', 'g')
            let files += [{'path': file..'.'..lang, 'lang': lang, 'func': matchstr(a:funcname, '.*#\zs.*')}]
        endif
    endfor
    return files
endfu

fu s:is_already_displayed(file) abort "{{{2
    let files_in_tab = map(tabpagebuflist(), {_,v -> fnamemodify(bufname(v), ':p')})
    return index(files_in_tab, a:file) != -1
endfu

