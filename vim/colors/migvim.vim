" Just my own color scheme
" Meant to work with Atom's One color scheme, dark or light.
" But mainly dark since it is my setup.

highlight clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name="migvim"

set background=dark
set notermguicolors

" 0: Black    8: Bright Black
" 1: Red      9: Bright Red
" 2: Green    10: Bright Green
" 3: Yellow   11: Bright Yellow
" 4: Blue     12: Bright Blue
" 5: Magenta  13: Bright Magenta
" 6: Cyan     14: Bright Cyan
" 7: White    15: Bright White

" Primary highlighting groups

highlight Normal ctermfg=7
highlight Comment ctermfg=8
highlight Constant ctermfg=4
highlight Statement ctermfg=3
highlight Function ctermfg=2
highlight PreProc ctermfg=1
highlight String ctermfg=4
highlight Number ctermfg=4
highlight Type ctermfg=3
highlight Directory ctermfg=4
highlight Visual ctermfg=NONE ctermbg=NONE cterm=inverse
highlight Search ctermfg=0 ctermbg=11
highlight Special ctermfg=6

" Tabs

highlight TabLine cterm=NONE ctermfg=8 ctermbg=0
highlight TabLineFill cterm=NONE ctermfg=8 ctermbg=0
highlight TabLineSel cterm=NONE ctermfg=0 ctermbg=15

" Cursor

highlight CursorLine ctermfg=NONE ctermbg=NONE cterm=NONE
highlight Cursor ctermfg=0 ctermbg=7 cterm=NONE " Does not work, term is king
highlight CursorLineNr ctermfg=0 ctermbg=15 cterm=NONE

" Diff

highlight DiffAdd ctermfg=0 ctermbg=2
highlight DiffChange ctermfg=0 ctermbg=3
highlight DiffDelete ctermfg=0 ctermbg=1
highlight DiffText ctermfg=0 ctermbg=11 cterm=bold

" Filetype specific

highlight link htmlTag Comment
highlight link htmlEndTag Comment
highlight link htmlTagN Comment

highlight link cssBraces Comment

highlight link svelteBrace Comment

highlight link vueSurroundingTag Comment

highlight netrwExe ctermfg=2
highlight netrwClassify ctermfg=8

" Rest

" highlight Identifier cterm=NONE ctermfg=2
" highlight Keyword ctermfg=1
" highlight vimCommand ctermfg=5

" Links

highlight link diffRemoved DiffDelete
highlight link diffAdded DiffAdd

