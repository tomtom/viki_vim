" listitem_move.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-08-28.
" @Last Change: 2012-09-25.
" @Revision:    15

if !exists('g:tinykeymap#map#listitem_move#options')
    " :read: let g:tinykeymap#map#listitem_move#options = {...}   "{{{2
    let g:tinykeymap#map#listitem_move#options = {
                \ 'name': 'move list item',
                \ 'after': 'call tlib#buffer#ViewLine(line("."))',
                \ 'start': 'call tlib#buffer#ViewLine(line("."))',
                \ }
endif

" Move list items
call tinykeymap#EnterMap("listitem_move", "gl", g:tinykeymap#map#listitem_move#options)
call tinykeymap#Map("listitem_move", "h", "silent call viki#ShiftListItem('<')",
            \ {'desc': 'Shift list item left'})
call tinykeymap#Map("listitem_move", "l", "silent call viki#ShiftListItem('>')",
            \ {'desc': 'Shift list item right'})
call tinykeymap#Map("listitem_move", "j", "silent call viki#MoveListItem('down')",
            \ {'desc': 'Move list item down'})
call tinykeymap#Map("listitem_move", "k", "silent call viki#MoveListItem('up')",
            \ {'desc': 'Move list item up'})
call tinykeymap#Map("listitem_move", "p", "norm vii\<esc>'<kvii\<esc>'<^",
            \ {'desc': 'Go to previous list item'})
call tinykeymap#Map("listitem_move", "n", "norm vii\<esc>'>j^",
            \ {'desc': 'Go to next list item'})

