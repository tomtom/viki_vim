" Viki.vim -- Some kind of personal wiki for Vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     08-Dec-2003.
" @Last Change: 2016-03-02.
" @Revision:    2786
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
" - vikitasks.vim (vimscript #2894)
" - kpsewhich (not a vim plugin :-) for vikiLaTeX

if &cp || exists("g:loaded_viki")
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 116
    runtime plugin/02tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 116
        echoerr 'tlib >= 1.16 is required'
        finish
    endif
endif
let g:loaded_viki = 409


if !exists("tlist_viki_settings")
    " Support for the taglist plugin.
    let tlist_viki_settings = "deplate;s:structure" "{{{2
endif

if !exists("g:vikiMenuPrefix")
    " The prefix for the menu of intervikis. Set to '' in order to remove the 
    " menu.
    let g:vikiMenuPrefix = "Plugin.Viki." "{{{2
endif

if !exists('g:vikiMenuLevel')
    " Make submenus for N letters of the interviki names.
    let g:vikiMenuLevel = 1 "{{{2
endif

if !exists("g:vikiMarkInexistent")
    " If non-zero, highligh links to existent or inexistent files in 
    " different colours.
    let g:vikiMarkInexistent = 1 "{{{2
endif

if !exists("g:vikiNameSuffix")
    " Default file suffix (including the optional period, e.g. '.viki').
    " Can also be buffer-local.
    let g:vikiNameSuffix = ".viki" "{{{2
endif

if !exists('g:viki_intervikis')
    " Definition of intervikis. (This variable won't be evaluated until 
    " autoload/viki.vim is loaded).
    let g:viki_intervikis = {}   "{{{2
endif

if !exists("g:vikiSaveHistory")
    " If non-nil, cache back-links information
    let g:vikiSaveHistory = index(split(&viminfo, ','), '!') != -1 "{{{2
endif

if !exists('g:vikiIndentedPriorityLists')
    " If true, priority lists must be indented by at least one 
    " whitespace character.
    let g:vikiIndentedPriorityLists = 1   "{{{2
endif

" -1 ... open all links in a new windows
" -2 ... open all links in a new windows but split vertically
" Any positive number ... open always in this window
" Can also be buffer-local.
" :read: let g:vikiSplit = NO DEFAULT

" :doc:
" If non-nil, simple viki names are disabled.
" :read: let b:vikiNoSimpleNames = 0 "{{{2

" Disable certain viki name types (see |vikiNameTypes|).
" E.g., in order to disable CamelCase names only, set this variable to 'c'.
" :read: let b:vikiDisableType = "" "{{{2

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
    if a:name =~ '[^A-Z0-9]'
        throw 'Invalid interviki name: '. a:name
    endif
    call add(g:vikiInterVikiNames, a:name .'::')
    call sort(g:vikiInterVikiNames)
    let g:vikiInter{a:name}          = a:prefix
    let g:vikiInter{a:name}_suffix   = a:0 >= 1 && a:1 != '*' ? a:1 : g:vikiNameSuffix
    let index = a:0 >= 2 && a:2 != '' ? a:2 : ''
    if !empty(index)
        let vname = VikiMakeName(a:name, index, 0)
        let g:vikiInter{a:name}_index = index
    else
        " let vname = '[['. a:name .'::]]'
        let vname = a:name .'::'
    end
    " let vname = escape(vname, ' \%#')
    if exists(':'+ a:name) != 2
        exec 'command! -bang -nargs=? -complete=customlist,viki#EditComplete '. a:name .' call viki#Edit(empty(<q-args>) ? '. string(vname) .' : viki#InterEditArg('. string(a:name) .', <q-args>), !empty("<bang>"))'
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


" :display: VikiDefine NAME BASE ?SUFFIX
" Define an interviki. See also |VikiDefine()|.
command! -nargs=+ VikiDefine call VikiDefine(<f-args>)

" NOTE: Be aware that we cannot highlight a reference if the text is embedded 
" in syntax group that doesn't allow inclusion of arbitrary syntax elemtents.
command! -nargs=? -bar VikiMinorMode call viki#MinorMode(empty(<q-args>) && exists('b:vikiFamily') ? b:vikiFamily : <q-args>)
command! -nargs=? -bar VikiMinorModeMaybe echom "Deprecated command: VikiMinorModeMaybe" | VikiMinorMode <q-args>
command! VikiMinorModeViki call viki_viki#MinorMode(1)
command! VikiMinorModeLaTeX call viki_latex#MinorMode(1)
command! VikiMinorModeAnyWord call viki_anyword#MinorMode(1)

" Basically the same as: >
"     set ft=viki
" < The main difference between these two is that VikiMode unlets 
" b:did_ftplugin to make sure that the ftplugin gets loaded.
command! -nargs=? -bar VikiMode call viki#Mode(<q-args>)
command! -nargs=? -bar VikiModeMaybe echom "Deprecated command: VikiModeMaybe: Please use 'set ft=viki' instead" | call viki#Mode(<q-args>)

command! -nargs=1 -complete=customlist,viki#BrowseComplete VikiBrowse :call viki#Browse(<q-args>)

" Open the |viki-homepage|.
command! VikiHome :call viki#HomePage()

" Open the |viki-homepage|.
command! VIKI :call viki#HomePage()


" :display: :Vikifind[!] KIND PATTERN
" Use |:Trag| to search the current directory or, with the optional [!] 
" search all intervikis matching |g:viki#find_intervikis_rx|. See 
" |:Trag| for the allowed values for KIND.
"
" NOTE: This command requires the trag plugin to be installed.
command! -bar -bang -nargs=+ -complete=customlist,trag#CComplete Vikifind if exists(':Trag') == 2 | Trag<bang> --filenames --file_sources=*viki#FileSources <args> | else | echom ':Vikifind requires the trag_vim plugin to be installed!' | endif



if !empty('g:vikiNameSuffix') && exists('#filetypedetect')
    exec 'autocmd filetypedetect BufRead,BufNewFile *'. g:vikiNameSuffix .' if empty(&ft) | setf viki | endif'
endif

augroup viki
    au!
    autocmd BufEnter * if exists("b:vikiEnabled") && b:vikiEnabled == 1 | call viki#MinorModeReset() | endif
    autocmd BufEnter * if exists("b:vikiEnabled") && b:vikiEnabled && exists("b:vikiCheckInexistent") && b:vikiCheckInexistent > 0 | call viki#CheckInexistent() | endif
    autocmd BufLeave * if &filetype == 'viki' | let b:vikiCheckInexistent = line(".") | endif
    autocmd BufWritePost,BufUnload * if &filetype == 'viki' | call viki#SaveCache() | endif
    autocmd VimLeavePre * let g:viki#quit = 1
    if g:vikiSaveHistory
        autocmd VimEnter * if exists('VIKIBACKREFS_STRING') | exec 'let g:VIKIBACKREFS = '. VIKIBACKREFS_STRING | unlet VIKIBACKREFS_STRING | endif
        autocmd VimLeavePre * let VIKIBACKREFS_STRING = string(g:VIKIBACKREFS)
    endif
    " As viki uses its own styles, we have to reset &filetype.
    autocmd ColorScheme * if &filetype == 'viki' | set filetype=viki | endif
augroup END


if exists('g:loaded_setsyntax') && g:loaded_setsyntax > 0
    let g:setsyntax_options['viki']['vikiPriorityListTodoGen'] = {'&l:tw': 0}
endif

