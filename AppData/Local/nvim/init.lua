local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use 'tpope/vim-sensible'
	use 'tpope/vim-eunuch'
	use 'tpope/vim-sleuth'
	use 'tpope/vim-commentary'
	use 'tpope/vim-surround'
	use 'tpope/vim-fugitive'

	use 'vim-airline/vim-airline'

	use 'jiangmiao/auto-pairs'

	use { 'dracula/vim', as = 'dracula' }

	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
	use { 'numToStr/Comment.nvim' }
	use 'JoosepAlviste/nvim-ts-context-commentstring'
	use 'p00f/nvim-ts-rainbow'
	use 'windwp/nvim-ts-autotag'
	use 'nvim-treesitter/nvim-treesitter-refactor'

	use 'gelguy/wilder.nvim'

	if packer_bootstrap then
		require('packer').sync()
	end
end)

vim.opt.termguicolors = true
vim.opt.mouse = 'a'

vim.cmd [[colorscheme dracula]]

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.hlsearch = true

require('nvim-treesitter.configs').setup {
	ensure_installed = "all",

	sync_installed = false,

	ignore_install = { "phpdoc" },

	highlight = {
		enable = true,

		disable = { "phpdoc" },

		additional_vim_regex_highlighting = true,
	},

	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
		colors = {
			"#F8F8F2",
			"#FF79C6",
			"#8BE9FD",
			"#50FA7B",
			"#BD93F9",
			"#FFB86C",
		}
	},

	autotag = {
		enable = true,
	},

	refactor = {
		highlight_current_scope = { enable = false},
		smart_rename = {
			enable = true,
			keymaps = {
				smart_rename = "grr",
			},
		},
		navigation = {
			enable = true,
			keymaps = {
				goto_definition = "gnd",
				list_definitions = "gnD",
				list_definitions_toc = "gO",
				goto_next_usage = "<a-*>",
				goto_previous_usage = "<a-#>",
			},
		},
	},

	context_commentstring = {
		enable = true
	},
}

require('Comment').setup({})
require('wilder').setup({})
