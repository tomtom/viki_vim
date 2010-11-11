" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/viki_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-08-16.
" @Last Change: 2010-10-24.
" @Revision:    4

if exists('g:vikiNameSuffix') && !empty(g:vikiNameSuffix)
    exec 'autocmd BufRead,BufNewFile *'. g:vikiNameSuffix .' set filetype=viki'
endif

