if exists('g:autoloaded_cookbook')
    finish
endif
let g:autoloaded_cookbook = 1

" Init {{{1

" TODO: To find a recipe among many, consider including a 'tag' key in the database.{{{
"
" We could use it like so:
"
"     :CookBook -tag 'foo and bar'
"
" This would display all recipes containing the tags 'foo' and 'bar'.
" In addition to `and`, we could use the operators `or` and `not` (just like `tmsu(1)`).
"}}}

const s:DB = {
    \ 'FzfBasic': {
    \     'env': '(n)vim',
    \     'sources': [{'func': 'cookbook#fzf#basic', 'path': 'autoload/cookbook/fzf.vim'}],
    \     'desc': 'filter some output via fzf',
    \ },
    \ 'FzfWithColors': {
    \     'env': '(n)vim',
    \     'sources': [{'func': 'cookbook#fzf#color', 'path': 'autoload/cookbook/fzf.vim'}],
    \     'desc': 'filter some output via fzf, coloring some part of it',
    \ },
    \ 'MathIsPrime': {
    \     'env': '(n)vim',
    \     'sources': [{'func': 'cookbook#math#is_prime', 'path': 'autoload/cookbook/math.vim'}],
    \     'desc': 'test whether a number is prime',
    \ },
    \ 'MathReadNumber': {
    \     'env': '(n)vim',
    \     'sources': [{'func': 'cookbook#math#read_number', 'path': 'autoload/cookbook/math.vim'}],
    \     'desc': 'read a numeric number in english words',
    \ },
    \ 'MathTransposeTable': {
    \     'env': '(n)vim',
    \     'sources': [{'func': 'cookbook#math#transpose_table', 'path': 'autoload/cookbook/math.vim'}],
    \     'desc': 'convert a list of lists, forming a table, as the list of columns of the latter',
    \ },
    \ 'LuaRequireExample': {
    \     'env': 'nvim',
    \     'sources': [
    \         {'func': 'cookbook#lua#substitute', 'path': 'autoload/cookbook/lua.vim'},
    \         {'func': 'compute', 'path': 'lua/substitute.lua'},
    \     ],
    \     'desc': 'invoke lua code from Vimscript',
    \ },
    \ 'LuaFloatWindowRelative': {
    \     'env': 'nvim',
    \     'sources': [
    \         {'func': 'cookbook#lua#float#window_relative#main', 'path': 'autoload/cookbook/lua/float/window_relative.vim'},
    \         {'func': 'main', 'path': 'lua/float/window_relative.lua'},
    \     ],
    \     'desc': 'create a floating window relative to the current window',
    \ },
    \ 'LuaFloatBufferRelative': {
    \     'env': 'nvim',
    \     'sources': [
    \         {'func': 'cookbook#lua#float#buffer_relative#main', 'path': 'autoload/cookbook/lua/float/buffer_relative.vim'},
    \         {'func': 'main', 'path': 'lua/float/buffer_relative.lua'},
    \     ],
    \     'desc': 'create a floating window relative to the current buffer',
    \ },
    \ }

const s:SFILE = expand('<sfile>:p')
const s:SROOTDIR = expand('<sfile>:p:h:h')

" Interface {{{1
fu cookbook#main(recipe) abort "{{{2
    if a:recipe is# ''
        return s:populate_qfl_with_recipes()
    elseif a:recipe is# '-check_db_integrity'
        return s:check_db_integrity()
    endif
    if s:is_invalid(a:recipe) | return | endif
    let sources = s:get_sources(a:recipe)
    call s:show_me_the_code(sources)
    let func = s:DB[a:recipe].sources[0].func
    try
        call s:running_code_failed(func)
    catch
        return lg#catch_error()
    endtry
endfu

fu cookbook#complete(_a, _l, _p) abort "{{{2
    return join(keys(s:DB) + ['-check_db_integrity'], "\n")
endfu
"}}}1
" Core {{{1
fu s:running_code_failed(func) abort "{{{2
    " TODO: Support languages other than Vim.{{{
    "
    " If your recipe is written in awk, there won't be any Vim function to invoke.
    " You'll probably just want to run  the script and see its result/output (in
    " a popup terminal?).
    "
    " ---
    "
    " Note that if you start writing recipes in other languages, an issue may arise;
    " you may have several recipes with the same name but for different languages.
    " To avoid a conflict, you may want to add a `lang` key at the root of `s:DB`.
    "
    " When asking `:CookBook`  for a recipe, you could specify  the language via
    " `-lang  foo`.  Without  the `-lang`  argument,  the plugin  would use  the
    " filetype of the current buffer.  If the latter has no filetype, the plugin
    " would fall back on the VimL language.
    "}}}
    try
        call call(a:func, [])
    catch /^Vim\%((\a\+)\)\=:E119:/
        echohl ErrorMsg
        echom v:exception
        echohl NONE
        return 1
    endtry
