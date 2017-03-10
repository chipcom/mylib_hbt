// ®ЇҐа жЁЁ § ЇЁбЁ Ё­д®а¬ жЁЁ ў XML-д ©«
// (ЇаҐ¤Ї®« Ј Ґвбп, зв® д ©« г¦Ґ ®вЄалв б Public-¤ҐбЄаЁЇв®а®¬ "fp")
#include "function.ch"

Static otstup := 0, step_otstup := 1

***** ЇҐаў п бва®Є  XML-д ©« 
Function xml_1(s)
DEFAULT s TO '<?xml version="1.0" encoding="windows-1251"?>'
add_string(dos2win(s))
return NIL

***** бва®Є  ¤«п ®д®а¬«Ґ­Ёп ­ з «  Ё­д®а¬ жЁ®­­®Ј® Ў«®Є  (­  ®в¤Ґ«м­®© бва®ЄҐ)
Function xml_Begin(s,arr)
// s   - ­ Ё¬Ґ­®ў ­ЁҐ н«Ґ¬Ґ­в 
// arr - ¤ўг¬Ґа­л© ¬ ббЁў (Ё«Ё NIL)
add_string(space(otstup)+"<"+dos2win(s)+xml_Put_Arr(arr)+">")
otstup += step_otstup
return NIL

***** бва®Є  ¤«п ®д®а¬«Ґ­Ёп ®Є®­з ­Ёп Ё­д®а¬ жЁ®­­®Ј® Ў«®Є  (­  ®в¤Ґ«м­®© бва®ЄҐ)
Function xml_End(s)
// s - ­ Ё¬Ґ­®ў ­ЁҐ н«Ґ¬Ґ­в 
otstup -= step_otstup
add_string(space(otstup)+"</"+dos2win(s)+">")
return NIL

***** ўлў®¤ бва®ЄЁ ў XML-д ©«
Function xml_Stroke(s,xvalue,is_need)
// s       - ­ Ё¬Ґ­®ў ­ЁҐ н«Ґ¬Ґ­в 
// xvalue  - §­ зҐ­ЁҐ н«Ґ¬Ґ­в  (Ё«Ё ¤ўг¬Ґа­л© ¬ ббЁў)
// is_need - ®Ўп§ вҐ«м­®бвм ўлў®¤  ¤ ­­®Ј® н«Ґ¬Ґ­в 
Local stroke, fl := .t.
DEFAULT xvalue TO "", is_need TO .t.
if !is_need .and. empty(xvalue)
  fl := .f.
endif
if fl
  stroke := space(otstup)+"<"+dos2win(s)
  if empty(xvalue)
    add_string(stroke+"/>")
  elseif valtype(xvalue) == "A"
    add_string(stroke+xml_Put_Arr(xvalue)+"/>")
  else
    add_string(stroke+">"+dos2win(xml_Convert(xvalue))+"</"+dos2win(s)+">")
  endif
endif
return NIL

***** ўлў®¤ ЇаЁ¬Ґз ­Ёп ў XML-д ©«
Function xml_Prim(s)
add_string(space(otstup)+"<!-- "+dos2win(s)+" -->")
return NIL

***** ўлў®¤ ¬ ббЁў 
Static Function xml_Put_Arr(arr)
Local i, s := ''
if valtype(arr) == "A"
  for i := 1 to len(arr)
    s += ' '+dos2win(arr[i,1])+'="'+dos2win(xml_Convert(arr[i,2]))+'"'
  next
endif
return s

***** ЇаҐўа йҐ­ЁҐ «оЎ®© ЇҐаҐ¬Ґ­­®© ў бва®Єг
Static Function xml_Convert(xvalue)
Local i, c, lvalue := ""
if valtype(xvalue) == "D"
  lvalue := full_date(xvalue)
elseif valtype(xvalue) == "N"
  lvalue := lstr(xvalue)
elseif valtype(xvalue) == "C"
  // ў бва®ЄҐ гЎа вм «Ёи­ЁҐ Їа®ЎҐ«л
  xvalue := charone(" ",alltrim(xvalue))
  // ў бва®ЄҐ § ¬Ґ­Ёвм гЈ«®ўлҐ бЄ®ЎЄЁ ­  Є ўлзЄЁ (  Є ўлзЄЁ = &quot;)
  for i := 1 to len(xvalue)
    c := substr(xvalue,i,1)
    lvalue += iif(c $ '"<>', '&quot;', c)
  next
endif
return lvalue
