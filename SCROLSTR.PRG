#include "function.ch"
#include "inkey.ch"

*****  горизонтальный скроллинг строки
FUNCTION scroll_str
LOCAL i := 1, tmp, s, n, ch, ri := readinsert(.f.)
PARAMETERS pole,pos,lp
s := RTRIM(&pole)
IF EMPTY(s)
  RETURN 0
ENDIF
n := LEN(s)
IF n < lp
  s += SPACE(lp-n)
  n := lp
ENDIF
SETCOLOR(cColorStMsg)
SETCURSOR()
@ cur_row,pos SAY SUBSTR(s,1,lp)
@ cur_row,pos SAY ""
tmp := pos
DO WHILE .T.
  ch := INKEYTRAP(0)
  DO CASE
    CASE ch == K_HOME
      tmp := pos
      i := 1
      @ cur_row,pos SAY SUBSTR(s,i,lp)
      @ cur_row,tmp SAY ""
    CASE ch == K_END
      tmp := lp+pos-1
      i := n-lp+1
      @ cur_row,pos SAY SUBSTR(s,i,lp)
      @ cur_row,tmp SAY ""
    CASE ch == K_RIGHT
      IF tmp < lp+pos-1
        Inc(tmp)
        @ cur_row,tmp SAY ""
      ELSEIF i < n-lp+1
        Inc(i)
        @ cur_row,pos SAY SUBSTR(s,i,lp)
        @ cur_row,tmp SAY ""
      ENDIF
    CASE ch == K_LEFT
      IF tmp > pos
        Dec(tmp)
        @ cur_row,tmp SAY ""
      ELSEIF i > 1
        Dec(i)
        @ cur_row,pos SAY SUBSTR(s,i,lp)
        @ cur_row,tmp SAY ""
      ENDIF
    CASE ch == K_ENTER .OR. ch == K_ESC .OR. ch == K_UP .OR. ch == K_DOWN
      EXIT
  ENDCASE
ENDDO
IF ch == K_UP .OR. ch == K_DOWN
  SETCOLOR(color1)
ENDIF
@ cur_row,pos SAY SUBSTR(&pole,1,lp)
readinsert(ri)
SETCURSOR(0)
SETCOLOR(color1)
KEYBOARD ""
RETURN IF(ch == K_UP .OR. ch == K_DOWN, ch, 0)
