-- Neovim version check.
local MIN_VERSION = "0.11"
if vim.fn.has("nvim-" .. MIN_VERSION) ~= 1 then
	vim.api.nvim_echo({
		{ "Warning: ", "WarningMsg" },
		{ "This configuration expects Neovim >= " .. MIN_VERSION .. "\n", "Normal" },
		{ "Some features may not work correctly with current version: ", "Normal" },
		{ vim.fn.execute("version"):match("NVIM v%S+"), "Title" },
	}, true, {})
end

-- Space is the leader
vim.g.mapleader = " "
vim.opt.timeoutlen = 200
vim.opt.ttimeoutlen = 10

-- Mouse is enabled in friendly mode, not by default.
vim.opt.mouse = ""

-- Visuals.
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.showmode = false
vim.opt.scrolloff = 6

-- Suppress swap file errors.
vim.opt.shortmess:append("A")
vim.opt.autoread = true

-- Use the system clipboard for all yank, delete, and put operations.
vim.opt.clipboard = "unnamedplus"

-- Disable netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 4-spaces tab please!
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Bindings for common things.
vim.keymap.set("n", "<Esc>", ":noh | redraw!<CR>", { silent = true, desc = "[Search] Clear search highlighting" })
vim.keymap.set("n", "<Leader>ip", ":set invpaste<CR>", { desc = "[Edit] Toggle paste mode" })
vim.keymap.set("n", "<Leader>rw", ":%s/\\<<C-r><C-w>\\>/", { desc = "[Edit] Replace word under cursor" }) -- "replace this word".
vim.keymap.set("n", "Y", "y$", { desc = "[Edit] Yank to End of Line" })
vim.keymap.set("n", "D", "d$", { desc = "[Edit] Delete to End of Line" })
vim.keymap.set("n", "<Leader>6", "<C-^>", { desc = "[Window] Switch to Last Buffer" })


-- Window cleanup
vim.keymap.set("n", "<Leader>c", function()
    local function pclose(cmd) pcall(vim.cmd, cmd) end
    pclose("pclose") -- Close preview windows
    pclose("cclose") -- Close quickfix windows
    pclose("lclose") -- Close location list windows
    pclose("helpclose") -- Close help windows
    -- Close the Trouble plugin window if it's open
    local success, trouble = pcall(require, "trouble")
    if success then trouble.close() end
    -- Close any open Fugitive buffers (like :G status)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.fn.bufname(buf):match("^fugitive://") then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
end, { desc = "[Window] Close Special Windows" })

-- Friendly mode ^^
local friendly_mode_is_active = true
local function toggle_friendly_mode(verbose)
	if friendly_mode_is_active then
		vim.keymap.set("n", "<Up>", function()
			vim.cmd("resize -3")
		end, { desc = "[Window] Decrease Height" })
		vim.keymap.set("n", "<Down>", function()
			vim.cmd("resize +3")
		end, { desc = "[Window] Increase Height" })
		vim.keymap.set("n", "<Left>", function()
			vim.cmd("vertical resize -3")
		end, { desc = "[Window] Decrease Width" })
		vim.keymap.set("n", "<Right>", function()
			vim.cmd("vertical resize +3")
		end, { desc = "[Window] Increase Width" })
		vim.opt.mouse = ""
		friendly_mode_is_active = false
		if verbose then
			vim.notify(
				"Friendly mode disabled: Arrow keys resize splits.",
				vim.log.levels.INFO,
				{ title = "Mode Change" }
			)
		end
	else
		pcall(vim.api.nvim_del_keymap, "n", "<Up>")
		pcall(vim.api.nvim_del_keymap, "n", "<Down>")
		pcall(vim.api.nvim_del_keymap, "n", "<Left>")
		pcall(vim.api.nvim_del_keymap, "n", "<Right>")
		vim.opt.mouse = "a"
		friendly_mode_is_active = true
		if verbose then
			vim.notify("Friendly mode enabled: Arrow keys move cursor.", vim.log.levels.INFO, { title = "Mode Change" })
		end
	end
