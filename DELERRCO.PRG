***** �������� EVAL ��� ��� ��������� �訡�� ��������� �믮������
Function del_err_compiler()
Local bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  eval( &( "{|| 2+2}" ) )
RECOVER USING error
  // ��祣�
END
ERRORBLOCK(bSaveHandler)
return NIL
