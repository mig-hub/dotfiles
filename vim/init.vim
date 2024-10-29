" This file only contains settings for nvim.
" The vimrc for vim will source this file and add vim related options.

" =======
" Plugins
" =======

call plug#begin('~/.local/share/nvim/plugged')
" Color schemes
" Plug 'altercation/vim-colors-solarized'
Plug 'jeffkreeftmeijer/vim-dim'
" Filetypes
Plug 'sheerun/vim-polyglot'
Plug 'lee-jon/vim-io'
Plug 'Shougo/context_filetype.vim'
" Snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
Plug 'mattn/emmet-vim'
" Misc
Plug '/usr/local/opt/fzf'
Plug 'tomtom/tcomment_vim'
" Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-afterimage'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'mhinz/vim-signify'
Plug 'michaeljsmith/vim-indent-object'
Plug 'ap/vim-css-color'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-orgmode/orgmode'
Plug 'dhruvasagar/vim-table-mode'
Plug 'github/copilot.vim'
call plug#end()

" ============
" Color Scheme
" ============

set background=dark
colorscheme grim

" 0: Black    8: Bright Black
" 1: Red      9: Bright Red
" 2: Green    10: Bright Green
" 3: Yellow   11: Bright Yellow
" 4: Blue     12: Bright Blue
" 5: Magenta  13: Bright Magenta
" 6: Cyan     14: Bright Cyan
" 7: White    15: Bright White

highlight Identifier cterm=NONE ctermfg=2
highlight String ctermfg=4
highlight Number ctermfg=4
highlight Type ctermfg=3
highlight Keyword ctermfg=1
highlight PreProc ctermfg=1
highlight vimCommand ctermfg=5
highlight Statement ctermfg=3
highlight TabLine cterm=NONE ctermfg=0 ctermbg=8
highlight TabLineFill cterm=NONE ctermfg=0 ctermbg=8
highlight TabLineSel cterm=NONE ctermfg=0 ctermbg=15
highlight CursorLine cterm=NONE ctermbg=0
if &background == "dark"
  highlight Comment ctermfg=8
  highlight htmlTag ctermfg=8
  highlight htmlEndTag ctermfg=8
  highlight cssBraces ctermfg=8
  highlight netrwClassify ctermfg=8
  highlight CursorLineNr ctermfg=0 ctermbg=15 cterm=NONE
  highlight MatchParen ctermbg=0
else
  highlight Comment ctermfg=7
  highlight htmlTag ctermfg=7
  highlight htmlEndTag ctermfg=7
  highlight cssBraces ctermfg=7
  highlight netrwClassify ctermfg=7
  highlight CursorLineNr ctermfg=15 ctermbg=0 cterm=NONE
  highlight MatchParen ctermbg=15
end
highlight link diffRemoved DiffDelete
highlight link diffAdded DiffAdd

" augroup Colors
"   autocmd!
"   autocmd VimEnter,InsertLeave * highlight StatusLine cterm=reverse ctermfg=4 ctermbg=0
"   autocmd InsertEnter * highlight StatusLine cterm=reverse ctermfg=2 ctermbg=0
" augroup END

" highlight IncSearch ctermfg=11 ctermbg=0 cterm=reverse

" Use this to know the highlight group of the thing under the cursor:
" :SynStack

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

command! SynStack echo SynStack()

" Test colors with:
command! HiTest so $VIMRUNTIME/syntax/hitest.vim

" ====
" Misc
" ====

" This nohidden avoids a bug when landing on a directory.
" Without it, it will open a [No Name] buffer and
" fuck up the first alternate buffer
set nohidden

set cursorline
set linebreak
set breakindent
set showmatch
set number
set mouse=a
set nofoldenable
set timeoutlen=1000 ttimeoutlen=0
set scrolloff=999 " Large number keeps cursor in the middle
set sidescrolloff=10
set clipboard^=unnamed
set list
set listchars=tab:▸\ ,trail:␠,nbsp:⎵
set splitbelow
set splitright

" SnipMate
let g:snipMate = get( g:, 'snipMate', { 'snippet_version' : 1 } )
" Replace Tab because tab is used by Copilot
imap <C-J> <Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

" Markdown
let g:vim_markdown_folding_disabled=1

" Vue
let g:vue_pre_processors = ['pug', 'scss']
" This is not the plugin from polyglot
let g:vim_vue_plugin_config = { 
      \'syntax': {
      \   'template': ['html', 'pug'],
      \   'script': ['javascript'],
      \   'style': ['css', 'scss'],
      \},
      \'full_syntax': [],
      \'initial_indent': [],
      \'attribute': 0,
      \'keyword': 0,
      \'foldexpr': 0,
      \'debug': 0,
      \}

" Context filetype
if !exists('g:context_filetype#same_filetypes')
  let g:context_filetype#filetypes = {}
