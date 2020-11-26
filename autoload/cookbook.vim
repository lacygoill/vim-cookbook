if exists('g:autoloaded_cookbook')
    finish
endif
let g:autoloaded_cookbook = 1

" Init {{{1

import Catch from 'lg.vim'
import Popup_notification from 'lg/popup.vim'

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
"
" ---
"
" Also,  this  lets   us  get  more  meaningful  recipes   when  tab  completing
" `:Cookbook`, or just when executing  the command without arguments to populate
" the qfl.
"}}}
const s:DB = {
    \ 'vim': {
    \     'FzfBasic': {
    \         'sources': [{'funcname': 'cookbook#fzf#basic', 'path': 'autoload/cookbook/fzf.vim', 'ft': 'vim'}],
    \         'desc': 'filter some output via fzf',
    \     },
    \     'FzfWithColors': {
    \         'sources': [{'funcname': 'cookbook#fzf#color', 'path': 'autoload/cookbook/fzf.vim', 'ft': 'vim'}],
    \         'desc': 'filter some output via fzf, coloring some part of it',
    \     },
    \     'MathIsPrime': {
    \         'sources': [{'funcname': 'cookbook#math#is_prime#main', 'path': 'autoload/cookbook/math/is_prime.vim', 'ft': 'vim'}],
    \         'desc': 'test whether a number is prime',
    \     },
    \     'MathReadNumber': {
    \         'sources': [{'funcname': 'cookbook#math#read_number#main', 'path': 'autoload/cookbook/math/read_number.vim', 'ft': 'vim'}],
    \         'desc': 'read a numeric number in english words',
    \     },
    \     'Permutations': {
    \         'sources': [{'funcname': 'cookbook#permutations#main', 'path': 'autoload/cookbook/permutations.vim', 'ft': 'vim'}],
    \         'desc': 'get all permutations of items in a list',
    \     },
    \     'PopupBasic': {
    \         'sources': [{'funcname': 'cookbook#popup#basic#main', 'path': 'autoload/cookbook/popup/basic.vim', 'ft': 'vim'}],
    \         'desc': 'create a basic popup',
    \     },
    \     'PopupBorder': {
    \         'sources': [{'funcname': 'cookbook#popup#border#main', 'path': 'autoload/cookbook/popup/border.vim', 'ft': 'vim'}],
    \         'desc': 'create a popup with border',
    \     },
    \     'PopupTerminal': {
    \         'sources': [{'funcname': 'cookbook#popup#terminal#main', 'path': 'autoload/cookbook/popup/terminal.vim', 'ft': 'vim'}],
    \         'desc': 'create a popup terminal',
    \     },
    \ },
    \ 'git': {
    \     'BisectWithScript': {
    \         'sources': [
    \             {'funcname': '', 'path': 'autoload/cookbook/git/bisect/bisect', 'ft': 'sh'},
    \             {'funcname': '', 'path': 'autoload/cookbook/git/bisect/bisect.vim', 'ft': 'vim'},
    \         ],
    \         'desc': 'bisect a commit automatically using a shell script',
    \     },
    \ },
    \ }
let s:_ = keys(s:DB)->map({_, v -> {v : keys(s:DB[v])}})
let s:RECIPES = {} | call map(s:_, {_, v -> extend(s:RECIPES, v)}) | lockvar! s:RECIPES
unlet! s:_

const s:SFILE = expand('<sfile>:p')
const s:SROOTDIR = expand('<sfile>:p:h:h')

" Interface {{{1
fu cookbook#main(args) abort "{{{2
    let lang = s:get_curlang(a:args)
    let recipe = s:get_recipe(a:args)
    if recipe == ''
        return s:populate_qfl_with_recipes(lang)
    elseif recipe is# '-check_db'
        return s:check_db()
    endif
    if s:is_invalid(recipe, lang) | return | endif
    let sources = s:get_sources(recipe, lang)
    call s:show_me_the_code(sources)
    " TODO: Support languages other than Vim.{{{
    "
    " If your recipe is written in awk, there won't be any Vim function to invoke.
    " You'll probably just want to run  the script and see its result/output (in
    " a popup terminal?).
    "}}}
    if lang isnot# 'vim' | return | endif
    let funcname = s:DB[lang][recipe].sources[0].funcname
    try
        call s:running_code_failed(funcname)
    catch
        return s:Catch()
    endtry
endfu

fu cookbook#complete(arglead, cmdline, pos) abort "{{{2
    let from_dash_to_cursor = matchstr(a:cmdline, '.*\s\zs-.*\%' .. (a:pos + 1) .. 'c')
    if from_dash_to_cursor =~# '\C^-lang\s*\S*$'
        return keys(s:DB)->join("\n")
    elseif a:arglead[0] is# '-'
        let options = ['-check_db', '-lang']
        return join(options, "\n")
    else
        let curlang = s:get_curlang(a:cmdline)
        let matches = get(s:RECIPES, curlang, [])
        return join(matches, "\n")
    endif
