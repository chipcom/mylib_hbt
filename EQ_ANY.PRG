#include "function.ch"
#include "inkey.ch"

***** аналог макроса equalany(...)
Function eq_any
Local fl := .f., i, n, mvar
parameters mval,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,;
                v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,;
                v21,v22,v23,v24,v25,v26,v27,v28,v29,v30
if (n := pcount()-1) > 30
  n := 30
endif
for i := 1 to n
  mvar := "v"+lstr(i)
  if &mvar == mval
    fl := .t. ; exit
  endif
next
return fl

function eq_any_new( mval, ... )
  local fl := .f., i
  local n := pcount()
  local mType := ValType(mval)

  if n < 2
    return fl
  endif
  for i := 2 to n
    mvar := hb_PValue( i )
    if mType != ValType( mvar)
      loop
    endif

    if mval == mvar
    // if &mvar == mval
      fl := .t. ; exit
    endif
  next
  
return fl