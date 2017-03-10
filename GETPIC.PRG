#include "function.ch"
#include "inkey.ch"

*****  возвратить необходимый picture для определенного поля
FUNCTION get_pic
PARAMETERS field
PRIVATE pstring, s
DO CASE
  CASE TYPE(M->field) = "C"  && character field is bounded by window width
    pstring := "@KS" + LStr(MIN(LEN(&field), 78))
  CASE TYPE(M->field) = "N"  && convert to character to help format picture string
    s := STR(&field)
    IF "." $ M->s  && decimals in numeric...use the form "9999.99"
      pstring := REPLICATE("9", AT(".", M->s) - 1) + "."
      pstring += REPLICATE("9", LEN(M->s) - LEN(M->pstring))
    ELSE  && no decimals...only need the correct length
      pstring := REPLICATE("9", LEN(M->s))
    ENDIF
  OTHERWISE  && no picture
    pstring := ""
ENDCASE
RETURN pstring