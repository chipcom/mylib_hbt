#include "inkey.ch"

***** при продвижении по GET-ам вниз возвращает .f. в случае пустой переменной
Function func_empty(n)
Local fl := .t.
if empty(n) .and. lastkey() != K_UP
  fl := func_error(3,"Данное поле не должно быть пустым.")
  keyboard ""
endif
return fl
