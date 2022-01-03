"
"
" Hung Nguyen


" Default to utf-8 (It make error for Neovim)
if !has('nvim')
    set encoding=utf-8
    scriptencoding utf-8
endif

" Remap <Leader> to <Space>
let mapleader = "\<Space>"


" == Install plugin manager ==
" Vim-plug
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
            \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    else
        echoerr 'Need curl or wget to download vim-plug!'
    endif
    autocmd VimEnter * PlugUpdate! --sync 32 | source $MYVIMRC
    let s:fresh_install = 1
endif


" == Plugins ==
" Set path
let s:plugged_path = (has('nvim') ? '~/.config/nvim' : '~/.vim') . '/plugged'
execute 'call plug#begin("' . s:plugged_path . '")'

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

" Color schemes
Plug 'vim-scripts/xoria256.vim'
Plug 'dracula/vim'

" Colors for CSS
Plug 'ap/vim-css-color'

" Tag matching for HTML
Plug 'gregsexton/MatchTag'

" Underline all instances of current word
Plug 'itchyny/vim-cursorword'


" Things for Git
Plug 'tpope/vim-fugitive'
if has('nvim') || has('patch-8.0.902')
    Plug 'mhinz/vim-signify'
else
    Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

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
let g:signify_sign_add = '+'
let g:signify_sign_delete = '-'
let g:signify_sign_delete_first_line = 'f'
let g:signify_sign_change = 'u'


" NERDTree extensions: syntax highlighting, version control indicators
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  : 'M',
    \ 'Staged'    : '+',
    \ 'Untracked' : '?',
    \ 'Renamed'   : 'renamed',
    \ 'Unmerged'  : 'unmerged',
    \ 'Deleted'   : 'X',
    \ 'Dirty'     : 'd',
    \ 'Clean'     : 'c',
    \ 'Ignored'   : '-',
    \ 'Unknown'   : '??'
    \ }



" LSP
let g:hung_use_lsp = get(g:, 'hung_use_lsp', 0)
if g:hung_use_lsp == 0
    " Default not set, no need heavy things
    " Python magic (auto-completion, definition jumping, etc)
    Plug 'davidhalter/jedi-vim'
    let g:jedi#popup_on_dot=0
    let g:jedi#auto_close_doc=0
    let g:jedi#show_call_signatures=0

    " Match vim-lsp bindings (see below)
    let g:jedi#goto_command = "<Leader>gd"
    let g:jedi#goto_assignments_command = "<Leader>ga"
    let g:jedi#goto_stubs_command = "<Leader>gs"
    let g:jedi#goto_definitions_command = ""
    let g:jedi#documentation_command = "K"
    let g:jedi#usages_command = "<Leader>gr" 
    let g:jedi#completions_command = "<C-Space>" 
    let g:jedi#rename_command = "<Leader>rn"

else
    " LSP plugins for autocompletion, jump to def, etc
    " Note that we also need to actually install some LSPs, eg:
    " > https://github.com/mattn/vim-lsp-settings
    Plug 'prabirshrestha/async.vim'
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings'

    " Async 'appears as you type' autocompletion
    " > Use Tab, S-Tab to select, <CR> to confirm (see above for binding)
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/asyncomplete-lsp.vim'

    " Bindings
    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
        nmap <buffer> <Leader>gd <plug>(lsp-definition)
        nmap <buffer> <Leader>gr <plug>(lsp-references)
        nmap <buffer> <Leader>gi <plug>(lsp-implementation)
        nmap <buffer> <Leader>gt <plug>(lsp-type-definition)
        nmap <buffer> <Leader>rn <plug>(lsp-rename)
        nmap <buffer> <Leader>[g <Plug>(lsp-previous-diagnostic)
        nmap <buffer> <Leader>]g <Plug>(lsp-next-diagnostic)
        nmap <buffer> K <plug>(lsp-hover)
    endfunction

    " Call s:on_lsp_buffer_enabled only for languages with registered
    " servers
    augroup lsp_install
        autocmd!
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END
endif



