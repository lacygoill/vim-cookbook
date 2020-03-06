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

" Why do you put a filetype name at the root of the database?{{{
"
" It's not a filetype; it's the name of a language.
"
" This should allow us to use the same name for a recipe written in different languages.
" For example, you could write an `IsPrime` recipe in `vim`, `python` and `lua`.
" Without the name of a language at the root of the db, there would be a conflict.
"
" Note that  a single  recipe may  be implemented via  several files  written in
" different  languages.  When  you add  a recipe  to the  db, put  it under  the
" language in which its interface is written.
"}}}
const s:DB = {
    \ 'vim': {
    \     'FzfBasic': {
    \         'env': '(n)vim',
    \         'sources': [{'funcname': 'cookbook#fzf#basic', 'path': 'autoload/cookbook/fzf.vim', 'ft': 'vim'}],
    \         'desc': 'filter some output via fzf',
    \     },
    \     'FzfWithColors': {
    \         'env': '(n)vim',
    \         'sources': [{'funcname': 'cookbook#fzf#color', 'path': 'autoload/cookbook/fzf.vim', 'ft': 'vim'}],
    \         'desc': 'filter some output via fzf, coloring some part of it',
    \     },
    \     'MathIsPrime': {
    \         'env': '(n)vim',
    \         'sources': [{'funcname': 'cookbook#math#is_prime', 'path': 'autoload/cookbook/math.vim', 'ft': 'vim'}],
    \         'desc': 'test whether a number is prime',
    \     },
    \     'MathReadNumber': {
    \         'env': '(n)vim',
    \         'sources': [{'funcname': 'cookbook#math#read_number', 'path': 'autoload/cookbook/math.vim', 'ft': 'vim'}],
    \         'desc': 'read a numeric number in english words',
    \     },
    \     'MathTransposeTable': {
    \         'env': '(n)vim',
    \         'sources': [{'funcname': 'cookbook#math#transpose_table', 'path': 'autoload/cookbook/math.vim', 'ft': 'vim'}],
    \         'desc': 'convert a list of lists, forming a table, as the list of columns of the latter',
    \     },
    \     'RequireExampleLua': {
    \         'env': 'nvim',
    \         'sources': [
    \             {'funcname': 'cookbook#lua#substitute', 'path': 'autoload/cookbook/lua.vim', 'ft': 'vim'},
    \             {'funcname': 'compute', 'path': 'lua/substitute.lua', 'ft': 'lua'},
    \         ],
    \         'desc': 'invoke lua code from Vimscript',
    \     },
    \     'FloatWindowRelativeLua': {
    \         'env': 'nvim',
    \         'sources': [
    \             {'funcname': 'cookbook#lua#float#window_relative#main', 'path': 'autoload/cookbook/lua/float/window_relative.vim', 'ft': 'vim'},
    \             {'funcname': 'main', 'path': 'lua/float/window_relative.lua', 'ft': 'lua'},
    \         ],
    \         'desc': 'create a floating window relative to the current window',
    \     },
    \     'FloatBufferRelativeLua': {
    \         'env': 'nvim',
    \         'sources': [
    \             {'funcname': 'cookbook#lua#float#buffer_relative#main', 'path': 'autoload/cookbook/lua/float/buffer_relative.vim', 'ft': 'vim'},
    \             {'funcname': 'main', 'path': 'lua/float/buffer_relative.lua', 'ft': 'lua'},
    \         ],
    \         'desc': 'create a floating window relative to the current buffer',
    \     },
    \ },
    \ }
let s:_ = map(keys(s:DB), {_,v -> {v : keys(s:DB[v])}})
let s:RECIPES = {} | call map(s:_, {_,v -> extend(s:RECIPES, v)}) | lockvar! s:RECIPES
unlet s:_

const s:SFILE = expand('<sfile>:p')
const s:SROOTDIR = expand('<sfile>:p:h:h')

