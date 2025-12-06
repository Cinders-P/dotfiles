" Maintainer:	The Vim Project <https://github.com/vim/vim>
" Last Change:	2023 Aug 10
" Former Maintainer:	Bram Moolenaar <Bram@vim.org>
"
" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim
 
if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
if has('syntax') && has('eval')
  packadd! matchit
endif


"" ------- Custom Section --------

if !isdirectory(expand("~/.vim/undo"))
  call mkdir(expand("~/.vim/undo"), "p")
endif

if !isdirectory(expand("~/.vim/backup"))
  call mkdir(expand("~/.vim/backup"), "p")
endif

if !isdirectory(expand("~/.vim/swap"))
  call mkdir(expand("~/.vim/swap"), "p")
endif

set backup
set swapfile
set directory=~/.vim/swap/
set backupdir=~/.vim/backup/

set autoread " auto-read files changed outside of vim
set writebackup " backup while writing
set undodir=~/.vim/undo " store undo files
set hidden " this allows buffers to stay in memory

set number relativenumber " show absolute number on cursor, relative numbers around
set wildmenu " command-line completion
set lazyredraw " reduce screen redraw for better macro performance
set laststatus=2 " always show  status line

set ignorecase
set smartcase " ignore case except when search has capitals
set incsearch " incremental search
set showmatch " show matching paren

set tabstop=4
set shiftwidth=4
set expandtab  " convert tabs to spaces
set smartindent " auto-indent new liens
set wrap
set linebreak

set clipboard=unnamedplus
let mapleader=" " 

" WSL2 Bindings
nnoremap <leader>Y :%w !clip.exe<CR> " yank file into windows
vnoremap <leader>y :w !clip.exe<CR> " yank visual selection into windows
nnoremap <leader>p :r !powershell.exe Get-Clipboard<CR> " paste from windows
" if these don't work, restart WSL2
" wsl --shutdown
" wsl -d <distro>

map <Enter> o<ESC>
map <leader><leader> O<ESC>

filetype plugin indent on
set omnifunc=syntaxcomplete#Complete " turn on built in omni complete
" C-x C-o

set termguicolors " use true colors
syntax on
colorscheme habamax 
highlight Normal ctermbg=NONE guibg=NONE " set background to transparent

" allow modelines, vim commands at the top of files
" # vim: tabstop=4 shiftwidth=4 expandtab
" set modeline
" set modelines=5

" when reading these files, set vim filetype automatically
autocmd BufRead,BufNewFile ~/.aliases,~/.exports setfiletype sh
