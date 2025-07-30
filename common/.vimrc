"
"
" Hung Nguyen


set nocompatible

" Default to utf-8
set encoding=utf-8

" Backport for trim() function for older Vim versions
function! s:trim(s)
    if exists('*trim')
        return trim(a:s)
    else
        return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

" --- Leader key ---
let mapleader = "\<Space>"

" --- Shell ---
set shell=/bin/bash

" --- vim-plug: For Vim Only ---
" Automatically install vim-plug if it's not present
if !has('nvim')
    let s:vim_plug_folder = '$HOME/.vim/autoload/'
    let s:vim_plug_path = s:vim_plug_folder . 'plug.vim'
    if empty(glob(s:vim_plug_path))
        if executable('curl')
            execute 'silent !curl -fLo ' . s:vim_plug_path . ' --create-dirs ' . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        elseif executable('wget')
            execute 'silent !mkdir -p ' . s:vim_plug_folder
            execute 'silent !wget --output-document=' . s:vim_plug_path . ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        else
            echoerr 'Need curl or wget to download vim-plug!'
        endif
        autocmd VimEnter * PlugUpdate! --sync 32 | source $MYVIMRC
    endif
endif

" --- Track if this is a fresh install to defer setup ---
let s:vim_plug_path_check = (has('nvim') ? '$HOME/.config/nvim' : '$HOME/.vim') . '/autoload/plug.vim'
let s:fresh_install = empty(glob(s:vim_plug_path_check))

" ######################
" > Plugins (vim-plug) <
" ######################
let s:bundle_path = (has('nvim') ? '~/.config/nvim' : '~/.vim') . '/bundle'
execute 'call plug#begin("' . s:bundle_path . '")'

" --- UI & navigation ---
Plug 'scrooloose/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'easymotion/vim-easymotion'
Plug 'Yggdroot/indentLine'
Plug 'itchyny/lightline.vim'

" --- Editing ---
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

" --- Fuzzy finding ---
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" --- VCS ---
Plug 'tpope/vim-fugitive'
" Use legacy branch for Vim versions before 8.0.902
if has('patch-8.0.902')
    Plug 'mhinz/vim-signify'
else
    Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

" --- Utilities ---
Plug 'jmcantrell/vim-diffchanges'
Plug 'ap/vim-css-color'
Plug 'gregsexton/MatchTag'
Plug 'itchyny/vim-cursorword'
Plug 'hvng/vim-repo-file-search'

" --- Color schemes---
Plug 'vim-scripts/xoria256.vim'
Plug 'tomasr/molokai'
Plug 'sjl/badwolf'

call plug#end()


