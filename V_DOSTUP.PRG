#include 'function.ch'

// проверка прав доступа (дожна быть PUBLIC переменная pravo_write)
Function ver_dostup(fl)

  DEFAULT fl TO .t.
  if !pravo_write
    return func_error(4, 'Нарушение прав доступа на ' + if(fl, 'запись', 'удаление') + '!')
  endif
  return .t.
