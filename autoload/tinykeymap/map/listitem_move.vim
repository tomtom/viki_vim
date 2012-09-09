" listitem_move.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-08-28.
" @Last Change: 2012-08-29.
" @Revision:    2

" Move list items
call tinykeymap#EnterMap("listitem_move", "gl", {'name': 'move list item'})
call tinykeymap#Map("listitem_move", "h", "silent call viki#ShiftListItem('<')")
call tinykeymap#Map("listitem_move", "l", "silent call viki#ShiftListItem('>')")
call tinykeymap#Map("listitem_move", "j", "silent call viki#MoveListItem('down')")
call tinykeymap#Map("listitem_move", "k", "silent call viki#MoveListItem('up')")

