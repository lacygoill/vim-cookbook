if exists('g:loaded_cookbook')
    finish
endif
let g:loaded_cookbook = 1

com -bar -nargs=* -complete=custom,cookbook#complete Cookbook call cookbook#main(<q-args>)
