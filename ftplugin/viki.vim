" viki.vim -- the viki ftplugin
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     12-Jän-2004.
" @Last Change: 2012-07-26.
" @Revision: 502

if exists("b:did_ftplugin") "{{{2
    finish
endif
let b:did_ftplugin = 1
" if exists("b:did_viki_ftplugin")
"     finish
" endif
" let b:did_viki_ftplugin = 1

" Defines the prefix of comments when in "full" viki mode.
" In minor mode this variable is set to either:
"     - b:commentStart
"     - b:ECcommentOpen
"     - matchstr(&commentstring, "^\\zs.*\\ze%s")
let b:vikiCommentStart = "%" "{{{2
let b:vikiCommentEnd   = "" "{{{2
let b:vikiHeadingMaxLevel = -1 "{{{2


if !exists("g:vikiFoldMethodVersion")
    " :nodoc:
    " Choose folding method version
    " Viki supports several methods (1..7) for defining folds. If you 
    " find that text entry is slowed down it is probably due to the 
    " chosen fold method. You could try to use another method (see 
    " ../ftplugin/viki.vim for alternative methods) or check out this 
    " vim tip:
    " http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text
    let g:vikiFoldMethodVersion = 8 "{{{2
endif

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
if !exists("g:vikiFoldBodyLevel")
    " Consider fold levels bigger that this as text body, levels smaller 
    " than this as headings
    " This variable is only used if |g:vikiFoldMethodVersion| is 1.
    " If set to 0, the "b" mode in |vikiFolds| will set the body level 
    " depending on the headings used in the current buffer. Otherwise 
    " |b:vikiHeadingMaxLevel| + 1 will be used.
    let g:vikiFoldBodyLevel = 6 "{{{2
endif

if !exists("g:vikiFolds")
    " Define which elements should be folded:
    "     h :: Heading
    "     H :: Headings (but inverse folding)
    "     l :: Lists
    "     b :: The body has max heading level + 1. This is slightly faster 
    "       than the other version as vim never has to scan the text; but 
    "       the behaviour may vary depending on the sequence of headings if 
    "       |vikiFoldBodyLevel| is set to 0.
    "     f :: Files regions.
    "     s :: ???
    " This variable is only used if |g:vikiFoldMethodVersion| is 1.
    let g:vikiFolds = 'hf' "{{{2
endif

if !exists("g:vikiFoldsContext") "{{{2
    " Context lines for folds
    let g:vikiFoldsContext = [2, 2, 2, 2]
endif


exec "setlocal commentstring=". substitute(b:vikiCommentStart, "%", "%%", "g") 
            \ ."%s". substitute(b:vikiCommentEnd, "%", "%%", "g")
exec "setlocal comments=fb:-,fb:+,fb:*,fb:#,fb:?,fb:@,:". b:vikiCommentStart

if g:vikiFoldMethodVersion > 0
    setlocal foldmethod=expr
    setlocal foldexpr=VikiFoldLevel(v:lnum)
    setlocal foldtext=VikiFoldText()
