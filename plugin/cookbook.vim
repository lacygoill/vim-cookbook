if exists('g:loaded_cookbook')
    finish
endif
let g:loaded_cookbook = 1

com -bar -complete=custom,cookbook#complete -nargs=1 -range=% Cookbook call cookbook#main(<q-args>, <line1>, <line2>)