endfu

fu s:show_me_the_code(sources) abort "{{{2
    let i = 0 | for source in a:sources | let i += 1
        if s:is_already_displayed(source.path) | continue | endif
        if i == 1 && bufname('%') is# '' && line2byte(line('$')+1) <= 2
            let cmd = 'e'
        else
            let cmd = 'sp'
        endif
        exe cmd..' '..source.path
        if i == 1 | let first_win_open = winnr() | endif
        let func_pat = get({
            \ 'vim': 'fu\%[nction]!\=\s\+',
            \ 'nvim': 'fu\%[nction]!\=\s\+',
            \ '(n)vim': 'fu\%[nction]!\=\s\+',
            \ 'lua': 'local\s\+function\s\+',
            \ }, fnamemodify(source.path, ':e'), '')
        exe '/^\s*'..func_pat..source.func..'('
        norm! zMzv
    endfor
    if exists('first_win_open') | exe first_win_open..'wincmd w' | endif
endfu

fu s:populate_qfl_with_recipes() abort "{{{2
    let qfl = map(keys(s:DB), {_,v -> {
        \ 'bufnr': bufadd(s:SROOTDIR..'/'..s:DB[v].sources[0].path),
        \ 'module': v,
        \ 'text': s:DB[v].desc,
        \ 'pattern': s:DB[v].sources[0].func,
        \ }})
    call setqflist([], ' ', {'items': qfl, 'title': ':Cookbook'})
    cw
    if &bt isnot# 'quickfix' | return | endif
    call s:conceal_noise()
    augroup cookbook_conceal_noise
        au!
        au BufWinEnter <buffer> call s:conceal_noise()
    augroup END
    nno <buffer><nowait><silent> z<cr> :<c-u>call <sid>qf_run_recipe()<cr>
endfu

fu s:conceal_noise() abort "{{{2
    setl cocu=nc cole=3
    call matchadd('Conceal', '^.\{-}\zs|.\{-}|\ze\s*', 0, -1, {'conceal': 'x'})
endfu

fu s:qf_run_recipe() abort "{{{2
    let curwin = winnr()
    exe 'Cookbook '..matchstr(getline('.'), '\S\+')
    exe curwin..'close'
endfu

fu s:check_db_integrity() abort "{{{2
    let info = map(keys(s:DB),
        \ {_,v -> map(deepcopy(s:DB[v].sources),
        \     {_,w -> {'recipe': v, 'file': s:SROOTDIR..'/'..w.path, 'func': w.func}})})
    let flattened = []
    for i in info
        let flattened += i
    endfor
    call map(flattened, {_,v -> extend(v, {'filereadable': filereadable(v.file)})})
    call map(flattened, {_,v -> extend(v, {'funcdefined': v.filereadable && match(readfile(v.file), v.func) >= 0})})
    let problematic = filter(flattened, {_,v -> !v.filereadable || !v.funcdefined})
    if problematic == []
        echo 'the database is ok'
        return
    endif
    let report = []
    for entry in problematic
        if !entry.filereadable
            let report += [printf('%s: "%s" is not readable', entry.recipe, entry.file)]
        elseif !entry.funcdefined
            let report += [printf('%s: the function "%s" is not defined in "%s"', entry.recipe, entry.func, entry.file)]
        endif
    endfor
    new
    call setline(1, report)
endfu
"}}}1
" Util {{{1
fu cookbook#error(msg) abort "{{{2
    redraw
    echohl ErrorMsg
    echo a:msg
    echohl NONE
    return 1
endfu

fu s:is_invalid(recipe) abort "{{{2
    if !has_key(s:DB, a:recipe)
        return cookbook#util#error(a:recipe..' is not a known recipe')
    elseif s:DB[a:recipe].env is# 'vim' && has('nvim')
        return cookbook#util#error('this recipe only works in Vim')
    elseif s:DB[a:recipe].env is# 'nvim' && !has('nvim')
        return cookbook#util#error('this recipe only works in Neovim')
    endif
    return 0
endfu

fu s:get_sources(recipe) abort "{{{2
    let root = matchstr(s:SFILE, '^.\{-}\ze/autoload/')
    return map(deepcopy(s:DB[a:recipe].sources), {_,v -> extend(v, {'path': root..'/'..v.path})})
endfu

fu s:is_already_displayed(file) abort "{{{2
    let files_in_tab = map(tabpagebuflist(), {_,v -> fnamemodify(bufname(v), ':p')})
    return index(files_in_tab, a:file) != -1
endfu

