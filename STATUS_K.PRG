#include 'inkey.ch'
#include 'function.ch'

//
Function STATUS_KEY(cStr, cColor1, cColor2)
  LOCAL out_str := '', out_arr := {}, i, j := 2, s

  DEFAULT cColor1 TO cColorStMsg, cColor2 TO cColorSt2Msg
  cStr := ' ' + cStr
  FOR i := 1 TO NUMTOKEN(cStr, '^')
    s := TOKEN(cStr, '^', i)
    if j == 1
      out_str += s
      aadd(out_arr, s)
      j := 2
    else
      out_str += s
      j := 1
    endif
  NEXT
  out_str := padc(alltrim(out_str), maxcol() + 1)
  @ maxrow(), 0 say out_str color cColor1
  for i := 1 to len(out_arr)
    if (j := at(out_arr[i], out_str)) > 0
      @ maxrow(), j - 1 say out_arr[i] color cColor2
    endif
  next
  return NIL
