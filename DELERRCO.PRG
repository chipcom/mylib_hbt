***** запустить EVAL для сброса возможной ошибки компилятора выполнения
Function del_err_compiler()
Local bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  eval( &( "{|| 2+2}" ) )
RECOVER USING error
  // ничего
END
ERRORBLOCK(bSaveHandler)
return NIL
