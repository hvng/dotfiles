"
"
" Hung Nguyen


set nocompatible

" Default to utf-8 (not needed error for Neovim)
if !has('nvim')
    set encoding=utf-8
endif

if has('nvim') && has('termguicolors')
    set termguicolors
endif

" Backport for trim()
" https://github.com/Cimbali/vim-better-whitespace/commit/855bbef863418a36bc10e5a51ac8ce78bcbdcef8
function! s:trim(s)
    if exists('*trim')
        return trim(a:s)
    else
        return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

" Remap <Leader> to <Space>
let mapleader = "\<Space>"

" Run shell commands using bash
set shell=/bin/bash

" Automatically install vim-plug
let s:vim_plug_folder = (has('nvim') ? '$HOME/.config/nvim' : '$HOME/.vim') . '/autoload/'
let s:vim_plug_path = s:vim_plug_folder . 'plug.vim'
let s:fresh_install = 0
if empty(glob(s:vim_plug_path))
    if executable('curl')
        execute 'silent !curl -fLo ' . s:vim_plug_path . ' --create-dirs '
            \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    elseif executable('wget')
        execute 'silent !mkdir -p ' . s:vim_plug_folder
        execute 'silent !wget --output-document=' . s:vim_plug_path
            \ . ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    else
        echoerr 'Need curl or wget to download vim-plug!'
    endif
    autocmd VimEnter * PlugUpdate! --sync 32 | source $MYVIMRC
    let s:fresh_install = 1
endif


" ##################################
" ############ Plugins ############
" ##################################
let s:bundle_path = (has('nvim') ? '~/.config/nvim' : '~/.vim') . '/bundle'
execute 'call plug#begin("' . s:bundle_path . '")'

" NerdTree
Plug 'scrooloose/nerdtree'
let NERDTreeIgnore = ['^lang$', '__pycache__', '\.idea', 'pyc$', '.cache', '.DS_Store', '\.swp$']
let g:NERDTreeShowHidden = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
map <C-n> :NERDTreeToggle<CR>


" NerdComments
Plug 'preservim/nerdcommenter'
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_python = 1
map <C-_> <Plug>NERDCommenterToggle<CR>


" Jump inside files
Plug 'easymotion/vim-easymotion'
map s <Plug>(easymotion-overwin-f)
map S <Plug>(easymotion-overwin-w)


" Manipulating quotes, brackets, parentheses, HTML tags
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'


" Show unsaved changes to a file
Plug 'jmcantrell/vim-diffchanges'
nnoremap <Leader>dc :DiffChangesDiffToggle<CR>


" Colors for CSS, tag matching for HTML, underline all current word's instances
Plug 'ap/vim-css-color'
Plug 'gregsexton/MatchTag'
Plug 'itchyny/vim-cursorword'


" Color schemes
Plug 'vim-scripts/xoria256.vim'
Plug 'tomasr/molokai'
Plug 'sjl/badwolf'
if has('nvim')
    " Use color schemes with treesitter support.
    Plug 'ChristianChiarulli/nvcode-color-schemes.vim'
    Plug 'tanvirtin/monokai.nvim'
endif


" fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
let g:fzf_layout = {
    \ 'window': 'new'
    \ }
