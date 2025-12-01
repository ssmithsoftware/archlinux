" Load defaults
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Start insert mode sets cursor to bar
let &t_SI = "\e[5 q"

" Start replace mode sets cursor to underline
let &t_SR = "\e[3 q"

" End insert/replace mode sets cursor to block
let &t_EI = "\e[1 q"

set autoindent
set hlsearch
set incsearch
set shiftwidth=4
set shortmess+=I
set softtabstop=-1

set tabstop=4

" Edit previous buffer in vertical split
nnoremap <Leader>ep :vertical sbprevious<CR>

" Edit/Source .vimrc
nnoremap <Leader>ev :vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>

" No highlight current search
nnoremap <Leader>nh :nohlsearch<CR>

" Remove all trailing whitespace before buffer write
augroup remove_whitespace
	autocmd!
	autocmd BufWritePre * %substitute/\s\+$//e
augroup END


if &diff
	" Adjust syntax highlighting for diff
	set termguicolors
else
	" Save manual folds when not in diff mode or help files
	augroup save_folds
		autocmd!
		autocmd BufWinEnter * silent! loadview
		autocmd BufWinLeave * mkview
	augroup END
endif
