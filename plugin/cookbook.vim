vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

command -bar -nargs=* -complete=custom,cookbook#complete Cookbook cookbook#main(<q-args>)
