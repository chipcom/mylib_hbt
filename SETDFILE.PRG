#include "directry.ch"
#include "function.ch"

***** установить дату файла по дате другого файла
Function SetDateFile(file_out,file_in,dplus)
Local nf := directory(file_in)
DEFAULT dplus TO 0
SETFDATI(file_out,nf[1,F_DATE]+dplus,nf[1,F_TIME])
return NIL
