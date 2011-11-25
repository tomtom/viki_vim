" viki.vim -- viki indentation
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     16-Jän-2004.
" @Last Change: 2011-10-21.
" @Revision: 0.268

if exists("b:did_indent") || exists("g:vikiNoIndent")
    finish
endif
let b:did_indent = 1

" Possible values: 'sw', '::'
if !exists("g:vikiIndentDesc") | let g:vikiIndentDesc = 'sw' | endif "{{{2

setlocal indentexpr=viki#GetIndent()
" setlocal indentkeys&
setlocal indentkeys=0=#\ ,0=?\ ,0=<*>\ ,0=-\ ,0=+\ ,0=@\ ,=::\ ,!^F,o,O
" setlocal indentkeys=0=#<space>,0=?<space>,0=<*><space>,0=-<space>,=::<space>,!^F,o,O
" setlocal indentkeys=0=#<space>,0=?<space>,0=<*><space>,0=-<space>,=::<space>,!^F,o,O,e