" Floating Term - Respect to Huytd
if has('nvim')
    let s:float_term_border_win = 0
    let s:float_term_win = 0
    function! FloatTerminal(...)
        " Configuration
        let height = float2nr((&lines - 2) * 0.6)
        let row = float2nr((&lines - height) / 2)
        let width = float2nr(&columns * 0.6)
        let col = float2nr((&columns - width) / 2)
        " Border Window
        let border_opts = {
            \ 'relative': 'editor',
            \ 'row': row - 1,
            \ 'col': col - 2,
            \ 'width': width + 4,
            \ 'height': height + 2,
            \ 'style': 'minimal'
            \ }
        " Terminal Window
        let opts = {
            \ 'relative': 'editor',
            \ 'row': row,
            \ 'col': col,
            \ 'width': width,
            \ 'height': height,
            \ 'style': 'minimal'
            \ }
        let top = "╭" . repeat("─", width + 2) . "╮"
        let mid = "│" . repeat(" ", width + 2) . "│"
        let bot = "╰" . repeat("─", width + 2) . "╯"
        let lines = [top] + repeat([mid], height) + [bot]
        let bbuf = nvim_create_buf(v:false, v:true)
        call nvim_buf_set_lines(bbuf, 0, -1, v:true, lines)
        let s:float_term_border_win = nvim_open_win(bbuf, v:true, border_opts)
        let buf = nvim_create_buf(v:false, v:true)
        let s:float_term_win = nvim_open_win(buf, v:true, opts)
        " Styling
        hi FloatWinBorder guifg=#87bb7c
        call setwinvar(s:float_term_border_win, '&winhl', 'Normal:FloatWinBorder')
        call setwinvar(s:float_term_win, '&winhl', 'Normal:Normal')
        if a:0 == 0
            terminal
        else
            call termopen(a:1)
        endif
        startinsert
        " Close border window when terminal window close
        autocmd TermClose * ++once :bd! | call nvim_win_close(s:float_term_border_win, v:true)
    endfunction
    " Open float terminal
    nnoremap <Leader>ft :call FloatTerminal()<CR>
endif

" Gutentags, generating tag files
" > Brentyi's version can suppresses some errors for machines without ctags installed
Plug 'brentyi/vim-gutentags'

" Set cache location
let g:gutentags_cache_dir = '~/.vim/.cache/tags'

" Enable extra ctags features
" - a: Access/export of class members
" - i: Inheritance information
" - l: Programming language
" - m: Implementation information
" - n: Line number
" - S: Signature of routine (e.g. prototype or parameter list)
let g:gutentags_ctags_extra_args = [
    \ '--fields=+ailmnS',
    \ ]

" Disable tag generation if using an LSP
if g:hung_use_lsp
    let g:gutentags_enabled = 0
endif

" If we have a hardcoded repository root, use for gutentags
if exists('g:repo_file_search_root')
    function! FindRepoRoot(path)
        return g:repo_file_search_root
    endfunction
    let g:gutentags_project_root_finder = "FindRepoRoot"
endif

" Lightline integration
function! GutentagsStatus()
    if exists('g:gutentags_ctags_executable') && executable(expand(g:gutentags_ctags_executable, 1)) == 0
        return 'missing ctags'
    endif
    return ''
endfunction
augroup GutentagsStatusLineRefresher
    autocmd!
    autocmd User GutentagsUpdating call lightline#update()
    autocmd User GutentagsUpdated call lightline#update()
augroup END

" Summarize tags in current file
Plug 'majutsushi/tagbar'
nmap <Leader>tbt :TagbarToggle<CR>
let g:tagbar_show_linenumbers = 2
let g:tagbar_map_nexttag = 'J'
let g:tagbar_map_prevtag = 'K'


