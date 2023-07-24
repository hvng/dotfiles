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


" ###############################################
" ################### Plugins ###################
" ###############################################
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
map <Leader>/ <Plug>NERDCommenterToggle<CR>


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


" Display markers to signify different indentation levels
Plug 'Yggdroot/indentLine'
let g:indentLine_char = '·'
let g:indentLine_fileTypeExclude = ['json', 'markdown', 'tex']


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

" ###############
" > NEOVIM PLUG <
" ###############
" LONGIF
" Functions are called after plug#end. Note: Can't indent the lua code
if has("nvim")

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

function! s:treesitter_configure()
lua << EOF
require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = {
        "cpp",
        "lua",
        "vim",
        "python",
        "html",
        "css",
        "javascript",
        "markdown",
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to ignore installing (for "all")
    ignore_install = {},

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of language that will be disabled
        disable = {},

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}
EOF
endfunction


" LSP plugs for autocompletion, jump to def, etc
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

" Make colors a bit less distracting
augroup LspColors
    autocmd!
    function! s:SetLspColors()
        highlight DiagnosticVirtualTextError ctermfg=238 guifg=#8c3032
        highlight DiagnosticVirtualTextWarn ctermfg=238 guifg=#5a5a30
        highlight DiagnosticVirtualTextInfo ctermfg=238 guifg=#303f5a
        highlight DiagnosticVirtualTextHint ctermfg=238 guifg=#305a35
    endfunction
    autocmd ColorScheme * call s:SetLspColors()
augroup END

function! s:configure_mason()
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup()

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = function()
                local opts = {
                    focusable = false,
                    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                    border = "rounded",
                    source = "always",
                    prefix = " ",
                    scope = "cursor",
                }
                vim.diagnostic.open_float(nil, opts)
            end
        })
        vim.lsp.handlers["textDocument/hover"] =
            vim.lsp.with(
            vim.lsp.handlers.hover,
            {
                border = "rounded"
            }
        )

        vim.lsp.handlers["textDocument/signatureHelp"] =
            vim.lsp.with(
            vim.lsp.handlers.signature_help,
            {
                border = "rounded"
            }
        )

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>la', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>lr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>ll', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<C-S-d>', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<C-S-f>', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
EOF
endfunction


" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-emoji'

" Completion bindings
" Use <CR> for completion confirmation, <Tab> and <S-Tab> for selection
function! s:smart_carriage_return()

    if !pumvisible()
        " No completion window open -> insert line break
        return "\<CR>"
    endif
    if exists('*complete_info') && complete_info()['selected'] == -1
        " No element selected: close the completion window with Ctrl+E, then
        " carriage return
        "
        " Requires Vim >8.1ish
        return "\<C-e>\<CR>"
    endif

    " Select completion
    return "\<C-y>"
endfunction
inoremap <expr> <CR> <SID>smart_carriage_return()

smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

function! s:setup_nvim_cmp()
lua << EOF
    local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
    end

    local cmp = require('cmp')
    -- Set up nvim-cmp.
    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            end,
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ["<Tab>"] = vim.schedule_wrap(function(fallback)
                if cmp.visible() and has_words_before() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end),
            ['<S-Tab>'] = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'emoji' },
            { name = 'path' },
            { name = 'vsnip' }, -- For vsnip users.
            -- { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        }, {
            { name = 'buffer' },
        })
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
            { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
            { name = 'emoji' }
        }, {
            { name = 'buffer' },
        })
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

    require("mason-lspconfig").setup {
        ensure_installed = { "pyright", "tsserver", "eslint", "clangd" },
    }

    -- Set up lspconfig.
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
        require("lspconfig").pyright.setup{
            capabilities = capabilities
        }
        require("lspconfig").tsserver.setup{
            capabilities = capabilities
        }
        require("lspconfig").eslint.setup{
            capabilities = capabilities
        }
        require("lspconfig").clangd.setup{
            capabilities = capabilities
        }
EOF
endfunction


Plug 'folke/trouble.nvim'

nmap <Leader><Tab> :TroubleToggle<CR>

function! s:configure_trouble()
lua << EOF
require("trouble").setup {
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = false, -- use devicons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = {"o"}, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = {"zM", "zm"}, -- close all folds
        open_folds = {"zR", "zr"}, -- open all folds
        toggle_fold = {"zA", "za"}, -- toggle fold of current file
        previous = "k", -- previous item
        next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warn ",
        hint = "hint ",
        information = "info "
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
  }
EOF
endfunction

" End LONGIF
endif

call plug#end()



" ##################################
" ############ SETTINGS ############
" ##################################
" Plugins are already installed, now time for the rest ^^
if !s:fresh_install
    syntax on
    set autochdir
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

    " Some stuffs for neovim
    if has('nvim')
        call s:configure_mason()
        call s:setup_nvim_cmp()
        call s:configure_trouble()
        call s:treesitter_configure()
    endif


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


    " ###########
    " > Visuals <
    " ###########

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

    " ##############################
    " > Key mappings for usability <
    " ##############################

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


    " ######################################
    " > Automatic window renaming for tmux <
    " ######################################
    if exists('$TMUX')
    augroup TmuxHelpers
      " TODO: fix strange behavior when we break-pane in tmux
        autocmd!
        autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter,FocusGained * call system('tmux rename-window "vim ' . expand('%:t') . '"')
        autocmd VimLeave,FocusLost * call system('tmux set-window-option automatic-rename')
    augroup END
    endif

    " ##############
    " > Spellcheck <
    " ##############
    map <F5> :setlocal spell! spelllang=en_us<CR>
    inoremap <F5> <C-\><C-O>:setlocal spelllang=en_us spell! spell?<CR>
    highlight clear SpellBad
    highlight SpellBad cterm=bold,italic ctermfg=red


    " ########
    " > Meta <
    " ########
    augroup AutoReloadVimRC
        autocmd!
        autocmd BufWritePost $MYVIMRC source $MYVIMRC

        " For init.vim->.vimrc symlinks in Neovim
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