end
vim.keymap.set("n", "<Leader>f", function()
	toggle_friendly_mode(true)
end, { silent = true, desc = "[UI] Toggle Friendly/Resize Mode" })
toggle_friendly_mode(false) -- Disable by default

-- Show virtual text for diagnostics (lsp errors, etc.)
vim.diagnostic.config({
	virtual_text = {
		current_line = false,
	},
	signs = false,
})

-- Install lazy.nvim. (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Make sure a package is installed via Mason.
INSTALL_IF_MISSING = function(filetype, package_name)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = filetype,
		callback = function()
			local registry = require("mason-registry")
			local notify = function(message, level, opts)
				return require("notify").notify(message, level, opts)
			end

			if not registry.is_installed(package_name) then
				local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

				registry.refresh()
				local install_handle = registry.get_package(package_name):install()
				local notif_id = notify("", "info", {}).id
				while not install_handle:is_closed() do
					---@diagnostic disable-next-line: missing-parameter
					local spinner_index = (math.floor(vim.fn.reltimefloat(vim.fn.reltime()) * 10.0)) % #spinner_frames
						+ 1
					notif_id = notify("Installing " .. package_name .. "...", 2, {
						title = "Setup",
						icon = spinner_frames[spinner_index],
						replace = notif_id,
					}).id
					vim.wait(100)
					vim.cmd("redraw")
				end

				if registry.is_installed(package_name) then
					---@diagnostic disable-next-line: missing-fields
					notify("Installed " .. package_name, 2, {
						title = "Setup",
						icon = "✓",
						replace = notif_id,
					})
				else
					---@diagnostic disable-next-line: missing-fields
					notify("Failed to install " .. package_name, "error", {
						title = "Setup",
						icon = "𐄂",
						replace = notif_id,
					})
				end
			end
		end,
	})
end