endif
let g:context_filetype#filetypes.svelte =
\ [
\   {'filetype' : 'javascript', 'start' : '<script>', 'end' : '</script>'},
\   {
\     'filetype': 'typescript',
\     'start': '<script\%( [^>]*\)\? \%(ts\|lang="\%(ts\|typescript\)"\)\%( [^>]*\)\?>',
\     'end': '',
\   },
\   {'filetype' : 'scss', 'start' : '<style>', 'end' : '</style>'},
\ ]
let g:ft = ''
" \   {'filetype' : 'css', 'start' : '<style \?.*>', 'end' : '</style>'},

" Github Copilot
let g:copilot_workspace_folders =
       \ ["~/work"]

" ==========
" Statusline
" ==========
"
set laststatus=2

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! GitStatusline()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

let s:latestmode = 'n'

function! RedrawStatusline(mode)
  " Not perfect but not bad.
  " It just wait for one move before changing color in visual mode.
  if a:mode == s:latestmode
    return ''
  else
    let s:latestmode = a:mode
  endif
  if a:mode == 'n'
    highlight StatusLine cterm=reverse ctermfg=4 ctermbg=0
  elseif a:mode == 'i'
    highlight StatusLine cterm=reverse ctermfg=2 ctermbg=0
  elseif a:mode == 'R'
    highlight StatusLine cterm=reverse ctermfg=5 ctermbg=0
  elseif a:mode == 'v' || a:mode == 'V' || a:mode == '^V'
    highlight StatusLine cterm=reverse ctermfg=3 ctermbg=0
  else
    highlight StatusLine cterm=reverse ctermfg=4 ctermbg=0
  endif
endfunction

set statusline=\ 
set statusline+=%.30f
set statusline+=%{GitStatusline()}
set statusline+=%=
set statusline+=%y
set statusline+=\ 
set statusline+=%l/%L
set statusline+=%{RedrawStatusline(mode())}

" =====
" Netrw
" =====

let g:netrw_sort_options = "i"
let g:netrw_sort_by = "name"
let g:netrw_sort_sequence = ""
let g:netrw_banner = 0
let g:netrw_localcopydircmd = 'cp -r'
let g:netrw_list_hide= '^\.\.\=/\=$,.DS_Store'
let g:netrw_hide = 1
highlight! link netrwMarkFile Search

function! NetrwMapping() " Mappings available inside netrw
  " Toggle hidden files
  nmap <buffer> . gh
  " Close preview window
  " p/P = open/close preview
  nmap <buffer> P <C-w>z
endfunction

augroup netrw_mapping " Activate netrw mappings
  autocmd!
  autocmd filetype netrw call NetrwMapping()
augroup END

" =======
" Orgmode
" =======

:lua require('setuporgmode')

" ===========
" Indentation
" ===========

set smartindent
set shiftwidth=2
set tabstop=2
set expandtab
augroup TabExceptions
  autocmd!
  autocmd FileType make setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType calendar setlocal noexpandtab
  autocmd FileType rust setlocal tabstop=4 shiftwidth=4
augroup END
let g:rust_recommended_style = 0
set foldmethod=indent

" ==============
" Search options
" ==============

set ignorecase
set smartcase
set path+=**

" =======================
" No backup or swap files
" =======================

set nobackup
set noswapfile

" =============
" Quickfix list
" =============
"
" A typical workflow is to use the `<leader>sg` to begin a search for a
" pattern: e.g. `... grep transform -t sass ...`. This will open a new tab,
" search and then open the quickfix list.
"
" From there you can navigate through matches and do what you want.
" Navigation is simplified with `]q`/`[q` mappings.
"
" But most of the time you will want to start a search and replace with
" `<leader>sr`. This will prepare the command and put you in place to populate
" the patterns: e.g. `... s/apple/pear/ce ...`. The default flags ask for
" confirmation on each match and ignore errors, but you can change these as
" well before running the command.
"
" ================================

" Use ripgrep as the default grep
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

" Show the quickfix window
nnoremap <Leader>co :copen<CR>
" Hide the quickfix window
nnoremap <Leader>cc :cclose<CR>
" Go to the previous location
nnoremap [q :cprev<CR>
" Go to the next location
nnoremap ]q :cnext<CR>

augroup quickfix_group
  autocmd!
  " Ensures qf can read its own error format
  autocmd FileType qf setlocal errorformat+=%f\|%l\ col\ %c\|%m
  autocmd FileType qf nnoremap <buffer> <Enter> :.cc<CR>
augroup END

" ========
" Mappings
" ========

