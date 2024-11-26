set nocompatible

call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'luochen1990/rainbow'
Plug 'jiangmiao/auto-pairs'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'dracula/vim', { 'as': 'dracula' }

call plug#end()

set termguicolors

colorscheme dracula

set number relativenumber
set cursorline
set hlsearch

let g:rainbow_active = 1

lua << EOF
vim.opt.list = true
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup {
    show_end_of_line = true,
}
EOF

onoremap af :<C-u>normal! ggVG<CR>

"Make editing cron files easier.
autocmd filetype crontab setlocal nobackup nowritebackup

"Make editing Makefiles easier
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

"open NERDTree on vim startup
autocmd vimenter * NERDTree
"open NERDTree on vim startup with no file specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"close NERDTree if NERDTree is the only buffer left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"move cursor to buffer not NERDTree pane
autocmd VimEnter * wincmd l
