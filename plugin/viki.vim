" Viki.vim -- Some kind of personal wiki for Vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     08-Dec-2003.
" @Last Change: 2010-12-09.
" @Revision:    2706
"
" GetLatestVimScripts: 861 1 viki.vim
"
" Short Description:
" This plugin adds wiki-like hypertext capabilities to any document.  
" Just type :VikiMinorMode and all wiki names will be highlighted. If 
" you press <c-cr> (or <LocalLeader>vf) when the cursor is over a wiki 
" name, you jump to (or create) the referred page. When invoked via :set 
" ft=viki, additional highlighting is provided.
"
" Requirements:
" - tlib.vim (vimscript #1863)
" 
" Optional Enhancements:
" - imaps.vim (vimscript #244 or #475 for |:VimQuote|)
" - kpsewhich (not a vim plugin :-) for vikiLaTeX
"
" TODO: File names containing # (the # is interpreted as URL component)
" TODO: Per Interviki simple name patterns
" TODO: Allow Wiki links like ::Word or even ::word (not in minor mode 
" due possible conflict with various programming languages?)
" TODO: :VikiRename command: rename links/files (requires a 
" cross-plattform grep or similar; or one could a global register)
" TODO: don't know how to deal with viki names that span several lines 
" (e.g.  in LaTeX mode)

if &cp || exists("loaded_viki") "{{{2
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 39
    runtime plugin/02tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 39
        echoerr 'tlib >= 0.39 is required'
        finish
    endif
endif
let loaded_viki = 319


" Configuration {{{1
" Support for the taglist plugin.
if !exists("tlist_viki_settings") "{{{2
    let tlist_viki_settings="deplate;s:structure"
endif

" The prefix for the menu of intervikis. Set to '' in order to remove the 
" menu.
if !exists("g:vikiMenuPrefix") "{{{2
    let g:vikiMenuPrefix = "Plugin.Viki."
endif

" Make submenus for N letters of the interviki names.
if !exists('g:vikiMenuLevel')
    let g:vikiMenuLevel = 1   "{{{2
endif

