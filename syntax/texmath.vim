" texmath.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-15.
" @Last Change: 2010-11-15.
" @Revision:    0.0.75

" Use only as embedded syntax to be included from other syntax files.

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif
scriptencoding utf-8

if exists(':HiLink')
    let s:delhilink = 0
else
    let s:delhilink = 1
    if version < 508
        command! -nargs=+ HiLink hi link <args>
    else
        command! -nargs=+ HiLink hi def link <args>
    endif
endif


" syn match texmathArgDelimiters /[{}\[\]]/ contained containedin=texmathMath
syn match texmathCommand /\\[[:alnum:]]\+/ contained containedin=texmath
syn match texmathMathWord /[[:alnum:].]\+/ contained containedin=texmathMath
syn match texmathUnword /\(\\\\\|[^[:alnum:]${}()[\]^_\\]\+\)/ contained containedin=texmath
syn match texmathPairs /\([<>()[\]]\|\\[{}]\|\\[lr]\(brace\|vert\|Vert\|angle\|ceil\|floor\|group\|moustache\)\)/
            \ contained containedin=texmath
syn match texmathSub /_/ contained containedin=texmathMath
syn match texmathSup /\^/ contained containedin=texmathMath

syn region texmathText matchgroup=Statement
            \ start=/\\text{/ end=/}/ skip=/\\[{}]/
            \ contained containedin=texmath
syn region texmathArgDelimiters matchgroup=Delimiter
            \ start=/\\\@<!{/ end=/\\\@<!}/ skip=/\\[{}]/
            \ contained contains=@texmathMath containedin=texmath