noremap ` :Files<CR>
noremap ; :Buffers<CR>


" Various path/repository-related helpers
" Populates b:repo_file_... variables
Plug 'hvng/vim-repo-file-search'


" Git, Mecurial
Plug 'tpope/vim-fugitive'
"Plug 'ludovicchabant/vim-lawrencium'
if has('nvim') || has('patch-8.0.902')
    Plug 'mhinz/vim-signify'
else
    Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

" Keybinding for opening diffs
nnoremap <Leader>vcd :call <SID>vc_diff()<CR>
function! s:vc_diff()
if b:repo_file_search_type ==# 'hg'
    Hgvdiff
elseif b:repo_file_search_type ==# 'git'
    Gdiff
endif
endfunction

" Keybinding for printing repo status
nnoremap <Leader>vcs :call <SID>vc_status()<CR>
function! s:vc_status()
if b:repo_file_search_type ==# 'hg'
    Hgstatus
elseif b:repo_file_search_type ==# 'git'
    Gstatus
endif
endfunction

" Keybinding for blame/annotate
nnoremap <Leader>vcb :call <SID>vc_blame()<CR>
function! s:vc_blame()
if b:repo_file_search_type ==# 'hg'
    Hgannotate
elseif b:repo_file_search_type ==# 'git'
    Gblame
endif
endfunction

" For vim-signify
set updatetime=300
augroup SignifyColors
autocmd!
function! s:SetSignifyColors()
    highlight SignColumn ctermbg=NONE guibg=NONE
    highlight SignifySignAdd ctermfg=green guifg=#00ff00 cterm=NONE gui=NONE
    highlight SignifySignDelete ctermfg=red guifg=#ff0000 cterm=NONE gui=NONE
    highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE
endfunction
autocmd ColorScheme * call s:SetSignifyColors()
augroup END
let g:signify_sign_add = '•'
let g:signify_sign_delete = '•'
let g:signify_sign_delete_first_line = '•'
let g:signify_sign_change = '•'
let g:signify_priority = 5


" Status line
Plug 'itchyny/lightline.vim'
"Plug 'josa42/nvim-lightline-lsp'
" Display human-readable path to file
" This is generated in vim-repo-file-search
function! s:lightline_filepath()
return get(b:, 'repo_file_search_display', '')
endfunction

let g:hung_lightline_colorscheme = get(g:, 'hung_lightline_colorscheme', 'wombat')
let g:lightline = {}

" Lightline colors
let g:lightline.colorscheme = g:hung_lightline_colorscheme
let g:lightline.active = {
\ 'left': [ [ 'mode', 'paste' ],
\           [ 'readonly', 'filename', 'modified' ],
\           [ 'signify' ] ],
\ 'right': [ [ 'lineinfo' ],
\            [ 'filetype', 'charvaluehex' ],
\            [ 'filepath' ],
\            [ 'truncate' ]]
\ }
let g:lightline.inactive = {
\ 'left': [ [ 'readonly', 'filename', 'modified' ] ],
\ 'right': [ [],
\            [ 'filepath', 'lineinfo' ],
\            [ 'truncate' ]]
\ }

" Components
let g:lightline.component = {
\   'charvaluehex': '0x%B',
\   'signify': has('patch-8.0.902') ? '%{sy#repo#get_stats_decorated()}' : '',
\   'truncate': '%<',
\ }
let g:lightline.component_function = {
\   'filepath': string(function('s:lightline_filepath')),
\ }

call plug#end()

" ##################################
" ############ SETTINGS ############
" ##################################
" Plugins are already installed, now time for the rest ^^
if !s:fresh_install
    syntax on
    set wildmenu
    set wildmode=longest:full,full
    set clipboard=unnamed,unnamedplus
    set number
    "set relativenumber
    set scrolloff=6
    set hlsearch
    set incsearch
    set laststatus=2
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent
    set history=1000
    set cursorline
    set ignorecase
    set noerrorbells
    set title
    set foldlevel=99
    set foldmethod=indent
    set splitbelow
    set splitright
    set list listchars=tab:>·,trail:\ ,extends:»,precedes:«,nbsp:×
    filetype plugin indent on

    " Hide redundant mode indicator underneath statusline
    set noshowmode

    " Make escape insert mode zippier
    set timeoutlen=300 ttimeoutlen=10

    " Allow backspacing over everything (eg line breaks)
    set backspace=2

    " Enable modeline for file-specific vim settings
    set modeline

    " By default, disable automatic text wrapping
    " This will often be overrided locally based on filetype
    set formatoptions-=t

    " Passive FTP mode for remote netrw
    let g:netrw_ftp_cmd = 'ftp -p'


    " #############################################
    " > Visuals <
    " #############################################

    " Cursor crosshair when we enter insert mode
    " Note we re-bind Ctrl+C in order for InsertLeave to be called
    augroup InsertModeCrossHairs
    autocmd!
    if exists('+cursorlineopt')
        " Highlight current line in insertmode, line number always
        " Unfixes this patch: https://github.com/vim/vim/issues/5017
        set cursorline
        set cursorlineopt=number
        autocmd InsertEnter * set cursorlineopt=both
        autocmd InsertLeave * set cursorlineopt=number
    else
        " Neovim + legacy
        autocmd InsertEnter * set cursorline
        autocmd InsertLeave * set nocursorline
    endif
    "autocmd InsertEnter * set cursorcolumn
    autocmd InsertLeave * set nocursorcolumn
    augroup END

    " Configuring colors
    set background=dark
    augroup ColorschemeOverrides
    autocmd!
    function! s:ColorschemeOverrides()
        if g:hung_colorscheme ==# 'legacy'
            " Fallback colors for some legacy terminals
            set t_Co=16
            set foldcolumn=1
            highlight FoldColumn ctermbg=7
            highlight LineNr cterm=bold ctermfg=0 ctermbg=0
            highlight CursorLineNr ctermfg=0 ctermbg=7
            highlight Visual cterm=bold ctermbg=1
            highlight TrailingWhitespace ctermbg=1
            highlight Search ctermfg=4 ctermbg=7
            let l:todo_color = 7
        else
            " TODO: most of this won't do anything when termguicolors is set!

            " When we have 256 colors available
            " (This is usually true)
            set t_Co=256
            highlight LineNr ctermfg=241 ctermbg=234
            highlight CursorLineNr cterm=bold ctermfg=232 ctermbg=250 guifg=#080808 guibg=#585858
            highlight Visual cterm=bold ctermbg=238
            highlight TrailingWhitespace ctermbg=52
            let g:indentLine_color_term=237
            highlight SpecialKey ctermfg=238
            let l:todo_color = 247

            " Cursorword is just underline
            highlight CursorWord0 ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
            highlight CursorWord1 ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE

            " The rest of this block is doing some colors for popups, eg
            " autocomplete or floating help windows.

            " The main purpose here is to make the Pmenu color
            " darker than the default, as a light Pmenu can cause display
            " issues for syntax highlighting applied within popups.
            highlight Pmenu ctermfg=252 ctermbg=235
            highlight PmenuSel cterm=bold ctermfg=255 ctermbg=238

            " We also darken the scrollbar to increase contrast:
            highlight PmenuSbar ctermbg=237

            " Some newer builds of Neovim add a distinct highlight group
            " for borders of floating windows.
            highlight FloatBorder ctermfg=242 ctermbg=235

            " And, to be explicit, we (unnecessarily) link the
            " Neovim-specific 'normal' floating text highlight group. Like
            " FloatBorder, this is unused in Vim8.
            highlight link NormalFloat Pmenu
        endif

        " Todo note highlighting
        " Copy the comment highlighting, then override (a bit superfluous)
        redir => l:comment_highlight
        silent highlight Comment
        redir END
        let l:comment_highlight = s:trim(split(l:comment_highlight, 'xxx')[1])
        highlight clear Todo
        execute 'highlight Todo ' . l:comment_highlight . ' cterm=bold ctermfg=' . l:todo_color . ' guifg=#9e9e9e'
    endfunction
    autocmd ColorScheme * call s:ColorschemeOverrides()
    augroup END

    if has('nvim')
        " Treesitter support
        let g:hung_colorscheme = get(g:, 'brent_colorscheme', 'monokai_pro')
    else
        let g:hung_colorscheme = get(g:, 'brent_colorscheme', 'xoria256')
    endif
    if g:hung_colorscheme !=# 'legacy'
        execute 'colorscheme ' . g:hung_colorscheme
    else
        execute 'colorscheme peachpuff'
    endif

    highlight MatchParen cterm=bold,underline ctermbg=none ctermfg=7
    highlight VertSplit ctermfg=0 ctermbg=0

    augroup MatchTrailingWhitespace
        autocmd!
        autocmd VimEnter,BufEnter,WinEnter * call matchadd('TrailingWhitespace', '\s\+$')
    augroup END

    " #############################################
    " > Key mappings for usability <
    " #############################################

    " Match tmux behavior + bindings (with <C-w> instead of <C-b>)
    nmap <C-w>" :sp<CR>
    nmap <C-w>% :vsp<CR>

    " Bindings for switching between tabs
    nnoremap <Leader>tt :tabnew<CR>
    nnoremap <Leader>tn :tabn<CR>

    vnoremap <Tab> >
    vnoremap <S-Tab> <

    " Bindings for copy,del to end-of-line
    nnoremap Y y$
    nnoremap D d$

    " Search utilities -- highlight matches, clear highlighting with <Esc>
    nnoremap <Esc> :noh<CR>:redraw!<CR><Esc>

    " Use backslash to toggle folds
    nnoremap <Bslash> za

    " Binding to trim trailing whitespaces in current file
    nnoremap <Leader>ttws :%s/\s\+$//e<CR>

    " Binding to 'replace this word'
    nnoremap <Leader>rtw :%s/\<<C-r><C-w>\>/

    " Bindings for lower-effort writing, quitting, reloading
    nnoremap <Leader>wq :wq<CR>
    nnoremap <Leader>w :w<Bar>source $MYVIMRC<CR>
    nnoremap <Leader>q :q<CR>
    nnoremap <Leader>e :e<CR>

    " Bindings for buffer stuff
    " > bd: delete current buffer
    " > bc: clear all but current buffer
    " > baa: open buffer for all files w/ same extension in current directory
    nnoremap <Leader>bd :bd<CR>
    nnoremap <Leader>bc :%bd\|e#<CR>
    nnoremap <Leader>baa :call <SID>buffer_add_all()<CR>
    function! s:buffer_add_all()
        " Get a full path to the current file
        let l:path = expand('%:p')

        " Chop off the filename and add wildcard
        let l:pattern = l:path[:-len(expand('%:t')) - 1] . '**/*.' . expand('%:e')
        echom 'Loaded buffers matching pattern: ' . l:pattern
        for l:path in split(glob(l:pattern), '\n')
            let filesize = getfsize(l:path)
            if filesize > 0 && filesize < 80000
            execute 'badd ' . l:path
            endif
        endfor
    endfunction


    " Close preview/quickfix/location list/help windows with <Leader>c
    nnoremap <Leader>c :call <SID>window_cleanup()<CR>
    function! s:window_cleanup()
        " Close preview windows
        execute 'pclose'
        " Close quickfix windows
        execute 'cclose'
        " Close location list windows
        execute 'lclose'
        " Close help windows
        execute 'helpclose'

        if has("nvim")
            TroubleClose
        endif

        " Close fugitive diffs
        let l:diff_buffers = range(1, bufnr('$'))
        let l:diff_buffers = filter(l:diff_buffers, 'bufname(v:val) =~# "^fugitive://"')
        for l:b in l:diff_buffers
            execute 'bd ' . l:b
        endfor

        diffoff " Generally not needed, but handles some edge cases when multiple diffs are opened
    endfun


    " #############################################
    " > Automatic window renaming for tmux <
    " #############################################
    if exists('$TMUX')
    augroup TmuxHelpers
      " TODO: fix strange behavior when we break-pane in tmux
        autocmd!
        autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter,FocusGained * call system('tmux rename-window "vim ' . expand('%:t') . '"')
        autocmd VimLeave,FocusLost * call system('tmux set-window-option automatic-rename')
    augroup END
    endif

    " #############################################
    " > Spellcheck <
    " #############################################
    map <F5> :setlocal spell! spelllang=en_us<CR>
    inoremap <F5> <C-\><C-O>:setlocal spelllang=en_us spell! spell?<CR>
    highlight clear SpellBad
    highlight SpellBad cterm=bold,italic ctermfg=red


    " #############################################
    " > Meta <
    " #############################################
    augroup AutoReloadVimRC
        autocmd!
        autocmd BufWritePost $MYVIMRC source $MYVIMRC

        " For init.vim->.vimrc symlinks in Neovim
        autocmd BufWritePost .vimrc source $MYVIMRC
    augroup END


   " #############################################
   " > Friendly mode ^^ <
   " #############################################
    nnoremap <silent> <Leader>f :call <SID>toggle_friendly_mode(1)<CR>
    let s:hung_use_friendly_mode = 1
    function! s:toggle_friendly_mode(verbose)
        if s:hung_use_friendly_mode
            nnoremap <silent> <Up> :resize -3<CR>
            nnoremap <silent> <Down> :resize +3<CR>
            nnoremap <silent> <Left>  :vertical resize -3<CR>
            nnoremap <silent> <Right> :vertical resize +3<CR>
            set mouse=
            let s:hung_use_friendly_mode = 0
            if a:verbose
            echo 'disabled friendly mode!'
            endif
        else
            unmap <silent> <Up>
            unmap <silent> <Down>
            unmap <silent> <Right>
            unmap <silent> <Left>
            set mouse=a
            let s:hung_use_friendly_mode = 1
            if a:verbose
            echo 'enabled friendly mode!'
            endif
        endif
    endfunction
    call <SID>toggle_friendly_mode(0)

endif

