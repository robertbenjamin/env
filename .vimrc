" *** SANE DEFAULTS ***
set nocompatible              " be iMproved, required
filetype off                  " required
set noshowmode                " hide the default mode indicator
set nobackup                  " remove tmp file backups
set noswapfile                " remove swap files
set nowb                      " prevent automatic write backup
set smartcase                 " only search by case if at least 1 letter is uppercase


" *** VIM PLUG ***
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'kien/ctrlp.vim'
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'elixir-lang/vim-elixir'
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'tyrannicaltoucan/vim-deep-space'
Plug 'reedes/vim-colors-pencil'
call plug#end()


" *** AIRLINE ***
let g:airline_section_c='%{getcwd()}/%t'
let g:airline_section_x=0    " disable tagbar, filetype, virtualenv section
let g:airline_section_y=0    " disable fileencoding, fileformat section
" let g:airline_section_z='%3pp %l:%c'


" *** CTRLP ***
let g:ctrlp_custom_ignore='node_modules\|bower_components\|DS_Store\|tmp\|dist\|git'


" *** CUSTOMIZATION ***
" DEFAULT THEME
set background=light
colorscheme pencil
let g:airline_theme='pencil'
let g:pencil_higher_contrast_ui=1
set termguicolors
" DARK MODE
function Dark()
  colorscheme deep-space
  let g:airline_theme='deep_space'
  set background=dark
endfun
" LIGHT MODE
function Light()
  colorscheme pencil
  let g:airline_theme='pencil'
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


set so=999                    " keep vim cursor in the middle of the screen for visual context
set shiftwidth=2              " indent uses 2 spaces
set tabstop=2                 " show 2 spaces per tab
set softtabstop=2             " add 2 spaces when a tab is added
set laststatus=2              " show airline
set autoindent                " automatically indents in files
set expandtab                 " turn tabs into spaces


set number                    " show number lines
filetype indent on            " load filetype specific indentation
set wildmenu                  " show visual autocomplete
set lazyredraw                " minimize redrawing
set showmatch                 " highlight matching parens


set incsearch                 " search as characters are entered
set hlsearch                  " hightlight matches


" move vertically by visual line (not actual line)
nnoremap j gj
nnoremap k gk
" set jk to escape
inoremap jk <esc>


set hidden
set history=100

autocmd BufWritePre * %s/\s\+$//e " remove trailing whitespace on save
