/*
I'm a 27 years old Clipper Programmer,
living in Schumanstr.8, W-8500 NБrnberg 80, Germany
Tel : 0049-911-316838
FidoNet : 2:246/16.6
Internet : k.froeb@msn.rmi.de

The program consists of the following UDFs :

* scrollread  - The Scrolling-Get engine (sort of replace for Readmodal)
* FirstGetinBox - Find the Number of the Get in the upper left corner
* MaxGetrow   - Find the Number of the Get with the highest Virtual Line Number
* ScrollNext  - Calculate new rows when Scrolling to the next get
* ShowGetBG   - Display the Getbackground (Titles etc) wich fits in the box
* NewGetRows  - Reset the row values in the Getobject to new values
* ShowGets    - Display the Gets wich fit in the box
* GetFocus    - activate / deactivate a Get
* GetPreValidate  - check When Clause of Get
* GetPostValidate - check Valid clause of Get
*/
#include "function.ch"
#include "edit_spr.ch"
#include "inkey.ch"
#include "getexit.ch"

// first element in Cargo Array of getelements indicates virtual row
#define CARGO_ROW 1
// second element in Cargo Array of getelements indicates virtual column
#define CARGO_COL 2

Static aGet, BGh, Boxh, Boxw, BGTop, sBoxtop, sBGcolor

/*
*****************************************
* 0     1════════╗ <--- Background
* 1     2        ║
* 2  1──3────────╫────┐ Boxtop =2
* 3  2  4BGTOP=4 ║    │<------- Box (Window)
* 4  3  5        ║    │  Boxh  =5
* 5  4  6BGbot=6 ║    │
* 6  5──7────────╫────┘ Boxbot =6
* 7     8════════╝ BGh =8
******************************************
*/
*

*****
Function init_VGET()
if type("vGetCol") != "N"
  Public vGetCol
endif
if type("vGetBG") != "A"
  Public vGetBG
endif
if type("vGetlist") != "A"
  Public vGetlist
endif
vGetCol := 0
vGetBG := {}
vGetlist := {}
return NIL

*****
Function VCOL()
return vGetCol

*****
FUNCTION scrollread(Boxtop,;    // верх
                    Boxleft,;   // лево
                    Boxbot,;    // низ
                    Boxright,;  // право
                    BGcolor,;   // цвет
                    nGet,;      // на какой GET сразу встать
                    bDrawBox,;  // блок кода для отрисовки рамки вокруг GET'ов
                    arr_alert,; // массив вызова alert при выходе
                    mode)
// все параметры необязательны
Local cThisGet, lSkiped := .f., i, j, k, ;
      nKey := 0, nLastGet, nKounter,;
      lInsert := .T., cO_color := setcolor(), buf := savescreen()