" Autoclosings
inoremap [<CR> [<CR>]<Esc>O
inoremap {<CR> {<CR>}<Esc>O
inoremap (<CR> (<CR>)<Esc>O
inoremap /*<CR> /*<CR>*/<Esc>O

" Normal Mappings prefixed by `s`
" Save
nnoremap ss :w<CR>
vnoremap ss <Esc>:w<CR>

" Remove highlights when escaping with jk
inoremap <silent> jk <Esc>:nohlsearch<CR>

" Visual up/down
noremap j gj
noremap k gk
noremap gj j
noremap gk k
noremap <Down> j
noremap <Up> k

" Indenting
vnoremap < <gv
vnoremap > >gv

" Select line without indentation
nnoremap vv ^vg_

" Quick colon
nnoremap ; :
vnoremap ; :
" and use , instead of ;
nnoremap , ;
vnoremap , ;

" Break line
nnoremap <CR> i<CR><Esc>k$
nnoremap s ^f{%i<CR><Esc>k^f{wi<CR><Esc>^

" Previous tab
" This makes browsing tabs easy because R and T are next to each other.
" `gr` goes left `gt` goes right.
nnoremap gr gT
nnoremap H gT
nnoremap L gt

" Search with magic on
nnoremap / /\v

" Center when searching
nnoremap n nzz

" Change dashes to underscores on current word
inoremap <C-t> <esc>viW:s/-/_/g<CR>gv<esc>a

" Make current word uppercase (for constants)
inoremap <C-u> <esc>gUiwEa

" Example of how to use complete()
inoremap <C-j> <C-R>=ListMonths()<CR>
func ListMonths()
  call complete(col('.'), ['January', 'February', 'March',
  \ 'April', 'May', 'June', 'July', 'August', 'September',
  \ 'October', 'November', 'December'])
  return ''
endfunc

" Switch absolute/relative line number
nnoremap <C-n> :set relativenumber!<CR>

" Copilot mappings
inoremap <C-\> <Plug>(copilot-next)
inoremap <C-,> <Plug>(copilot-accept-word)
inoremap <C-;> <Plug>(copilot-accept-line)

" ===============
" Leader Mappings
" ===============

let mapleader = ' '
let maplocalleader = '\'

" Quickly edit vimrc
nnoremap <leader>ve :tabe $MYVIMRC<CR>
" Reload vimrc
nnoremap <leader>vr :so $MYVIMRC<CR>
" Select all
nnoremap <leader>a ggVG
" Add empty lines
nnoremap <leader><CR> o<Esc>k
" Quit
nnoremap <leader>qq :q<CR>
nnoremap <leader>qa :qa<CR>
" Fzf
set rtp+=/opt/homebrew/opt/fzf
nnoremap <leader>ff :FZF<CR>
" File Browse
nnoremap <leader>fb :e.<CR>
nnoremap <leader>e. :e.<CR>
nnoremap <leader>tn :tabe.<CR>
nnoremap <leader>tb :tabe.<CR>
nnoremap <leader>t. :tabe.<CR>
" Git/Fugitive
nnoremap <leader>gs :vertical G<CR>
nnoremap <leader>gpn :G push nas master<CR>
nnoremap <leader>gph :G push heroku master<CR>
nnoremap <leader>gpg :G push github master<CR>
nnoremap <leader>gpw :G push web master<CR>
nnoremap <leader>gpo :G push origin master<CR>
nnoremap <leader>gpa :G push admin master<CR>
nnoremap <leader>gps :G push staging master<CR>
" Git/GV - git log interactive
nnoremap <leader>gl :GV<CR>
" Minitest
nnoremap <leader>mt :vsplit term://bundle exec ruby -Ilib:test % --pride<CR>
" Plug
nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>pu :PlugUpdate<CR>
nnoremap <leader>ps :PlugStatus<CR>
nnoremap <leader>pc :PlugClean!<CR>
" Copilot
nnoremap <leader>cpp :Copilot panel<CR>
nnoremap <leader>cpe :Copilot enable<CR>
nnoremap <leader>cpd :Copilot disable<CR>

" =======
" Runtime
" =======

" load matchit
runtime macros/matchit.vim

" Filetypes
augroup RecognizeFiles
  autocmd!
  autocmd BufRead,BufNewFile *.ru setlocal filetype=ruby
  autocmd BufRead,BufNewFile Gemfile setlocal filetype=ruby
  autocmd BufRead,BufNewFile Brewfile setlocal filetype=ruby
  autocmd BufRead,BufNewFile *.Brewfile setlocal filetype=ruby
  autocmd BufRead,BufNewFile *.json setlocal filetype=javascript
  autocmd BufRead,BufNewFile *.muttrc setlocal filetype=muttrc
augroup END

" This avoid the skeleton creation and reads in general
" to mess up with the alternate file.
set cpoptions-=a

augroup Misc
  autocmd!
  " automatically reload init.vim when it's saved
  autocmd BufWritePost '~/.config/nvim/init.vim' source %
  " autocmd FileType css inoremap <buffer> :<Space> :<Space>;<Left>
  " autocmd FileType markdown setlocal textwidth=80 formatoptions=tacqw
  autocmd FileType markdown setlocal spell spelllang=en_us
  autocmd FileType slim setlocal nobreakindent
  autocmd BufNewFile *.vue silent! 0r ~/.dotfiles/skeletons/vue-pug-scss.vue
  autocmd BufNewFile *.url silent! 0r ~/.dotfiles/skeletons/default.url
  " autocmd BufNewFile *.svelte silent! 0r ~/.dotfiles/skeletons/default.svelte
  autocmd BufWritePre *.svelte call sveltekit#ImportAllComponents()
  " Hide matching parens in insert mode
  autocmd InsertEnter * NoMatchParen
  autocmd VimEnter,InsertLeave * DoMatchParen
augroup END

" ============================
" Change cursor on insert mode
" ============================

" let $NVIM_TUI_ENABLE_TRUE_COLOR=1
" let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