endfu
"}}}1
" Core {{{1
fu s:running_code_failed(funcname) abort "{{{2
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
        if i == 1 && bufname('%') == '' && (line('$') + 1)->line2byte() <= 2
            let cmd = 'e'
        else
            let cmd = 'sp'
        endif
        exe cmd .. ' ' .. source.path
        if i == 1 | let first_win_open = winnr() | endif
        if source.funcname != ''
            let func_pat = s:get_func_pat(source.funcname, source.ft)
            try
                exe '/' .. func_pat
            catch /^Vim\%((\a\+)\)\=:E486:/
                return s:Catch()
            endtry
        endif
        norm! zMzv
    endfor
    if exists('first_win_open') | exe first_win_open .. 'wincmd w' | endif
endfu

fu s:populate_qfl_with_recipes(lang) abort "{{{2
    let items = deepcopy(s:RECIPES[a:lang])->map({_, v -> {
        \ 'bufnr': bufadd(s:SROOTDIR .. '/' .. s:DB[a:lang][v].sources[0].path),
        \ 'module': v,
        \ 'pattern': s:DB[a:lang][v].sources[0].funcname,
        \ 'text': s:DB[a:lang][v].desc,
        \ }})
    call setqflist([], ' ', {
        \ 'items': items,
        \ 'title': ':Cookbook -lang ' .. a:lang,
        \ 'quickfixtextfunc': {-> []},
        \ })
    cw
    if &bt isnot# 'quickfix' | return | endif
    call s:conceal_noise()
    let s:qfid = get(s:, 'qfid', []) + [getqflist({'id': 0})]
    augroup cookbook_conceal_noise | au!
        " Why do you inspect the qf id?  Isn't `<buffer>` enough?{{{
        "
        " Since 8.1.0877,  Vim re-uses the  *same* quickfix buffer every  time a
        " quickfix window is opened.  Obviously,  the contents might be updated,
        " but the number stays the same.
        "
        " We  need to  *also* inspect  the quickfix  id; otherwise,  the conceal
        " could be re-applied to a new qf window displaying a different qfl.
        "}}}
        au BufWinEnter <buffer> if index(s:qfid, getqflist({'id': 0})) >= 0 | call s:conceal_noise() | endif
    augroup END
    nno <buffer><nowait> <cr> <cmd>call <sid>qf_run_recipe()<cr>
endfu

fu s:conceal_noise() abort "{{{2
    setl cocu=nc cole=3
    call matchadd('Conceal', '^.\{-}\zs|.\{-}|\ze\s*', 0, -1, #{conceal: 'x'})
endfu

fu s:qf_run_recipe() abort "{{{2
    " The recipe name should not include two consecutive bars resulting from an empty middle field.{{{
    "
    " When pressing Enter on an entry, they  would cause the current line in the
    " file we've jumped to be printed, which is distracting.
    "}}}
    let recipe = getline('.')->matchstr('[^ |]*')
    close
    let title = getqflist({'title': 0}).title
    let cmd = title .. ' ' .. recipe
    exe cmd
endfu

fu s:check_db() abort "{{{2
    let report = []
    " iterate over languages
    for l in keys(s:RECIPES)
        let report += [l]
        " iterate over recipes in a given language
        for r in s:RECIPES[l]
            " iterate over source files of a given recipe
            for s in s:DB[l][r].sources
                let file = s:SROOTDIR .. '/' .. s.path
                if !filereadable(file)
                    let report += [printf('    %s: "%s" is not readable', r, file)]
                else
                    if s.funcname == '' | continue | endif
                    let func_pat = s:get_func_pat(s.funcname, s.ft)
                    if readfile(file)->match(func_pat) == -1
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
        return cookbook#error(a:recipe .. ' is not a known recipe')
    endif
    return 0
endfu

fu s:get_curlang(args) abort "{{{2
    if a:args =~# '\C\%(^\|\s\)-lang\s'
        return matchstr(a:args, '-lang\s\+\zs\S\+')
    elseif &ft != '' && has_key(s:RECIPES, &ft)
        return &ft
    else
        return 'vim'
    endif
endfu

fu s:get_recipe(recipe) abort "{{{2
    return substitute(a:recipe, '-lang\s\+\S\+\s*', '', '')
endfu

fu s:get_sources(recipe, lang) abort "{{{2
    let root = matchstr(s:SFILE, '^.\{-}\ze/autoload/')
    return deepcopy(s:DB[a:lang][a:recipe].sources)
        \ ->map({_, v -> extend(v, {'path': root .. '/' .. v.path, 'ft': v.ft})})
endfu

fu s:get_func_pat(funcname, ft) abort "{{{2
    let kwd = get({
        \ 'vim': 'fu\%[nction]!\=\|def!\=',
        \ 'lua': 'local\s\+function',
        \ 'sh': '',
        \ }, a:ft, '')
    return '^\s*' .. kwd .. (kwd == '' ? '\s*' : '\s\+') .. a:funcname .. '('
endfu

fu s:is_already_displayed(file) abort "{{{2
    let files_in_tab = tabpagebuflist()->map({_, v -> bufname(v)->fnamemodify(':p')})
    return index(files_in_tab, a:file) != -1
endfu

fu cookbook#notify(msg, ...) abort "{{{2
    try
        call call('s:Popup_notification', [a:msg] + a:000)
    catch /^Vim\%((\a\+)\)\=:E117:/
        call cookbook#error('need s:Popup_notification(); install vim-lg-lib')
    endtry
endfu

