*****
Function is_field(sname,stype)
Local i, fl := .f.
if (i := fieldnum(sname)) > 0
  fl := .t.
  if stype != NIL
    fl := (fieldtype(i) == upper(stype))
  endif
endif
return fl