endif
setlocal expandtab
" setlocal iskeyword+=#,{
setlocal iskeyword+={
setlocal iskeyword-=_

if g:vikiFoldLevel > 0 && &l:foldlevel == 0
    let &l:foldlevel = g:vikiFoldLevel
endif

if has('balloon_multiline')
    call tlib#balloon#Register('viki#Balloon()')
endif

let &include='\(^\s*#INC.\{-}\(\sfile=\|:\)\)'
let &define='^\s*\(#Def.\{-}id=\|#\(Fn\|Footnote\).\{-}\(:\|id=\)\|#VAR.\{-}\s\)'

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

let b:vikiEnabled = 2

if g:vikiAutoupdateFiles
    call viki#FilesUpdateAll()
endif

if exists('*VikiFoldLevel') || g:vikiFoldMethodVersion == 0 "{{{2
    finish
endif

function! VikiFoldText() "{{{3
  let line = getline(v:foldstart)
  if synIDattr(synID(v:foldstart, 1, 1), 'name') =~ '^vikiFiles'
      let line = fnamemodify(viki#FilesGetFilename(line), ':h')
  else
      let ctxtlev = tlib#var#Get('vikiFoldsContext', 'wbg')
      let ctxt    = get(ctxtlev, v:foldlevel, 0)
      " TLogVAR ctxt
      " TLogDBG type(ctxt)
      if type(ctxt) == 3
          let [ctxtbeg, ctxtend] = ctxt
      else
          let ctxtbeg = 1
          let ctxtend = ctxt
      end
      let line = matchstr(line, '^\s*\zs.*$')
      for li in range(ctxtbeg, ctxtend)
          let li = v:foldstart + li
          if li > v:foldend
              break
          endif
          let lp = matchstr(getline(li), '^\s*\zs.\{-}\ze\s*$')
          if !empty(lp)
              let lp = substitute(lp, '\s\+', ' ', 'g')
              let line .= ' | '. lp
          endif
      endfor
  endif
  return v:folddashes . line
endf

function! s:VikiFolds() "{{{3
    let vikiFolds = tlib#var#Get('vikiFolds', 'bg')
    " TLogVAR vikiFolds
    if vikiFolds == 'ALL'
        let vikiFolds = 'hlsfb'
        " let vikiFolds = 'hHlsfb'
    elseif vikiFolds == 'DEFAULT'
        let vikiFolds = 'hf'
    endif
    " TLogVAR vikiFolds
    return vikiFolds
endf

function! s:SetMaxLevel() "{{{3
    " let pos = getpos('.')
    let view = winsaveview()
    " TLogVAR b:vikiHeadingStart
    let vikiHeadingRx = '\V\^'. b:vikiHeadingStart .'\+\ze\s'
    let b:vikiHeadingMaxLevel = 0
    exec 'keepjumps g/'. vikiHeadingRx .'/let l = matchend(getline("."), vikiHeadingRx) | if l > b:vikiHeadingMaxLevel | let b:vikiHeadingMaxLevel = l | endif'
    " TLogVAR b:vikiHeadingMaxLevel
    " call setpos('.', pos)
    call winrestview(view)
endf

function! s:UpdateHeadings() "{{{3
    let viki_headings = {}
    let pos = getpos('.')
    try
        silent! g/^\*\+\s/let viki_headings[line('.')] = matchend(getline('.'), '^\*\+\s')
    finally
        call setpos('.', pos)
    endtry
    if !exists('b:viki_headings') || b:viki_headings != viki_headings
        let b:viki_headings = viki_headings
    endif
endf

autocmd viki CursorHold,CursorHoldI,InsertLeave <buffer> call s:UpdateHeadings()
call s:UpdateHeadings()

func s:NumericSort(i1, i2)
    return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc

function VikiFoldLevel(lnum)
    let vikiFolds = s:VikiFolds()
    if vikiFolds == ''
        " TLogDBG 'no folds'
        return
    endif
    let new = 0
    let level = 1
    if vikiFolds =~? 'h'
        let hd_lnums = map(keys(b:viki_headings), 'str2nr(v:val)')
        let hd_lnums = filter(hd_lnums, 'v:val <= a:lnum')
        " TLogVAR hd_lnums
        if !empty(hd_lnums)
            let hd_lnums = sort(hd_lnums, 's:NumericSort')
            let hd_lnum = hd_lnums[-1]
            let level = b:viki_headings[''. hd_lnum]
            if hd_lnum == a:lnum
                let new = 1
            endif
            " TLogVAR hd_lnums, hd_lnum, level
        endif
        if vikiFolds =~# 'H'
            let max_level = max(values(b:viki_headings))
            let level = max_level - level + 1
        endif
    endif
    if vikiFolds =~# 'l'
        let level += matchend(getline(prevnonblank(a:lnum)), '^\s\+') / &shiftwidth
    endif
    " TLogVAR a:lnum, level
    return new ? '>'. level : level
endf

