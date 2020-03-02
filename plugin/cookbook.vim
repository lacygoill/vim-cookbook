if exists('g:loaded_cookbook')
    finish
endif
let g:loaded_cookbook = 1

" TODO: Without any argument, the command should populate the qfl with all the recipes.
" Use the 'module' property to replace the file paths with recipes names.
" And replace the text with a short description of the recipe.
" Include a 'desc' key in the recipes dictionary.

" TODO: Include a 'tag' key in the recipes dictionary.
" We could use it like so:
"
"     :CookBook -tag 'foo and bar'
"
" ... would display all recipes containing the tags 'foo' and 'bar'.
" In addition to `and`, we could use the operators `or` and `not` (just like `tmsu(1)`).
com -bar -complete=custom,cookbook#complete -nargs=+ -range=%
    \ Cookbook call cookbook#main(<q-args>, <line1>, <line2>)
