" Load defaults
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

packadd comment
packadd! editorconfig
packadd! matchit
packadd nohlsearch

let g:EditorConfig_max_line_indicator = 'none'

" Start insert mode sets cursor to bar
let &t_SI = "\e[5 q"

" Start replace mode sets cursor to underline
let &t_SR = "\e[3 q"

" End insert/replace mode sets cursor to block
let &t_EI = "\e[1 q"

set autoindent
set hlsearch
set incsearch

if &diff
	" Adjust syntax highlighting for diff. See scripts/256.sh
	highlight DiffAdd cterm=bold ctermbg=68 ctermfg=none
	highlight DiffChange cterm=bold ctermbg=68 ctermfg=none
	highlight DiffDelete cterm=bold ctermbg=134 ctermfg=none
	highlight DiffText cterm=bold ctermbg=234 ctermfg=none

	" git diffs reside in /tmp and will not be affected by .editorconfig
	set shiftwidth=4
	set softtabstop=4
	set tabstop=4
else
	" Save manual folds when not in diff mode
	augroup save_folds
		autocmd!
		autocmd BufWinEnter * silent! loadview
		autocmd BufWinLeave * silent! mkview!
	augroup END
endif
