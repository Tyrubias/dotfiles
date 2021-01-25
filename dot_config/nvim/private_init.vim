set nocompatible

call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

call plug#end()

colorscheme onedark

set termguicolors

set number
set relativenumber
set cursorline
set tabstop=8
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab

onoremap af :<C-u>normal! ggVG<CR>
"Make editing cron files easier.
autocmd filetype crontab setlocal nobackup nowritebackup

"open NERDTree on vim startup
autocmd vimenter * NERDTree
"open NERDTree on vim startup with no file specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"close NERDTree if NERDTree is the only buffer left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"move cursor to buffer not NERDTree pane
autocmd VimEnter * wincmd l