if has('conceal') && &enc == 'utf-8'
    if &conceallevel == 0
        setlocal conceallevel=2
    endif
    if empty(&concealcursor)
        setlocal concealcursor=n
    endif

    if !exists('g:did_tex_syntax_inits')
        let s:tex_conceal = exists("g:tex_conceal") ? g:tex_conceal : 'admgs'

        if s:tex_conceal =~ 'm'
            " Copied from $VIMRUNTIME/syntax/tex.vim
            " Math Symbols {{{2
            " (many of these symbols were contributed by Björn Winckler)
            let s:texMathList = [
                        \ ['angle'		, '∠'],
                        \ ['approx'		, '≈'],
                        \ ['ast'		, '∗'],
                        \ ['asymp'		, '≍'],
                        \ ['backepsilon'	, '∍'],
                        \ ['backsimeq'	, '≃'],
                        \ ['barwedge'	, '⊼'],
                        \ ['because'	, '∵'],
                        \ ['between'	, '≬'],
                        \ ['bigcap'		, '∩'],
                        \ ['bigcup'		, '∪'],
                        \ ['bigodot'	, '⊙'],
                        \ ['bigoplus'	, '⊕'],
                        \ ['bigotimes'	, '⊗'],
                        \ ['bigsqcup'	, '⊔'],
                        \ ['bigtriangledown', '∇'],
                        \ ['bigvee'		, '⋁'],
                        \ ['bigwedge'	, '⋀'],
                        \ ['blacksquare'	, '∎'],
                        \ ['bot'		, '⊥'],
                        \ ['boxdot'		, '⊡'],
                        \ ['boxminus'	, '⊟'],
                        \ ['boxplus'	, '⊞'],
                        \ ['boxtimes'	, '⊠'],
                        \ ['bumpeq'		, '≏'],
                        \ ['Bumpeq'		, '≎'],
                        \ ['cap'		, '∩'],
                        \ ['Cap'		, '⋒'],
                        \ ['cdot'		, '·'],
                        \ ['cdots'		, '⋯'],
                        \ ['circ'		, '∘'],
                        \ ['circeq'		, '≗'],
                        \ ['circlearrowleft', '↺'],
                        \ ['circlearrowright', '↻'],
                        \ ['circledast'	, '⊛'],
                        \ ['circledcirc'	, '⊚'],
                        \ ['complement'	, '∁'],
                        \ ['cong'		, '≅'],
                        \ ['coprod'		, '∐'],
                        \ ['cup'		, '∪'],
                        \ ['Cup'		, '⋓'],
                        \ ['curlyeqprec'	, '⋞'],
                        \ ['curlyeqsucc'	, '⋟'],
                        \ ['curlyvee'	, '⋎'],
                        \ ['curlywedge'	, '⋏'],
                        \ ['dashv'		, '⊣'],
                        \ ['diamond'	, '⋄'],
                        \ ['div'		, '÷'],
                        \ ['doteq'		, '≐'],
                        \ ['doteqdot'	, '≑'],
                        \ ['dotplus'	, '∔'],
                        \ ['dotsb'		, '⋯'],
                        \ ['dotsc'		, '…'],
                        \ ['dots'		, '…'],
                        \ ['dotsi'		, '⋯'],
                        \ ['dotso'		, '…'],
                        \ ['doublebarwedge'	, '⩞'],
                        \ ['downarrow'	, '↓'],
                        \ ['Downarrow'	, '⇓'],
                        \ ['emptyset'	, '∅'],
                        \ ['eqcirc'		, '≖'],
                        \ ['eqsim'		, '≂'],
                        \ ['eqslantgtr'	, '⪖'],
                        \ ['eqslantless'	, '⪕'],
                        \ ['equiv'		, '≡'],
                        \ ['exists'		, '∃'],
                        \ ['fallingdotseq'	, '≒'],
                        \ ['forall'		, '∀'],
                        \ ['ge'		, '≥'],
                        \ ['geq'		, '≥'],
                        \ ['geqq'		, '≧'],
                        \ ['gets'		, '←'],
                        \ ['gneqq'		, '≩'],
                        \ ['gtrdot'		, '⋗'],
                        \ ['gtreqless'	, '⋛'],
                        \ ['gtrless'	, '≷'],
                        \ ['gtrsim'		, '≳'],
                        \ ['hookleftarrow'	, '↩'],
                        \ ['hookrightarrow'	, '↪'],
                        \ ['iiint'		, '∭'],
                        \ ['iint'		, '∬'],
                        \ ['Im'		, 'ℑ'],
                        \ ['in'		, '∈'],
                        \ ['infty'		, '∞'],
                        \ ['int'		, '∫'],
                        \ ['lceil'		, '⌈'],
                        \ ['ldots'		, '…'],
                        \ ['le'		, '≤'],
                        \ ['leftarrow'	, '⟵'],
                        \ ['Leftarrow'	, '⟸'],
                        \ ['leftarrowtail'	, '↢'],
                        \ ['left('		, '('],
                        \ ['left\['		, '['],
                        \ ['left\\{'	, '{'],
                        \ ['Leftrightarrow'	, '⇔'],
                        \ ['leftrightsquigarrow', '↭'],
                        \ ['leftthreetimes'	, '⋋'],
                        \ ['leq'		, '≤'],
                        \ ['leqq'		, '≦'],
                        \ ['lessdot'	, '⋖'],
                        \ ['lesseqgtr'	, '⋚'],
                        \ ['lesssim'	, '≲'],
                        \ ['lfloor'		, '⌊'],
                        \ ['lneqq'		, '≨'],
                        \ ['ltimes'		, '⋉'],
                        \ ['mapsto'		, '↦'],
                        \ ['measuredangle'	, '∡'],
                        \ ['mid'		, '∣'],
                        \ ['mp'		, '∓'],
                        \ ['nabla'		, '∇'],
                        \ ['ncong'		, '≇'],
                        \ ['nearrow'	, '↗'],
                        \ ['ne'		, '≠'],
                        \ ['neg'		, '¬'],
                        \ ['neq'		, '≠'],
                        \ ['nexists'	, '∄'],
                        \ ['ngeq'		, '≱'],
                        \ ['ngeqq'		, '≱'],
                        \ ['ngtr'		, '≯'],
                        \ ['ni'		, '∋'],
                        \ ['nleftarrow'	, '↚'],
                        \ ['nLeftarrow'	, '⇍'],
                        \ ['nLeftrightarrow', '⇎'],
                        \ ['nleq'		, '≰'],
                        \ ['nleqq'		, '≰'],
                        \ ['nless'		, '≮'],
                        \ ['nmid'		, '∤'],
                        \ ['notin'		, '∉'],
                        \ ['nprec'		, '⊀'],
                        \ ['nrightarrow'	, '↛'],
                        \ ['nRightarrow'	, '⇏'],
                        \ ['nsim'		, '≁'],
                        \ ['nsucc'		, '⊁'],
                        \ ['ntriangleleft'	, '⋪'],
                        \ ['ntrianglelefteq', '⋬'],
                        \ ['ntriangleright'	, '⋫'],
                        \ ['ntrianglerighteq', '⋭'],
                        \ ['nvdash'		, '⊬'],
                        \ ['nvDash'		, '⊭'],
                        \ ['nVdash'		, '⊮'],
                        \ ['nwarrow'	, '↖'],
                        \ ['odot'		, '⊙'],
                        \ ['oint'		, '∮'],
                        \ ['ominus'		, '⊖'],
                        \ ['oplus'		, '⊕'],
                        \ ['oslash'		, '⊘'],
                        \ ['otimes'		, '⊗'],
                        \ ['owns'		, '∋'],
                        \ ['partial'	, '∂'],
                        \ ['perp'		, '⊥'],
                        \ ['pitchfork'	, '⋔'],
                        \ ['pm'		, '±'],
                        \ ['precapprox'	, '⪷'],
                        \ ['prec'		, '≺'],
                        \ ['preccurlyeq'	, '≼'],
                        \ ['preceq'		, '⪯'],
                        \ ['precnapprox'	, '⪹'],
                        \ ['precneqq'	, '⪵'],
                        \ ['precsim'	, '≾'],
                        \ ['prod'		, '∏'],
                        \ ['propto'		, '∝'],
                        \ ['rceil'		, '⌉'],
                        \ ['Re'		, 'ℜ'],
                        \ ['rfloor'		, '⌋'],
                        \ ['rightarrow'	, '⟶'],
                        \ ['Rightarrow'	, '⟹'],
                        \ ['rightarrowtail'	, '↣'],
                        \ ['right)'		, ')'],
                        \ ['right]'		, ']'],
                        \ ['right\\}'	, '}'],
                        \ ['rightsquigarrow', '↝'],
                        \ ['rightthreetimes', '⋌'],
                        \ ['risingdotseq'	, '≓'],
                        \ ['rtimes'		, '⋊'],
                        \ ['searrow'	, '↘'],
                        \ ['setminus'	, '∖'],
                        \ ['sim'		, '∼'],
                        \ ['sphericalangle'	, '∢'],
                        \ ['sqcap'		, '⊓'],
                        \ ['sqcup'		, '⊔'],
                        \ ['sqsubset'	, '⊏'],
                        \ ['sqsubseteq'	, '⊑'],
                        \ ['sqsupset'	, '⊐'],
                        \ ['sqsupseteq'	, '⊒'],
                        \ ['subset'		, '⊂'],
                        \ ['Subset'		, '⋐'],
                        \ ['subseteq'	, '⊆'],
                        \ ['subseteqq'	, '⫅'],
                        \ ['subsetneq'	, '⊊'],
                        \ ['subsetneqq'	, '⫋'],
                        \ ['succapprox'	, '⪸'],
                        \ ['succ'		, '≻'],
                        \ ['succcurlyeq'	, '≽'],
                        \ ['succeq'		, '⪰'],
                        \ ['succnapprox'	, '⪺'],
                        \ ['succneqq'	, '⪶'],
                        \ ['succsim'	, '≿'],
                        \ ['sum'		, '∑'],
                        \ ['Supset'		, '⋑'],
                        \ ['supseteq'	, '⊇'],
                        \ ['supseteqq'	, '⫆'],
                        \ ['supsetneq'	, '⊋'],
                        \ ['supsetneqq'	, '⫌'],
                        \ ['surd'		, '√'],
                        \ ['swarrow'	, '↙'],
                        \ ['therefore'	, '∴'],
                        \ ['times'		, '×'],
                        \ ['to'		, '→'],
                        \ ['top'		, '⊤'],
                        \ ['triangleleft'	, '⊲'],
                        \ ['trianglelefteq'	, '⊴'],
                        \ ['triangleq'	, '≜'],
                        \ ['triangleright'	, '⊳'],
                        \ ['trianglerighteq', '⊵'],
                        \ ['twoheadleftarrow', '↞'],
                        \ ['twoheadrightarrow', '↠'],
                        \ ['uparrow'	, '↑'],
                        \ ['Uparrow'	, '⇑'],
                        \ ['updownarrow'	, '↕'],
                        \ ['Updownarrow'	, '⇕'],
                        \ ['varnothing'	, '∅'],
                        \ ['vartriangle'	, '∆'],
                        \ ['vdash'		, '⊢'],
                        \ ['vDash'		, '⊨'],
                        \ ['Vdash'		, '⊩'],
                        \ ['vdots'		, '⋮'],
                        \ ['veebar'		, '⊻'],
                        \ ['vee'		, '∨'],
                        \ ['Vvdash'		, '⊪'],
                        \ ['wedge'		, '∧'],
                        \ ['wr'		, '≀']]
            for texmath in s:texMathList
                exe "syn match texMathSymbol '\\\\".texmath[0]."\\>' contained containedin=texmath conceal cchar=".texmath[1]
            endfor
            unlet texmath s:texMathList

            " Copied from $VIMRUNTIME/syntax/tex.vim
            if &ambw == "double"
                syn match texMathSymbol '\\gg\>'			contained containedin=texmath conceal cchar=≫
                syn match texMathSymbol '\\ll\>'			contained containedin=texmath conceal cchar=≪
            else
                syn match texMathSymbol '\\gg\>'			contained containedin=texmath conceal cchar=⟫
                syn match texMathSymbol '\\ll\>'			contained containedin=texmath conceal cchar=⟪
            endif
        endif

        if s:tex_conceal =~ 'g'
            " Copied from $VIMRUNTIME/syntax/tex.vim
            fun! s:Greek(group,pat,cchar)
                exe 'syn match '.a:group." '".a:pat."' contained containedin=texmath conceal cchar=".a:cchar
            endfun
            call s:Greek('texGreek','\\alpha\>'		,'α')
            call s:Greek('texGreek','\\beta\>'		,'β')
            call s:Greek('texGreek','\\gamma\>'		,'γ')
            call s:Greek('texGreek','\\delta\>'		,'δ')
            call s:Greek('texGreek','\\epsilon\>'		,'ϵ')
            call s:Greek('texGreek','\\varepsilon\>'	,'ε')
            call s:Greek('texGreek','\\zeta\>'		,'ζ')
            call s:Greek('texGreek','\\eta\>'		,'η')
            call s:Greek('texGreek','\\theta\>'		,'θ')
            call s:Greek('texGreek','\\vartheta\>'		,'ϑ')
            call s:Greek('texGreek','\\kappa\>'		,'κ')
            call s:Greek('texGreek','\\lambda\>'		,'λ')
            call s:Greek('texGreek','\\mu\>'		,'μ')
            call s:Greek('texGreek','\\nu\>'		,'ν')
            call s:Greek('texGreek','\\xi\>'		,'ξ')
            call s:Greek('texGreek','\\pi\>'		,'π')
            call s:Greek('texGreek','\\varpi\>'		,'ϖ')
            call s:Greek('texGreek','\\rho\>'		,'ρ')
            call s:Greek('texGreek','\\varrho\>'		,'ϱ')
            call s:Greek('texGreek','\\sigma\>'		,'σ')
            call s:Greek('texGreek','\\varsigma\>'		,'ς')
            call s:Greek('texGreek','\\tau\>'		,'τ')
            call s:Greek('texGreek','\\upsilon\>'		,'υ')
            call s:Greek('texGreek','\\phi\>'		,'φ')
            call s:Greek('texGreek','\\varphi\>'		,'ϕ')
            call s:Greek('texGreek','\\chi\>'		,'χ')
            call s:Greek('texGreek','\\psi\>'		,'ψ')
            call s:Greek('texGreek','\\omega\>'		,'ω')
            call s:Greek('texGreek','\\Gamma\>'		,'Γ')
            call s:Greek('texGreek','\\Delta\>'		,'Δ')
            call s:Greek('texGreek','\\Theta\>'		,'Θ')
            call s:Greek('texGreek','\\Lambda\>'		,'Λ')
            call s:Greek('texGreek','\\Xi\>'		,'Χ')
            call s:Greek('texGreek','\\Pi\>'		,'Π')
            call s:Greek('texGreek','\\Sigma\>'		,'Σ')
            call s:Greek('texGreek','\\Upsilon\>'		,'Υ')
            call s:Greek('texGreek','\\Phi\>'		,'Φ')
            call s:Greek('texGreek','\\Psi\>'		,'Ψ')
            call s:Greek('texGreek','\\Omega\>'		,'Ω')
            delfun s:Greek
        endif

        if s:tex_conceal =~ 's'
            fun! s:SuperSub(group,leader,pat,cchar)
                exe 'syn match '.a:group." '".a:leader.a:pat."' contained containedin=texmath conceal cchar=".a:cchar
                exe 'syn match '.a:group."s '".a:pat."' contained containedin=texmath conceal cchar=".a:cchar.' nextgroup='.a:group.'s'
            endfun
            call s:SuperSub('texSuperscript','\^','0','⁰')
            call s:SuperSub('texSuperscript','\^','1','¹')
            call s:SuperSub('texSuperscript','\^','2','²')
            call s:SuperSub('texSuperscript','\^','3','³')
            call s:SuperSub('texSuperscript','\^','4','⁴')
            call s:SuperSub('texSuperscript','\^','5','⁵')
            call s:SuperSub('texSuperscript','\^','6','⁶')
            call s:SuperSub('texSuperscript','\^','7','⁷')
            call s:SuperSub('texSuperscript','\^','8','⁸')
            call s:SuperSub('texSuperscript','\^','9','⁹')
            call s:SuperSub('texSuperscript','\^','a','ᵃ')
            call s:SuperSub('texSuperscript','\^','b','ᵇ')
            call s:SuperSub('texSuperscript','\^','c','ᶜ')
            call s:SuperSub('texSuperscript','\^','d','ᵈ')
            call s:SuperSub('texSuperscript','\^','e','ᵉ')
            call s:SuperSub('texSuperscript','\^','f','ᶠ')
            call s:SuperSub('texSuperscript','\^','g','ᵍ')
            call s:SuperSub('texSuperscript','\^','h','ʰ')
            call s:SuperSub('texSuperscript','\^','i','ⁱ')
            call s:SuperSub('texSuperscript','\^','j','ʲ')
            call s:SuperSub('texSuperscript','\^','k','ᵏ')
            call s:SuperSub('texSuperscript','\^','l','ˡ')
            call s:SuperSub('texSuperscript','\^','m','ᵐ')
            call s:SuperSub('texSuperscript','\^','n','ⁿ')
            call s:SuperSub('texSuperscript','\^','o','ᵒ')
            call s:SuperSub('texSuperscript','\^','p','ᵖ')
            call s:SuperSub('texSuperscript','\^','r','ʳ')
            call s:SuperSub('texSuperscript','\^','s','ˢ')
            call s:SuperSub('texSuperscript','\^','t','ᵗ')
            call s:SuperSub('texSuperscript','\^','u','ᵘ')
            call s:SuperSub('texSuperscript','\^','v','ᵛ')
            call s:SuperSub('texSuperscript','\^','w','ʷ')
            call s:SuperSub('texSuperscript','\^','x','ˣ')
            call s:SuperSub('texSuperscript','\^','y','ʸ')
            call s:SuperSub('texSuperscript','\^','z','ᶻ')
            call s:SuperSub('texSuperscript','\^','A','ᴬ')
            call s:SuperSub('texSuperscript','\^','B','ᴮ')
            call s:SuperSub('texSuperscript','\^','D','ᴰ')
            call s:SuperSub('texSuperscript','\^','E','ᴱ')
            call s:SuperSub('texSuperscript','\^','G','ᴳ')
            call s:SuperSub('texSuperscript','\^','H','ᴴ')
            call s:SuperSub('texSuperscript','\^','I','ᴵ')
            call s:SuperSub('texSuperscript','\^','J','ᴶ')
            call s:SuperSub('texSuperscript','\^','K','ᴷ')
            call s:SuperSub('texSuperscript','\^','L','ᴸ')
            call s:SuperSub('texSuperscript','\^','M','ᴹ')
            call s:SuperSub('texSuperscript','\^','N','ᴺ')
            call s:SuperSub('texSuperscript','\^','O','ᴼ')
            call s:SuperSub('texSuperscript','\^','P','ᴾ')
            call s:SuperSub('texSuperscript','\^','R','ᴿ')
            call s:SuperSub('texSuperscript','\^','T','ᵀ')
            call s:SuperSub('texSuperscript','\^','U','ᵁ')
            call s:SuperSub('texSuperscript','\^','W','ᵂ')
            call s:SuperSub('texSuperscript','\^','+','⁺')
            call s:SuperSub('texSuperscript','\^','-','⁻')
            call s:SuperSub('texSuperscript','\^','<','˂')
            call s:SuperSub('texSuperscript','\^','>','˃')
            call s:SuperSub('texSuperscript','\^','/','ˊ')
            call s:SuperSub('texSuperscript','\^','(','⁽')
            call s:SuperSub('texSuperscript','\^',')','⁾')
            call s:SuperSub('texSuperscript','\^','\.','˙')
            call s:SuperSub('texSuperscript','\^','=','˭')
            call s:SuperSub('texSubscript','_','0','₀')
            call s:SuperSub('texSubscript','_','1','₁')
            call s:SuperSub('texSubscript','_','2','₂')
            call s:SuperSub('texSubscript','_','3','₃')
            call s:SuperSub('texSubscript','_','4','₄')
            call s:SuperSub('texSubscript','_','5','₅')
            call s:SuperSub('texSubscript','_','6','₆')
            call s:SuperSub('texSubscript','_','7','₇')
            call s:SuperSub('texSubscript','_','8','₈')
            call s:SuperSub('texSubscript','_','9','₉')
            call s:SuperSub('texSubscript','_','a','ₐ')
            call s:SuperSub('texSubscript','_','e','ₑ')
            call s:SuperSub('texSubscript','_','i','ᵢ')
            call s:SuperSub('texSubscript','_','o','ₒ')
            call s:SuperSub('texSubscript','_','u','ᵤ')
            call s:SuperSub('texSubscript','_','+','₊')
            call s:SuperSub('texSubscript','_','-','₋')
            call s:SuperSub('texSubscript','_','/','ˏ')
            call s:SuperSub('texSubscript','_','(','₍')
            call s:SuperSub('texSubscript','_',')','₎')
            call s:SuperSub('texSubscript','_','\.','‸')
            call s:SuperSub('texSubscript','_','r','ᵣ')
            call s:SuperSub('texSubscript','_','v','ᵥ')
            call s:SuperSub('texSubscript','_','x','ₓ')
            call s:SuperSub('texSubscript','_','\\beta\>' ,'ᵦ')
            call s:SuperSub('texSubscript','_','\\delta\>','ᵨ')
            call s:SuperSub('texSubscript','_','\\phi\>'  ,'ᵩ')
            call s:SuperSub('texSubscript','_','\\gamma\>','ᵧ')
            call s:SuperSub('texSubscript','_','\\chi\>'  ,'ᵪ')
            delfun s:SuperSub
        endif
        unlet s:tex_conceal
    endif

    syn match texmathMathFont /\\\(math[[:alnum:]]\+\|Bbb\|frak\)/
                \ contained containedin=texmath
                \ conceal
    syn cluster texmath contains=texmathArgDelimiters,texmathCommand,texmathMathFont,texmathPairs,texmathUnword,texmathText,texMathSymbol,texGreek,texSubscript,texSuperscript
else
    syn match texmathMathFont /\\\(math[[:alnum:]]\+\|Bbb\|frak\)/ contained containedin=texmath
    syn cluster texmath contains=texmathArgDelimiters,texmathCommand,texmathMathFont,texmathPairs,texmathUnword,texmathText
endif

syn cluster texmathMath contains=@texmath,texmathMathWord,texmathSup,texmathSub

" Statement PreProc
HiLink texmathSup Type
HiLink texmathSub Type
" HiLink texmathArgDelimiters Comment
HiLink texmathCommand Statement
HiLink texmathText Normal
HiLink texmathMathFont Type
HiLink texmathMathWord Identifier
HiLink texmathUnword Constant
HiLink texmathPairs PreProc


if s:delhilink
    delcommand HiLink
endif
" let b:current_syntax = 'texmath'