VALDEFAULT Boxtop,   "N" TO 0
VALDEFAULT Boxleft,  "N" TO 0
VALDEFAULT Boxbot,   "N" TO Maxrow()
VALDEFAULT Boxright, "N" TO Maxcol()
VALDEFAULT BGColor,  "C" TO setcolor()
VALDEFAULT nGet,     "N" TO 1
VALDEFAULT bDrawBox, "B" TO {||.t.}
VALDEFAULT arr_alert,"A" TO {" Выход без записи "," Запись "," Возврат в редактирование "}
VALDEFAULT mode,     "C" TO "E"
Boxh := Boxbot - Boxtop + 1
Boxw := Boxright - Boxleft + 1
sBoxtop  := Boxtop
sBGcolor := BGcolor
//
Private r_first := Boxtop, c_first := Boxright - 1
Private r_last := Boxbot, c_last := Boxright - 1
// определяем виртуальные GET'ы (массив VGET)
aGet := vGetlist
BGh := 1
BGTop := max(aGet[nGet]:Row-Boxh+3,1)
// nLastget is set to a dummy value (must be same as nGet)
nLastGet := nGet
// Save the original Boxrows and Cols..
aeval(aGet, {|oGet| oGet:Cargo := {oGet:Row,oGet:Col} } )
//
aeval(aGet, {|oGet| BGh := max(BGh,oGet:Row) } )
aeval(vGetBG, {|x| BGh := max(BGh,x[1]) } )
// Same with Get-Rows.. (Newgetrows() is a UDF below..)
NewGetRows(aGet,Boxtop,Bgtop)
// Draws the GET Frame..
eval(bDrawBox)
// Draw the Background of the Gets.. (Titles etc)
ShowGetBG(Boxtop,BGTOP,Boxh,Boxw,BGcolor)
// Display those gets which fit into the box :
ShowGets(aGet,nGet,Boxtop,Boxh)
// Positions the cursor to the first position in the first GET
DevPos( aGet[nGet]:ROW, aGet[nGet]:COL )
// Process Keystrokes in a Loop until the user wants to exit
// Don't enter this Loop, if we're in display-only mode
do while mode != "V" .and. !eq_any(nKey,K_PGDN,K_ESC)
  lSkiped := .f. // Set within When-Clause processing. Reset to .f. first
  do case
    // If the active get doesn't meet the when clause..
    case !GetPrevalidate(aGet[ nGet ])
      lSkiped = .t. // We skip the valid clause..
      // Whats going on here ?
      // We simulate a keystroke to bypass the actual get
      // we do it directly, not with the keyboard command,
      // for not running into any conflicts with pending keystrokes..
      do case
        case nGet <= 1   // If we can't move upwards
          nKey = K_DOWN
        case nGet >= len(aGet)  // if we can't move downwards
          nKey = K_UP
        case nKey = K_UP // if last Key was Cursor up i.e., the current direction is Upwards
          // just continue, nothing special to do...
          // nKey = K_UP
        otherwise  // default is moving downwards..
          nKey = K_DOWN
      endcase
    case ( ValType( aGet[nGet]:reader ) == "B" )
      Eval( aGet[nGet]:reader, aGet[nGet] )  // use custom reader block
      nKey := lastkey()
    otherwise
      SETCURSOR() // Cursor on...
      nKey := INKEYTRAP(0)
  endcase
  DO CASE
    case valtype(setkey(nkey)) == "B"   // Process hotkeys
      eval(setkey(nkey),"SCROLGET",0,aGet[nGet]:Name)
    CASE eq_any(nKey,K_ENTER,K_TAB,K_DOWN)
      // we're moving down (Tab also moves down, just like in windows)
      ++nGet
    CASE eq_any(nKey,K_SH_TAB,K_UP)
      // we're moving up (Shift-Tab also moves up, just like in windows)
      iif( nGet == 1, Nil, --nGet )
    CASE nKey == K_BS
      aGet[ nGet ]:BACKSPACE()
    CASE nKey == K_DEL
      aGet[ nGet ]:DELETE()
    CASE nKey == K_LEFT
      aGet[ nGet ]:LEFT()
    CASE nKey == K_RIGHT
      aGet[ nGet ]:RIGHT()
    CASE nKey == K_HOME
      aGet[ nGet ]:HOME()
    CASE nKey == K_END
      aGet[ nGet ]:END()
    CASE nKey == K_CTRL_LEFT
      aGet[ nGet ]:WORDLEFT()
    CASE nKey == K_CTRL_RIGHT
      aGet[ nGet ]:WORDRIGHT()
    CASE nKey == K_CTRL_HOME
      nGet := 1
    CASE nKey == K_CTRL_END
      nGet := LEN( aGet )
    CASE nKey == K_CTRL_T
      aGet[ nGet ]:DELWORDRIGHT()
    CASE nKey == K_CTRL_Y
      aGet[ nGet ]:DELEND()
    CASE nKey == K_CTRL_U
      aGet[ nGet ]:UNDO()
    CASE nKey == K_INS  //  Toggles the INSERT mode
      lInsert := ! lInsert
      SETCURSOR()
    CASE Range( nKey, 32, 255 )  // it's a character to be entered...
      iif( lInsert, aGet[ nGet ]:INSERT( CHR( nKey ) ),;
                    aGet[ nGet ]:OVERSTRIKE( CHR( nKey ) ) )
    case eq_any(nKey,K_CTRL_PGUP,K_CTRL_PGDN)
       //  dummy - will be processed below
    CASE eq_any(nKey,K_PGDN,K_ESC) // user wants out...
      k := f_alert({padc("Выберите действие",60,".")},arr_alert,;
                   if(nKey==K_ESC,1,2),"W+/N","N+/N",22,,"W+/N,N/BG" )
      nKey := 0
      if k == 1
        nKey := K_ESC
      elseif k == 2
        nKey := K_PGDN
      endif
  ENDCASE
  // стрелка вниз в последнем поле ни к чему не приводит
  IF nGet == LEN( aGet ) + 1
    nGet := LEN( aGet )
  ENDIF
  //  If the GET has changed, the old GET loses it's focus
  IF nLastGet != nGet .or. eq_any(nKey,K_CTRL_PGUP,K_CTRL_PGDN,K_PGDN)
    // First Look, if the get meets the Validclause
    if !lSkiped .and. !GetPostValidate(aGet[nLastget])
      // if it doesn't don't leave the get, reforce new input..
      nGet := nLastget
      loop
    endif
    // Kill the focus of the last get and set it to unselected Color
    GetFocus( aGet[ nLastGet ], .F.)
    /*****************************************
    0     1════════╗
    1     2        ║
    2  1──3────────╫────┐ Boxtop =2
    3  2  4BGTOP=4 ║    │
    4  3  5        ║    │  Boxh  =5
    5  4  6BGbot=6 ║    │
    6  5──7────────╫────┘ Boxbot =6
    7     8════════╝ BGh =8
    ******************************************/
    do case
      // new getrow is outside the window - time to scroll gets..
      case aGet[nGet]:Row <= Boxtop .or. aGet[nGet]:Row >= Boxtop+Boxh-1
        ScrollNext(aGet,nGet,nLastget,Boxtop,Boxh,@BGTop,bgh)
        // Show the new Background...
        ShowGetBG(Boxtop,BGTOP,Boxh,Boxw,BGcolor)
        // Show the new Gets, set focus to new get
        ShowGets(aGet,nGet,Boxtop,Boxh)
      case eq_any(nKey,K_CTRL_PGUP,K_CTRL_PGDN)
        do case
          case nKey == K_CTRL_PGUP
            BGTop := max(BGtop-Boxh+2,1)
          case nKey == K_CTRL_PGDN
            BGTop := min(BGtop+Boxh-2,BGh-Boxh+3)
        endcase
        nGet := FirstGetinBox(aGet,BGTop,Boxh)
        NewGetRows(aGet,Boxtop,Bgtop)
        // Show the new Background...
        ShowGetBG(Boxtop,BGTOP,Boxh,Boxw,BGcolor)
        // Show the new Gets, set focus to new get
        ShowGets(aGet,nGet,Boxtop,Boxh)
      otherwise
        // set focus to new get
        GetFocus( aGet[ nGet ], .T.)
    endcase
    // Save values
    nLastGet := nGet
  ENDIF
  //  Returns the cursor in the current GET
  ic := aGet[nGet]:col + aGet[nGet]:pos - 1
  if ic > 79
    ic := 79
  endif
  DevPos( aGet[nGet]:row, ic)
  //DevPos( aGet[nGet]:row, aGet[nGet]:col + aGet[nGet]:pos - 1 )
