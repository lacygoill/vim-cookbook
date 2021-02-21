vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Init {{{1

import Catch from 'lg.vim'
import Popup_notification from 'lg/popup.vim'

# TODO: To find a recipe among many, consider including a 'tag' key in the database.{{{
#
# We could use it like so:
#
#     :CookBook -tag 'foo and bar'
#
# This would display all recipes containing the tags 'foo' and 'bar'.
# In addition to `and`, we could use the operators `or` and `not` (just like `tmsu(1)`).
#}}}

# Why do you put a filetype name at the root of the database?{{{
#
# It's not a filetype; it's the name of a language.
#
# This should allow us to use the same name for a recipe written in different languages.
# For example, you could write an `IsPrime` recipe in `vim`, `python` and `lua`.
# Without the name of a language at the root of the db, there would be a conflict.
#
# Note that  a single  recipe may  be implemented via  several files  written in
# different  languages.  When  you add  a recipe  to the  db, put  it under  the
# language in which its interface is written.
#
# ---
#
# Also,  this  lets   us  get  more  meaningful  recipes   when  tab  completing
# `:Cookbook`, or just when executing  the command without arguments to populate
# the qfl.
#}}}
const DB: dict<dict<dict<any>>> = {
    vim: {
        FzfBasic: {
            sources: [{
                funcname: 'cookbook#fzf#basic',
                path: 'autoload/cookbook/fzf.vim',
                ft: 'vim'
                }],
            desc: 'filter some output via fzf',
        },
        FzfWithColors: {
            sources: [{
                funcname: 'cookbook#fzf#color',
                path: 'autoload/cookbook/fzf.vim',
                ft: 'vim'
                }],
            desc: 'filter some output via fzf, coloring some part of it',
        },
        MathIsPrime: {
            sources: [{
                funcname: 'cookbook#math#is_prime#main',
                path: 'autoload/cookbook/math/is_prime.vim',
                ft: 'vim'
                }],
            desc: 'test whether a number is prime',
        },
        MathReadNumber: {
            sources: [{
                funcname: 'cookbook#math#read_number#main',
                path: 'autoload/cookbook/math/read_number.vim',
                ft: 'vim'
                }],
            desc: 'read a numeric number in english words',
        },
        Permutations: {
            sources: [{
                funcname: 'cookbook#permutations#main',
                path: 'autoload/cookbook/permutations.vim',
                ft: 'vim'
                }],
            desc: 'get all permutations of items in a list',
        },
        PopupBasic: {
            sources: [{
                funcname: 'cookbook#popup#basic#main',
                path: 'autoload/cookbook/popup/basic.vim',
                ft: 'vim'
                }],
            desc: 'create a basic popup',
        },
        PopupBorder: {
            sources: [{
                funcname: 'cookbook#popup#border#main',
                path: 'autoload/cookbook/popup/border.vim',
                ft: 'vim'
                }],
            desc: 'create a popup with border',
        },
        PopupTerminal: {
            sources: [{
                funcname: 'cookbook#popup#terminal#main',
                path: 'autoload/cookbook/popup/terminal.vim',
                ft: 'vim'
                }],
            desc: 'create a popup terminal',
        },
        VirtualText: {
            sources: [{
                funcname: 'cookbook#virtualtext#main',
                path: 'autoload/cookbook/virtualtext.vim',
                ft: 'vim'
                }],
            desc: 'emulate a trailing "virtual" text at the end of a "real" line of text',
        },
    },
    git: {
        BisectWithScript: {
            sources: [{
                funcname: '',
                path: 'autoload/cookbook/git/bisect/bisect',
                ft: 'sh'
                }, {
                funcname: '',
                path: 'autoload/cookbook/git/bisect/bisect.vim',
                ft: 'vim'
                }],
            desc: 'bisect a commit automatically using a shell script',
        },
    },
    }

var recipes_per_lang: list<dict<list<string>>> = keys(DB)
    ->mapnew((_, v: string): dict<list<string>> => ({[v]: keys(DB[v])}))
var RECIPES: dict<list<string>> = {}
recipes_per_lang
    ->map((_, v: dict<list<string>>): dict<list<string>> => extend(RECIPES, v))
lockvar! RECIPES

const SFILE: string = expand('<sfile>:p')
const SROOTDIR: string = expand('<sfile>:p:h:h')

# Interface {{{1
def cookbook#main(args: string) #{{{2
    var lang: string = GetCurlang(args)
    var recipe: string = GetRecipe(args)
    if recipe == ''
        PopulateQflWithRecipes(lang)
        return
    elseif recipe == '-check_db'
        CheckDb()
        return
    endif
    if IsInvalid(recipe, lang)
        return
    endif
    var sources: list<dict<string>> = GetSources(recipe, lang)
    ShowMeTheCode(sources)
    # TODO: Support languages other than Vim.{{{
    #
    # If your recipe is written in awk, there won't be any Vim function to invoke.
    # You'll probably just want to run  the script and see its result/output (in
    # a popup terminal?).
    #}}}
    if lang != 'vim'
        return
    endif
    var funcname: string = DB[lang][recipe].sources[0].funcname
    try
        call(funcname, [])
    catch /^Vim\%((\a\+)\)\=:E119:/
        Catch()
        return
    endtry
enddef

def cookbook#complete(arglead: string, cmdline: string, pos: number): string #{{{2
    var from_dash_to_cursor: string = matchstr(cmdline,
        '.*\s\zs-.*\%' .. (pos + 1) .. 'c')
    if from_dash_to_cursor =~ '\C^-lang\s*\S*$'
        return keys(DB)->join("\n")
    elseif arglead[0] == '-'
        var options: list<string> = ['-check_db', '-lang']
        return join(options, "\n")
    else
        var curlang: string = GetCurlang(cmdline)
        var matches: list<string> = get(RECIPES, curlang, [])
        return join(matches, "\n")
    endif
enddef

def cookbook#error(msg: string): bool #{{{2
    redraw
    echohl ErrorMsg
    echom msg
    echohl NONE
    return true
enddef

def cookbook#notify(msg: string, opts: dict<number> = {}) #{{{2
    try
        call('Popup_notification', [msg, opts])
    catch /^Vim\%((\a\+)\)\=:E117:/
        cookbook#error('need Popup_notification(); install vim-lg-lib')
    endtry
enddef
#}}}1
# Core {{{1
def ShowMeTheCode(sources: list<any>) #{{{2
    var first_win_open: number
    var i: number = 0 | for source in sources | i += 1
        if IsAlreadyDisplayed(source.path)
            continue
        endif
        var cmd: string
        if i == 1 && bufname('%') == '' && (line('$') + 1)->line2byte() <= 2
            cmd = 'e'
        else
            cmd = 'sp'
        endif
        exe cmd .. ' ' .. source.path
        if i == 1
            first_win_open = winnr()
        endif
        if source.funcname != ''
            var func_pat: string = GetFuncPat(source.funcname, source.ft)
            try
                exe ':/' .. func_pat
            catch /^Vim\%((\a\+)\)\=:E486:/
                Catch()
                return
            endtry
        endif
        norm! zMzv
    endfor
    if first_win_open != 0
        exe ':' .. first_win_open .. 'wincmd w'
    endif
enddef

def PopulateQflWithRecipes(lang: string) #{{{2
    var items: list<dict<any>> = RECIPES[lang]
        ->mapnew((_, v: string): dict<any> => ({
            bufnr: bufadd(SROOTDIR .. '/' .. DB[lang][v].sources[0].path),
            module: v,
            pattern: DB[lang][v].sources[0].funcname,
            text: DB[lang][v].desc,
            }))
    setqflist([], ' ', {
        items: items,
        title: ':Cookbook -lang ' .. lang,
        quickfixtextfunc: () => [],
        })
    cw
    if &bt != 'quickfix'
        return
    endif
    ConcealNoise()
    qfid += [getqflist({id: 0})]
    augroup CookbookConcealNoise | au!
        # Why do you inspect the qf id?  Isn't `<buffer>` enough?{{{
        #
        # Since 8.1.0877,  Vim re-uses the  *same* quickfix buffer every  time a
        # quickfix window is opened.  Obviously,  the contents might be updated,
        # but the number stays the same.
        #
        # We  need to  *also* inspect  the quickfix  id; otherwise,  the conceal
        # could be re-applied to a new qf window displaying a different qfl.
        #}}}
        au BufWinEnter <buffer> if index(qfid, getqflist({id: 0})) >= 0
            |     ConcealNoise()
            |     InstallMapping()
            | endif
    augroup END
    nno <buffer><nowait> <cr> <cmd>call <sid>QfRunRecipe()<cr>
enddef
var qfid: list<dict<number>>

def ConcealNoise() #{{{2
    setl cocu=nc cole=3
    matchadd('Conceal', '^.\{-}\zs|.\{-}|\ze\s*', 0, -1, {conceal: 'x'})
enddef

def InstallMapping() #{{{2
    nno <buffer><nowait> <cr> <cmd>call <sid>QfRunRecipe()<cr>
enddef

def QfRunRecipe() #{{{2
    # The recipe name should not include two consecutive bars resulting from an empty middle field.{{{
    #
    # When pressing Enter on an entry, they  would cause the current line in the
    # file we've jumped to be printed, which is distracting.
    #}}}
    var recipe: string = getline('.')->matchstr('[^ |]*')
    close
    var title: string = getqflist({title: 0}).title
    var cmd: string = title .. ' ' .. recipe
    exe cmd
enddef

def CheckDb() #{{{2
    var report: list<string> = []
    # iterate over languages
    for l in keys(RECIPES)
        report += [l]
        # iterate over recipes in a given language
        for r in RECIPES[l]
            # iterate over source files of a given recipe
            for s in DB[l][r].sources
                var file: string = SROOTDIR .. '/' .. s.path
                if !filereadable(file)
                    report += [printf('    %s: "%s" is not readable', r, file)]
                else
                    if s.funcname == ''
                        continue
                    endif
                    var func_pat: string = GetFuncPat(s.funcname, s.ft)
                    if readfile(file)->match(func_pat) == -1
                        report += [printf('    %s: the function "%s" is not defined in "%s"', r, s.funcname, file)]
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
    setline(1, report)
enddef
#}}}1
# Util {{{1
def IsInvalid(recipe: string, lang: string): bool #{{{2
    if !(has_key(DB, lang) && has_key(DB[lang], recipe))
        return cookbook#error(recipe .. ' is not a known recipe')
    endif
    return false
enddef

def GetCurlang(args: string): string #{{{2
    if args =~ '\C\%(^\|\s\)-lang\s'
        return matchstr(args, '-lang\s\+\zs\S\+')
    elseif &ft != '' && has_key(RECIPES, &ft)
        return &ft
    else
        return 'vim'
    endif
enddef

def GetRecipe(recipe: string): string #{{{2
    return substitute(recipe, '-lang\s\+\S\+\s*', '', '')
enddef

def GetSources(recipe: string, lang: string): list<dict<string>> #{{{2
    var root: string = matchstr(SFILE, '^.\{-}\ze/autoload/')
    return DB[lang][recipe].sources
        ->deepcopy()
        ->map((_, v: dict<string>): dict<string> =>
            extend(v, {path: root .. '/' .. v.path, 'ft': v.ft})
            )
enddef

def GetFuncPat(funcname: string, ft: string): string #{{{2
    var kwd: string = get({
        vim: 'fu\%[nction]!\=\|def!\=',
        lua: 'local\s\+function',
        sh: '',
        }, ft, '')
    return '^\s*' .. kwd .. (kwd == '' ? '\s*' : '\s\+') .. funcname .. '('
enddef

def IsAlreadyDisplayed(file: string): bool #{{{2
    var files_in_tab: list<string> = tabpagebuflist()
        ->mapnew((_, v: number): string => bufname(v)->fnamemodify(':p'))
    return index(files_in_tab, file) >= 0
enddef

