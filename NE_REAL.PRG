*****
FUNCTION ne_real()
Local c := cColorStMsg, c1 := cColorStMsg
if type("cColorSt2Msg") == "C"
  c1 := cColorSt2Msg
endif
n_message({"","В данный момент функция не реализована"},,c,c,,,c1 )
return NIL
