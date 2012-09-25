" viki.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim-viki)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-03-25.
" @Last Change: 2012-09-24.
" @Revision:    0.1112


exec 'runtime! autoload/viki/enc_'. substitute(&enc, '[\/<>*+&:?]', '_', 'g') .'.vim'

""" General {{{1

" This is what we consider nil, in the absence of nil in vimscript
let g:vikiDefNil  = ''

" In a previous version this was used as list separator and as nil too
let g:vikiDefSep  = "\n"

" In extended viki links this is considered as a reference to the current 
" document. This is likely to go away.
let g:vikiSelfRef = '.'


" :doc:
" Simple Viki Names [2]:                              *viki-vars-simple-names*

if !exists("g:vikiUpperCharacters")
    " A simple viki name is made from a series of upper and lower characters 
    " (i.e. CamelCase-names). These two variables define what is considered as 
    " upper and lower-case characters. We don't rely on the builtin 
    " functionality for this.
    let g:vikiUpperCharacters = "A-Z" "{{{2
endif
if !exists("g:vikiLowerCharacters")
    let g:vikiLowerCharacters = "a-z" "{{{2
endif

" :doc:
" Extended Viki Names [2]:                            *viki-vars-ext-names*
" - b:vikiExtendedNameRx, b:vikiExtendedNameSimpleRx[1]
" - b:vikiExtendedNameNameIdx, b:vikiExtendedNameDestIdx, 
"   b:vikiExtendedNameAnchorIdx
" 
" URLs [2]:                                           *viki-vars-urls*
" - b:vikiUrlRx, b:vikiUrlSimpleRx[1]
" - b:vikiUrlNameIdx, b:vikiUrlDestIdx, b:vikiUrlAnchorIdx
" 
" NOTE: [1] The same as *Rx variables but with less groups.
" NOTE: [2] These variables are defined by |VikiSetupBuffer()|.
" 
" - b:vikiAnchorRx                                    *b:vikiAnchorRx*
"     If this variable exists, the string "%{ANCHOR}" will be replaced with the 
"     search text. The expression has to conform to the very nomagic |/\V| 
"     syntax.

" Characters allowed in anchors
" Defaults to:
" [b:vikiLowerCharacters][b:vikiLowerCharacters +  b:vikiUpperCharacters + '_0-9]*
if !exists('g:vikiAnchorNameRx')
    let g:vikiAnchorNameRx = '' "{{{2
endif

if !exists('g:vikiUrlRestRx')
    let g:vikiUrlRestRx = '['. g:vikiLowerCharacters . g:vikiUpperCharacters .'0-9?%_=&+-]*'  "{{{2
endif

if !exists('g:viki#error_malformed_names')
    " If true, throw an error on malformed viki names.
    let g:viki#error_malformed_names = 0   "{{{2
endif

if !exists("g:vikiSpecialProtocols")
    " URLs matching these protocols are handled by |VikiOpenSpecialProtocol()|.
    " Can also be buffer-local.
    let g:vikiSpecialProtocols = 'https\?\|ftps\?\|nntp\|mailto\|mailbox\|file' "{{{2
    if exists("g:vikiSpecialProtocolsExtra")
        let g:vikiSpecialProtocols .= '\|'. g:vikiSpecialProtocolsExtra
    endif
endif

if !exists("g:vikiSpecialProtocolsExceptions")
    " Exceptions from g:vikiSpecialProtocols
    let g:vikiSpecialProtocolsExceptions = "" "{{{2
endif

if !exists("g:vikiSpecialFiles") "{{{2
    " Files matching these suffixes are handled by |viki#OpenSpecialFile()|.
    " Can also be buffer-local.
    " :read: let g:vikiSpecialFiles = [...] "{{{2
    let g:vikiSpecialFiles = [
                \ '3gp',
                \ 'aac',
                \ 'aif',
                \ 'aiff',
                \ 'au',
                \ 'avi',
                \ 'bmp',
                \ 'dia',
                \ 'doc',
                \ 'docx',
                \ 'dvi',
                \ 'eml',
                \ 'eps',
                \ 'gif',
                \ 'htm',
                \ 'html',
                \ 'jpeg',
                \ 'jpg',
                \ 'm3u',
                \ 'mhtml',
                \ 'mp1',
                \ 'mp2',
                \ 'mp3',
                \ 'mp4',
                \ 'mpeg',
                \ 'mpg',
                \ 'odg',
                \ 'ods',
                \ 'odt',
                \ 'ogg',
                \ 'pdf',
                \ 'png',
                \ 'ppt',
                \ 'pptx',
                \ 'ps',
                \ 'rtf',
                \ 'voc',
                \ 'wav',
                \ 'wma',
                \ 'wmf',
                \ 'wmv',
                \ 'xhtml',
                \ 'xls',
                \ 'xlsx',
                \ 'xmind',
                \ ]
    if exists("g:vikiSpecialFilesExtra")
        let g:vikiSpecialFiles += g:vikiSpecialFilesExtra
    endif
endif

if !exists("g:vikiSpecialFilesExceptions")
    " Exceptions from g:vikiSpecialFiles
    let g:vikiSpecialFilesExceptions = "" "{{{2
endif

if !exists('g:viki_highlight_hyperlink_light')
    let g:viki_highlight_hyperlink_light = 'term=underline cterm=underline gui=underline ctermfg=DarkBlue guifg=DarkBlue' "{{{2
endif
if !exists('g:viki_highlight_hyperlink_dark')
    let g:viki_highlight_hyperlink_dark = 'term=underline cterm=underline gui=underline ctermfg=LightBlue guifg=#bfbfff' "{{{2
endif

if !exists('g:viki_highlight_inexistent_light')
    let g:viki_highlight_inexistent_light = 'term=underline cterm=underline gui=underline ctermfg=DarkRed guifg=DarkRed' "{{{2
endif
if !exists('g:viki_highlight_inexistent_dark')
    let g:viki_highlight_inexistent_dark = 'term=underline cterm=underline gui=underline ctermfg=Red guifg=Red' "{{{2
endif

if !exists('g:vikiPromote')
    " If set to true, any files loaded by viki will become viki enabled (in 
    " minor mode); this was the default behaviour in earlier versions
    let g:vikiPromote = 0 "{{{2
endif

if !exists("g:vikiUseParentSuffix")
    " If true, use the parent document's suffix.
    " If true, always append the "parent" file's suffix to the 
    " destination file name. I.e. if the current file is "ThisIdea.txt" 
    " the the viki name "OtherIdea" will refer to the file 
    " "OtherIdea.txt".
    let g:vikiUseParentSuffix = 1 "{{{2
endif

if !exists("g:vikiAnchorMarker")
    " Prefix for anchors
    let g:vikiAnchorMarker = "#" "{{{2
endif

if !exists("g:vikiFreeMarker")
    " If true and an explicitly marked anchor isn't found, search for the anchor 
    " text as such. This search will be case-insensitive. deplate won't be able 
    " to deal with such pseudo-references, of course.
    let g:vikiFreeMarker = 0 "{{{2
endif

if !exists('g:vikiPostFindAnchor')
    let g:vikiPostFindAnchor = 'norm! zz' "{{{2
endif

if !exists("g:vikiNameTypes")
    " Disable certain types of viki names globally or for a single buffer.
    " (experimental, doesn't fully work yet)
    " List of enabled viki name types:
    "     s ... Simple viki name 
    "         c ... CamelCase 
    "         S ... simple, quoted viki name
    "         i ... |interviki|
    "         w ... Hyperwords
    "             f ... file-bases hyperwords
    "     e ... Extended viki name
    "     u ... URL
    "     x ... Directives (some commands, regions ...)
    let g:vikiNameTypes = "csSeuixwf" "{{{2
endif

if !exists("g:vikiExplorer")
    " Which directory explorer to use to edit directories
    let g:vikiExplorer = "Sexplore" "{{{2
endif

if !exists('g:viki#cmd_no_fnameescape')
    " A |regexp| matching commands for which the filename should not be 
    " pre-processed with |fnameescape()| when opening a file.
    let g:viki#cmd_no_fnameescape = '^\(\ue\|E\)xplore\>'   "{{{2
endif

if !exists("g:vikiHide")
    " If hide or update: use the respective command when leaving a buffer
    " If a dirty buffers gets hidden, vim usually complains. This can be 
    " tiresome -- depending on your editing habits. When this variable is set to 
    " "hide", vim won't complain. If you set it to "update", a viki buffer will 
    " be automatically updated before editing a different file.  If you leave 
    " this empty (""), the default behaviour is in effect. See also |hidden|.
    let g:vikiHide = '' "{{{2
endif

if !exists("g:vikiNoWrapper")
    " Don't use g:vikiHide for commands matching this rx
    let g:vikiNoWrapper = '\cexplore' "{{{2
endif

if !exists("g:vikiCacheInexistent")
    " Cache information about a document's inexistent names
    " If non-zero, save patterns for |g:vikiMarkInexistent| for later 
    " re-use using |tlib#cache#Filename()|. You might want to delete old 
    " files from the |g:tlib_cache| directory from time to time.
    let g:vikiCacheInexistent = 0 "{{{2
endif

if !exists("g:vikiMapInexistent")
    " If non-nil, map keys that trigger the evaluation of inexistent names
    let g:vikiMapInexistent = 1 "{{{2
endif

if !exists("g:vikiMapKeys")
    " Map these keys for g:vikiMapInexistent to LineQuick
    let g:vikiMapKeys = "]).,;:!?\"' " "{{{2
endif

if !exists("g:vikiMapQParaKeys")
    " Map these keys for g:vikiMapInexistent to ParagraphVisible
    let g:vikiMapQParaKeys = "\n" "{{{2
endif

if !exists("g:vikiHCM")
    " Install hooks for these conditions (requires hookcursormoved to be 
    " installed)
    " "linechange" could cause some slowdown.
    let g:vikiHCM = ['syntaxleave_oneline'] "{{{2
endif

if !exists("g:vikiMapBeforeKeys")
    " Check the viki name before inserting this character
    let g:vikiMapBeforeKeys = ']' "{{{2
endif

if !exists("g:vikiFamily")
    " Some functions a gathered in families/classes. See vikiLatex.vim for 
    " an example.
    " By defining this variable, family specific functions will be called for:
    "     - viki#{b:vikiFamily}#SetupBuffer(state)
    "     - viki#{b:vikiFamily}#DefineMarkup(state)
    "     - viki#{b:vikiFamily}#DefineHighlighting(state)
    "     - viki#{b:vikiFamily}#CompleteSimpleNameDef(def)
    "     - viki#{b:vikiFamily}#CompleteExtendedNameDef(def)
    "     - viki#{b:vikiFamily}#FindAnchor(anchor)
    " If one of these functions is undefined for a "viki family", then the
    " default one is called.
    " 
    " Apart from the default behaviour the following families are defined:
    "     - latex (see |viki-latex|)
    "     - anyword (see |viki-anyword|)
    let g:vikiFamily = "viki" "{{{2
endif

if !exists("g:vikiDirSeparator")
    " The directory separator
    let g:vikiDirSeparator = "/" "{{{2
endif

if !exists("g:vikiTextstylesVer")
    " The version of Deplate markup.
    " Defines the markup of |viki-textstyles| like emphasized or code.
    let g:vikiTextstylesVer = 2 "{{{2
endif

if !exists("g:vikiHomePage")
    " The default viki page (as absolute filename).
    " An absolute filename that is the general viki homepage (see also 
    " |:VikiEdit| and |:VikiHome|).
    let g:vikiHomePage = '' "{{{2
endif 

if !exists("g:vikiFeedbackMin")
    " How often the feedback is changed when marking inexisting links
    let g:vikiFeedbackMin = &lines "{{{2
endif

if !exists("g:vikiMapLeader")
    " The map leader for most viki key maps.
    let g:vikiMapLeader = '<LocalLeader>v' "{{{2
endif

if !exists("g:vikiAutoMarks")
    " If non-nil, anchors like #mX are turned into vim marks
    let g:vikiAutoMarks = 1 "{{{2
endif

if !exists("g:VIKIBACKREFS")
    " The variable that keeps back-links information
    let g:VIKIBACKREFS = {} "{{{2
endif

if !exists("g:vikiBalloonLines")
    " An expression that evaluates to the number of lines that should be 
    " included in the balloon tooltop text if &ballonexpr is set to 
    " viki#Balloon().
    let g:vikiBalloonLines = '&lines / 3' "{{{2
endif

if !exists("g:vikiBalloon")
    " If true, show some line of the target file in a balloon tooltip 
    " window.
    let g:vikiBalloon = 1 "{{{2
endif

if !exists("g:vikiBalloonEncoding")
    let g:vikiBalloonEncoding = &enc "{{{2
endif


if v:version >= 700 && !exists("g:vikiHyperWordsFiles")
    " A list of files that contain special viki names
    " :read: let g:vikiHyperWordsFiles = [...] "{{{2
    let g:vikiHyperWordsFiles = [
                \ get(split(&rtp, ','), 0).'/vikiWords.txt',
                \ './.vikiWords',
                \ ]
endif


if !exists("g:vikiMapFunctionality")
    " Define which keys to map
    " b     ... go back
    " c     ... follow link (c-cr)
    " e     ... edit
    " F     ... find
    " f     ... follow link (<LocalLeader>v)
    " i     ... check for inexistant destinations
    " I     ... map keys in g:vikiMapKeys and g:vikiMapQParaKeys
    " m[fb] ... map mouse (depends on f or b)
    " p     ... edit parent (or backlink)
    " q     ... quote
    " tF    ... tab as find
    " Files ... #Files related
    " let g:vikiMapFunctionality      = 'mf mb tF c q e i I Files'
    let g:vikiMapFunctionality      = 'ALL' "{{{2
endif

if !exists("g:vikiMapFunctionalityMinor")
    " Define which keys to map in minor mode (invoked via :VikiMinorMode)
    let g:vikiMapFunctionalityMinor = 'f b p mf mb tF c q e' "{{{2
endif

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

if !exists('g:viki#files_head_rx')
    " If a "head" argument is passed to the #Files region, the retrieved 
    " lines will be preprocessed by removing text matching this 
    " expression.
    let g:viki#files_head_rx = '^\(\*\s\+\)'   "{{{2
endif

if !exists('g:viki#use_texmath')
    " If true, load syntax/texmath.vim for a prettier display of 
    " mathematical formulas.
    let g:viki#use_texmath = 1   "{{{2
endif

let g:viki#quit = 0

let s:positions = {}
let s:InterVikiRx = '^\(['. g:vikiUpperCharacters .']\+\)::\(.*\)$'
let s:hookcursormoved_oldpos = []
" let s:vikiSelfEsc = '\'
" let s:vikiEnabledID = loaded_viki .'_'. strftime('%c')



""" Commands {{{1

" Find the next viki name or URL
command! -count VikiFindNext call viki#DispatchOnFamily('Find', '', '',  <count>)
" Find the previous viki name or URL
command! -count VikiFindPrev call viki#DispatchOnFamily('Find', '', 'b', <count>)


" Update the highlighting of links to inexistent files. 
" VikiMarkInexistent can take a range as argument.
command! -nargs=* -range=% VikiMarkInexistent call viki#MarkInexistentInRange(<line1>, <line2>)

if exists(':VEnclose')
    " Mark selected text as a quoted simple viki name, i.e., enclose it in 
    " [- and -].
    " This command requires imaps to be installed.
    command! -range VikiQuote :call VEnclose("[-", "-]", "[-", "-]")
endif

command! -narg=? VikiGoBack call viki#GoBack(<f-args>)

command! VikiJump call viki#MaybeFollowLink(0,1)

command! VikiIndex :call viki#Index()

" :display: VikiEdit[!] NAME
" Edit the wiki page called NAME. If the NAME is '*', the |viki-homepage| will 
" be opened. This is a convenient way to edit any wiki page from vim's command 
" line. If you call :VikiEdit! (with bang), the homepage will be opened first, 
" so that the homepage's customizations (and not the current buffer's one) are 
" in effect. There are a few gotchas:
" 
"     1. Viki doesn't define a default directory for wiki pages. Thus a wiki page 
"        will be looked for in the directory of the current buffer -- 
"        whatever this is -- and the customizations of this buffer are in 
"        effect. You can circumvent this problem by using |interviki| 
"        names or define a |viki-homepage| and call :VikiEdit! with a 
"        bang.
" 
"     2. Viki relies on some buffer local variables to be set. As customizability 
"        is one viki's main design goal (although, one might want to 
"        discuss whether I overdid it), there are no global settings that 
"        would define what a valid viki name is supposed to look like. As 
"        a consequence, if you disabled a certain type of wiki name in the 
"        current buffer, you won't be able to edit a wiki page of this 
"        type. E.g.: If the current buffer contains a LaTeX file, 
"        |vikiFamily| is most likely set to "LaTeX" (see |viki-latex|). 
"        For the LaTeX family, e.g., CamelCase and interwiki names are 
"        disabled. Consequently, you can't do, e.g., >
"          :VikiEdit IDEAS::WikiPage
"<       Again, you can circumvent this problem by defining a 
"        |viki-homepage| and call :VikiEdit! with a bang.
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEdit :call viki#Edit(<q-args>, !empty("<bang>"))
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditTab :call viki#Edit(<q-args>, !empty("<bang>"), 'tab')
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin1 :call viki#Edit(<q-args>, !empty("<bang>"), 1)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin2 :call viki#Edit(<q-args>, !empty("<bang>"), 2)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin3 :call viki#Edit(<q-args>, !empty("<bang>"), 3)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin4 :call viki#Edit(<q-args>, !empty("<bang>"), 4)

" Update the current |viki-files| #Files region under the cursor.
command! VikiFilesUpdate call viki#FilesUpdate()
    
" Update all |viki-files| #Files regions in the current buffer.
command! VikiFilesUpdateAll call viki#FilesUpdateAll()

command! -nargs=* -bang -complete=command VikiFileExec call viki#FilesExec(<q-args>, '<bang>', 1)
" |:execute| a vim command after doing some replacements with the command 
" string. For each formatted string the command is issued only once -- 
" i.e. you can work easily with the directories. If no special formatting 
" string is contained, the preformatted filename is appended to the command.
"   %{FILE}  ... filename
"   %{FFILE} ... preformatted filename (with '#%\ ' escaped)
"   %{DIR}   ... file's directory
command! -nargs=* -bang -complete=command VikiFilesExec call viki#FilesExec(<q-args>, '<bang>')
" |:execute| VikiCmd_{VIKI_COMMAND_NAME} FILENAME
command! -nargs=* -bang VikiFilesCmd call viki#FilesCmd(<q-args>, '<bang>')
" |:call| VikiCmd_{FUNCTION_NAME}(FILENAME)
command! -nargs=* -bang VikiFilesCall call viki#FilesCall(<q-args>, '<bang>')



""" Functions {{{1


" This is mostly a legacy function. Using set ft=viki should work too.
function! viki#Mode(...) "{{{3
    TVarArg 'family'
    " if exists('b:vikiEnabled')
    "     if b:vikiEnabled
    "         return 0
    "     endif
    "     " if b:vikiEnabled && a:state < 0
    "     "     return 0
    "     " endif
    "     " echom "VIKI: Viki mode already set."
    " endif
    unlet! b:did_ftplugin
    if !empty(family)
        let b:vikiFamily = family
    endif
    set filetype=viki
endf


" Special file handlers {{{1
if !exists('g:vikiOpenFileWith_ws') && exists(':WsOpen')
    function! VikiOpenAsWorkspace(file)
        exec 'WsOpen '. escape(a:file, ' &!%')
        exec 'lcd '. escape(fnamemodify(a:file, ':p:h'), ' &!%')
    endf
    let g:vikiOpenFileWith_ws = "call VikiOpenAsWorkspace('%{FILE}')"
    call add(g:vikiSpecialFiles, 'ws')
endif
if type(g:vikiSpecialFiles) != 3
    echoerr 'Viki: g:vikiSpecialFiles must be a list'
endif
" TAssert IsList(g:vikiSpecialFiles)

if !exists("g:vikiOpenFileWith_ANY")
    if exists('g:netrw_browsex_viewer')
        let g:vikiOpenFileWith_ANY = "exec 'silent !'. g:netrw_browsex_viewer .' '. shellescape('%{FILE}')" "{{{2
    elseif has("win32") || has("win16") || has("win64")
        let g:vikiOpenFileWith_ANY = "exec 'silent ! start \"\" '. shellescape('%{FILE}')"
    elseif has("mac")
        let g:vikiOpenFileWith_ANY = "exec 'silent !open '. shellescape('%{FILE}')"
    elseif exists('$XDG_CURRENT_DESKTOP') && !empty($XDG_CURRENT_DESKTOP)
        let g:vikiOpenFileWith_ANY = "exec 'silent !xdg-open '. shellescape('%{FILE}')"
    elseif $GNOME_DESKTOP_SESSION_ID != "" || $DESKTOP_SESSION == 'gnome'
        let g:vikiOpenFileWith_ANY = "exec 'silent !gnome-open '. shellescape('%{FILE}')"
    elseif exists("$KDEDIR") && !empty($KDEDIR)
        let g:vikiOpenFileWith_ANY = "exec 'silent !kfmclient exec '. shellescape('%{FILE}')"
    endif
endif

if !exists('*VikiOpenSpecialFile')
    " Handles filenames that match |vikiSpecialFiles|.
    " If g:vikiOpenFileWith_{SUFFIX} is defined, it contains a command 
    " definition for opending files of this type. "%{FILE}" is replaced with the 
    " file name ("%%" = "%") and the resulting string is executed. Example: >
    " 
    "     let g:vikiOpenFileWith_html = '!firefox %{FILE}'
    " 
    " The contents of variable g:vikiOpenFileWith_ANY will be used as fallback
    " command. Under Windows, g:vikiOpenFileWith_ANY defaults to "silent !cmd /c 
    " start".
    " All suffixes are translated to lower case.
    function! VikiOpenSpecialFile(file) "{{{3
        " TLogVAR a:file
        let proto = tolower(fnamemodify(a:file, ':e'))
        if exists('g:vikiOpenFileWith_'. proto)
            let prot = g:vikiOpenFileWith_{proto}
        elseif exists('g:vikiOpenFileWith_ANY')
            let prot = g:vikiOpenFileWith_ANY
        else
            let prot = ''
        endif
        if prot != ''
            " let openFile = viki#SubstituteArgs(prot, 'FILE', fnameescape(a:file))
            let openFile = viki#SubstituteArgs(prot, 'FILE', a:file)
            " TLogVAR openFile
            call viki#ExecExternal(openFile)
        else
            throw 'Viki: Please define g:vikiOpenFileWith_'. proto .' or g:vikiOpenFileWith_ANY!'
        endif
    endf
endif


" Special protocol handlers {{{1
if !exists('g:vikiOpenUrlWith_mailbox')
    let g:vikiOpenUrlWith_mailbox = "call VikiOpenMailbox('%{URL}')" "{{{2
    function! VikiOpenMailbox(url) "{{{3
        exec viki#DecomposeUrl(strpart(a:url, 10))
        let idx = matchstr(args, 'number=\zs\d\+$')
        if filereadable(filename)
            call viki#OpenLink(filename, '', 0, 'go '.idx)
        else
            throw 'Viki: Can't find mailbox url: '.filename
        endif
    endf
endif

if !exists("g:vikiUrlFileAs")
    " Possible values: special*, query, normal
    let g:vikiUrlFileAs = 'special' "{{{2
endif

if !exists("g:vikiOpenUrlWith_file")
    let g:vikiOpenUrlWith_file = "call VikiOpenFileUrl('%{URL}')" "{{{2
    function! VikiOpenFileUrl(url) "{{{3
        " TLogVAR url
        if viki#IsSpecialFile(a:url)
            if g:vikiUrlFileAs == 'special'
                let as_special = 1
            elseif g:vikiUrlFileAs == 'query'
                echo a:url
                let as_special = input('Treat URL as special file? (Y/n) ')
                let as_special = (as_special[0] !=? 'n')
            else
                let as_special = 0
            endif
            " TLogVAR as_special
            if as_special
                call VikiOpenSpecialFile(a:url)
                return
            endif
        endif
        exec viki#DecomposeUrl(strpart(a:url, 7))
        if filereadable(filename) || isdirectory(filename)
            call viki#OpenLink(filename, anchor)
        else
            throw "Viki: Can't find file url: ". filename
        endif
    endf
endif

if !exists("g:vikiOpenUrlWith_ANY")
    " let g:vikiOpenUrlWith_ANY = "exec 'silent !". g:netrw_browsex_viewer ." '. escape('%{URL}', ' &!%')"
    if has("win32")
        " let g:vikiOpenUrlWith_ANY = "exec 'silent !rundll32 url.dll,FileProtocolHandler '. shellescape('%{URL}')"
        let g:vikiOpenUrlWith_ANY = "exec 'silent ! RunDll32.EXE URL.DLL,FileProtocolHandler '. shellescape('%{URL}', 1)"
    elseif has("mac")
        let g:vikiOpenUrlWith_ANY = "exec 'silent !open '. escape('%{URL}', ' &!%')"
    elseif exists('$XDG_CURRENT_DESKTOP') && !empty($XDG_CURRENT_DESKTOP)
        let g:vikiOpenFileWith_ANY = "exec 'silent !xdg-open '. shellescape('%{URL}')"
    elseif $GNOME_DESKTOP_SESSION_ID != ""
        let g:vikiOpenUrlWith_ANY = "exec 'silent !gnome-open '. shellescape('%{URL}')"
    elseif $KDEDIR != ""
        let g:vikiOpenUrlWith_ANY = "exec 'silent !kfmclient exec '. shellescape('%{URL}')"
    endif
endif

if !exists("*VikiOpenSpecialProtocol")
    " Handles filenames that match |vikiSpecialProtocols|.
    " If g:vikiOpenUrlWith_{PROTOCOL} is defined, it contains a command definition 
    " for opending urls of this type. "%{URL}" is replaced with the url ("%%" = 
    " "%") and the resulting string is executed. Example: >
    " 
    "     let g:vikiOpenUrlWith_mailto = '!thunderbird -compose %{URL}'
    " 
    " The contents of variable g:vikiOpenUrlWith_ANY will be used as fallback
    " command. Under Windows, g:vikiOpenUrlWith_ANY defaults to "silent 
    " !rundll32 url.dll ...".
    " All protocol names are translated to lower case.
    function! VikiOpenSpecialProtocol(url) "{{{3
        " TLogVAR a:url
        " TLogVAR a:url
        let proto = tolower(matchstr(a:url, '\c^[a-z]\{-}\ze:'))
        let prot  = 'g:vikiOpenUrlWith_'. proto
        let protp = exists(prot)
        if !protp
            let prot  = 'g:vikiOpenUrlWith_ANY'
            let protp = exists(prot)
        endif
        if protp
            exec 'let openURL = '. prot
            " let url = shellescape(a:url)
            let url = a:url
            " TLogVAR url, a:url
            let openURL = viki#SubstituteArgs(openURL, 'URL', url)
            " TLogVAR openURL
            call viki#ExecExternal(openURL)
        else
            throw 'Viki: Please define g:vikiOpenUrlWith_'. proto .' or g:vikiOpenUrlWith_ANY!'
        endif
    endf
endif


" Outdated: a cheap implementation of printf
function! s:sprintf1(string, arg) "{{{3
    if exists('printf')
        return printf(string, a:arg)
    else
        let rv = substitute(a:string, '\C[^%]\zs%s', escape(a:arg, '"\'), 'g')
        let rv = substitute(rv, '%%', '%', 'g')
        return rv
    end
endf


function! viki#GetInterVikis() "{{{3
    return g:vikiInterVikiNames
endf


" Get a rx that matches a simple name
function! viki#GetSimpleRx4SimpleWikiName() "{{{3
    let upper = s:UpperCharacters()
    let lower = s:LowerCharacters()
    let simpleWikiName = '\<['.upper.']['.lower.']\+\(['.upper.']['.lower.'0-9]\+\)\+\>'
    " This will mistakenly highlight words like LaTeX
    " let simpleWikiName = '\<['.upper.']['.lower.']\+\(['.upper.']['.lower.'0-9]\+\)\+'
    return simpleWikiName
endf


function! s:AddToRegexp(regexp, pattern) "{{{3
    if a:pattern == ''
        return a:regexp
    elseif a:regexp == ''
        return a:pattern
    else
        return a:regexp .'\|'. a:pattern
    endif
endf

" Make all filenames use slashes
function! viki#CanonicFilename(fname) "{{{3
    return substitute(simplify(a:fname), '[\/]\+', '/', 'g')
endf

" Build the rx to find viki names
function! viki#FindRx() "{{{3
    let rx = s:AddToRegexp('', b:vikiSimpleNameSimpleRx)
    let rx = s:AddToRegexp(rx, b:vikiExtendedNameSimpleRx)
    let rx = s:AddToRegexp(rx, b:vikiUrlSimpleRx)
    return rx
endf

" Wrap edit commands. Every action that creates a new buffer should use 
" this function.
function! s:EditWrapper(cmd, fname) "{{{3
    " TLogVAR a:cmd, a:fname
    let fname = simplify(a:fname)
    if g:vikiDirSeparator == '\' && fname !~ '^\w\+://'
        let fname = substitute(fname, '/', '\\', 'g')
        " TLogVAR fname
    endif
    if a:cmd =~ '^\(silent!\?\s\+\)\?!'
        " TLogVAR 1
        let fname = escape(fname, '%#')
        let fname = shellescape(fname)
        " TLogVAR fname
    elseif a:cmd !~ g:viki#cmd_no_fnameescape
        " TLogVAR 2
        let fname = fnameescape(fname)
    else
        " TLogVAR 3
        let fname = escape(fname, '%#')
    endif
    " let fname = escape(simplify(a:fname), '%#')
    if a:cmd =~ g:vikiNoWrapper
        " TLogDBG a:cmd .' '. fname
        " echom 'No wrapper: '. a:cmd .' '. fname
        exec a:cmd fname
    else
        try
            if g:vikiHide == 'hide'
                " TLogDBG 'hide '. a:cmd .' '. fname
                exec 'hide' a:cmd fname
            elseif g:vikiHide == 'update'
                " TLogDBG 'update | '. a:cmd .' '. fname
                update
                exec a:cmd fname
            else
                let pre = ''
                if &modified && !&hidden
                    call inputsave()
                    let val = input('Viki: Hide/save modified buffer? (HIDE/save/cancel) ')
                    call inputrestore()
                    if val =~? '^s\%[ave]$'
                        update
                    elseif val =~? '^c\%[ancel]$'
                        return
                    else
                        let pre = 'hide'
                    endif
                    echom "Viki: Please set g:vikiHide"
                endif
                " TLogDBG a:cmd .' '. fname
                exec pre a:cmd fname
            endif
        catch /^Vim\%((\a\+)\)\=:E37/
            echoerr "Vim raised E37: You tried to abondon a dirty buffer (see :h E37)"
            echoerr "Viki: You may want to reconsider your g:vikiHide or 'hidden' settings"
        catch /^Vim\%((\a\+)\)\=:E325/
        endtry
    endif
endf

" Find the previous heading
function! viki#FindPrevHeading()
    let vikisr=@/
    let cl = getline('.')
    if cl =~ '^\*'
        let head = matchstr(cl, '^\*\+')
        let head = '*\{1,'. len(head) .'}'
    else
        let head = '*\+'
    endif
    call search('\V\^'. head .'\s', 'bW')
    let @/=vikisr
endf

" Find the next heading
function! viki#FindNextHeading()
    " let pos = getpos('.')
    let view = winsaveview()
    " TLogVAR pos
    let cl  = getline('.')
    " TLogDBG 'line0='. cl
    if cl =~ '^\*'
        let head = matchstr(cl, '^\*\+')
        let head = '*\{1,'. len(head) .'}'
    else
        let head = '*\+'
    endif
    " TLogDBG 'head='. head
    " TLogVAR pos
    " call setpos('.', pos)
    call winrestview(view)
    let vikisr = @/
    call search('\V\^'. head .'\s', 'W')
    let @/=vikisr
endf

" Test whether we want to markup a certain viki name type for the current 
" buffer
" viki#IsSupportedType(type, ?types=b:vikiNameTypes)
function! viki#IsSupportedType(type, ...) "{{{3
    if a:0 >= 1
        let types = a:1
    elseif exists('b:vikiNameTypes')
        let types = b:vikiNameTypes
    else
        let types = g:vikiNameTypes
    end
    if types == ''
        return 1
    else
        " return stridx(b:vikiNameTypes, a:type) >= 0
        return types =~# '['. a:type .']'
    endif
endf

" Build an rx from a list of names
function! viki#RxFromCollection(coll) "{{{3
    " TAssert IsList(a:coll)
    let rx = join(a:coll, '\|')
    if rx == ''
        return ''
    else
        return '\V\('. rx .'\)'
    endif
endf

" Mark inexistent viki names
" VikiMarkInexistent(line1, line2, ?maxcol, ?quick)
" maxcol ... check only up to maxcol
" quick  ... check only if the cursor is located after a link
function! s:MarkInexistent(line1, line2, ...) "{{{3
    if !exists('b:vikiMarkInexistent') || !b:vikiMarkInexistent
        return
    endif
    if exists('b:vikiPosition')
        let li0 = b:vikiPosition.pos[1]
        let co0 = b:vikiPosition.pos[2]
        let co1 = co0 - 2
    else
        let li0 = line('.')
        let co0 = col('.')
        let co1 = co0 - 1
    end
    if a:0 >= 2 && a:2 > 0 && synIDattr(synID(li0, co1, 1), 'name') !~ '^viki.*Link$'
        return
    endif

    let lazyredraw = &lazyredraw
    set lazyredraw

    let maxcol = a:0 >= 1 ? (a:1 == -1 ? 9999999 : a:1) : 9999999

    if a:line1 > 0
        keepjumps call cursor(a:line1, 1)
        let min = a:line1
    else
        go
        let min = 1
    endif
    let max = a:line2 > 0 ? a:line2 : line('$')

    if line('.') == 1 && line('$') == max
        let b:vikiNamesNull = []
        let b:vikiNamesOk   = []
    else
        if !exists('b:vikiNamesNull') | let b:vikiNamesNull = [] | endif
        if !exists('b:vikiNamesOk')   | let b:vikiNamesOk   = [] | endif
    endif
    let b:vikiNamesNull0 = copy(b:vikiNamesNull)
    let b:vikiNamesOk0   = copy(b:vikiNamesOk)

    let feedback = (max - min) > b:vikiFeedbackMin
    let b:vikiMarkingInexistent = 1
    try
        if feedback
            call tlib#progressbar#Init(line('$'), 'Viki: Mark inexistent %s', 20)
        endif

        let rx = viki#FindRx()
        let pp = 0
        let ll = 0
        let cc = 0
        keepjumps let li = search(rx, 'Wc', max)
        let co = col('.')
        while li != 0 && !(ll == li && cc == co) && li >= min && li <= max && co <= maxcol
            let lic = line('.')
            if synIDattr(synID(lic, col('.'), 1), "name") !~ '^vikiFiles'
                if feedback
                    call tlib#progressbar#Display(lic)
                endif
                let ll  = li
                let co1 = co - 1
                " TLogVAR co1
                let def = viki#GetLink(1, getline('.'), co1)
                " TAssert IsList(def)
                " TLogDBG getline('.')[co1 : -1]
                " TLogVAR def
                if empty(def)
                    echom 'Internal error: VikiMarkInexistent: '. co .' '. getline('.')
                else
                    exec viki#SplitDef(def)
                    " TLogVAR v_part
                    if v_part =~ '^'. b:vikiSimpleNameSimpleRx .'$'
                        if v_dest =~ g:vikiSpecialProtocols
                            " TLogDBG "v_dest =~ g:vikiSpecialProtocols => 0"
                            let check = 0
                        elseif v:version >= 700 && viki#IsHyperWord(v_part)
                            " TLogDBG "viki#IsHyperWord(v_part) => 0"
                            let check = 0
                        elseif v_name == g:vikiSelfRef
                            " TLogDBG "simple self ref"
                            let check = 0
                        else
                            " TLogDBG "else1 => 1"
                            let check = 1
                            let partx = escape(v_part, "'\"\\/")
                            if partx !~ '^\['
                                let partx = '\<'.partx
                            endif
                            if partx !~ '\]$'
                                let partx = partx.'\>'
                            endif
                        endif
                    elseif v_dest =~ '^'. b:vikiUrlSimpleRx .'$'
                        " TLogDBG "v_dest =~ '^'. b:vikiUrlSimpleRx .'$' => 0"
                        let check = 0
                        let partx = escape(v_part, "'\"\\/")
                        call filter(b:vikiNamesNull, 'v:val != partx')
                        if index(b:vikiNamesOk, partx) == -1
                            call insert(b:vikiNamesOk, partx)
                        endif
                    elseif v_part =~ b:vikiExtendedNameSimpleRx
                        if v_dest =~ '^'. g:vikiSpecialProtocols .':'
                            " TLogDBG "v_dest =~ '^'. g:vikiSpecialProtocols .':' => 0"
                            let check = 0
                        else
                            " TLogDBG "else2 => 1"
                            let check = 1
                            let partx = escape(v_part, "'\"\\/")
                        endif
                        " elseif v_part =~ b:vikiCmdSimpleRx
                        " <+TODO+>
                    else
                        " TLogDBG "else3 => 0"
                        let check = 0
                    endif
                    " TLogVAR check, v_dest
                    if check && v_dest != g:vikiSelfRef && !isdirectory(v_dest)
                        if filereadable(v_dest)
                            call filter(b:vikiNamesNull, 'v:val != partx')
                            if index(b:vikiNamesOk, partx) == -1
                                call insert(b:vikiNamesOk, partx)
                            endif
                        else
                            if index(b:vikiNamesNull, partx) == -1
                                call insert(b:vikiNamesNull, partx)
                            endif
                            call filter(b:vikiNamesOk, 'v:val != partx')
                        endif
                        " TLogVAR partx, b:vikiNamesNull, b:vikiNamesOk
                    endif
                endif
                unlet! def
            endif
            keepjumps let li = search(rx, 'W', max)
            let co = col('.')
        endwh
        if b:vikiNamesOk0 != b:vikiNamesOk || b:vikiNamesNull0 != b:vikiNamesNull
            call viki#HighlightInexistent()
            if tlib#var#Get('vikiCacheInexistent', 'wbg')
                call viki#SaveCache()
            endif
        endif
        let b:vikiCheckInexistent = 0
    finally
        if feedback
            call tlib#progressbar#Restore()
        endif
        let &lazyredraw = lazyredraw
        unlet! b:vikiMarkingInexistent
    endtry
endf

" Actually highlight inexistent file names
function! viki#HighlightInexistent() "{{{3
    if b:vikiMarkInexistent == 1
        if exists('b:vikiNamesNull')
            exe 'syntax clear '. b:vikiInexistentHighlight
            let rx = viki#RxFromCollection(b:vikiNamesNull)
            if rx != ''
                exe 'syntax match '. b:vikiInexistentHighlight .' /\C'. rx .'/'
            endif
        endif
    elseif b:vikiMarkInexistent == 2
        if exists('b:vikiNamesOk')
            syntax clear vikiOkLink
            syntax clear vikiExtendedOkLink
            let rx = viki#RxFromCollection(b:vikiNamesOk)
            if rx != ''
                exe 'syntax match vikiOkLink /\C'. rx .'/'
            endif
        endif
    endif
endf

" Check a text element for inexistent names
if v:version == 700 && !has('patch8')
    function! s:SID()
        let fullname = expand("<sfile>")
        return matchstr(fullname, '<SNR>\d\+_')
    endf

    function! viki#MarkInexistentInElement(elt) "{{{3
        if exists('b:vikiEnabled') && b:vikiEnabled <= 1
            finish
        endif
        let lr = &lazyredraw
        set lazyredraw
        call viki#SaveCursorPosition()
        let kpk = s:SID() . "MarkInexistentIn" . a:elt
        call {kpk}()
        call viki#RestoreCursorPosition()
        call s:ResetSavedCursorPosition()
        let &lazyredraw = lr
        return ''
    endf

else

    " :nodoc:
    function! viki#MarkInexistentInElement(elt)
        if exists('b:vikiEnabled') && b:vikiEnabled <= 1
            finish
        endif
        let lr = &lazyredraw
        set lazyredraw
        try
            call viki#SaveCursorPosition()
            call s:MarkInexistentIn{a:elt}()
            call viki#RestoreCursorPosition()
            call s:ResetSavedCursorPosition()
            return ''
        finally
            let &lazyredraw = lr
        endtry
    endf

endif


function! viki#ExprMarkInexistentInElement(elt, key) "{{{3
    call viki#MarkInexistentInElement(a:elt)
    return a:key
endf


function! viki#MarkInexistentInRange(line1, line2) "{{{3
    let lr = &lazyredraw
    set lazyredraw
    try
        call viki#SaveCursorPosition()
        call s:MarkInexistent(a:line1, a:line2)
        call viki#RestoreCursorPosition()
        call s:ResetSavedCursorPosition()
    finally
        let &lazyredraw = lr
    endtry
endf

function! s:MarkInexistentInParagraph() "{{{3
    if getline('.') =~ '\S'
        call s:MarkInexistent(line("'{"), line("'}"))
    endif
endf

function! s:MarkInexistentInDocument() "{{{3
    call s:MarkInexistent(1, line("$"))
endf

function! s:MarkInexistentInParagraphVisible() "{{{3
    let l0 = max([line("'{"), line("w0")])
    let l1 = line(".")
    call s:MarkInexistent(l0, l1)
endf

function! s:MarkInexistentInParagraphQuick() "{{{3
    let l0 = line("'{")
    let l1 = line("'}")
    call s:MarkInexistent(l0, l1, -1, 1)
endf

function! s:MarkInexistentInLine() "{{{3
    call s:MarkInexistent(line("."), line("."))
endf

function! s:MarkInexistentInLineQuick() "{{{3
    call s:MarkInexistent(line("."), line("."), (col('.') + 1), 1)
endf

" Set values for the cache
function! s:CValsSet(cvals, var) "{{{3
    if exists('b:'. a:var)
        let a:cvals[a:var] = b:{a:var}
    endif
endf

" First-time markup of inexistent names. Handles cached values. Called 
" from syntax/viki.vim
function! viki#MarkInexistentInitial() "{{{3
    if tlib#var#Get('vikiCacheInexistent', 'wbg')
        let cfile = tlib#cache#Filename('viki_inexistent', '', 1)
        " TLogVAR cfile
        if getftime(cfile) < getftime(expand('%:p'))
        elseif !empty(cfile)
            let cvals = tlib#cache#Get(cfile)
            " TLogVAR cvals
            if !empty(cvals)
                for [key, value] in items(cvals)
                    let b:{key} = value
                    unlet value
                endfor
                call viki#HighlightInexistent()
                return
            endif
        endif
    else
        let cfile = ''
    endif
    call viki#MarkInexistentInElement('Document')
endf

function! viki#SaveCache(...) "{{{3
    if tlib#var#Get('vikiCacheInexistent', 'wbg')
        let cfile = a:0 >= 1 ? a:1 : tlib#cache#Filename('viki_inexistent', '', 1)
        if !empty(cfile)
            " TLogVAR cfile
            let cvals = {}
            call s:CValsSet(cvals, 'vikiNamesNull')
            call s:CValsSet(cvals, 'vikiNamesOk')
            call s:CValsSet(cvals, 'vikiInexistentHighlight')
            call s:CValsSet(cvals, 'vikiMarkInexistent')
            call tlib#cache#Save(cfile, cvals)
        endif
    endif
endf

" The function called from autocommands: re-check for inexistent names 
" when re-entering a buffer.
function! viki#CheckInexistent() "{{{3
    if !g:viki#quit && exists("b:vikiCheckInexistent") && b:vikiCheckInexistent > 0
        call viki#MarkInexistentInRange(b:vikiCheckInexistent, b:vikiCheckInexistent)
    endif
endf

" Initialize buffer-local variables on the basis of other variables "..." 
" or from a global variable.
function! viki#SetBufferVar(name, ...) "{{{3
    if !exists('b:'.a:name)
        if a:0 > 0
            let i = 1
            while i <= a:0
                exe 'let altVar = a:'. i
                if altVar[0] == '*'
                    exe 'let b:'.a:name.' = '. strpart(altVar, 1)
                    return
                elseif exists(altVar)
                    exe 'let b:'.a:name.' = '. altVar
                    return
                endif
                let i = i + 1
            endwh
            throw 'VikiSetBuffer: Couldn't set '. a:name
        elseif exists('g:'. a:name)
            exe 'let b:'.a:name.' = g:'.a:name
        endif
    endif
endf

" Get some vimscript code to set a variable from either a buffer-local or 
" a global variable
function! s:LetVar(name, var) "{{{3
    if exists('b:'.a:var)
        return 'let '.a:name.' = b:'.a:var
    elseif exists('g:'.a:var)
        return 'let '.a:name.' = g:'.a:var
    else
        return ''
    endif
endf

" Call a fn.family if existent, call fn otherwise.
" viki#DispatchOnFamily(fn, ?family='', *args)
function! viki#DispatchOnFamily(fn, ...) "{{{3
    let fam = a:0 >= 1 && a:1 != '' ? a:1 : viki#Family()
    if !exists('*viki_'. fam .'#SetupBuffer')
        exec 'runtime autoload/viki_'. fam .'.vim'
    endif
    if fam == '' || !exists('*viki_'.fam.'#'.a:fn)
        let cmd = 'viki'
    else
        let cmd = fam
    endif
    let cmd .= '#'. a:fn
    if a:0 >= 2
        let args = join(map(range(2, a:0), 'string(a:{v:val})'), ', ')
    else
        let args = ''
    endif
    " TLogDBG args
    " TLogDBG cmd .'('. args .')'
    exe 'return viki_'. cmd .'('. args .')'
endf

function! viki#IsHyperWord(word) "{{{3
    if !exists('b:vikiHyperWordTable')
        return 0
    endif
    return has_key(b:vikiHyperWordTable, s:CanonicHyperWord(a:word))
endf

function! viki#HyperWordValue(word) "{{{3
    return b:vikiHyperWordTable[s:CanonicHyperWord(a:word)]
endf

function! s:CanonicHyperWord(word) "{{{3
    " return substitute(a:word, '\s\+', '\\s\\+', 'g')
    return substitute(a:word, '\s\+', ' ', 'g')
endf

function! viki#CollectFileWords(table, simpleWikiName) "{{{3
    let patterns = []
    if exists('b:vikiNameSuffix')
        call add(patterns, b:vikiNameSuffix)
    endif
    if g:vikiNameSuffix != '' && index(patterns, g:vikiNameSuffix) == -1
        call add(patterns, g:vikiNameSuffix)
    end
    let suffix = '.'. expand('%:e')
    if suffix != '.' && index(patterns, suffix) == -1
        call add(patterns, suffix)
    end
    for p in patterns
        let files = glob(expand('%:p:h').'/*'. p)
        if files != ''
            let files_l = split(files, '\n')
            call filter(files_l, '!isdirectory(v:val) && v:val != expand("%:p")')
            if !empty(files_l)
                for w in files_l
                    let ww = s:CanonicHyperWord(fnamemodify(w, ":t:r"))
                    if !has_key(a:table, ww) && 
                                \ (a:simpleWikiName == '' || ww !~# a:simpleWikiName)
                        let a:table[ww] = w
                    endif
                endfor
            endif
        endif
    endfor
endf


function! viki#CollectHyperWords(table) "{{{3
    let vikiWordsBaseDir = expand('%:p:h')
    for filename in g:vikiHyperWordsFiles
        if filename =~ '^\./'
            let bn  = fnamemodify(filename, ':t')
            let filename = vikiWordsBaseDir . filename[1:-1]
            let acc = []
            for dir in tlib#file#Split(vikiWordsBaseDir)
                call add(acc, dir)
                let fn = tlib#file#Join(add(copy(acc), bn))
                call s:CollectVikiWords(a:table, fn, vikiWordsBaseDir)
            endfor
        else
            call s:CollectVikiWords(a:table, filename, vikiWordsBaseDir)
        endif
    endfor
endf


function! s:CollectVikiWords(table, filename, basedir) "{{{3
    " TLogVAR a:filename, a:basedir
    if filereadable(a:filename)
        let dir = fnamemodify(a:filename, ':p:h')
        " TLogVAR dir
        call tlib#dir#Push(dir, 1)
        try
            let hyperWords = readfile(a:filename)
            for wl in hyperWords
                if wl =~ '^\s*%'
                    continue
                endif
                let ml = matchlist(wl, '^\(.\{-}\) *\t\+ *\(.\+\)$')
                if !empty(ml)
                    let mkey = s:CanonicHyperWord(ml[1])
                    let mval = ml[2]
                    if mval == '-'
                        if has_key(a:table, mkey)
                            call remove(a:table, mkey)
                        endif
                    elseif !has_key(a:table, mkey)
                        " TLogVAR mval
                        " call TLogDBG(viki#IsInterViki(mval))
                        if viki#IsInterViki(mval)
                            let interviki = viki#InterVikiName(mval)
                            let suffix    = viki#InterVikiSuffix(mval, interviki)
                            let name      = viki#InterVikiPart(mval)
                            " TLogVAR mkey, interviki, suffix, name
                            let a:table[mkey] = {
                                        \ 'interviki': interviki,
                                        \ 'suffix':    suffix,
                                        \ 'name':      name,
                                        \ }
                        else
                            let a:table[mkey] = tlib#file#Relative(mval, a:basedir)
                            " TLogVAR mkey, mval, a:basedir, a:table[mkey]
                        endif
                    endif
                endif
            endfor
        finally
            call tlib#dir#Pop()
        endtry
    endif
endf

" Return a string defining upper-case characters
function! s:UpperCharacters() "{{{3
    return exists('b:vikiUpperCharacters') ? b:vikiUpperCharacters : g:vikiUpperCharacters
endf

" Return a string defining lower-case characters
function! s:LowerCharacters() "{{{3
    return exists('b:vikiLowerCharacters') ? b:vikiLowerCharacters : g:vikiLowerCharacters
endf

" Remove backslashes from string
function! s:StripBackslash(string) "{{{3
    return substitute(a:string, '\\\(.\)', '\1', 'g')
endf

" Map a key that triggers checking for inexistent names
function! viki#MapMarkInexistent(key, element) "{{{3
    if a:key == "\n"
        let key = '<cr>'
    elseif a:key == ' '
        let key = '<space>'
    else
        let key = a:key
    endif
    let arg = maparg(key, 'i')
    if arg == ''
        let arg = key
    endif
    exe 'inoremap <buffer> <expr> '. key .' viki#ExprMarkInexistentInElement('. string(a:element) .','. string(key) .')'
endf


" In case this function gets called repeatedly for the same position, check only once.
function! viki#HookCheckPreviousPosition(mode) "{{{3
    if s:hookcursormoved_oldpos != b:hookcursormoved_oldpos
        keepjumps keepmarks call s:MarkInexistent(b:hookcursormoved_oldpos[1], b:hookcursormoved_oldpos[1])
        let s:hookcursormoved_oldpos = b:hookcursormoved_oldpos
    endif
endf


" Outdated way to keep cursor information
function! s:ResetSavedCursorPosition() "{{{3
    let bn = bufnr('%')
    if has_key(s:positions, bn)
        call remove(s:positions, bn)
    endif
endf

call s:ResetSavedCursorPosition()


" Restore the cursor position
" viki#RestoreCursorPosition(?line, ?VCol, ?EOL, ?Winline)
function! viki#RestoreCursorPosition(...) "{{{3
    let bn = bufnr('%')
    if has_key(s:positions, bn)
        let ve = &virtualedit
        set virtualedit=all
        call winrestview(s:positions[bn].view)
        let &virtualedit = ve
    endif
endf

" Save the cursor position
function! viki#SaveCursorPosition() "{{{3
    let ve = &virtualedit
    set virtualedit=all
    " let s:lazyredraw = &lazyredraw
    " set nolazyredraw
    let bn = bufnr('%')
    let s:positions[bn] = {
                \ 'pos': getpos('.'),
                \ 'view': winsaveview(),
                \ 'w0': line('w0'),
                \ }
    "             \ 'eol': (col('.') == col('$')),
    "             \ 'virt': virtcol('.'),
    " if s:positions[bn].eol
    "     let s:positions[bn].virt += 1
    " endif

    let &virtualedit    = ve
    " call viki#DebugCursorPosition()
    return ''
endf

" Display a debug message
function! viki#DebugCursorPosition(...) "{{{3
    let bn = bufnr('%')
    if !has_key(s:positions, bn)
        return
    endif
    let msg = 'DBG '
    if a:0 >= 1 && a:1 != ''
        let msg = msg . a:1 .' '
    endif
    let msg = msg . string(s:positions[bn])
    if a:0 >= 2 && a:2
        echo msg
    else
        echom msg
    endif
endf

" Check if the key maps should support a specified functionality
function! viki#MapFunctionality(mf, key)
    return a:mf == 'ALL' || (a:mf =~# '\<'. a:key .'\>')
endf

function! viki#MinorMode(...) "{{{3
    let type = a:0 >= 1 ? a:1 : ''
    call viki#DispatchOnFamily('MinorMode', type, 1)
endf

" Re-set minor mode if the buffer is already in viki minor mode.
function! viki#MinorModeReset() "{{{3
    if exists("b:vikiEnabled") && b:vikiEnabled == 1
        call viki#DispatchOnFamily('MinorMode', '', 1)
    endif
endf

" Check whether line is within a region syntax
function! viki#IsInRegion(line) "{{{3
    let i   = 0
    let max = col('$')
    while i < max
        if synIDattr(synID(a:line, i, 1), "name") == "vikiRegion"
            return 1
        endif
        let i = i + 1
    endw
    return 0
endf

" Set back references for use with viki#GoBack()
function! s:SetBackRef(file, li, co) "{{{3
    if !empty(a:file)
        let br = s:GetBackRef()
        call filter(br, 'v:val[0] != a:file')
        call insert(br, [a:file, a:li, a:co])
    endif
endf

" Retrieve a certain back reference
function! s:SelectThisBackRef(n) "{{{3
    return 'let [vbf, vbl, vbc] = s:GetBackRef()['. a:n .']'
endf

" Select a back reference
function! s:SelectBackRef(...) "{{{3
    if a:0 >= 1 && a:1 >= 0
        let s = a:1
    else
        let br  = s:GetBackRef()
        let br0 = map(copy(br), 'v:val[0]')
        let st  = tlib#input#List('s', 'Select Back Reference', br0)
        if st != ''
            let s = index(br0, st)
        else
            let s = -1
        endif
    endif
    if s >= 0
        return s:SelectThisBackRef(s)
    endif
    return ''
endf

" Retrieve information for back references
function! s:GetBackRef()
    if g:vikiSaveHistory
        if type(g:VIKIBACKREFS) != 4
            unlet g:VIKIBACKREFS
            let g:VIKIBACKREFS = {}
        endif
        let id = expand('%:p')
        if empty(id)
            return []
        else
            if !has_key(g:VIKIBACKREFS, id)
                let g:VIKIBACKREFS[id] = []
            endif
            return g:VIKIBACKREFS[id]
        endif
    else
        if !exists('b:VIKIBACKREFS')
            let b:VIKIBACKREFS = []
        endif
        return b:VIKIBACKREFS
    endif
endf

" Jump to the parent buffer (or go back in history).
" If b:vikiParent is defined, open this viki name, otherwise use 
" |viki#GoBack()|.
function! viki#GoParent() "{{{3
    if exists('b:vikiParent')
        call viki#Edit(b:vikiParent)
    else
        call viki#GoBack()
    endif
endf

" Go back in history.
" Viki keeps record about the "source" files from where a viki page was 
" entered.  Calling this function jumps back to the "source" file (if only 
" one such back reference is known) or let's you select from a list of 
" "source" files. The information is stored in buffer variables -- i.e., 
" it gets lost after closing the buffer. Care was taken to reduce 
" information clutter, which is why the number of possible back references 
" per "source" file was limited to one.
function! viki#GoBack(...) "{{{3
    let s  = (a:0 >= 1) ? a:1 : -1
    let br = s:SelectBackRef(s)
    if br == ''
        echomsg "Viki: No back reference defined? (". s ."/". br .")"
    else
        exe br
        let buf = bufnr("^". vbf ."$")
        if buf >= 0
            call s:EditWrapper('buffer', buf)
        else
            call s:EditWrapper('edit', vbf)
        endif
        if vbf == expand("%:p")
            call cursor(vbl, vbc)
        else
            throw "Viki: Couldn't open file: ". vbf
        endif
    endif
endf

" Expand template strings as in
" "foo %{FILE} bar", 'FILE', 'file.txt' => "foo file.txt bar"
function! viki#SubstituteArgs(str, ...) "{{{3
    let i  = 1
    let rv = a:str
    let default = ''
    let done = 0
    while a:0 >= i
        exec "let lab = a:". i
        exec "let val = a:". (i+1)
        if lab == ''
            let default = val
        else
            let rv0 = substitute(rv, '\C\(^\|[^%]\)\zs%{'. lab .'}', escape(val, '\~&'), 'g')
            if rv != rv0
                let done = 1
                let rv = rv0
            endif
        endif
        let i = i + 2
    endwh
    if !done
        let rv .= ' '. default
    end
    let rv = substitute(rv, '%%', "%", "g")
    return rv
endf

if !exists('*VikiAnchor_l')
    " Handle special anchors in extented viki names
    " Example: [[index#l=10]]
    function! VikiAnchor_l(arg) "{{{3
        if a:arg =~ '^\d\+$'
            exec a:arg
        endif
    endf
endif

if !exists('*VikiAnchor_line')
    " Example: [[index#line=10]]
    function! VikiAnchor_line(arg) "{{{3
        call VikiAnchor_l(a:arg)
    endf
endif

if !exists('*VikiAnchor_rx')
    " Example: [[index#rx=foo]]
    function! VikiAnchor_rx(arg) "{{{3
        let arg = escape(s:StripBackslash(a:arg), '/')
        exec 'keepjumps norm! gg/'. arg .''
    endf
endif

if !exists('*VikiAnchor_vim')
    " Example: [[index#vim=/foo]]
    function! VikiAnchor_vim(arg) "{{{3
        exec s:StripBackslash(a:arg)
    endf
endif

" Return an rx for searching anchors
function! viki#GetAnchorRx(anchor)
    " TLogVAR a:anchor
    let anchorRx = tlib#var#Get('vikiAnchorMarker', 'wbg') . a:anchor
    if exists('b:vikiEnabled')
        let anchorRx = '\^\s\*\('. b:vikiCommentStart .'\)\?\s\*'. anchorRx
        if exists('b:vikiAnchorRx')
            " !!! b:vikiAnchorRx must be a very nomagic (\V) regexp 
            "     expression
            let varx = viki#SubstituteArgs(b:vikiAnchorRx, 'ANCHOR', a:anchor)
            let anchorRx = '\('.anchorRx.'\|'. varx .'\)'
        endif
    endif
    " TLogVAR anchorRx
    return '\V'. anchorRx
endf

" Set automatic anchor marks: #ma => 'a
function! viki#SetAnchorMarks() "{{{3
    let view = winsaveview()
    " TLogVAR pos
    let sr  = @/
    let anchorRx = viki#GetAnchorRx('m\zs\[a-zA-Z]\ze\s\*\$')
    " TLogVAR anchorRx
    exec 'silent! keepjumps g /'. anchorRx .'/exec "norm! m". matchstr(getline("."), anchorRx)'
    let @/ = sr
    call winrestview(view)
    if exists('*QuickfixsignsSet')
        call QuickfixsignsSet('', ['marks'])
    endif
endf

" Get the window number where the destination file should be opened
function! viki#GetWinNr(...) "{{{3
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    if type(winNr) == 0 && winNr == 0
        if exists('b:vikiSplit')
            let winNr = b:vikiSplit
        elseif exists('g:vikiSplit')
            let winNr = g:vikiSplit
        else
            let winNr = 0
        endif
    endif
    return winNr
endf

" Set the window where to open a file/display a buffer
function! viki#SetWindow(winNr) "{{{3
    let winNr = viki#GetWinNr(a:winNr)
    " TLogVAR winNr
    if type(winNr) == 1 && winNr == 'tab'
        tabnew
    elseif winNr != 0
        let wm = s:HowManyWindows()
        if winNr == -2
            wincmd v
        elseif wm == 1 || winNr == -1
            wincmd s
        else
            exec winNr ."wincmd w"
        end
    endif
endf

" Open a filename in a certain window and jump to an anchor if any
" viki#OpenLink(filename, anchor, ?create=0, ?postcmd='', ?wincmd=0)
function! viki#OpenLink(filename, anchor, ...) "{{{3
    " TLogVAR a:filename, a:anchor
    let create  = a:0 >= 1 ? a:1 : 0
    let postcmd = a:0 >= 2 ? a:2 : ''
    if a:0 >= 3
        let winNr = a:3
    elseif exists('b:vikiNextWindow')
        let winNr = b:vikiNextWindow
    else
        let winNr = 0
    endif
    " TLogVAR winNr
    
    let li = line('.')
    let co = col('.')
    let fi = expand('%:p')
   
    let filename = fnamemodify(a:filename, ':p')
    if exists('*simplify')
        let filename = simplify(filename)
    endif
    let buf = bufnr('^'. filename .'$')
    " TLogVAR filename, buf, bufloaded(buf), create, exists('b:editVikiPage')
    call viki#SetWindow(winNr)
    if buf >= 0 && bufloaded(buf)
        call s:EditLocalFile('buffer', buf, fi, li, co, a:anchor)
    elseif create && exists('b:createVikiPage')
        call s:EditLocalFile(b:createVikiPage, filename, fi, li, co, g:vikiDefNil)
    elseif exists('b:editVikiPage')
        call s:EditLocalFile(b:editVikiPage, filename, fi, li, co, g:vikiDefNil)
    elseif isdirectory(filename)
        call s:EditLocalFile(g:vikiExplorer, tlib#dir#PlainName(filename), fi, li, co, g:vikiDefNil)
    else
        call s:EditLocalFile('edit', filename, fi, li, co, a:anchor)
    endif
    if postcmd != ''
        exec postcmd
    endif
endf

" Open a local file in vim
function! s:EditLocalFile(cmd, fname, fi, li, co, anchor) "{{{3
    " TLogVAR a:cmd, a:fname, a:fi, a:li, a:co, a:anchor
    let vf = viki#Family()
    let cb = bufnr('%')
    call tlib#dir#Ensure(fnamemodify(a:fname, ':p:h'))
    call s:EditWrapper(a:cmd, a:fname)
    if cb != bufnr('%')
        set buflisted
    endif
    if vf != ''
        let b:vikiFamily = vf
    endif
    call s:SetBackRef(a:fi, a:li, a:co)
    if g:vikiPromote && (!exists('b:vikiEnabled') || !b:vikiEnable)
        call viki#DispatchOnFamily('MinorMode', vf, 1)
    endif
    call viki#DispatchOnFamily('FindAnchor', vf, a:anchor)
endf

" Get the current viki family
function! viki#Family(...) "{{{3
    let anyway = a:0 >= 1 ? a:1 : 0
    if (anyway || (exists('b:vikiEnabled') && b:vikiEnabled)) && exists('b:vikiFamily') && !empty(b:vikiFamily)
        let rv = b:vikiFamily
    else
        let rv = g:vikiFamily
    endif
    return empty(rv) ? 'viki' : rv
endf

" Return the number of windows
function! s:HowManyWindows() "{{{3
    let i = 1
    while winbufnr(i) > 0
        let i = i + 1
    endwh
    return i - 1
endf

" Decompose an url into filename, anchor, args
function! viki#DecomposeUrl(dest) "{{{3
    let dest = substitute(a:dest, '^\c/*\([a-z]\)|', '\1:', "")
    let rv = ""
    let i  = 0
    while 1
        let in = match(dest, '%\d\d', i)
        if in >= 0
            let c  = "0x".strpart(dest, in + 1, 2)
            let rv = rv. strpart(dest, i, in - i) . nr2char(c)
            let i  = in + 3
        else
            break
        endif
    endwh
    let rv     = rv. strpart(dest, i)
    let uend   = match(rv, '[?#]')
    if uend >= 0
        let args   = matchstr(rv, '?\zs.\+$', uend)
        let anchor = matchstr(rv, '#\zs.\+$', uend)
        let rv     = strpart(rv, 0, uend)
    else
        let args   = ""
        let anchor = ""
        let rv     = rv
    end
    return "let filename='". rv ."'|let anchor='". anchor ."'|let args='". args ."'"
endf

" Get a list of special files' suffixes
function! viki#GetSpecialFilesSuffixes() "{{{3
    " TAssert IsList(g:vikiSpecialFiles)
    if exists("b:vikiSpecialFiles")
        " TAssert IsList(b:vikiSpecialFiles)
        return b:vikiSpecialFiles + g:vikiSpecialFiles
    else
        return g:vikiSpecialFiles
    endif
endf

" Get an rx matching special files' suffixes
function! viki#GetSpecialFilesSuffixesRx(...) "{{{3
    let sfx = a:0 >= 1 ? a:1 : viki#GetSpecialFilesSuffixes()
    return join(sfx, '\|')
endf

" Check if dest is a special file
function! viki#IsSpecialFile(dest) "{{{3
    return (a:dest =~ '\.\('. viki#GetSpecialFilesSuffixesRx() .'\)$' &&
                \ (g:vikiSpecialFilesExceptions == "" ||
                \ !(a:dest =~ g:vikiSpecialFilesExceptions)))
endf

" Check if dest uses a special protocol
function! viki#IsSpecialProtocol(dest) "{{{3
    return a:dest =~ '^\('.b:vikiSpecialProtocols.'\):' &&
                \ (b:vikiSpecialProtocolsExceptions == "" ||
                \ !(a:dest =~ b:vikiSpecialProtocolsExceptions))
endf

" Check if dest is somehow special
function! viki#IsSpecial(dest) "{{{3
    return viki#IsSpecialProtocol(a:dest) || 
                \ viki#IsSpecialFile(a:dest) ||
                \ isdirectory(a:dest)
endf

" Open a viki name/link
function! s:FollowLink(def, ...) "{{{3
    " TLogVAR a:def
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    exec viki#SplitDef(a:def)
    if type(winNr) == 0 && winNr == 0
        " TAssert IsNumber(winNr)
        if exists('v_winnr')
            let winNr = v_winnr
        elseif exists('b:vikiOpenInWindow')
            if b:vikiOpenInWindow =~ '^l\(a\(s\(t\)\?\)\?\)\?'
                let winNr = s:HowManyWindows()
            elseif b:vikiOpenInWindow =~ '^[+-]\?\d\+$'
                if b:vikiOpenInWindow[0] =~ '[+-]'
                    exec 'let winNr = '. bufwinnr("%") . b:vikiOpenInWindow
                else
                    let winNr = b:vikiOpenInWindow
                endif
            endif
        endif
    endif
    let inter = s:GuessInterViki(a:def)
    let bn    = bufnr('%')
    " TLogVAR v_name, v_dest, v_anchor
    if v_name == g:vikiSelfRef || v_dest == g:vikiSelfRef
        call viki#DispatchOnFamily('FindAnchor', '', v_anchor)
    elseif v_dest == g:vikiDefNil
		throw 'No target? '. string(a:def)
    else
        call s:OpenLink(v_dest, v_anchor, winNr)
    endif
    if exists('b:vikiEnabled') && b:vikiEnabled && inter != '' && !exists('b:vikiInter')
        let b:vikiInter = inter
    endif
    return ""
endf

" Actually open a viki name/link
function! s:OpenLink(dest, anchor, winNr)
    let b:vikiNextWindow = a:winNr
    " TLogVAR a:dest, a:anchor, a:winNr
    try
        " TLogVAR viki#IsSpecialProtocol(a:dest)
        " TLogVAR viki#IsSpecialFile(a:dest)
        " TLogVAR isdirectory(a:dest)
        " TLogVAR filereadable(a:dest)
        " TLogVAR bufexists(a:dest), buflisted(a:dest)
        if viki#IsSpecialProtocol(a:dest)
            let url = viki#MakeUrl(a:dest, a:anchor)
            " TLogVAR url
            call VikiOpenSpecialProtocol(url)
        elseif viki#IsSpecialFile(a:dest)
            call VikiOpenSpecialFile(a:dest)
        elseif isdirectory(a:dest)
            " exec g:vikiExplorer .' '. a:dest
            call viki#OpenLink(a:dest, a:anchor, 0, '', a:winNr)
        elseif filereadable(a:dest) "reference to a local, already existing file
            call viki#OpenLink(a:dest, a:anchor, 0, '', a:winNr)
        elseif bufexists(a:dest) && buflisted(a:dest)
            call s:EditWrapper('buffer!', a:dest)
        else
            let ok = input("File doesn't exists. Create '".a:dest."'? (Y/n) ", "y")
            if ok != "" && ok != "n"
                let b:vikiCheckInexistent = line(".")
                call viki#OpenLink(a:dest, a:anchor, 1, '', a:winNr)
            endif
        endif
    finally
        let b:vikiNextWindow = 0
    endtry
endf

function! viki#MakeUrl(dest, anchor) "{{{3
    if a:anchor == ""
        return a:dest
    else
        return join([a:dest, a:anchor], '#')
    endif 
endf

" Guess the interviki name from a viki name definition
function! s:GuessInterViki(def) "{{{3
    exec viki#SplitDef(a:def)
    if v_type == 's'
        let exp = v_name
    elseif v_type == 'e'
        let exp = v_dest
    else
        return ''
    endif
    if viki#IsInterViki(exp)
        return viki#InterVikiName(exp)
    else
        return ''
    endif
endf

" Somewhat pointless legacy function
function! s:MakeVikiDefPart(txt) "{{{3
    if a:txt == ''
        return g:vikiDefNil
    else
        return a:txt
    endif
endf

" Return a structure or whatever describing a viki name/link
function! viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type) "{{{3
    let arr = map([a:v_name, a:v_dest, a:v_anchor, a:v_part, a:v_type, 0], 's:MakeVikiDefPart(v:val)')
    " TLogDBG string(arr)
    return arr
endf

" Legacy function: Today we would use dictionaries for this
" Return vimscript code that defines a set of variables on the basis of a 
" viki name definition
function! viki#SplitDef(def) "{{{3
    " TAssert IsList(a:def)
    " TLogDBG string(a:def)
    if empty(a:def)
        let rv = 'let [v_name, v_dest, v_anchor, v_part, v_type, v_winnr] = ["", "", "", "", "", ""]'
    else
        if a:def[4] == 'e'
            let mod = viki#ExtendedModifier(a:def[3])
            if mod =~# '*'
                let a:def[5] = -1
            endif
        endif
        let rv = 'let [v_name, v_dest, v_anchor, v_part, v_type, v_winnr] = '. string(a:def)
    endif
    return rv
endf

function! s:ExtractMatch(match, idx, default) "{{{3
    if a:idx > 0
        return get(a:match, a:idx, a:default)
    else
        return a:default
    endif
endf

function! viki#MalformedName(msg) "{{{3
    let msg = "Viki: Malformed viki name: ". a:msg
    if g:viki#error_malformed_names
        throw msg
    else
        echohl WarningMsg
        echom msg
        echohl NONE
    endif
endf

" If txt matches a viki name typed as defined by compound return a 
" structure defining this viki name.
function! viki#LinkDefinition(txt, col, compound, ignoreSyntax, type) "{{{3
    " TLogVAR a:txt, a:compound, a:col
    exe a:compound
    if erx != ''
        let ebeg = -1
        let cont = match(a:txt, erx, 0)
        " TLogDBG 'cont='. cont .'('. a:col .')'
        while (ebeg >= 0 || (0 <= cont) && (cont <= a:col))
            let contn = matchend(a:txt, erx, cont)
            " TLogDBG 'contn='. contn .'('. cont.')'
            if (cont <= a:col) && (a:col < contn)
                let ebeg = match(a:txt, erx, cont)
                let elen = contn - ebeg
                break
            else
                let cont = match(a:txt, erx, contn)
            endif
        endwh
        " TLogDBG 'ebeg='. ebeg
        if ebeg >= 0
            let part   = strpart(a:txt, ebeg, elen)
            let match  = matchlist(part, '^\C'. erx .'$')
            let name   = s:ExtractMatch(match, nameIdx,   g:vikiDefNil)
            let dest   = s:ExtractMatch(match, destIdx,   g:vikiDefNil)
            let anchor = s:ExtractMatch(match, anchorIdx, g:vikiDefNil)
            " TLogVAR name, dest, anchor, part, a:type
            return viki#MakeDef(name, dest, anchor, part, a:type)
        elseif a:ignoreSyntax
            return []
        else
            call viki#MalformedName("v_name: " . a:txt . " (". erx .")")
            return []
        endif
    else
        return []
    endif
endf

" Return a viki filename with a suffix
function! viki#WithSuffix(fname)
    " TLogVAR a:fname
    " TLogDBG isdirectory(a:fname)
    if isdirectory(a:fname)
        return a:fname
    else
        return a:fname . s:GetSuffix()
    endif
endf

" Get the suffix to use for viki filenames
function! s:GetSuffix() "{{{3
    if exists('b:vikiNameSuffix')
        return b:vikiNameSuffix
    endif
    if g:vikiUseParentSuffix
        let sfx = expand("%:e")
        " TLogVAR sfx
        if !empty(sfx)
            return '.'. sfx
        endif
    endif
    return g:vikiNameSuffix
endf

" Return the real destination for a simple viki name
function! viki#ExpandSimpleName(dest, name, suffix) "{{{3
    " TLogVAR a:dest
    if a:name == ''
        return a:dest
    else
        if a:dest == ''
            let dest = a:name
        else
            let dest = a:dest . g:vikiDirSeparator . a:name
        endif
        " TLogVAR dest, a:suffix
        if a:suffix == g:vikiDefSep
            " TLogDBG 'ExpandSimpleName 1'
            return viki#WithSuffix(dest)
        elseif isdirectory(dest)
            " TLogDBG 'ExpandSimpleName 2'
            return dest
        else
            " TLogDBG 'ExpandSimpleName 3'
            return dest . a:suffix
        endif
    endif
endf

" Check whether a vikiname uses an interviki
function! viki#IsInterViki(vikiname)
    return  viki#IsSupportedType('i') && a:vikiname =~# s:InterVikiRx
endf

" Get the interviki name of a vikiname
function! viki#InterVikiName(vikiname)
    let ml = matchlist(a:vikiname, s:InterVikiRx)
    let name = get(ml, 1, '')
    " echom "DBG" a:vikiname string(ml) name
    return name
endf

" Get the plain vikiname of a vikiname
function! viki#InterVikiPart(vikiname)
    let ml = matchlist(a:vikiname, s:InterVikiRx)
    let part = get(ml, 2, '')
    " echom "DBG" a:vikiname string(ml) part
    return part
endf

" Return vimscript code describing an interviki
function! s:InterVikiDef(vikiname, ...)
    let ow = a:0 >= 1 ? a:1 : viki#InterVikiName(a:vikiname)
    let vd = s:LetVar('i_dest', 'vikiInter'.ow)
    let id = s:LetVar('i_index', 'vikiInter'.ow.'_index')
    " TLogVAR a:vikiname, ow, id
    if !empty(id)
        let vd .= '|'. id
    endif
    " TLogVAR vd
    if vd != ''
        exec vd
        if i_dest =~ '^\*\S\+('
            let it = 'fn'
        elseif i_dest[0] =~ '%'
            let it = 'fmt'
        else
            let it = 'prefix'
        endif
        return vd .'|let i_type="'. it .'"|let i_name="'. ow .'"'
    end
    return vd
endf

" Return an interviki's root directory
function! viki#InterVikiDest(vikiname, ...)
    TVarArg 'ow', ['rx', 0]
    " TLogVAR ow, rx
    if empty(ow)
        let ow     = viki#InterVikiName(a:vikiname)
        let v_dest = viki#InterVikiPart(a:vikiname)
    else
        let v_dest = a:vikiname
    endif
    let vd = s:InterVikiDef(a:vikiname, ow)
    " TLogVAR vd
    if vd != ''
        exec vd
        let f = strpart(i_dest, 1)
        " TLogVAR i_type, i_dest
        if !empty(rx)
            let f = s:RxifyFilename(f)
        endif
        if i_type == 'fn'
            exec 'let v_dest = '. s:sprintf1(f, v_dest)
        elseif i_type == 'fmt'
            let v_dest = s:sprintf1(f, v_dest)
        else
            if empty(v_dest) && exists('i_index')
                let v_dest = i_index
                " TLogVAR v_dest, i_index
            endif
            let i_dest = fnamemodify(i_dest, ':p')
            " TLogVAR i_dest, rx
            if !empty(rx)
                if i_dest !~ '[\/]$'
                    let i_dest .= '/'
                endif
                let i_dest = s:RxifyFilename(i_dest)
                " TLogVAR i_dest
                let v_dest = i_dest . v_dest
            else
                let v_dest = tlib#file#Join([i_dest, v_dest], 1)
            endif
        endif
        " TLogVAR v_dest
        return v_dest
    else
        " TLogVAR ow
        echohl Error
        echom "Viki: InterViki is not defined: ". ow
        echohl NONE
        return g:vikiDefNil
    endif
endf

function! s:RxifyFilename(filename) "{{{3
    let f = tlib#rx#Escape(a:filename)
    if exists('+shellslash')
        let f = substitute(f, '\(\\\\\|/\)', '[\\/]', 'g')
    endif
    return f
endf

" Return an interviki's suffix
function! viki#InterVikiSuffix(vikiname, ...)
    exec tlib#arg#Let(['ow'])
    if empty(ow)
        let ow = viki#InterVikiName(a:vikiname)
    endif
    let vd = s:InterVikiDef(a:vikiname, ow)
    if vd != ''
        exec vd
        if i_type =~ 'fn'
            return ''
        else
            if fnamemodify(a:vikiname, ':e') != ''
                let useSuffix = ''
            else
                exec s:LetVar('useSuffix', 'vikiInter'.ow.'_suffix')
            endif
            return useSuffix
        endif
    else
        return ''
    endif
endf

" Return the modifiers in extended viki names
function! viki#ExtendedModifier(part)
    " let mod = substitute(a:part, b:vikiExtendedNameRx, '\'.b:vikiExtendedNameModIdx, '')
    let mod = matchlist(a:part, b:vikiExtendedNameRx)[b:vikiExtendedNameModIdx]
    if mod != a:part
        return mod
    else
        return ''
    endif
endf

" Complete a file's basename on the basis of a list of suffixes
function! viki#FindFileWithSuffix(filename, suffixes) "{{{3
    " TAssert IsList(a:suffixes)
    " TLogVAR a:filename, a:suffixes
    if filereadable(a:filename)
        return a:filename
    else
        for elt in a:suffixes
            if elt != ''
                let fn = a:filename .".". elt
                if filereadable(fn)
                    return fn
                endif
            else
                return g:vikiDefNil
            endif
        endfor
    endif
    return g:vikiDefNil
endf

" Do something if no viki name was found under the cursor position
function! s:LinkNotFoundEtc(oldmap, ignoreSyntax) "{{{3
    if a:oldmap == ""
        echomsg "Viki: Show me the way to the next viki name or I have to ... ".a:ignoreSyntax.":".getline(".")
    elseif a:oldmap == 1
        return "\<c-cr>"
    else
        return a:oldmap
    endif
endf

" This is the core function that builds a viki name definition from what 
" is under the cursor.
" viki#GetLink(ignoreSyntax, ?txt, ?col=0, ?supported=b:vikiNameTypes)
function! viki#GetLink(ignoreSyntax, ...) "{{{3
    let col   = a:0 >= 2 ? a:2 : 0
    let types = a:0 >= 3 ? a:3 : b:vikiNameTypes
    if a:0 >= 1 && a:1 != ''
        let txt      = a:1
        let vikiType = a:ignoreSyntax
        let tryAll   = 1
    else
        let synName = synIDattr(synID(line('.'), col('.'), 0), 'name')
        if synName ==# 'vikiLink'
            let vikiType = 1
            let tryAll   = 0
        elseif synName ==# 'vikiExtendedLink'
            let vikiType = 2
            let tryAll   = 0
        elseif synName ==# 'vikiURL'
            let vikiType = 3
            let tryAll   = 0
        elseif synName ==# 'vikiCommand' || synName ==# 'vikiMacro'
            let vikiType = 4
            let tryAll   = 0
        elseif a:ignoreSyntax
            let vikiType = a:ignoreSyntax
            let tryAll   = 1
        else
            return ''
        endif
        let txt = getline('.')
        let col = col('.') - 1
    endif
    " TLogDBG "txt=". txt
    " TLogDBG "col=". col
    " TLogDBG "tryAll=". tryAll
    " TLogDBG "vikiType=". tryAll
    if (tryAll || vikiType == 2) && viki#IsSupportedType('e', types)
        if exists('b:getExtVikiLink')
            exe 'let def = ' . b:getExtVikiLink.'()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiExtendedNameCompound, a:ignoreSyntax, 'e')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteExtendedNameDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 3) && viki#IsSupportedType('u', types)
        if exists('b:getURLViki')
            exe 'let def = ' . b:getURLViki . '()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiUrlCompound, a:ignoreSyntax, 'u')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteExtendedNameDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 4) && viki#IsSupportedType('x', types)
        if exists('b:getCmdViki')
            exe 'let def = ' . b:getCmdViki . '()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiCmdCompound, a:ignoreSyntax, 'x')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteCmdDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 1) && viki#IsSupportedType('s', types)
        if exists('b:getVikiLink')
            exe 'let def = ' . b:getVikiLink.'()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiSimpleNameCompound, a:ignoreSyntax, 's')
        endif
        " TLogVAR def
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteSimpleNameDef', '', def)
        endif
    endif
    return []
endf

" :display: viki#MaybeFollowLink(oldmap, ignoreSyntax, ?winNr=0)
" Follow a viki name if any or complain about not having found a valid 
" viki name under the cursor.
" oldmap: If there isn't a viki link under the cursor:
"     ""       ... throw error 
"     1        ... return \<c-cr>
"  	whatever ... return whatever
" ignoreSyntax: If there isn't a viki syntax group under the cursor:
"     0 ... no viki name found
"     1 ... look if there is a viki name under cursor anyways
function! viki#MaybeFollowLink(oldmap, ignoreSyntax, ...) "{{{3
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    let def = viki#GetLink(a:ignoreSyntax)
    " TAssert IsList(def)
    if empty(def)
        return s:LinkNotFoundEtc(a:oldmap, a:ignoreSyntax)
    else
        return s:FollowLink(def, winNr)
    endif
endf


function! viki#InterEditArg(iname, name) "{{{3
    if a:name !~ '^'. tlib#rx#Escape(a:iname) .'::'
        return a:iname .'::'. a:name
    else
        return a:name
    endif
endf


" :display: viki#HomePage(?winNr=0)
" Open the homepage.
function! viki#HomePage(...) "{{{3
    TVarArg ['winNr', 0]
    if g:vikiHomePage != ''
        let bufnr = bufnr(g:vikiHomePage)
        if bufnr != -1
            exec 'buffer '. bufnr
        else
            call viki#OpenLink(g:vikiHomePage, '', '', '', winNr)
        endif
        return 1
    else
        return 0
    endif
endf


" :display: viki#Edit(name, ?ignoreSpecial=0, ?winNr=0)
" Edit a vikiname
function! viki#Edit(name, ...) "{{{3
    TVarArg ['ignoreSpecial', 0], ['winNr', 0]
    " TLogVAR a:name
    if winNr != 0
        exec winNr .'wincmd w'
    endif
    if exists('b:vikiEnabled') 
        if !viki#HomePage(winNr)
            call tlib#notify#Echo('VIKI: Please set g:vikiHomePage', 'WarningMsg')
            call s:EditWrapper('buffer', 1)
        endif
    endif
    if a:name == '*'
        let name = g:vikiHomePage
    else
        let name = a:name
    end
    if empty(name)
        return
    endif
    let name = substitute(name, '\\', '/', 'g')
    if !exists('b:vikiNameTypes')
        call viki#SetBufferVar('vikiNameTypes')
        call viki#DispatchOnFamily('SetupBuffer', '', 0)
    endif
    let def = viki#GetLink(1, '[['. name .']]', 0, '')
    " TLogVAR def
    " TAssert IsList(def)
    if empty(def)
        call s:LinkNotFoundEtc('', 1)
    else
        exec viki#SplitDef(def)
        if ignoreSpecial
            call viki#OpenLink(v_dest, '', '', '', winNr)
        else
            call s:OpenLink(v_dest, '', winNr)
        endif
    endif
endf


function! viki#Browse(name) "{{{3
    " TLogVAR a:name
    let iname = a:name .'::'
    let vd = s:InterVikiDef(iname, a:name)
    " TLogVAR vd
    if !empty(vd)
        exec vd
        " TLogVAR i_type
        if i_type == 'prefix'
            exec s:LetVar('sfx', 'vikiInter'. a:name .'_suffix')
            " TLogVAR i_dest, sfx
            let files = split(globpath(i_dest, '**'), '\n')
            if !empty(sfx)
                call filter(files, 'v:val =~ '''. tlib#rx#Escape(sfx) .'$''')
            endif
            let files = tlib#input#List('m', 'Select files', files, [
                        \ {'display_format': 'filename'},
                        \ ])
            for fn in files
                call viki#OpenLink(fn, g:vikiDefNil)
                " echom fn
            endfor
            return
        endif
    endif
    echoerr 'Viki: No an interviki name: '. a:name
endf

function! viki#BrowseComplete(ArgLead, CmdLine, CursorPos) "{{{3
    let rv = copy(g:vikiInterVikiNames)
    let rv = filter(rv, 'v:val =~ ''^'. a:ArgLead .'''')
    let rv = map(rv, 'matchstr(v:val, ''\w\+'')')
    return rv
endf


" Helper function for the command line completion of :VikiEdit
function! s:EditCompleteAgent(interviki, afname, fname) "{{{3
    if isdirectory(a:afname)
        return a:afname .'/'
    else
        if exists('g:vikiInter'. a:interviki .'_suffix')
            let sfx = g:vikiInter{a:interviki}_suffix
        else
            let sfx = s:GetSuffix()
        endif
        if sfx != '' && sfx == '.'. fnamemodify(a:fname, ':e')
            let name = fnamemodify(a:fname, ':t:r')
        else
            let name = a:fname
        endif
        if a:interviki != ''
            let name = a:interviki .'::'. name
        endif
        return name
    endif
endf

" Helper function for the command line completion of :VikiEdit
function! s:EditCompleteMapAgent1(val, sfx, iv, rx) "{{{3
    if isdirectory(a:val)
        let rv = a:val .'/'
    else
        let rsfx = '\V'. a:sfx .'\$'
        if a:sfx != '' && a:val !~ rsfx
            return ''
        else
            let rv = substitute(a:val, rsfx, '', '')
            if isdirectory(rv)
                let rv = a:val
            endif
        endif
    endif
    " TLogVAR rv, a:rx
    let m = matchlist(rv, a:rx)
    " TLogVAR m
    let rv = m[1]
    " TLogVAR rv
    if empty(a:iv)
        return rv
    else
        return a:iv .'::'. rv
    endif
endf

" Command line completion of |:VikiEdit|
function! viki#EditComplete(ArgLead, CmdLine, CursorPos) "{{{3
    " TLogVAR a:ArgLead, a:CmdLine, a:CursorPos
    let rx_pre = '^\s*\(\d*\(verb\|debug\|sil\|sp\|vert\|tab\)\w\+!\?\s\+\)*'
    let arglead = matchstr(a:CmdLine, rx_pre .'\(\u\+\)!\?\s\zs.*')
    let ii = matchstr(a:CmdLine, rx_pre .'\zs\(\u\+\)\ze!\?\s')
    " TLogVAR ii
    if !empty(ii) && arglead !~ '::'
        let arglead = ii.'::'.arglead
    endif
    let i = viki#InterVikiName(arglead)
    " TLogVAR i, arglead
    if index(g:vikiInterVikiNames, i.'::') >= 0
        if exists('g:vikiInter'. i .'_suffix')
            let sfx = g:vikiInter{i}_suffix
        else
            let sfx = s:GetSuffix()
        endif
    else
        let i = ''
        let sfx = s:GetSuffix()
    endif
    " TLogVAR i
    if i != '' && exists('g:vikiInter'. i)
        " TLogDBG 'A'
        let f  = matchstr(arglead, '::\(\[-\)\?\zs.*$')
        let d  = viki#InterVikiDest(f.'*', i)
        let r  = '^'. viki#InterVikiDest('\(.\{-}\)', i, 1) .'$'
        " TLogVAR f,d,r
        let d  = substitute(d, '\', '/', 'g')
        let rv = split(glob(d), '\n')
        " TLogVAR d,rv
        if sfx != ''
            call filter(rv, 'isdirectory(v:val) || ".". fnamemodify(v:val, ":e") == sfx')
        endif
        " TLogVAR rv
        call map(rv, 's:EditCompleteMapAgent1(v:val, sfx, i, r)')
        " TLogVAR rv
        call filter(rv, '!empty(v:val)')
        " TLogVAR rv
    else
        " TLogDBG 'B'
        let rv = split(glob(arglead.'*'.sfx), '\n')
        " TLogVAR rv
        call map(rv, 's:EditCompleteAgent('. string(i) .', v:val, v:val)')
        " TLogVAR rv
        if arglead == ''
            let rv += g:vikiInterVikiNames
        else
            let rv += filter(copy(g:vikiInterVikiNames), 'v:val =~ ''\V\^''.arglead')
        endif
    endif
    " TLogVAR rv
    return rv
endf

" Edit the current directory's index page
function! viki#Index() "{{{3
    if exists('b:vikiIndex')
        let fname = viki#WithSuffix(b:vikiIndex)
    else
        let fname = viki#WithSuffix(g:vikiIndex)
    endif
    if filereadable(fname)
        return viki#OpenLink(fname, '')
    else
        echom "Index page not found: ". fname
    endif
endf


fun! viki#FindNextRegion(name) "{{{3
    let rx = s:GetRegionStartRx(a:name)
    return search(rx, 'We')
endf

" Indentation
fun! viki#GetIndent()
    let lr = &lazyredraw
    set lazyredraw
    try
        let cnum = v:lnum
        " Find a non-blank line above the current line.
        let lnum = prevnonblank(v:lnum - 1)

        " At the start of the file use zero indent.
        if lnum == 0
            " TLogVAR lnum
            return 0
        endif

        let ind  = indent(lnum)
        " if ind == 0
        "     TLogVAR ind
        "     return 0
        " end

        let line = getline(lnum)      " last line
        " TLogVAR lnum, ind, line
        
        let cind  = indent(cnum)
        let cline = getline(cnum)
        " TLogVAR v:lnum, cnum, cind, cline
        
        " Do not change indentation in regions
        if viki#IsInRegion(cnum)
            " TLogVAR cnum, cind
            return cind
        endif
        
        let cHeading = matchend(cline, '^\*\+\s\+')
        if cHeading >= 0
            " TLogVAR cHeading
            return 0
        endif
            
        let pnum   = v:lnum - 1
        let pind   = indent(pnum)
        let pline  = getline(pnum) " last line
        let plCont = matchend(pline, '\\$')
        
        if plCont >= 0
            " TLogVAR plCont, cind
            return cind
        end
        
        if cind > 0
            " TLogVAR cind
            " Do not change indentation of:
            "   - commented lines
            "   - headings
            if cline =~ '^\(\s*%\|\*\)'
                " TLogVAR cline, ind
                return ind
            endif

            let markRx = '^\s\+\([#?!+]\)\1\{2,2}\s\+'
            let listRx = '^\s\+\([-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\)\s\+'
            let priRx  = '^\s\+#[A-Z]\d\? \+\([x_0-9%-]\+ \+\)\?'
            let descRx = '^\s\+.\{-1,}\s::\s\+'
            
            let clMark = matchend(cline, markRx)
            let clList = matchend(cline, listRx)
            let clPri  = matchend(cline, priRx)
            let clDesc = matchend(cline, descRx)
            " let cln    = clList >= 0 ? clList : clDesc

			let swhalf = &sw / 2

            if clList >= 0 || clDesc >= 0 || clMark >= 0 || clPri >= 0
                " let spaceEnd = matchend(cline, '^\s\+')
                " let rv = (spaceEnd / &sw) * &sw
                let rv = (cind / &sw) * &sw
                " TLogVAR clList, clDesc, clMark, clPri, rv
                return rv
            else
                let plMark = matchend(pline, markRx)
                if plMark >= 0
                    " TLogVAR plMark
                    " return plMark
                    return pind + 4
                endif
                
                let plList = matchend(pline, listRx)
                if plList >= 0
                    " TLogVAR plList
                    return plList
                endif

                let plPri = matchend(pline, priRx)
                if plPri >= 0
                    " let rv = indent(pnum) + &sw / 2
                    let rv = pind + swhalf
                    " TLogVAR plPri, rv
                    " return plPri
                    return rv
                endif

                let plDesc = matchend(pline, descRx)
                if plDesc >= 0
                    " TLogVAR plDesc, pind
                    if plDesc >= 0 && g:vikiIndentDesc == '::'
                        " return plDesc
                        return pind
                    else
                        return pind + swhalf
                    endif
                endif

                " TLogVAR cind, ind
                if cind < ind
                    let rv = (cind / &sw) * &sw
                    return rv
                elseif cind >= ind
                    if cind % &sw == 0
                        return cind
                    else
                        return ind
                    end
                endif
            endif
        endif

        " TLogVAR ind
        return ind
    finally
        let &lazyredraw = lr
    endtry
endf

function! viki#ExecExternal(cmd) "{{{3
    " TLogVAR a:cmd
    exec a:cmd
    if !has("gui_running")
        " Scrambled window with vim
        redraw!
    endif
endf


" :doc:
" #Files related stuff

fun! viki#FilesUpdateAll() "{{{3
    let view = winsaveview()
    try
        norm! gg
        while viki#FindNextRegion('Files')
            call viki#FilesUpdate()
            norm! j
        endwh
    finally
        if winsaveview() != view
            call winrestview(view)
        endif
    endtry
endf

fun! viki#FilesExec(cmd, bang, ...) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    if a:0 >= 1 && a:1
        let lb = line('.')
        let le = line('.') + 1
    endif
    let ilen = len(indent)
    let done = []
    for f in s:CollectFileNames(lb, le, a:bang)
        let ff = escape(f, '%#\ ')
        let x = viki#SubstituteArgs(a:cmd, 
                    \ '', ff, 
                    \ 'FILE', f, 
                    \ 'FFILE', ff,
                    \ 'DIR', fnamemodify(f, ':h'))
        if index(done, x) == -1
            exec x
            call add(done, x)
        endif
    endfor
endf

fun! viki#FilesCmd(cmd, bang) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        exec VikiCmd_{a:cmd} .' '. escape(t, '%#\ ')
    endfor
endf

fun! viki#FilesCall(cmd, bang) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        call VikiCmd_{a:cmd}(t)
    endfor
endf

fun! s:CollectFileNames(lb, le, bang) "{{{3
    let afile = viki#FilesGetFilename(getline('.'))
    let acc   = []
    for l in range(a:lb, a:le - 1)
        let line  = getline(l)
        let bfile = viki#FilesGetFilename(line)
        if s:IsEligibleLine(afile, bfile, a:bang)
            call add(acc, fnamemodify(bfile, ':p'))
        endif
    endfor
    return acc
endf

fun! s:IsEligibleLine(afile, bfile, bang) "{{{3
    if empty(a:bang)
        return 1
    else
        if isdirectory(a:bfile)
            return 0
        else
            let adir  = isdirectory(a:afile) ? a:afile : fnamemodify(a:afile, ':h')
            let bdir  = isdirectory(a:bfile) ? a:bfile : fnamemodify(a:bfile, ':h')
            let rv = s:IsSubdir(adir, bdir)
            return rv
        endif
    endif
endf

fun! s:IsSubdir(adir, bdir) "{{{3
    if a:adir == '' || a:bdir == ''
        return 0
    elseif a:adir == a:bdir
        return 1
    else
        return s:IsSubdir(a:adir, fnamemodify(a:bdir, ':h'))
    endif
endf

fun! viki#FilesUpdate() "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    " TLogVAR lh, lb, le, indent
    call s:DeleteRegionBody(lb, le)
    call viki#DirListing(lh, lb, indent)
endf

" Update a #Files region. The following arguments are allowed to specify 
" how the file list should be displayed:
"
"     glob=PATTERN ... A file pattern with |wildcards|. % and # (see 
"                      |cmdline-special|) are expanded too.
"     head=NUMBER .... Display the first N lines of the file's content
"     list=detail .... Include additional file info
"     list=flat ...... Display a flat list
"     types=[fd] ..... Whether to display files (f) and directories (d)
"     filter=REGEXP .. List only those files matching a |regexp|
"     exclude=REGEXP . Don't list files matching a |regexp|
"     sort=name|time|head ... Sort the list on the files' names, times, 
"                      or head lines. If the argument begins with "-", 
"                      the list is displayed in reverse order.
"
" Comments (i.e. text after the file link) are maintained if possible 
" and if list is not "detail".
fun! viki#DirListing(lhs, lhb, indent) "{{{3
    let args = s:GetRegionArgs(a:lhs, a:lhb - 1)
    " TLogVAR args
    let patt = get(args, 'glob', '')
    " TLogVAR patt
    if empty(patt)
        echoerr 'Viki: No glob pattern: '. string(args)
    else
        let deep = patt =~ '\*\*'
        let bufdir = expand('%:p:h')
        if patt !~ '^\([%\\/]\|\w\+:\)' && !&autochdir && bufdir != getcwd()
            let patt = tlib#file#Join([expand('%:p:h'), patt])
        endif
        " TLogVAR patt
        if patt =~ '^[^\\/*?]*[*?]'
            let s:dirlisting_depth0 = 0
        else
            let patt_parts = split(patt, '[*?]')
            " TLogVAR patt_parts
            let s:dirlisting_depth0 = s:GetDepth(patt_parts[0])
        endif
        let view = winsaveview()
        let t = @t
        try
            let ls = split(glob(patt), '\n')
            " TLogVAR ls
            let types = get(args, 'types', '')
            if !empty(types)
                let show_files = stridx(types, 'f') != -1
                let show_dirs  = stridx(types, 'd') != -1
                if show_files || show_dirs
                    call filter(ls, '(show_files && !isdirectory(v:val)) || (show_dirs && isdirectory(v:val))')
                else
                    let ls = []
                endif
            endif
            let filter = get(args, 'filter', '')
            if !empty(filter)
                call filter(ls, 'v:val =~ filter')
            endif
            let exclude = get(args, 'exclude', '')
            if !empty(exclude)
                call filter(ls, 'v:val !~ exclude')
            endif
            if !empty(ls)
                let list = split(get(args, 'list', ''), ',\s*')
                let head = str2nr(get(args, 'head', '0'))
                let s:files_options = {}
                let sort = get(args, 'sort', '')
                if !empty(sort)
                    if sort =~ '^-'
                        let s:files_options.sort_order = -1
                    else
                        let s:files_options.sort_order = 1
                    endif
                    let sort = substitute(sort, '^[+-]', '', '')
                    if sort == 'name'
                        let s:files_options.sort_on = 'filename'
                    elseif sort == 'time'
                        let s:files_options.ftime = 1
                        let s:files_options.sort_on = 'ftime'
                    elseif sort == 'head'
                        let s:files_options.head = 1
                        let s:files_options.sort_on = 'head'
                    else
                        throw "viki: #Files: sort must be either name, time, or head but was ". string(sort)
                    endif
                endif
                let s:getfileentry_deep = 0
                let ls = map(ls, 's:GetFileEntry(v:val, deep, list, head, s:files_options)')
                if !empty(sort)
                    let ls = sort(ls, 's:SortFiles')
                endif
                unlet s:files_options
                let ls = map(ls, 'a:indent . v:val.filename')
                let @t = join(ls, "\<c-j>") ."\<c-j>"
                " TLogVAR a:lhb
                exec 'norm! '. a:lhb .'G"t'. (a:lhb > line('$') ? 'p' : 'P')
            endif
        finally
            let @t = t
            call winrestview(view)
        endtry
    endif
endf


function! s:SortFiles(i1, i2) "{{{3
    let sort_on = s:files_options.sort_on
    let i1 = get(a:i1, sort_on)
    let i2 = get(a:i2, sort_on)
    let rv = i1 == i2 ? 0 : i1 > i2 ? 1 : -1
    return rv * s:files_options.sort_order
endf


fun! s:GetFileEntry(file, deep, list, head, options) "{{{3
    let f = []
    let props = {}
    let d = s:GetDepth(a:file) - s:dirlisting_depth0
    let attr = []
    let is_dir = 0
    if index(a:list, 'detail') != -1
        let props.type = getftype(a:file)
        if props.type != 'file'
            if props.type == 'dir'
                let is_dir = 1
            else
                call add(attr, props.type)
            endif
        endif
        let props.ftime = strftime('%Y-%m-%d %H:%M:%S', getftime(a:file))
        call add(attr, props.ftime)
        let props.fperm = getfperm(a:file)
        call add(attr, props.fperm)
    else
        if isdirectory(a:file)
            let is_dir = 1
        endif
    endif
    if index(a:list, 'flat') == -1
        let prefix  = repeat(' ', d)
        if a:deep
            if s:getfileentry_deep == d
                let prefix .= is_dir ? ' +' : ' |'
            else
                let prefix .= is_dir ? '`+' : '`|'
            endif
            let s:getfileentry_deep = d
        else
            let prefix .= is_dir ? '+' : '|'
        endif
        let prefix .= ' '
        call add(f, prefix)
    endif
    if g:viki_viki#conceal_extended_link_markup && has('conceal')
        call add(f, '[['. a:file .']['. fnamemodify(a:file, ':t') .']!]')
    else
        call add(f, '[['. a:file .']!]')
    endif
    if !empty(attr)
        call add(f, ' {'. join(attr, '|') .'}')
    endif
    if a:head > 0 && !isdirectory(a:file)
        let props.head = s:GetHead(a:file, a:head)
        call add(f, ' -- '. props.head)
    else
        if get(a:options, 'head', 0)
            let props.head = s:GetHead(a:file, a:options.head)
        endif
        let c = get(s:savedComments, a:file, '')
        " TLogVAR a:file, c
        if !empty(c)
            call add(f, c)
        endif
    endif
    if get(a:options, 'ftime', 0) && !has_key(props, 'ftime')
        let props.ftime = strftime('%Y-%m-%d %H:%M:%S', getftime(a:file))
    endif
    let props.filename = join(f, '')
    return props
endf

function! s:GetHead(file, head) "{{{3
    let lines = readfile(a:file, '', a:head)
    let lines = filter(lines, 'v:val =~ ''\S''')
    let lines = map(lines, 'substitute(v:val, g:viki#files_head_rx, "", "g")')
    let head_text = join(lines, '|')
    " TLogVAR &l:fenc, &l:enc, head_text
    if &l:fenc != &l:enc && has('iconv')
        let head_text = iconv(head_text, &l:fenc, &l:enc)
        " TLogVAR head_text
    endif
    return head_text
endf

fun! s:GetDepth(file) "{{{3
    return len(substitute(a:file, '[^\/]', '', 'g'))
endf

fun! s:GetRegionArgs(ls, le) "{{{3
    let t = @t
    try
        let t = s:GetBrokenLine(a:ls, a:le)
        " TLogVAR t
        let t = matchstr(t, '^\s*#\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)\zs.\{-}\ze<<$')
        " TLogVAR t
        let args = {}
        let rx = '^\s*\(\(\S\{-}\)=\("\(\(\"\|.\{-}\)\{-}\)"\|\(\(\S\+\|\\ \)\+\)\)\|\(\w\)\+!\)\s*'
        let s  = 0
        let sm = len(t)
        while s < sm
            let m = matchlist(t, rx, s)
            " TLogVAR m
            if empty(m)
                echoerr "Viki: Can't parse argument list: ". t
            else
                let key = m[2]
                " TLogVAR key
                if !empty(key)
                    let val = empty(m[4]) ? m[6] : m[4]
                    if val =~ '^".\{-}"'
                        let val = val[1:-2]
                    endif
                    let args[key] = substitute(val, '\\\(.\)', '\1', 'g')
                else
                    let key = m[8]
                    if key == '^no\u'
                        let antikey = substitute(key, '^no\zs.', '\l&', '')
                    else
                        let antikey = 'no'. substitute(key, '^.', '\u&', '')
                    endif
                    let args[key] = 1
                    let args[antikey] = 0
                endif
                let s += len(m[0])
            endif
        endwh
        return args
    finally
        let @t = t
    endtry
endf

fun! s:GetBrokenLine(ls, le) "{{{3
    let t = @t
    try
        exec 'norm! '. a:ls .'G"ty'. a:le .'G'
        let @t = substitute(@t, '[^\\]\zs\\\n\s*', '', 'g')
        let @t = substitute(@t, '\n*$', '', 'g')
        return @t
    finally
        let @t = t
    endtry
endf

fun! s:GetRegionStartRx(...) "{{{3
    let name = a:0 >= 1 && !empty(a:1) ? '\(\('. a:1 .'\>\)\)' : '\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)'
    let rx_start = '^\([[:blank:]]*\)#'. name .'\(\\\n\|.\)\{-}<<\(.*\)$'
    return rx_start
endf

fun! s:GetRegionGeometry(...) "{{{3
    " TLogVAR a:000
    let view = winsaveview()
    try
        norm! $
        let rx_start = s:GetRegionStartRx(a:0 >= 1 ? a:1 : '')
        let hds = search(rx_start, 'cbWe')
        " TLogVAR rx_start, hds
        if hds > 0
            if hds == line('$')
                let hde = hds
            else
                let hde = search(rx_start, 'cWe')
            endif
            let hdt = s:GetBrokenLine(hds, hde)
            let hdm = matchlist(hdt, rx_start)
            let hdi = hdm[1]
            let rx_end = '\V\^\[[:blank:]]\*'. escape(hdm[5], '\') .'\[[:blank:]]\*\$'
            if hds == line('$')
                let hbe = hds + 1
            else
                let hbe = search(rx_end, 'W')
            endif
            if hbe == 0 && empty(hdm[5])
                let hbe = line('$') + 1
            endif
            " TLogVAR hdm, hds, hde, hbe
            if hds > 0 && hde > 0 && hbe > 0
                return [hds, hde + 1, hbe, hdi]
            else
                echoerr "Viki: Can't determine region geometry: ". string([hds, hde, hbe, hdi, hdm, rx_start, rx_end])
            endif
        else
            echoerr "Viki: Can't determine region geometry: ". join([rx_start], ', ')
        endif
        return [0, 0, 0, '']
    finally
        call winrestview(view)
    endtry
endf

fun! s:DeleteRegionBody(...) "{{{3
    if a:0 >= 2
        let lb = a:1
        let le = a:2
    else
        let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    endif
    " TLogVAR lb, le
    if le <= line('$') + 1
        call s:SaveComments(lb, le - 1)
        if le > lb
            exec 'norm! '. lb .'Gd'. (le - 1) .'G'
        endif
    endif
endf

fun! s:SaveComments(lb, le) "{{{3
    " TLogVAR a:lb, a:le
    let s:savedComments = {}
    for l in range(a:lb, a:le)
        let t = getline(l)
        let k = viki#FilesGetFilename(t)
        if !empty(k)
            let comment = viki#FilesGetComment(t)
            let s:savedComments[k] = comment
            " TLogVAR k, t, comment
        endif
    endfor
endf

fun! viki#FilesGetFilename(t) "{{{3
    return matchstr(a:t, '^\s*[`_+|\\-]*\s*\[\[\zs.\{-}\ze\]\(\[\|!\]\)')
endf

fun! viki#FilesGetComment(t) "{{{3
    return matchstr(a:t, '^\s*[`_+|\\-]*\s*\[\[.\{-}\]!\]\( {.\{-}}\)\?\zs.*')
endf


function! viki#Balloon() "{{{3
    if synIDattr(synID(v:beval_lnum, v:beval_col, 1), "name") =~ '^viki'
        let def = viki#GetLink(1, getline(v:beval_lnum), v:beval_col)
        exec viki#SplitDef(def)
        " TLogVAR v_dest
        let text = ''
        if viki#IsSpecial(v_dest) 
            if isdirectory(v_dest)
                let pattern = tlib#file#Join([v_dest, '*'])
                let files = glob(pattern)
                let list = split(files, '\n')
                call map(list, 'fnamemodify(v:val, ":t")')
                let lines = []
                if !empty(list)
                    let max = &columns
                    let line = []
                    let len = 0
                    for file in list
                        let len1 = len + strlen(file)
                        if len1 < max
                            call add(line, file)
                            let len = len1
                        else
                            call add(lines, join(line, ', '))
                            let line = []
                            let len = 0
                        endif
                    endfor
                endif
                let text  = join(lines, "\n")
            endif
        else
            try
                let lines = readfile(v_dest)[0 : eval(g:vikiBalloonLines)]
                let text  = join(lines, "\n")
            catch
            endtry
        endif
        if !empty(text) && &fenc != g:vikiBalloonEncoding && has('iconv')
            let text = iconv(text, &fenc, g:vikiBalloonEncoding)
        endif
        return text
    endif
    return ''
endf


function! viki#MatchList(lnum) "{{{3
    let rx = '^[[:blank:]]\+\ze\(#[A-Z]\d\?\|#\d[A-Z]\?\|[-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\|.\{-1,}[[:blank:]]::\)[[:blank:]]'
    return matchend(getline(a:lnum), rx)
endf


" "                                                     *viki-text-objects* *ii*
" " Create a new text-object ii that works on a inner list item. Once the 
" " maps are enabled, users may, e.g., visually select an item in a list 
" " by typing vii. See |viki#SelectListItem()| for a definition of what is 
" " considered a list item.
" " 
" " The maps are local to the current buffer. Add this line to your 
" " |vimrc| file in order to enable the ii text-object for all viki 
" " buffers:>
" "   au FileType viki call viki#MapListItemTextObject()
function! viki#ListItemTextObject() "{{{3
    if indent('.') == 0
        return "ip"
    else
        return ":\<c-u>silent! call viki#SelectListItem('.')\<cr>"
    endif
endf


" Visually select the list item at line lnum.
" A list item also contains all its child items. E.g. in a list like:>
"
"   1. Venenatis diam dignissim dui. Praesent risus.
"   2. Tincidunt facilisis, est nisi pellentesque ligula.
"       a. Adipiscing dui non quam.
"       b. Duis posuere tortor.
"   3. Massa lorem, dignissim at, vehicula et.
"
" If the cursor is placed on item #2, this function also selects the 
" items a and b.
function! viki#SelectListItem(lnum) "{{{3
    let lnum = line(a:lnum)
    if lnum == 0
        let lnum = a:lnum
    endif
    let lbeg = lnum
    let item_indent = -1
    " TLogVAR lbeg, indent(lbeg)
    while lbeg > 1 && indent(lbeg) > 0
        " TLogVAR lbeg
        let item_indent = viki#MatchList(lbeg)
        if item_indent > 0
            break
        endif
        let lbeg -= 1
    endwh
    " TLogVAR item_indent
    if item_indent > 0
        let lend = lnum
        let lmax = line('$')
        " TLogVAR lend, lmax
        while lend < lmax && indent(lend + 1) > item_indent
            " TLogVAR lend
            let lend += 1
        endwh
        exec printf('norm! %dggV%dgg', lbeg, lend)
        return item_indent
    else
        return -1
    endif
endf


" :doc:
" If the |tinykeymap| plugin is installed, a gl map is created to move 
" around list items.
"
" If you use the tinymode plugin, add the following to lines to your 
" |vimrc| file:
"
"   call tinymode#EnterMap("listitem_move", "gl")
"   call tinymode#ModeMsg("listitem_move", "Move list item: h/j/k/l")
"   call tinymode#Map("listitem_move", "h", "silent call viki#ShiftListItem('<')")
"   call tinymode#Map("listitem_move", "l", "silent call viki#ShiftListItem('>')")
"   call tinymode#Map("listitem_move", "j", "silent call viki#MoveListItem('down')")
"   call tinymode#Map("listitem_move", "k", "silent call viki#MoveListItem('up')")


function! viki#ShiftListItem(direction) "{{{3
    call viki#SelectListItem('.')
    exec 'norm!' a:direction
endf


function! viki#MoveListItem(direction) "{{{3
    let t = @t
    try
        let item_indent = viki#SelectListItem('.')
        if item_indent > 0
            " TLogVAR 1, line('.')
            norm! "td
            let lnum = line('.')
            if a:direction == 'up'
                let lmove = -1
                let lnum -= 1
            else
                let lmove = 1
            endif
            let lmax = line('$')
            while lnum > 0 && lnum <= lmax && (indent(lnum) > item_indent || getline(lnum) !~ '\S')
                let lnum += lmove
            endwh
            if lnum == 0 || lnum > lmax
                norm! u
            else
                exec lnum
                if viki#SelectListItem('.') > 0
                    " TLogVAR 2, line('.')
                    exec "norm! \<Esc>"
                    if a:direction == 'up'
                        exec line("'<")
                        " TLogVAR 3, line('.')
                        norm! "tP
                    else
                        exec line("'>")
                        " TLogVAR 3, line('.')
                        norm! "tp
                    endif
                    " TLogVAR 4, line('.')
                else
                    norm! u
                endif
            endif
        endif
    finally
        let @t = t
    endtry
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


func s:NumericSort(i1, i2)
    return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc


function viki#FoldLevel(lnum)
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


function! viki#FoldText() "{{{3
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


function! viki#UpdateHeadings() "{{{3
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
    " TLogVAR len(viki_headings)
endf

