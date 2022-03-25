" This file only contains settings for nvim.
" The vimrc for vim will source this file and add vim related options.

" =======
" Plugins
" =======

call plug#begin('~/.local/share/nvim/plugged')
" Color schemes
" Plug 'altercation/vim-colors-solarized'
" Filetypes
Plug 'slim-template/vim-slim'
Plug 'rust-lang/rust.vim'
Plug 'cakebaker/scss-syntax.vim'
Plug 'kchmck/vim-coffee-script'
Plug 'rhysd/vim-crystal'
Plug 'elixir-editors/vim-elixir'
Plug 'dag/vim-fish'
Plug 'lee-jon/vim-io'
Plug 'mityu/vim-applescript'
Plug 'elmcast/elm-vim'
Plug 'leafOfTree/vim-vue-plugin'
Plug 'digitaltoad/vim-pug'
" Snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
" Misc
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-afterimage'
Plug 'tpope/vim-repeat'
Plug 'michaeljsmith/vim-indent-object'
Plug 'easymotion/vim-easymotion'
Plug '/usr/local/opt/fzf'
call plug#end()

" ====
" Misc
" ====

" This nohidden avoids a bug when landing on a directory.
" Without it, it will open a [No Name] buffer and
" fuck up the first alternate buffer
set nohidden

set linebreak
set breakindent
set showmatch
set number
set guifont=Monaco:h24
set nofoldenable
set statusline=%.30F\ %y%=%l/%L
set timeoutlen=1000 ttimeoutlen=0
set scrolloff=5
set sidescrolloff=10
set clipboard^=unnamed
set list
set listchars=tab:▸\ ,trail:␠,nbsp:⎵
let g:vim_markdown_folding_disabled=1
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
hi! link netrwMarkFile Search

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

" ========
" Mappings
" ========

" Digraph
inoremap <C-k><C-k> <Esc>:help digraph-table<CR>

" Autoclosings
inoremap '' ''<Left>
inoremap "" ""<Left>
inoremap [] []<Left>
inoremap [<CR> [<CR>]<Esc>O
inoremap [' ['']<Left><Left>
inoremap [: [:]<Left>
inoremap {<Space> {<Space><Space>}<Left><Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap {{<Space> {{<Space><Space>}}<Left><Left><Left>
inoremap () ()<Left>
inoremap (<CR> (<CR>)<Esc>O
inoremap <> <><Left>
inoremap </ </><Left>
inoremap `` ``<Left>
inoremap ``` ```<Esc>yyPA
inoremap /*<Space> /*<Space><Space>*/<Left><Left><Left>
inoremap /*<CR> /*<CR>*/<Esc>O

" Save
nnoremap ss :w<CR>
vnoremap ss <Esc>:w<CR>
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
vnoremap <C-h> <gv
vnoremap <C-l> >gv

" C-L clears but also removes search highlight
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

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

" Search with magic on
nnoremap / /\v

" Center when searching
nnoremap n nzz

" Change dashes to underscores on current word
inoremap <C-t> <esc>viW:s/-/_/g<CR>gv<esc>a

" Make current word uppercase (for constants)
inoremap <C-u> <esc>gUiwEa

" Switch absolute/relative line number
nnoremap <C-n> :set relativenumber!<CR>

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
" Minitest
nnoremap <leader>mt :vsplit term://bundle exec ruby -Ilib:test % --pride<CR>
" Plug
nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>pu :PlugUpdate<CR>
nnoremap <leader>ps :PlugStatus<CR>
nnoremap <leader>pc :PlugClean!<CR>

" =================
" Fix muscle memory
" =================

nnoremap <leader>q<CR> :echo "Use [leader]qq instead."<CR>
nnoremap <leader>e.<CR> :echo "Do not type enter after this leader mapping"<CR>
nnoremap <C-P> :echo "Use fzf with [leader]ff instead"<CR>

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
  " Show insert mode without cursor change
  " Avoids osx+tmux+nvim cursor change hell
  autocmd InsertEnter * hi StatusLine term=reverse cterm=reverse gui=reverse ctermfg=DarkBlue guifg=DarkBlue
  autocmd InsertLeave * hi StatusLine term=reverse cterm=reverse gui=reverse ctermfg=Cyan guifg=Cyan
augroup END

" ============
" Color Scheme
" ============

set background=dark
" colorscheme solarized
" Fix IncSearch because solarized started to change the style 
" of the first search result
hi IncSearch term=reverse cterm=reverse gui=reverse ctermfg=Yellow guifg=Yellow

" ============================
" Change cursor on insert mode
" ============================

" let $NVIM_TUI_ENABLE_TRUE_COLOR=1
" let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