" Don't run the rest of the setup on a fresh install until plugins are ready
if !s:fresh_install

    " #########################
    " > Plugin configurations <
    " #########################
    " --- NERDTree ---
    let g:NERDTreeIgnore = ['^lang$', '__pycache__', '\.idea', 'pyc$', '.cache', '.DS_Store', '\.swp$']
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeShowLineNumbers = 1
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeFileExtensionHighlightFullName = 1

    " --- NERDCommenter ---
    let g:NERDCompactSexyComs = 1
    let g:NERDCommentEmptyLines = 1
    let g:NERDTrimTrailingWhitespace = 1
    let g:NERDDefaultAlign = 'left'
    let g:NERDAltDelims_python = 1

    " --- fzf ---
    let g:fzf_layout = { 'window': 'new' }

    " --- indentLine ---
    let g:indentLine_char = '·'
    let g:indentLine_fileTypeExclude = ['json', 'markdown', 'tex']

    " --- vim-signify ---
    set updatetime=300
    augroup SignifyColors
        autocmd!
        function! s:SetSignifyColors()
            highlight SignColumn ctermbg=NONE guibg=NONE
            highlight SignifySignAdd ctermfg=green guifg=#00ff00
            highlight SignifySignDelete ctermfg=red guifg=#ff0000
            highlight SignifySignChange ctermfg=yellow guifg=#ffff00
        endfunction
        autocmd ColorScheme * call s:SetSignifyColors()
    augroup END
    let g:signify_sign_add = '•'
    let g:signify_sign_delete = '•'
    let g:signify_sign_delete_first_line = '•'
    let g:signify_sign_change = '•'
    let g:signify_priority = 5

    " --- Lightline ---
    function! s:lightline_filepath()
      return get(b:, 'repo_file_search_display', '')
    endfunction
    let g:hung_lightline_colorscheme = get(g:, 'hung_lightline_colorscheme', 'wombat')
    let g:lightline = {
        \ 'colorscheme': g:hung_lightline_colorscheme,
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ], [ 'signify' ] ],
        \   'right': [ [ 'lineinfo' ], [ 'filetype', 'charvaluehex' ], [ 'filepath' ], [ 'truncate' ] ]
        \ },
        \ 'component': {
        \   'charvaluehex': '0x%B',
        \   'signify': has('patch-8.0.902') ? '%{sy#repo#get_stats_decorated()}' : '',
        \   'truncate': '%<',
        \ },
        \ 'component_function': {
        \   'filepath': string(function('s:lightline_filepath')),
        \ }
        \ }


    " ####################
    " > General settings <
    " ####################
    syntax on
    filetype plugin indent on

    set autochdir
    set wildmenu
    set wildmode=longest:full,full
    set clipboard=unnamed,unnamedplus
    set number
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
    set noshowmode
    set timeoutlen=300 ttimeoutlen=10
    set backspace=2
    set modeline
    set formatoptions-=t
    let g:netrw_ftp_cmd = 'ftp -p'


    " ####################
    " > Visuals & colors <
    " ####################
    " --- Cursor crosshair when we enter insert mode ---
    augroup InsertModeCrossHairs
        autocmd!
        set cursorline
        if exists('+cursorlineopt')
            set cursorlineopt=number
            autocmd InsertEnter * set cursorlineopt=both
            autocmd InsertLeave * set cursorlineopt=number
        else
            autocmd InsertEnter * set cursorline
            autocmd InsertLeave * set nocursorline
        endif
        autocmd InsertLeave * set nocursorcolumn
    augroup END

    " --- Color overrides ---
    set background=dark
    augroup ColorschemeOverrides
        autocmd!
        function! s:ColorschemeOverrides()
            set t_Co=256
            highlight LineNr ctermfg=241 ctermbg=234
            highlight CursorLineNr cterm=bold ctermfg=232 ctermbg=250 guifg=#080808 guibg=#585858
            highlight Visual cterm=bold ctermbg=238
            highlight TrailingWhitespace ctermbg=52
            let g:indentLine_color_term=237
            highlight SpecialKey ctermfg=238
            let l:todo_color = 247

            highlight CursorWord1 ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE

            " Make Pmenu darker to avoid display issues
            highlight Pmenu ctermfg=252 ctermbg=235
            highlight PmenuSel cterm=bold ctermfg=255 ctermbg=238
            highlight PmenuSbar ctermbg=237
        endfunction
        autocmd ColorScheme * call s:ColorschemeOverrides()
    augroup END

    " --- Set default colorscheme ---
    let g:hung_colorscheme = get(g:, 'brent_colorscheme', 'xoria256')
    if g:hung_colorscheme !=# 'legacy'
        execute 'colorscheme ' . g:hung_colorscheme
    else
        execute 'colorscheme peachpuff'
    endif

    highlight MatchParen cterm=bold,underline ctermbg=none ctermfg=7
    highlight VertSplit ctermfg=0 ctermbg=0

    " --- Highlight trailing whitespace ---
    augroup MatchTrailingWhitespace
        autocmd!
        autocmd VimEnter,BufEnter,WinEnter * call matchadd('TrailingWhitespace', '\s\+$')
    augroup END


    " ############################
    " > Key mappings & functions <
    " ############################

    " --- Mappings ---
    map <C-n> :NERDTreeToggle<CR>
    map <Leader>/ <Plug>NERDCommenterToggle
    map s <Plug>(easymotion-overwin-f)
    map S <Plug>(easymotion-overwin-w)
    noremap <C-p> :Files<CR>
    noremap ` :Rg<CR>
    noremap <C-`> :Rg <cword><CR>
    noremap ; :Buffers<CR>
    noremap <C-;> :History<CR>
    nnoremap <Leader>dc :DiffChangesDiffToggle<CR>
    nnoremap <Leader>tt :tabnew<CR>
    nnoremap <Leader>tn :tabn<CR>
    vnoremap <Tab> >
    vnoremap <S-Tab> <
    nnoremap Y y$
    nnoremap D d$
    nnoremap <Esc> :noh<CR>:redraw!<CR><Esc>
    nnoremap <Bslash> za
    nnoremap <Leader>rw :%s/\<<C-r><C-w>\>/
    nnoremap <Leader>w :w<Bar>source $MYVIMRC<CR>

    " --- Spellcheck ---
    map <F5> :setlocal spell! spelllang=en_us<CR>
    inoremap <F5> <C-\><C-O>:setlocal spelllang=en_us spell! spell?<CR>
    highlight clear SpellBad
    highlight SpellBad cterm=bold,italic ctermfg=red

    " --- VCS functions ---
    nnoremap <Leader>vcd :call <SID>vc_diff()<CR>
    function! s:vc_diff()
        if get(b:, 'repo_file_search_type', '') ==# 'hg'
            Hgvdiff
        elseif get(b:, 'repo_file_search_type', '') ==# 'git'
            Gdiff
        endif
    endfunction

    nnoremap <Leader>vcs :call <SID>vc_status()<CR>
    function! s:vc_status()
        if get(b:, 'repo_file_search_type', '') ==# 'hg'
            Hgstatus
        elseif get(b:, 'repo_file_search_type', '') ==# 'git'
            Gstatus
        endif
    endfunction

    nnoremap <Leader>vcb :call <SID>vc_blame()<CR>
    function! s:vc_blame()
        if get(b:, 'repo_file_search_type', '') ==# 'hg'
            Hgannotate
        elseif get(b:, 'repo_file_search_type', '') ==# 'git'
            Gblame
        endif
    endfunction

    " --- Buffer function ---
    nnoremap <Leader>baa :call <SID>buffer_add_all()<CR>
    function! s:buffer_add_all()
        let l:path = expand('%:p')
        let l:pattern = l:path[:-len(expand('%:t')) - 1] . '**/*.' . expand('%:e')
        echom 'Loaded buffers matching pattern: ' . l:pattern
        for l:path in split(glob(l:pattern), '\n')
            let filesize = getfsize(l:path)
            if filesize > 0 && filesize < 80000
                execute 'badd ' . l:path
            endif
        endfor
    endfunction

    " --- Window cleanup function ---
    nnoremap <Leader>c :call <SID>window_cleanup()<CR>
    function! s:window_cleanup()
        execute 'pclose'
        execute 'cclose'
        execute 'lclose'
        execute 'helpclose'
        " Close fugitive diffs
        let l:diff_buffers = filter(range(1, bufnr('$')), 'bufname(v:val) =~# "^fugitive://"')
        for l:b in l:diff_buffers
            execute 'bd ' . l:b
        endfor
        diffoff
    endfun

    " --- Tmux automatic window renaming ---
    if exists('$TMUX')
        augroup TmuxHelpers
            autocmd!
            autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter,FocusGained * call system('tmux rename-window "vim ' . expand('%:t') . '"')
            autocmd VimLeave,FocusLost * call system('tmux set-window-option automatic-rename')
        augroup END
    endif

    " ########
    " > Meta <
    " ########
    augroup AutoReloadVimRC
        autocmd!
        autocmd BufWritePost $MYVIMRC source $MYVIMRC
        autocmd BufWritePost .vimrc source $MYVIMRC
    augroup END

    " ####################
    " > Friendly mode ^^ <
    " ####################
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
            if a:verbose | echo 'disabled friendly mode!' | endif
        else
            unmap <silent> <Up>
            unmap <silent> <Down>
            unmap <silent> <Right>
            unmap <silent> <Left>
            set mouse=a
            let s:hung_use_friendly_mode = 1
            if a:verbose | echo 'enabled friendly mode!' | endif
        endif
    endfunction
    call <SID>toggle_friendly_mode(0)

endif
