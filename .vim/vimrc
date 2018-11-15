"-----Newly Learned Vim Features-----"
" <visual> o: alternates cursor position of highlighed text
"
"
"-----Test the speed of vim on startup on unix and windows, respectively-----"
" rm -f vim.log && vim --startuptime vim.log +q && tail -n 1 vim.log | cut -f1 -d' '
" rm -force -ErrorAction Ignore vim.log; vim --startuptime vim.log +q; tail -n 1 vim.log | cut -f1 -d' '

set nocompatible              " be iMproved, required
if has('nvim')
    let s:editor_root=expand("~/.config/nvim")
elseif has('win32')
    let s:editor_root=expand("~/vimfiles")
    set shell=powershell
    set shellcmdflag=-command
elseif has('unix')
    let s:editor_root=expand("~/.vim")
endif

" Setting up plugins
if empty(glob(s:editor_root . '/plugged'))
    autocmd VimEnter * PlugInstall
endif

call plug#begin(s:editor_root . '/plugged')
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-sensible'
    Plug 'tpope/vim-surround'
    Plug 'itchyny/lightline.vim'
    Plug 'vimwiki/vimwiki'
    Plug 'tpope/vim-vinegar'
    Plug 'tpope/vim-repeat'
    Plug 'mhinz/vim-startify'
    Plug 'lifepillar/vim-mucomplete'
    Plug 'davidhalter/jedi-vim', { 'for': ['python'] }
    Plug 'markonm/traces.vim'
    Plug 'simnalamburt/vim-mundo'
    Plug 'Quramy/tsuquyomi'
    Plug 'leafgarland/typescript-vim', { 'for': ['typescript'] }
    if has('win32')
        Plug 'Shougo/vimproc.vim'
    else
        Plug 'Shougo/vimproc.vim', {'do' : 'make'}
    endif
    if ( has('python') || has('python2') || has('python3') ) && has('win32')
        Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
    else
        Plug 'ctrlpvim/ctrlp.vim'
        if executable('rg')
            set grepprg=rg\ --color=never
            let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
            let g:ctrlp_use_caching = 0
        endif
    endif

    if has('unix')
        Plug 'christoomey/vim-tmux-navigator'
        Plug 'idanarye/vim-vebugger'
        Plug 'jiangmiao/auto-pairs'
        Plug 'mgee/lightline-bufferline'
    endif


    if (version >= 800 || has('nvim'))
        Plug 'w0rp/ale'
        let g:ale_fixers = {
        \   'javascript': ['eslint'],
        \   'typescript': ['tslint'],
        \   'java': [''],
        \}
        let g:ale_linters = {
        \   'java': [''],
        \}
    endif

    if version < 800 && has('unix')
        Plug 'vim-syntastic/syntastic'
    endif

call plug#end()
" Setting up plugins - end

syntax enable
set hlsearch
set shiftwidth=4
set background=dark
set ignorecase
set smartcase
set completeopt=longest,menuone
set incsearch
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
set background=dark
set number relativenumber
set infercase
set splitbelow
set splitright
set noerrorbells
let g:gutentags_file_list_command = 'rg --files'
let g:tsuquyomi_single_quote_import=1
let g:VM_no_meta_mappings=1
let g:vebugger_leader=','
let mapleader = ","
let g:rainbow_active = 1

"-----mappings-----"
nnoremap <leader>bg :ToggleBG<CR>
nnoremap <silent> + :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> \- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <leader>ev :silent e $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>rt :%retab<CR>
nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>rp :w<CR>:!python3 %<CR>
nnoremap <leader>pt :!python3 test_%<CR>
nnoremap <leader>jt :!.\gradlew test --tests *.%:t:r<CR>
nnoremap <leader>l :bn<CR>     " Move to the next buffer
nnoremap <leader>h :bp<CR>     " Move to the previous buffer
nnoremap <leader>pc :PlugClean<CR>
nnoremap <silent> <esc><esc> :nohlsearch<CR><esc>
nnoremap <leader>s :Startify<CR>
vnoremap <leader>q :norm @q<CR>
nnoremap gb :ls<CR>:b<Space>
nnoremap <leader>s :%s/\v
nnoremap gh :MundoToggle<CR>
nnoremap <leader>it :TsuImport<CR>
nnoremap <leader>af :ALEFix<CR>


