" enc_utf-8.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-02-19.
" @Last Change: 2012-08-20.
" @Revision:    10

if !exists("g:vikiUpperCharacters")
    let g:vikiUpperCharacters = "A-ZÄÖÜÁÀÉÈÍÌÓÒÇÑ"
endif
if !exists("g:vikiLowerCharacters")
    let g:vikiLowerCharacters = "a-zäöüßáàéèíìóòçñ"
endif

if !exists('g:viki_viki#conceal_extended_link_cchar')
    " let g:viki_viki#conceal_extended_link_cchar = '►'
    let g:viki_viki#conceal_extended_link_cchar = '↑'
endif

