#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"

***** 27.01.16
Function edit_browse(arr)
Local c1 := arr[BR_LEFT], c2, func_step
Private pr1 := arr[BR_TOP], pr2 := arr[BR_BOTTOM], pc1, pc2, fl_found, ;
        len_browse := arr[BR_RIGHT] - arr[BR_LEFT]
Private st_arr := br_default(arr)
if arr[BR_SEMAPHORE] != NIL
  if !G_SLock(arr[BR_SEMAPHORE])
    return func_error(4,"Сейчас с данным режимом работает другой пользователь!")
  endif
endif
c2 := c1 + len_browse
if !(arr[BR_LEFT] == 0 .and. arr[BR_RIGHT] == maxcol())
  if c2 > maxcol()-2
    c2 := maxcol()-2 ; c1 := c2 - len_browse
  endif
  if c1 < 0
    c1 := 0
  endif
  len_browse := c2 - c1
endif
memvar->pc1 := c1 ; memvar->pc2 := c2
if arr[BR_STEP_FUNC] != NIL
  func_step := "_f2_ed_browse"
endif
fl_found := eval(arr[BR_OPEN])
if valtype(fl_found) == "L"
  if !fl_found
    keyboard chr(K_INS)
  endif
  if Alpha_Browse(memvar->pr1,memvar->pc1,memvar->pr2,memvar->pc2,"_f1_ed_browse",arr[BR_COLOR],;
                  arr[BR_TITUL],arr[BR_TITUL_COLOR],;
                  arr[BR_FL_INDEX],arr[BR_FL_NOCLEAR],arr[BR_ARR_BLOCK],;
                  func_step,"_f3_ed_browse",arr[BR_ARR_MOUSE],;
                  arr[BR_ARR_BROWSE] )
    eval(arr[BR_ENTER])
  endif
endif
eval(arr[BR_CLOSE])
if arr[BR_SEMAPHORE] != NIL
  G_SUnLock(arr[BR_SEMAPHORE])
endif
return NIL

*****
Function _f1_ed_browse(oBrow)
Local i, oColumn
for i := 1 to len(st_arr[BR_COLUMN])
  oColumn := TBColumnNew(st_arr[BR_COLUMN,i,1], st_arr[BR_COLUMN,i,2] )
  if len(st_arr[BR_COLUMN,i]) > 2 .and. valtype(st_arr[BR_COLUMN,i,3])=="B"
    oColumn:colorBlock := st_arr[BR_COLUMN,i,3]
  endif
  if len(st_arr[BR_COLUMN,i]) > 3 .and. valtype(st_arr[BR_COLUMN,i,4])=="A"
    oColumn:defColor := st_arr[BR_COLUMN,i,4]
  endif
  oBrow:addColumn(oColumn)
next
if st_arr[BR_FREEZE] != NIL
  oBrow:freeze := st_arr[BR_FREEZE]
endif
if st_arr[BR_STAT_MSG] == NIL
  status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ins>^ - добавление;  ^<Del>^ - удаление")
else
  eval(st_arr[BR_STAT_MSG])
endif
return NIL

*****
Function _f2_ed_browse()
Local nrow := row(), ncol := col()
eval(st_arr[BR_STEP_FUNC])
setpos(nrow,ncol)
return NIL

*****
Function _f3_ed_browse(nKey,oBrow)
Local k, tmp_color := setcolor()
k := eval(st_arr[BR_EDIT],nKey,oBrow)
setcolor(tmp_color)
return k

*****
Static Function br_default(arr)
do while len(arr) < BR_LEN
  aadd(arr,NIL)
enddo
DEFAULT arr[BR_OPEN]  TO {|| .t. }
DEFAULT arr[BR_CLOSE] TO {|| .t. }
DEFAULT arr[BR_EDIT]  TO {|| -1 }
DEFAULT arr[BR_ENTER] TO {|| .t. }
if arr[BR_SEMAPHORE] != NIL .and. empty(arr[BR_SEMAPHORE])
  arr[BR_SEMAPHORE] := NIL
endif
return arr