" if !exists("g:vikiBasicSyntax")     | let g:vikiBasicSyntax = 0          | endif "{{{2
" If non-nil, display headings of different levels in different colors
if !exists("g:vikiFancyHeadings")   | let g:vikiFancyHeadings = 0        | endif "{{{2

" Mark up inexistent names.
if !exists("g:vikiMarkInexistent")  | let g:vikiMarkInexistent = 1       | endif "{{{2

" if !exists("g:vikiOpenInWindow")    | let g:vikiOpenInWindow = ''        | endif "{{{2
if !exists("g:vikiHighlightMath")   | let g:vikiHighlightMath = ''       | endif "{{{2

" Default file suffix (including the optional period, e.g. '.txt').
if !exists("g:vikiNameSuffix")      | let g:vikiNameSuffix = ""          | endif "{{{2

" The default filename for an interviki's index name
if !exists("g:vikiIndex")           | let g:vikiIndex = 'index'          | endif "{{{2

" Definition of intervikis. (This variable won't be evaluated until 
" autoload/viki.vim is loaded).
if !exists('g:viki_intervikis')
    let g:viki_intervikis = {}   "{{{2
endif

" If non-nil, cache back-links information
if !exists("g:vikiSaveHistory")     | let g:vikiSaveHistory = 0          | endif "{{{2


if g:vikiMenuPrefix != '' "{{{2
    exec 'amenu '. g:vikiMenuPrefix .'Home :VikiHome<cr>'
    exec 'amenu '. g:vikiMenuPrefix .'-SepViki1- :'
endif


let g:vikiInterVikiNames  = []


" Return a viki name for a vikiname on a specified interviki
" VikiMakeName(iviki, name, ?quote=1)
function! VikiMakeName(iviki, name, ...) "{{{3
    let quote = a:0 >= 1 ? a:1 : 1
    let name  = a:name
    if quote && name !~ '\C'. viki#GetSimpleRx4SimpleWikiName()
        let name = '[-'. name .'-]'
    endif
    if a:iviki != ''
        let name = a:iviki .'::'. name
    endif
    return name
endf


" Define an interviki name
" VikiDefine(name, prefix, ?suffix="*", ?index="Index.${suffix}")
" suffix == "*" -> g:vikiNameSuffix
function! VikiDefine(name, prefix, ...) "{{{3
    if a:name =~ '[^A-Z]'
        throw 'Invalid interviki name: '. a:name
    endif
    call add(g:vikiInterVikiNames, a:name .'::')
    call sort(g:vikiInterVikiNames)
    let g:vikiInter{a:name}          = a:prefix
    let g:vikiInter{a:name}_suffix   = a:0 >= 1 && a:1 != '*' ? a:1 : g:vikiNameSuffix
    " let index = a:0 >= 2 && a:2 != '' ? a:2 : g:vikiIndex
    " let findex = fnamemodify(g:vikiInter{a:name} .'/'. index . g:vikiInter{a:name}_suffix, ':p')
    " if filereadable(findex)
    let index = a:0 >= 2 && a:2 != '' ? a:2 : ''
    if !empty(index)
        let vname = VikiMakeName(a:name, index, 0)
        let g:vikiInter{a:name}_index = index
    else
        " let vname = '[['. a:name .'::]]'
        let vname = a:name .'::'
    end
    " let vname = escape(vname, ' \%#')
    if !exists(':'+ a:name)
        exec 'command -bang -nargs=? -complete=customlist,viki#EditComplete '. a:name .' call viki#Edit(empty(<q-args>) ? '. string(vname) .' : viki#InterEditArg('. string(a:name) .', <q-args>), !empty("<bang>"))'
    else
        echom "Viki: Command already exists. Cannot define a command for "+ a:name
    endif
    if g:vikiMenuPrefix != ''
        if g:vikiMenuLevel > 0
            let name = [ a:name[0 : g:vikiMenuLevel - 1] .'&'. a:name[g:vikiMenuLevel : -1] ]
            let weight = []
            for i in reverse(range(g:vikiMenuLevel))
                call insert(name, a:name[i])
                call insert(weight, char2nr(a:name[i]) + 500)
            endfor
            let ml = len(split(g:vikiMenuPrefix, '[^\\]\zs\.'))
            let mw = repeat('500.', ml) . join(weight, '.')
        else
            let name = [a:name]
            let mw = ''
        endif
        exec 'amenu '. mw .' '. g:vikiMenuPrefix . join(name, '.') .' :VikiEdit! '. vname .'<cr>'
    endif
endf

for [s:iname, s:idef] in items(g:viki_intervikis)
    " VikiDefine(name, prefix, ?suffix="*", ?index="Index.${suffix}")
    if type(s:idef) == 1
        call call('VikiDefine', [s:iname, s:idef])
    else
        call call('VikiDefine', [s:iname] + s:idef)
    endif
    unlet! s:iname s:idef
endfor


command! -nargs=+ VikiDefine call VikiDefine(<f-args>)

command! -nargs=? -bar VikiMinorMode call viki#DispatchOnFamily('MinorMode', empty(<q-args>) && exists('b:vikiFamily') ? b:vikiFamily : <q-args>, 1)
command! -nargs=? -bar VikiMinorModeMaybe echom "Deprecated command: VikiMinorModeMaybe" | VikiMinorMode <q-args>
command! VikiMinorModeViki call viki_viki#MinorMode(1)
command! VikiMinorModeLaTeX call viki_latex#MinorMode(1)
command! VikiMinorModeAnyWord call viki_anyword#MinorMode(1)

command! -nargs=? -bar VikiMode call viki#Mode(<q-args>)
command! -nargs=? -bar VikiModeMaybe echom "Deprecated command: VikiModeMaybe: Please use 'set ft=viki' instead" | call viki#Mode(<q-args>)

command! -nargs=1 -complete=customlist,viki#BrowseComplete VikiBrowse :call viki#Browse(<q-args>)

command! VikiHome :call viki#HomePage()
command! VIKI :call viki#HomePage()


augroup viki
    au!
    autocmd BufEnter * if exists("b:vikiEnabled") && b:vikiEnabled == 1 | call viki#MinorModeReset() | endif
    autocmd BufEnter * if exists("b:vikiEnabled") && b:vikiEnabled && exists("b:vikiCheckInexistent") && b:vikiCheckInexistent > 0 | call viki#CheckInexistent() | endif
    autocmd BufLeave * if &filetype == 'viki' | let b:vikiCheckInexistent = line(".") | endif
    autocmd BufWritePost,BufUnload * if &filetype == 'viki' | call viki#SaveCache() | endif
    autocmd VimLeavePre * let g:viki#quit = 1
    if g:vikiSaveHistory
        if has('vim_starting')
            autocmd VimEnter * if exists('VIKIBACKREFS_STRING') | exec 'let g:VIKIBACKREFS = '. VIKIBACKREFS_STRING | unlet VIKIBACKREFS_STRING | endif
        else
            if exists('VIKIBACKREFS_STRING') | exec 'let g:VIKIBACKREFS = '. VIKIBACKREFS_STRING | unlet VIKIBACKREFS_STRING | endif
        endif
        autocmd VimLeavePre * let VIKIBACKREFS_STRING = string(g:VIKIBACKREFS)
    endif
    " As viki uses its own styles, we have to reset &filetype.
    autocmd ColorScheme * if &filetype == 'viki' | set filetype=viki | endif
augroup END