ENDDO
// make sure getfield isn't active any more
// this is especialy important for "V"iew mode
GetFocus( aGet[ nGet ], .f.)
// Restore the getlist's original Boxrows
// coment this out, if you want to process the actual Row and Column settings
// within the calling routine..
aeval(aGet,{|oGet|oGet:Row := oGet:cargo[CARGO_ROW], oGet:Col := oGet:cargo[CARGO_COL]})
setcolor(cO_color)    // restore the color
set cursor off
restscreen(buf)
RETURN nKey != K_ESC

*
// The Bottom of the Box is calculated as Boxtop plus
// Boxheigth -1 (see Grafic above)
// extra step to make the code more readable
// converted to Preprocessor constant for better runtime performance
#define Boxbot (Boxtop+Boxh-1)

*****
Function FirstGetinBox(aGet,BGTop,Boxh)
Local nKounter, nMin, oGet
nMin := MaxGetRow(aGet)
for nKounter := 1 to len(aGet)
  oGet := aGet[nKounter]
  if oGet:cargo[CARGO_ROW] >= BGTop .and. oGet:cargo[CARGO_ROW] <= Bgtop+Boxh-2
    if oGet:cargo[CARGO_ROW] < aGet[nMin]:cargo[CARGO_ROW] .or.;
           (oGet:cargo[CARGO_ROW] == aGet[nMin]:cargo[CARGO_ROW] .and.;
            oGet:cargo[CARGO_COL] < aGet[nMin]:cargo[CARGO_COL] )
      nMin := nKounter
    endif
  endif