" Status line
Plug 'itchyny/lightline.vim'

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
    \            [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \            [ 'gutentags' ],
    \            [ 'filepath' ],
    \            [ 'truncate' ]]
    \ }
let g:lightline.inactive = {
    \ 'left': [ [ 'readonly', 'filename', 'modified' ] ],
    \ 'right': [ [],
    \            [],
    \            [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \            [ 'filepath', 'lineinfo' ],
    \            [ 'truncate' ]]
    \ }

" Components
let g:lightline.component = {
    \   'charvaluehex': '0x%B',
    \   'gutentags': '%{GutentagsStatus()}%{gutentags#statusline("", "", "[ctags indexing]")}',
    \   'signify': has('patch-8.0.902') ? '%{sy#repo#get_stats_decorated()}' : '',
    \   'truncate': '%<',
    \ }
let g:lightline.component_function = {
    \   'filepath': string(function('s:lightline_filepath')),
    \ }
let g:lightline.component_expand = {
    \  'linter_checking': 'lightline#ale#checking',
    \  'linter_infos': 'lightline#ale#infos',
    \  'linter_warnings': 'lightline#ale#warnings',
    \  'linter_errors': 'lightline#ale#errors',
    \  'linter_ok': 'lightline#ale#ok',
    \ }
let g:lightline.component_type = {
    \     'linter_checking': 'right',
    \     'linter_infos': 'right',
    \     'linter_warnings': 'warning',
    \     'linter_errors': 'error',
    \     'linter_ok': 'ok',
    \ }


" fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Use Vim colors for fzf
let g:fzf_layout = {
    \ 'window': 'new'
    \ }

noremap ` :Files<CR>
noremap ; :Buffers<CR>

call plug#end()

" == Other settings ==
" Do some easy settings
if !s:fresh_install
    set wildmenu
    set wildmode=longest:full,full
    syntax on
    set clipboard=unnamedplus
    set number
    set relativenumber
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
    set termguicolors
    set foldlevel=99
    set foldmethod=indent
    set list listchars=tab:❘-,trail:\ ,extends:»,precedes:«,nbsp:×
    filetype plugin indent on

    " Bindings for switching between tabs
    set splitbelow
    set splitright

    vnoremap <Tab> >
    vnoremap <S-Tab> <

    nnoremap <Leader>tt :tabnew<CR>
    nnoremap <Leader>tn :tabn<CR>
    
    " Bindings for copy,del to end-of-line
    nnoremap Y y$
    nnoremap D d$

    " Color
    set background=dark
    augroup ColorschemeCustomizes 
        autocmd!
        function! s:ColorschemeCustomizes()
    set ww+=<,>,[,]
            if g:hung_colorscheme == 'legacy'
                " Fallback colors for some legacy terminals
                set t_Co=16
                set foldcolumn=1
                hi FoldColumn ctermbg=7
                hi LineNr cterm=bold ctermfg=0 ctermbg=0
                hi CursorLineNr ctermfg=0 ctermbg=7
                hi Visual cterm=bold ctermbg=1
                hi TrailingWhitespace ctermbg=1
                hi Search ctermfg=4 ctermbg=7
            else
                " When 256 colors available
                set t_Co=256
                hi LineNr ctermfg=241 ctermbg=234
                hi CursorLineNr cterm=bold ctermfg=232 ctermbg=250
                hi Visual cterm=bold ctermbg=238
                hi TrailingWhitespace ctermbg=52
                let g:indentLine_color_term=237
            endif
        endfunction
        autocmd ColorScheme * call s:ColorschemeCustomizes()
    augroup END

    let g:hung_colorscheme = get(g:, 'hung_colorscheme', 'dracula')
    if g:hung_colorscheme != 'legacy'
        execute 'colorscheme ' . g:hung_colorscheme
    else
        execute 'colorscheme peachpuff'
    endif


    " This maps <Leader>f to toggle between:
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



