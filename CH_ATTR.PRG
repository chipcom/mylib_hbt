#include "function.ch"

***** 15.04.19 сделать область экрана "бледной"
FUNCTION change_attr(r1,c1,r2,c2)
LOCAL sTmpScr,  ch := CHR(255)+CHR(247)
DEFAULT r1 TO 0, c1 TO 0, r2 TO maxrow(), c2 TO maxcol()
sTmpScr := SAVESCREEN(r1, c1, r2, c2)
CHARAND(@sTmpScr, ch)
RESTSCREEN(r1, c1, r2, c2, sTmpScr)
colorwin(r1, c1, r2, c2, "N+/BG", "N/BG")
colorwin(r1, c1, r2, c2, "N+/W", "N/W")
RETURN NIL