next
return nMin

*****
Function MaxGetrow(aGet)
local nMax := 0, nKounter
if nMax < 1
  nMax := 1
  nKounter := 0
  for nKounter := 1 to len(aGet)
    if aGet[nKounter]:cargo[CARGO_ROW] > aGet[nMax]:cargo[CARGO_ROW]
      nMax := nKounter
    endif
  next
endif
return nMax

*****
Static Function ScrollNext(aGet,nGet,nLastget,Boxtop,Boxh,BGtop,Bgh)
/*****************************************
0    11         ║
1    12  *      ║                   *:row = 1, *:cargo[CARGO_ROW]=12
2  1─13─────────╫────┐ Boxtop =2
3  2 14BGTOP=14 ║    │
4  3 15         ║    │  Boxh  =5
5  4 16BGbot=16 ║    │
6  5─17─────────╫────┘ Boxbot =6
7    18══#══════╝ BGh =18           #:row = 7, #:cargo[CARGO_ROW] = 18
******************************************/
BGTop := BGtop-(aGet[nLastget]:cargo[CARGO_ROW]-aGet[nGet]:cargo[CARGO_ROW])
BGTop := max(min(BGtop,BGh-Boxh+3),1)
NewGetRows(aGet,Boxtop,Bgtop)
return nil

*****
Function ShowGetBG(Boxtop,BGTOP,Boxh,Boxw,BGcolor,cColor)
Local cO_Color := setcolor(), i, j, r, c := 79, arr := {}
if pcount() > 5 // 6-ой параметр (cColor) необязателен
  setcolor(cColor)
endif
for i := Boxtop+1 to Boxtop+Boxh-2
  aadd(arr, {i,.f.})
next
for i := 1 to len(vGetBg)
  if between(vGetBg[i,1], BGTop, BGTop+Boxh-3)
    r := Boxtop + (vGetBg[i,1]-BGTop) + 1
    devpos(r,vGetBG[i,2])
    devout(padr(vGetBG[i,3],Boxw-2),vGetBG[i,4])
    c := min(c,vGetBG[i,2])
    if (j := ascan(arr, {|x| x[1] == r } )) > 0
      arr[j,2] := .t.
    endif
  endif
next
for i := 1 to len(arr)
  if !arr[i,2]
    r := Boxtop + i
    devpos(r,c)
    devout(space(Boxw-2))
  endif
next
setcolor(cO_color) // Reset the color setting
return nil

*
// Next two functions interface between real screen coordinates and the
// virtual ones..
*****
Static Function NewGetRows(aGet,Boxtop,Bgtop,n)
// Internaly (in cargo[CARGO_ROW]), we have virtual Rows for every Get.
// Numbering starts with 1, So that the First virtual Row is Number 1,
// the second 2 etc.
//
// This function is to update the "real" (i.e. Get:Row) Rows of the
// getfield..
// The real job, to find out how many lines to shift, has been done above
// within the UDF ScrollNext()
//
// If you're using scrolling gets with funcky's window functions
// place a call to NewGetRows every time the window has been moved
Local nKounter, Shift := Boxtop-Bgtop+1
DEFAULT n TO 1
//aeval(aGet,{|oGet|oGet:Row := oGet:cargo[CARGO_ROW] + Shift})
for nKounter := n to len(aGet)
  aGet[nKounter]:Row := aGet[nKounter]:cargo[CARGO_ROW] + Shift