" Interface {{{1
fu cookbook#main(recipe) abort "{{{2
    if a:recipe is# ''
        return s:populate_qfl_with_recipes()
    elseif a:recipe is# '-check_db_integrity'
        return s:check_db_integrity()
    endif
    let lang = s:get_curlang()
    if s:is_invalid(a:recipe, lang) | return | endif
    let sources = s:get_sources(a:recipe, lang)
    call s:show_me_the_code(sources)
    let funcname = s:DB[lang][a:recipe].sources[0].funcname
    try
        call s:running_code_failed(funcname)
    catch
        return lg#catch_error()
    endtry
endfu

fu cookbook#complete(_a, _l, _p) abort "{{{2
    let matches = []
    let curlang = s:get_curlang()
    let matches = get(s:RECIPES, curlang, [])
    return join(matches + ['-check_db_integrity'], "\n")
endfu
"}}}1
" Core {{{1
fu s:running_code_failed(funcname) abort "{{{2
    " TODO: Support languages other than Vim.{{{
    "
    " If your recipe is written in awk, there won't be any Vim function to invoke.
    " You'll probably just want to run  the script and see its result/output (in
    " a popup terminal?).
    "}}}
    try
        call call(a:funcname, [])
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
        let func_pat = s:get_func_pat(source.funcname, source.ft)
        exe '/'..func_pat
        norm! zMzv
    endfor
    if exists('first_win_open') | exe first_win_open..'wincmd w' | endif
endfu

fu s:populate_qfl_with_recipes() abort "{{{2
    let lang = s:get_curlang()
    let qfl = map(deepcopy(s:RECIPES[lang]), {_,v -> {
        \ 'bufnr': bufadd(s:SROOTDIR..'/'..s:DB[lang][v].sources[0].path),
        \ 'module': v,
        \ 'text': s:DB[lang][v].desc,
        \ 'pattern': s:DB[lang][v].sources[0].funcname,
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
    let report = []
    " iterate over languages
    for l in keys(s:RECIPES)
        let report += [l]
        " iterate over recipes in a given language
        for r in s:RECIPES[l]
            " iterate over source files of a given recipe
            for s in s:DB[l][r].sources
                let file = s:SROOTDIR..'/'..s.path
                if !filereadable(file)
                    let report += [printf('    %s: "%s" is not readable', r, file)]
                else
                    let func_pat = s:get_func_pat(s.funcname, s.ft)
                    if match(readfile(file), func_pat) == -1
                        let report += [printf('    %s: the function "%s" is not defined in "%s"', r, s.funcname, file)]
                    endif
                endif
            endfor
        endfor
    endfor
    if match(report, 'is not') == -1
        echo 'the database is ok'
        return
    endif
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

fu s:is_invalid(recipe, lang) abort "{{{2
    if !(has_key(s:DB, a:lang) && has_key(s:DB[a:lang], a:recipe))
        return cookbook#error(a:recipe..' is not a known recipe')
    elseif s:DB[a:lang][a:recipe].env is# 'vim' && has('nvim')
        return cookbook#error('this recipe only works in Vim')
    elseif s:DB[a:lang][a:recipe].env is# 'nvim' && !has('nvim')
        return cookbook#error('this recipe only works in Neovim')
    endif
    return 0
endfu

fu s:get_curlang() abort "{{{2
    return &ft isnot# '' && has_key(s:RECIPES, &ft) ? &ft : 'vim'
endfu

fu s:get_sources(recipe, lang) abort "{{{2
    let root = matchstr(s:SFILE, '^.\{-}\ze/autoload/')
    return map(deepcopy(s:DB[a:lang][a:recipe].sources),
        \ {_,v -> extend(v, {'path': root..'/'..v.path, 'ft': v.ft})})
endfu

fu s:get_func_pat(funcname, ft) abort "{{{2
    return '^\s*'
        \ ..get({
        \     'vim': 'fu\%[nction]!\=',
        \     'nvim': 'fu\%[nction]!\=',
        \     '(n)vim': 'fu\%[nction]!\=',
        \     'lua': 'local\s\+function',
        \ }, a:ft, '')
        \ ..'\s\+'..a:funcname..'('
endfu

fu s:is_already_displayed(file) abort "{{{2
    let files_in_tab = map(tabpagebuflist(), {_,v -> fnamemodify(bufname(v), ':p')})
    return index(files_in_tab, a:file) != -1
endfu