-- Configure plugins.
local lazy_plugins = {
	-- Color scheme.
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			require("onedark").setup({ style = "darker" })
			vim.cmd.colorscheme("onedark")
		end,
	},
	-- Statusline.
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			-- to display invpaste (paste mode) status
			local function paste_indicator()
				if vim.o.paste then
					return "PASTE"
				end
				return ""
			end

			require("lualine").setup({
				options = {
					icons_enabled = false,
					theme = "auto",
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode", paste_indicator }, -- 3. Use the function here
					lualine_b = { "filename" },
					lualine_c = { "diff" },
					lualine_x = {
						{
							function()
								return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
							end,
							color = { fg = "#777777" },
						},
						"diagnostics",
					},
					lualine_y = { "filetype", "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	-- Notification
	{
		"rcarriga/nvim-notify",
		opts = {
			icons = {
				DEBUG = "[D]",
				ERROR = "[E]",
				INFO = "[I]",
				TRACE = "[T]",
				WARN = "[W]",
			},
		},
	},
	-- LSP progress indicator.
	{ "j-hui/fidget.nvim", opts = {} },
	-- Syntax highlighting.
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
					-- additional_vim_regex_highlighting = { "markdown" },
				},
				indent = { enable = true },
			})
		end,
	},
	-- Show indentation guides.
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#573757" })
			vim.api.nvim_set_hl(0, "IblScope", { fg = "#555585" })
			require("ibl").setup({ indent = { char = "·" }, scope = { show_start = false, show_end = false } })
		end,
	},
	-- Fuzzy find.
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("telescope").setup({ pickers = { find_files = { hidden = true } } })
			require("telescope").load_extension("fzf")

			-- Use repository root as cwd for Telescope.
			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "*",
				callback = vim.schedule_wrap(function()
					local root = vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
					if root ~= nil then
						vim.b["Telescope#repository_root"] = root
					else
						vim.b["Telescope#repository_root"] = "."
					end
				end),
			})
			vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")
			vim.api.nvim_create_autocmd("User", {
				pattern = "TelescopePreviewerLoaded",
				callback = function() vim.opt_local.number = true end,
			})

			-- Bindings.
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<C-p>", function()
				builtin.find_files({ cwd = vim.b["Telescope#repository_root"] })
			end, { desc = "[Search] Ctrl + P" })
			vim.keymap.set("n", "`", function()
				builtin.live_grep({ cwd = vim.b["Telescope#repository_root"] })
			end, { desc = "[Search] Grep" })
			vim.keymap.set("n", "<C-`>", function()
				builtin.grep_string({ cwd = vim.b["Telescope#repository_root"] })
			end, { desc = "[Search] Grep cursor-word" })
			vim.keymap.set("n", ";", builtin.buffers, { desc = "[Search] Find buffers" })
			vim.keymap.set("n", "<C-;>", builtin.oldfiles, { desc = "[Search] Recent files" })
			vim.keymap.set("n", "<Leader>h", builtin.help_tags, { desc = "[Search] Find help" })
		end,
	},
	-- Tagbar-style code overview.
	{
		"stevearc/aerial.nvim",
		config = function()
			require("aerial").setup()
			vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "[Code] Toggle outline" })
		end,
	},
	-- Git helpers.
	{
		"tpope/vim-fugitive",
		keys = {
			{ "<Leader>vs", function() vim.cmd("G status") end, desc = "[VCS] Git status" },
			{ "<Leader>vd", function() vim.cmd("G diff") end, desc = "[VCS] Git diff" },
			{ "<Leader>vb", function() vim.cmd("G blame") end, desc = "[VCS] Git blame" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = true,
		keys = {
			{ "<Leader>hp", function() require("gitsigns").preview_hunk() end, desc = "[VCS] Preview hunk" },
			{ "<Leader>hu", function() require("gitsigns").reset_hunk() end, desc = "[VCS] Undo hunk" },
		},
	},
	{ "akinsho/git-conflict.nvim", version = "*", config = true },
	-- Comments.
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
			-- For normal mode, map to 'gcc' (works linewise and as an operator)
			vim.keymap.set("n", "<C-/>", "gcc", {
				remap = true,
				desc = "[Code] Toggle Comment (Normal)",
			})
			-- For visual mode, map to 'gc' (works on the selection)
			vim.keymap.set("v", "<C-/>", "gc", {
				remap = true,
				desc = "[Code] Toggle Comment (Visual)",
			})
		end,
	},
	-- Motions
	{
		"easymotion/vim-easymotion",
		init = function()
			vim.keymap.set("n", "s", "<Plug>(easymotion-overwin-f)", { desc = "[Motion] EasyMotion Find Character" })
			vim.keymap.set("n", "S", "<Plug>(easymotion-overwin-w)", { desc = "[Motion] EasyMotion Find Word" })
		end,
	},
	{ "kylechui/nvim-surround", config = true },
	-- Save my cursor position when I close a file.
	{ "vim-scripts/restore_view.vim" },
	-- File tree.
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			default_component_configs = {
				icon = {
					folder_closed = "+",
					folder_open = "-",
					folder_empty = "%",
					default = "",
				},
				git_status = {
					symbols = {
						deleted = "x",
						renamed = "r",
						modified = "m",
						untracked = "u",
						ignored = "i",
						unstaged = "u",
						staged = "s",
						conflict = "c",
					},
				},
				name = {
					use_git_status_colors = true,
				},
			},
			filesystem = {
				bind_to_cwd = false,
				hijack_netrw_behavior = "open_current",
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = false,
				},
			},
		},
		keys = {
			{ "<C-n>", "<cmd>Neotree toggle<CR>", desc = "[File] Open tree" },
		},
	},
	-- Automatically set indentation settings.
	{ "NMAC427/guess-indent.nvim", config = true },
	-- Misc visuals from mini.nvim.
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.animate").setup({
				cursor = { enable = false },
				scroll = { enable = false },
			})
			require("mini.cursorword").setup()
			require("mini.trailspace").setup()
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
		end,
	},
	-- Split navigation. Requires corresponding changes to tmux config for tmux
	-- integration.
	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			local nvim_tmux_nav = require("nvim-tmux-navigation")
			nvim_tmux_nav.setup({
				disable_when_zoomed = true, -- defaults to false
			})
			vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, { desc = "[Nav] Move left" })
			vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, { desc = "[Nav] Move down" })
			vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, { desc = "[Nav] Move up" })
			vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, { desc = "[Nav] Move right" })
			vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive, { desc = "[Nav] Last active" })
			vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext, { desc = "[Nav] Next pane" })
		end,
	},
	-- Package management.
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	-- Formatting.
	{
		"mhartington/formatter.nvim",
		config = function()
			-- Format keybinding.
			vim.keymap.set("n", "<Leader>cf", ":Format<CR>", { noremap = true, desc = "[Code] Format" })

			-- Automatically install formatters via Mason.
			INSTALL_IF_MISSING("lua", "stylua")
			INSTALL_IF_MISSING("c,cpp,cuda", "clang-format")
			INSTALL_IF_MISSING("python", "isort")
			INSTALL_IF_MISSING("python", "ruff") -- ruff > (isort + black)
			INSTALL_IF_MISSING("typescript,javascript,typescriptreact,javascriptreact", "prettier")
			INSTALL_IF_MISSING("html,css", "prettier")

			-- Configure formatters.
			local util = require("formatter.util")
			require("formatter").setup({
				logging = true,
				log_level = vim.log.levels.WARN,
				filetype = {
					-- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
					lua = { require("formatter.filetypes.lua").stylua },
					cpp = { require("formatter.filetypes.cpp").clangformat },
					go = { require("formatter.filetypes.go").goimports },
					python = { require("formatter.filetypes.python").isort, require("formatter.filetypes.python").ruff },
					typescript = { require("formatter.filetypes.typescript").prettier },
					typescriptreact = { require("formatter.filetypes.typescript").prettier },
					javascript = { require("formatter.filetypes.javascript").prettier },
					javascriptreact = { require("formatter.filetypes.javascript").prettier },
					html = { require("formatter.filetypes.html").prettier },
					css = { require("formatter.filetypes.css").prettier },
					svg = { require("formatter.filetypes.xml").tidy },
					markdown = { require("formatter.filetypes.markdown").prettier },
					["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
				},
			})
		end,
	},
	-- Language servers.
	{ "williamboman/mason-lspconfig.nvim", config = true },
	-- Completion sources.
	{ "hrsh7th/cmp-nvim-lsp" }, -- lsp
	{ "hrsh7th/cmp-buffer" }, -- typed words
	{ "hrsh7th/cmp-path" }, -- filesystem path when type /
	{ "hrsh7th/cmp-cmdline" }, -- after :
	{ "hrsh7th/cmp-nvim-lsp-signature-help" }, -- required arguments in the popup menu
	{ "hrsh7th/cmp-emoji" }, -- emoji, type :
	{
		"github/copilot.vim",
		config = function()
			-- Off by default
			local copilot_default_enabled = false
			if copilot_default_enabled then
				vim.cmd("Copilot enable")
			else
				vim.cmd("Copilot disable")
			end
			vim.g.copilot_enabled = copilot_default_enabled

			-- Toggle Copilot
			vim.api.nvim_create_user_command("ToggleCopilot", function()
				if vim.g.copilot_enabled then
					vim.cmd("Copilot disable")
					vim.g.copilot_enabled = false
					vim.notify("Copilot disabled", vim.log.levels.INFO, { title = "Copilot" })
				else
					vim.cmd("Copilot enable")
					vim.g.copilot_enabled = true
					vim.notify("Copilot enabled", vim.log.levels.INFO, { title = "Copilot" })
				end
			end, {})

			vim.g.copilot_no_tab_map = true
			vim.api.nvim_set_keymap("i", "<C-c>", "<Esc><C-c>", { noremap = true, desc = "[Edit] Exit insert mode" }) -- prevent accidentally accepting suggestion
			vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Accept("<CR>")', { silent = true, expr = true, desc = "[Copilot] Accept suggestion" })
			vim.api.nvim_set_keymap("n", "<Leader>cc", "<cmd>ToggleCopilot<CR>", { desc = "[Copilot] Toggle On/Off" })
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
					return false
				end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end

			-- Set up nvim-cmp.
			local cmp = require("cmp")
			cmp.setup({
				-- `vim.snippet` is introduced in Neovim 0.10 and will be used by default.
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = vim.schedule_wrap(function(fallback)
						if cmp.visible() and has_words_before() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end),
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "emoji" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "emoji" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` and `?` (if native_menu is enabled, this will not work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if native_menu is enabled, this will not work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { { "folke/neodev.nvim", config = true } },
		config = function()
			-- Dim LSP errors.
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#6c1010" })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#434300" })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#303f5a" })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#305a35" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#333333", bg = "#a7a7a7" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2b2b2b" })

			-- Automatically install language servers via Mason.
			INSTALL_IF_MISSING("python", "pyright")
			INSTALL_IF_MISSING("lua", "lua-language-server")
			INSTALL_IF_MISSING("c,cpp,cuda", "clangd")
			INSTALL_IF_MISSING("go", "gopls")
			INSTALL_IF_MISSING("go", "goimports")
			INSTALL_IF_MISSING("typescript,javascript,typescriptreact,javascriptreact", "typescript-language-server")
			INSTALL_IF_MISSING("typescript,javascript,typescriptreact,javascriptreact", "eslint-lsp")
			INSTALL_IF_MISSING("html", "html-lsp")
			INSTALL_IF_MISSING("css", "css-lsp")
			INSTALL_IF_MISSING("plaintex", "texlab")

			-- Config lsp
			vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" }}}}})

			-- Enable lsp
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("pyright")
			vim.lsp.enable("ts_ls")
			vim.lsp.enable("html")
			vim.lsp.enable("cssls")
			vim.lsp.enable("eslint")
			vim.lsp.enable("texlab")
			vim.lsp.enable("clangd")
			vim.lsp.enable("gopls")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					vim.api.nvim_create_autocmd("CursorHold", {
						buffer = ev.buf,
						callback = function()
							vim.diagnostic.open_float(nil, {
								focusable = false,
								close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
								border = "rounded",
								source = "always",
								prefix = " ",
								scope = "cursor",
							})
						end,
					})

					local function bmap(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
					end
					bmap("<Leader>gd", vim.lsp.buf.definition, "[LSP] Go to definition")
					bmap("<Leader>gt", vim.lsp.buf.type_definition, "[LSP] Go to type definition")
					bmap("<Leader>gi", vim.lsp.buf.implementation, "[LSP] Go to implementation")
					bmap("<Leader>gr", vim.lsp.buf.references, "[LSP] Find references")
					bmap("<Leader>ca", vim.lsp.buf.code_action, "[LSP] Code actions")
					bmap("<Leader>sd", vim.diagnostic.setqflist, "[LSP] Show diagnostics")
					bmap("K", function()
						vim.lsp.buf.hover({ border = "single", max_height = 25, max_width = 120 })
					end, "[LSP] Hover")
				end,
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "[Help] Show buffer keymaps",
			},
		},
	},
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		mode = "legacy",
		lazy = false,
		version = false, -- latest change
		opts = {
			windows = {
				sidebar_header = {
					align = "left", -- title: left, center, right
					rounded = false,
				},
			},
			providers = {
				claude = {
					disable_tools = true,
				},
			},
		},
		build = "make",
		dependencies = {
			-- "nvim-tree/nvim-web-devicons",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
	},
}

local lazy_opts = {
	-- Unicode icons, no custom fonts needed
	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			lazy = "💤 ",
			plugin = "🔌",
			require = "🌙",
			runtime = "💻",
			source = "📄",
			start = "🚀",
			task = "📌",
		},
	},
	lockfile = "~/dotfiles/common/lazy-lock.json",
}
require("lazy").setup(lazy_plugins, lazy_opts)
