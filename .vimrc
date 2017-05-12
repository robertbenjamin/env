" *** SANE DEFAULTS ***
set nocompatible              " be iMproved, required
filetype off                  " required
set noshowmode                " hide the default mode indicator
set nobackup                  " remove tmp file backups
set noswapfile                " remove swap files
set nowb                      " prevent automatic write backup
set smartcase                 " only search by case if at least 1 letter is uppercase
set backspace=2               " delete over linebreaks and indentation
set ttyfast                   " faster vim

set mouse=a                   " allow mouse usage in all modes
set clipboard=unnamed         " copy/paste etc. work with system clipboard


" *** NO STATUS BAR ***
set noshowmode
set noruler
set laststatus=0
set noshowcmd


" *** VIM PLUG ***
call plug#begin('~/.vim/plugged')
Plug 'ajh17/VimCompletesMe'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'elixir-lang/vim-elixir', { 'for': 'elixir' }
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'tyrannicaltoucan/vim-deep-space'
Plug 'reedes/vim-colors-pencil'
call plug#end()


" *** VIM COMPLETES ME ***
set completeopt+=longest       " show first autocomplete item by default


" *** CTRLP ***
let g:ctrlp_custom_ignore='node_modules\|bower_components\|DS_Store\|tmp\|dist\|git'


" *** CUSTOMIZATION ***
" DEFAULT THEME
set background=light
colorscheme pencil
let g:pencil_higher_contrast_ui=1
set termguicolors
" DARK MODE
function Dark()
  colorscheme deep-space
  set background=dark
endfun
" LIGHT MODE
function Light()
  colorscheme pencil
  let g:pencil_higher_contrast_ui=1
  set background=light
endfun


abbreviate dac :call Dark()
abbreviate lic :call Light()


" *** MATCH ITERM COLOR ***
if $ITERM_PROFILE != ""
  if $ITERM_PROFILE =~ "(Dark)"
    :call Dark()
  else
    :call Light()
  end
end


set shiftwidth=2              " indent uses 2 spaces
set tabstop=2                 " show 2 spaces per tab
set softtabstop=2             " add 2 spaces when a tab is added
set autoindent                " automatically indents in files
set expandtab                 " turn tabs into spaces


set number                    " show number lines
filetype indent on            " load filetype specific indentation
set wildmenu                  " show visual autocomplete
set showmatch                 " highlight matching parens


set incsearch                 " search as characters are entered
set hlsearch                  " hightlight matches


" keep vim cursor in the middle of the screen
" move vertically by visual line (not actual line)
nnoremap j gjzz
nnoremap k gkzz
" set jk to escape
inoremap jk <esc>


set hidden
set history=100

autocmd BufWritePre * %s/\s\+$//e " remove trailing whitespace on save
