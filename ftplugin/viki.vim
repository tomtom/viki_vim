" viki.vim -- the viki ftplugin
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     12-Jän-2004.
" @Last Change: 2012-09-07.
" @Revision: 522

if exists("b:did_ftplugin") "{{{2
    finish
endif
let b:did_ftplugin = 1


" Defines the prefix of comments when in "full" viki mode.
" In minor mode this variable is set to either:
"     - b:commentStart
"     - b:ECcommentOpen
"     - matchstr(&commentstring, "^\\zs.*\\ze%s")
let b:vikiCommentStart = "%" "{{{2
let b:vikiCommentEnd   = "" "{{{2
let b:vikiHeadingMaxLevel = -1 "{{{2

if !exists("b:vikiMaxFoldLevel")
    let b:vikiMaxFoldLevel = 5 "{{{2
endif

if !exists("b:vikiInverseFold")
    " If set, the section headings' levels are folded in reversed order 
    " so that |b:vikiMaxFoldLevel| corresponds to the top level and 1 to 
    " the lowest level. This is useful when maintaining a file with a 
    " fixed structure where the important things happen in subsections 
    " while the top sections change little.
    let b:vikiInverseFold  = 0 "{{{2
endif


exec "setlocal commentstring=". substitute(b:vikiCommentStart, "%", "%%", "g") 
            \ ."%s". substitute(b:vikiCommentEnd, "%", "%%", "g")
exec "setlocal comments=fb:-,fb:+,fb:*,fb:#,fb:?,fb:@,:". b:vikiCommentStart

setlocal expandtab
" setlocal iskeyword+=#,{
setlocal iskeyword+={
setlocal iskeyword-=_
let &l:include='\(^\s*#INC.\{-}\(\sfile=\|:\)\)'
let &l:define='^\s*\(#Def.\{-}id=\|#\(Fn\|Footnote\).\{-}\(:\|id=\)\|#VAR.\{-}\s\)'

if g:vikiFoldLevel > 0 && &l:foldlevel == 0
    let &l:foldlevel = g:vikiFoldLevel
endif

if has('balloon_multiline')
    call tlib#balloon#Register('viki#Balloon()')
endif


map <buffer> <silent> [[ :call viki#FindPrevHeading()<cr>
map <buffer> <silent> ][ :call viki#FindNextHeading()<cr>
map <buffer> <silent> ]] ][
map <buffer> <silent> [] [[
vnoremap <buffer> <expr> ii viki#ListItemTextObject()
omap <buffer> ii :normal Vii<cr>


let b:undo_ftplugin = 'setlocal iskeyword< expandtab< foldtext< foldexpr< foldmethod< comments< commentstring< '
            \ .'define< include<'
            \ .'| unlet b:vikiHeadingMaxLevel b:vikiCommentStart b:vikiCommentEnd b:vikiInverseFold b:vikiMaxFoldLevel '
            \ .' b:vikiEnabled '
            \ .'| unmap <buffer> [['
            \ .'| unmap <buffer> ]]'
            \ .'| unmap <buffer> ]['
            \ .'| unmap <buffer> []'

if g:vikiAutoupdateFiles
    call viki#FilesUpdateAll()
endif

if g:vikiFoldMethodVersion == 0 "{{{2
    finish
else
    setlocal foldmethod=expr
    setlocal foldexpr=viki#FoldLevel(v:lnum)
    setlocal foldtext=viki#FoldText()
    autocmd viki CursorHold,CursorHoldI,InsertLeave <buffer> call viki#UpdateHeadings()
    call viki#UpdateHeadings()
endif

let b:vikiEnabled = 2