next
return nil

*****
Static Function ShowGets(aGet,nGet,Boxtop,Boxh)
Local nKounter, fl_first := .f., fl_last := .f.
/*
AEVAL(aGet, {|oGet| nKounter++,;
                    iif(oGet:Row > Boxtop .and. oGet:Row < Boxbot,;
                            iif(nKounter == nGet, GetFocus( oGet,.t.),;
                                                  oGet:display()),;
                            NIL);
            })
*/
for nKounter := 1 to len(aGet)
  // if the getfiled is within the frame
  if aGet[nKounter]:Row > Boxtop .and. aGet[nKounter]:Row < Boxbot
    if nKounter == nGet  // if it's the cative getfield
      GetFocus(aGet[nKounter],.t.)  // Tell the getsystem
    else
      aGet[nKounter]:display()      // otherwise display "only"
    endif
    if nKounter == 1
      fl_first := .t.
    elseif nKounter == len(aGet)
      fl_last := .t.
    endif
  else
    // If we know that the GetList is ordered by Rows
    // Rather the by colums or otherwise...
    // We could place an "Exit"-Statement at this place..
  endif
next
@ r_first,c_first say iif(fl_first, " ", "") color cDataPgDn
@ r_last,c_last say iif(fl_last, " ", "") color cDataPgDn
return nil

*

*****
Static Function GetFocus( oGetObj, lFocus)
IF lFocus
  oGetObj:SETFOCUS() //  Returns the cursor to the current Get
  // DEVPOS( oGetObj:ROW, oGetObj:COL )
ELSE
  oGetObj:KILLFOCUS()
ENDIF
RETURN nil

*****
Static Function GetPreValidate(get)
Local lwhen := .t.
if !( get:preBlock == NIL )
  lwhen := Eval(get:preBlock, get)
  get:Display()
endif
return (lwhen)

*****
Static Function GetPostValidate(get)
Local saveUpdated, changed, lvalid := .t.
if ( get:BadDate() )
  get:Home()
  return (.f.)
end
if ( get:changed )
  get:Assign()
end
get:Reset()
if !( get:postBlock == NIL )
  // S87 compat.: SetPos( get:row, get:col + Len(get:buffer) )
  lvalid := Eval(get:postBlock, get)
  // reset compat. pos
  SetPos( get:row, get:col )
  get:UpdateBuffer()
end
return (lvalid)

*

*****
Function update_vgets(n,j)
Local i
if valtype(vGetlist)=="A"
  if valtype(n) == "N"  // обновить VGET'ы, начиная с n-го
    DEFAULT j TO 1  // какой VGET "подсветить"
    aGet := vGetlist
    BGh := 1
    aeval(aGet, {|oGet| BGh := max(BGh,oGet:Row) } )
    aeval(vGetBG, {|x| BGh := max(BGh,x[1]) } )
    // Save the original Boxrows and Cols..
    aeval(aGet, {|oGet| oGet:Cargo := {oGet:Row,oGet:Col} }, n )
    // Same with Get-Rows.. (Newgetrows() is a UDF below..)
    NewGetRows(aGet,sBoxtop,Bgtop,n)
    // Draw the Background of the Gets.. (Titles etc)
    ShowGetBG(sBoxtop,BGTOP,Boxh,Boxw,sBGcolor)
    // Display those gets which fit into the box :
    ShowGets(aGet,j,sBoxtop,Boxh,Boxw)
  else                           // обновить конкретный VGET
    for i := 1 to len(vGetlist)
      if upper(n) == upper(vGetlist[i]:name)
        vGetlist[i]:Display() ; exit
      endif
    next
  endif
endif
return .t.