if exists(':tnoremap')
    if has('win32')
        nnoremap <leader>T :tab terminal<CR>Set-Theme tehrob<CR>clear<CR>
        nnoremap <leader>t :terminal<cr><C-w>:exe "resize " . (winheight(0) * 2/3)<CR>Set-Theme tehrob<CR>clear<CR>
    else
        nnoremap <leader>T :tab terminal<CR>set -o vi<CR>
        nnoremap <leader>t :terminal<cr><C-w>:exe "resize " . (winheight(0) * 2/3)<CR>set -o vi<CR>
    endif
endif

" pulls vim changes from git
if has('unix')
    nnoremap <leader>pv :!(cd ~/.vim && git reset HEAD --hard && git pull)<CR>
elseif has ('win32')
    nnoremap <leader>pv :!cd ~/vimfiles; git reset HEAD --hard; git pull<CR>
endif

" Renames selected word accross the file
nnoremap <leader>rn :%s/\<<c-r><c-w>\>/
nnoremap Y y$

" mappings for vebugger
" ':help vebugger-keymaps' for more
nnoremap ,k :VBGkill<CR>
nnoremap ,s :VBGstartPDB %<CR>

" more natural windows mappings
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-=> <C-W><C-=>

if exists(':tnoremap')
    tnoremap <C-n> <C-\><C-n>
    tnoremap <C-J> <C-W><C-J>
    tnoremap <C-K> <C-W><C-K>
    tnoremap <C-L> <C-W><C-L>
    tnoremap <C-H> <C-W><C-H>
endif

" buffer mappings
set hidden                      " This allows buffers to be hidden if you've modified a buffer

"-----Macros-----"
" Takes clipboard link of github to plugin and turns it into vim-plug syntax
let @p = 'oPlug ''''"+PF''ldf/.'

"-----auto-commands-----"
augroup autosourcing
    autocmd!
    if has('nvim')
        autocmd BufWritePost vimrc execute "source " . s:editor_root . "/init.vim"
    else
        autocmd BufWritePost vimrc execute "source " . s:editor_root . "/vimrc"
        if has('win32') && has('gui_running')
            autocmd BufWritePost vimrc simalt ~x
        endif
    endif
augroup END

augroup TrimTrailingWhitespace
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END

if has("gui_running")
    colorscheme solarized
    autocmd GUIEnter * set vb t_vb=
endif

" Ignore these directories
set wildignore+=*/build/**
set wildignore+=*/bin/**
set wildignore+=*/node_modules/**
set wildignore=*.swp,*.bak
set wildignore+=*.pyc,*.class,*.sln,*.Master,*.csproj,*.csproj.user,*.cache,*.dll,*.pdb,*.min.*
set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
set wildignore+=tags
set wildignore+=*.tar.*

" put abbreviations at the end
inoremap \dlr '${:,.2f}'.format()<esc>i

if has('unix') && !has('gui_running')
    au VimLeave * :!clear
endif

if has('win32') && !has('gui_running') && !empty($CONEMUBUILD)
    set term=xterm
    set t_Co=256
    inoremap <Char-0x07F> <BS>
    nnoremap <Char-0x07F> <BS>
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    set encoding=utf-8
    set termencoding=utf-8
    set fileencoding=utf-8
endif

if has('unix') && has('gui_running')
    set macligatures
    set lines=999 columns=9999
    set guifont=Fira\ Code:h12
    set guioptions=ca
endif

if has('win32') && has('gui_running')
    set renderoptions=type:directx
    set encoding=utf-8
    autocmd GUIEnter * simalt ~x
    set guifont=Fira\ Code:h12
    set guioptions=ca
endif

let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'
let g:lightline = {}
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
let g:lightline.colorscheme = 'solarized'
set noshowmode
if has('unix')
    set showtabline=2
endif

