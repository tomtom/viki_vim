" viki.vim -- the viki ftplugin
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     12-Jän-2004.
" @Last Change: 2011-08-14.
" @Revision: 452

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
    " Choose folding method version
    " Viki supports several methods (1..7) for defining folds. If you 
    " find that text entry is slowed down it is probably due to the 
    " chosen fold method. You could try to use another method (see 
    " ../ftplugin/viki.vim for alternative methods) or check out this 
    " vim tip:
    " http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text
    let g:vikiFoldMethodVersion = 7 "{{{2
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

if has('balloon_multiline')
    call tlib#balloon#Register('viki#Balloon()')
endif

let &include='\(^\s*#INC.\{-}\(\sfile=\|:\)\)'
let &define='^\s*\(#Def.\{-}id=\|#\(Fn\|Footnote\).\{-}\(:\|id=\)\|#VAR.\{-}\s\)'

map <buffer> <silent> [[ :call viki#FindPrevHeading()<cr>
map <buffer> <silent> ][ :call viki#FindNextHeading()<cr>
map <buffer> <silent> ]] ][
map <buffer> <silent> [] [[

let b:undo_ftplugin = 'setlocal iskeyword< expandtab< foldtext< foldexpr< foldmethod< comments< commentstring< '
            \ .'define< include<'
            \ .'| unlet b:vikiHeadingMaxLevel b:vikiCommentStart b:vikiCommentEnd b:vikiInverseFold b:vikiMaxFoldLevel '
            \ .' b:vikiEnabled '
            \ .'| unmap <buffer> [['
            \ .'| unmap <buffer> ]]'
            \ .'| unmap <buffer> ]['
            \ .'| unmap <buffer> []'

let b:vikiEnabled = 2

if exists('*VikiFoldLevel') "{{{2
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

if g:vikiFoldMethodVersion == 7

    " :nodoc:
    function VikiFoldLevel(lnum)
        let vikiFolds = s:VikiFolds()
        if vikiFolds == ''
            " TLogDBG 'no folds'
            return
        endif
        let cline = getline(a:lnum)
        let level = matchend(cline, '^\*\+')
        " TLogVAR level, cline
        if level == -1
            return "="
        else
            return ">". level
        endif
    endf

elseif g:vikiFoldMethodVersion == 6

    " Fold paragraphs (see :help fold-expr)
    " :nodoc:
    function VikiFoldLevel(lnum)
        let vikiFolds = s:VikiFolds()
        if vikiFolds == ''
            " TLogDBG 'no folds'
            return
        endif
        return getline(a:lnum) =~ '^\\s*$' && getline(a:lnum + 1) =~ '\\S' ? '<1' : 1
    endf

elseif g:vikiFoldMethodVersion == 5

    " :nodoc:
    function! VikiFoldLevel(lnum)
        " TLogVAR a:lnum
        let vikiFolds = s:VikiFolds()
        if vikiFolds == ''
            " TLogDBG 'no folds'
            return
        endif
        if vikiFolds =~# 'h'
            " TLogVAR b:vikiHeadingStart
            let lt = getline(a:lnum)
            let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
            if fh != -1
                " TLogVAR fh, b:vikiHeadingMaxLevel
                if b:vikiHeadingMaxLevel == -1
                    " TLogDBG 'SetMaxLevel'
                    call s:SetMaxLevel()
                endif
                if fh > b:vikiHeadingMaxLevel
                    let b:vikiHeadingMaxLevel = fh
                endif
                if vikiFolds =~# 'H'
                    " TLogDBG 'inverse folds'
                    let fh = b:vikiHeadingMaxLevel - fh + 1
                endif
                " TLogVAR fh, lt
                return '>'.fh
            endif
            let body_level = indent(a:lnum) / &sw + 1
            return b:vikiHeadingMaxLevel + body_level
        endif
    endf

elseif g:vikiFoldMethodVersion == 4

    " :nodoc:
    function! VikiFoldLevel(lnum)
        " TLogVAR a:lnum
        let vikiFolds = s:VikiFolds()
        if vikiFolds == ''
            " TLogDBG 'no folds'
            return
        endif
        if vikiFolds =~# 'h'
            " TLogVAR b:vikiHeadingStart
            let lt = getline(a:lnum)
            let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
            if fh != -1
                " TLogVAR fh, b:vikiHeadingMaxLevel
                if b:vikiHeadingMaxLevel == -1
                    " TLogDBG 'SetMaxLevel'
                    call s:SetMaxLevel()
                endif
                if fh > b:vikiHeadingMaxLevel
                    let b:vikiHeadingMaxLevel = fh
                endif
                if vikiFolds =~# 'H'
                    " TLogDBG 'inverse folds'
                    let fh = b:vikiHeadingMaxLevel - fh + 1
                endif
                " TLogVAR fh, lt
                return '>'.fh
            endif
            if b:vikiHeadingMaxLevel <= 0
                return b:vikiHeadingMaxLevel + 1
            else
                return '='
            endif
        endif
    endf

elseif g:vikiFoldMethodVersion == 3

    " :nodoc:
    function! VikiFoldLevel(lnum)
        let vikiFolds = s:VikiFolds()
        if vikiFolds == ''
            " TLogDBG 'no folds'
            return
        endif
        let lt = getline(a:lnum)
        if lt !~ '\S'
            return '='
        endif
        let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
        if fh != -1
            " let fh += 1
            if b:vikiHeadingMaxLevel == -1
                call s:SetMaxLevel()
            endif
            if fh > b:vikiHeadingMaxLevel
                let b:vikiHeadingMaxLevel = fh
                " TLogVAR b:vikiHeadingMaxLevel
            endif
            " TLogVAR fh
            return fh
        endif
        let li = indent(a:lnum)
        let tf = b:vikiHeadingMaxLevel + 1 + (li / &sw)
        " TLogVAR tf
        return tf
    endf

elseif g:vikiFoldMethodVersion == 2

    " :nodoc:
    function! VikiFoldLevel(lnum)
        let vikiFolds = s:VikiFolds()
        if vikiFolds == ''
            " TLogDBG 'no folds'
            return
        endif
        let lt = getline(a:lnum)
        let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
        if fh != -1
            return fh
        endif
        let ll = prevnonblank(a:lnum)
        if ll != a:lnum
            return '='
        endif
        let li = indent(a:lnum)
        let pl = prevnonblank(a:lnum - 1)
        let pi = indent(pl)
        if li == pi || pl == 0
            return '='
        elseif li > pi
            return 'a'. ((li - pi) / &sw)
        else
            return 's'. ((pi - li) / &sw)
        endif
    endf

else

    function! VikiFoldLevel(lnum) "{{{3
        " let lc = getpos('.')
        let view = winsaveview()
        " TLogVAR lc
        let w0 = line('w0')
        let lr = &lazyredraw
        set lazyredraw
        try
            let vikiFolds = s:VikiFolds()
            if vikiFolds == ''
                " TLogDBG 'no folds'
                return
            endif
            if b:vikiHeadingMaxLevel == -1
                call s:SetMaxLevel()
            endif
            if vikiFolds =~# 'f'
                let idt = indent(a:lnum)
                if synIDattr(synID(a:lnum, idt, 1), 'name') =~ '^vikiFiles'
                    call s:SetHeadingMaxLevel(1)
                    " TLogDBG 'vikiFiles: '. idt
                    return b:vikiHeadingMaxLevel + idt / &shiftwidth
                endif
            endif
            if stridx(vikiFolds, 'h') >= 0
                if vikiFolds =~? 'h'
                    let fl = s:ScanHeading(a:lnum, a:lnum, vikiFolds)
                    if fl != ''
                        " TLogDBG 'heading: '. fl
                        return fl
                    endif
                endif
                if vikiFolds =~# 'l' 
                    let list = viki#MatchList(a:lnum)
                    if list > 0
                        call s:SetHeadingMaxLevel(1)
                        " TLogVAR list
                        " return '>'. (b:vikiHeadingMaxLevel + (list / &sw))
                        return (b:vikiHeadingMaxLevel + (list / &sw))
                    elseif getline(a:lnum) !~ '^[[:blank:]]' && viki#MatchList(a:lnum - 1) > 0
                        let fl = s:ScanHeading(a:lnum - 1, 1, vikiFolds)
                        if fl != ''
                            if fl[0] == '>'
                                let fl = strpart(fl, 1)
                            endif
                            " TLogDBG 'list indent: '. fl
                            return '<'. (fl + 1)
                        endif
                    endif
                endif
                " I have no idea what this is about.
                " Is this about "inverse" folding?
                " if vikiFolds =~# 's'
                "     if exists('b:vikiFoldDef')
                "         exec b:vikiFoldDef
                "         if vikiFoldLine == a:lnum
                "             return vikiFoldLevel
                "         endif
                "     endif
                "     let i = 1
                "     while i > a:lnum
                "         let vfl = VikiFoldLevel(a:lnum - i)
                "         if vfl[0] == '>'
                "             let b:vikiFoldDef = 'let vikiFoldLine='. a:lnum 
                "                         \ .'|let vikiFoldLevel="'. vfl .'"'
                "             return vfl
                "         elseif vfl == '='
                "             let i = i + 1
                "         endif
                "     endwh
                " endif
                call s:SetHeadingMaxLevel(1)
                " if b:vikiHeadingMaxLevel == 0
                "     return 0
                " elseif vikiFolds =~# 'b'
                if vikiFolds =~# 'b'
                    let bl = exists('b:vikiFoldBodyLevel') ? b:vikiFoldBodyLevel : g:vikiFoldBodyLevel
                    if bl > 0
                        " TLogDBG 'body: '. bl
                        return bl
                    else
                        " TLogDBG 'body fallback: '. b:vikiHeadingMaxLevel
                        return b:vikiHeadingMaxLevel + 1
                    endif
                else
                    " TLogDBG 'else'
                    return "="
                endif
            endif
            " TLogDBG 'zero'
            return 0
        finally
            exec 'norm! '. w0 .'zt'
            " TLogVAR lc
            " call setpos('.', lc)
            call winrestview(view)
            let &lazyredraw = lr
        endtry
    endfun

    function! s:ScanHeading(lnum, top, vikiFolds) "{{{3
        " TLogVAR a:lnum, a:top
        let [lhead, head] = s:SearchHead(a:lnum, a:top)
        " TLogVAR head
        if head > 0
            if head > b:vikiHeadingMaxLevel
                let b:vikiHeadingMaxLevel = head
            endif
            if b:vikiInverseFold || a:vikiFolds =~# 'H'
                if b:vikiMaxFoldLevel > head
                    return ">". (b:vikiMaxFoldLevel - head)
                else
                    return ">0"
                end
            else
                return ">". head
            endif
        endif
        return ''
    endf

    function! s:SetHeadingMaxLevel(once) "{{{3
        if a:once && b:vikiHeadingMaxLevel == 0
            return
        endif
        " let pos = getpos('.')
        let view = winsaveview()
        " TLogVAR pos
        try
            silent! keepjumps exec 'g/\V\^'. b:vikiHeadingStart .'\+\s/call s:SetHeadingMaxLevelAtCurrentLine(line(".")'
        finally
            " TLogVAR pos
            " call setpos('.', pos)
            call winrestview(view)
        endtry
    endf

    function! s:SetHeadingMaxLevelAtCurrentLine(lnum) "{{{3
        let m = s:MatchHead(lnum)
        if m > b:vikiHeadingMaxLevel
            let b:vikiHeadingMaxLevel = m
        endif
    endf

    function! s:SearchHead(lnum, top) "{{{3
        " let pos = getpos('.')
        let view = winsaveview()
        " TLogVAR pos
        try
            exec a:lnum
            norm! $
            let ln = search('\V\^'. b:vikiHeadingStart .'\+\s', 'bWcs', a:top)
            if ln
                return [ln, s:MatchHead(ln)]
            endif
            return [0, 0]
        finally
            " TLogVAR pos
            " call setpos('.', pos)
            call winrestview(view)
        endtry
    endf

    function! s:MatchHead(lnum) "{{{3
        " let head = matchend(getline(a:lnum), '\V\^'. escape(b:vikiHeadingStart, '\') .'\ze\s\+')
        return matchend(getline(a:lnum), '\V\^'. b:vikiHeadingStart .'\+\ze\s')
    endf

endif

