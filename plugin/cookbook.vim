vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

com -bar -nargs=* -complete=custom,cookbook#complete Cookbook cookbook#main(<q-args>)
