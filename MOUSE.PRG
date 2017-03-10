//
// Реализация мыши (идея и ассемблерный модуль взяты из библиотеки NANFORUM)
//
#include "inkey.ch"
#include "function.ch"

static is_mouse := .f.
static nMouseX := 0//92
static nMouseY := 0//312
static aReg[10]

/*
 *    FT_MRESET() -> nMouseStatus
 * RETURNS
 *    An integer representing the mouse status (0 == mouse not installed)
 * DESCRIPTION
 *    Resets the mouse driver and returns mouse status. Use FT_MSHOWCRS()
 *    to display the mouse cursor.
 * EXAMPLES
 *    IF Empty( FT_MRESET() )
 *       ? "No mouse driver is installed"
 *    ENDIF
 */
FUNCTION FT_MRESET()
RETURN ""

/*
 *    FT_MSHOWCRS() -> NIL
 * RETURNS
 *    NIL
 * DESCRIPTION
 *    Displays the mouse cursor. Make sure to turn the mouse cursor off
 *    when redrawing screens.  The mouse cursor dutifully saves the screen
 *    under it, so if you draw over the mouse cursor it will create a "hole"
 *    in your screen when you move the mouse cursor.
 * EXAMPLES
 *    IF Empty( FT_MRESET() )
 *       FT_MSHOWCRS()
 *    ENDIF
 */
FUNCTION FT_MSHOWCRS(flag_mouse)
RETURN NIL

/*
 *    FT_MHIDECRS() -> NIL
 * RETURNS
 *    NIL
 * DESCRIPTION
 *    Hides the mouse cursor. Make sure to turn the mouse cursor off when
 *    redrawing screens.  The mouse cursor dutifully saves the screen
 *    under it, so if you draw over the mouse cursor it will create a
 *    "hole" in your screen when you move the mouse cursor.
 * EXAMPLES
 *    FT_MHIDECRS()
 *    @ 10, 10 to 20, 20
 *    FT_MSHOWCRS()
 */
FUNCTION FT_MHIDECRS(flag_mouse)  // hide cursor
RETURN NIL

/*
 *    FT_MGETPOS( @<nX>, @<nY> ) -> nButtonStatus
 *
 *    <nX> is a variable that will receive the mouse X position.  It must
 *    be passed by reference.
 *
 *    <nY> is a variable that will receive the mouse Y position.  It must
 *    be passed by reference.
 * RETURNS
 *    an integer representing button status
 *
 *          - 0 for no button pressed
 *          - 1 for left pressed
 *          - 2 for right pressed
 *          - 3 for left and right pressed
 *          - 4 for middle pressed
 *          - 5 for left and middle pressed
 *          - 6 for right and middle pressed
 *          - 0 for all three buttons pressed
 * DESCRIPTION
 *    Loads cursor position into x and y coordinates passed by reference and
 *    returns the button status.
 * EXAMPLES
 *    LOCAL nX, nY
 *    LOCAL nButton := FT_MGETPOS( @nX, @nY )
 *    ? "Mouse Row    :", nX
 *    ? "Mouse Column :", nY
 *    ? "Button Status:", nButton
 */
FUNCTION FT_MGETPOS( nX, nY )
DEFAULT nX TO 0, nY TO 0
RETURN 0

/*
 *    FT_MGETX() -> nRowPos
 * RETURNS
 *    Row position of mouse
 * DESCRIPTION
 *    Retrieves mouse's row position
 * EXAMPLES
 *    ? FT_MGETX()
 */
FUNCTION FT_MGETX()
RETURN 0

/*
 *    FT_MGETY() -> nColPos
 * RETURNS
 *    Column position of mouse.
 * DESCRIPTION
 *    Retrieves mouse's column position.
 * EXAMPLES
 *    ? FT_MGETY()
 */
FUNCTION FT_MGETY()
RETURN 0

/*
 *    FT_MSETPOS( <nX>, <nY> ) -> NIL
 *
 *    <nX> is the desired mouse row.
 *
 *    <nY> is the desired mouse column.
 * RETURNS
 *    NIL
 * DESCRIPTION
 *    Positions mouse cursor on screen.
 * EXAMPLES
 *    FT_MSETPOS( 10, 20 )     // position mouse cursor at row 10, col 20
 */
FUNCTION FT_MSETPOS( nX, nY )  // set mouse cursor location
RETURN NIL                     // no function output

***** установить курсор мыши в "текущую позицию"
FUNCTION SETPOSMOUSE(x,y)
RETURN .f.

***** есть ли "мышь" в данный момент на экране
FUNCTION IS_MOUSE_ON_SCREEN()
RETURN is_mouse

***** имитация функции INKEY(0) совместно с мышью
Function Inkey_Mouse(ndelay)
Local nKey := 0, km, time1, fl_mouse := SETPOSMOUSE()
DEFAULT ndelay TO 0  // время ожидания в секундах
KEYBOARD ""
FT_MSHOWCRS(fl_mouse)
if ndelay > 0
  time1 := seconds()
endif
do while nKey == 0
  if fl_mouse .and. (km := FT_MGETPOS()) > 0
    if km == 1           // если нажата левая кнопка,
      nKey := K_ENTER    // то возвращается <Enter>,
    else                 // иначе
      nKey := K_ESC      // возвращается <Esc>
    endif
  endif
  if nKey == 0
    nKey := INKEYTRAP()
  endif
  if ndelay > 0 .and. seconds() - time1 > ndelay
    nKey := 32
  endif
enddo
if fl_mouse
  clear_mouse()
  FT_MHIDECRS()
endif
return nKey

***** очистить буфер мыши
Function clear_mouse()
return NIL
