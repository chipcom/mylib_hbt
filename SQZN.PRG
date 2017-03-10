#include "function.ch"

// идея функций взята из NANFORUM.LIB

***** "скрутить" число в строку
Function ft_sqzn(nValue,nSize,nDecimals)
// Правило определения размера выходной строки:
// - если в числе есть десятичная точка, она удаляется
// - длина строки равна - количество цифр разделить на два с округлением в
//                                                           большую сторону
local tmpstr, cCompressed, k
DEFAULT nSize TO 10, nDecimals TO 0
tmpstr := str(abs(nValue),nSize,nDecimals)
if nDecimals > 0
  tmpstr := substr(tmpstr,1,nSize-nDecimals-1)+right(tmpstr,nDecimals)
  Dec(nSize)
endif
if nSize % 2 != 0
  Inc(nSize)
endif
if len(tmpstr) < nSize
  tmpstr := " "+tmpstr
endif
tmpstr := strtran(tmpstr," ","0")
cCompressed := chr( val(substr(tmpstr,1,2))+if(nValue<0,128,0) )
for k := 3 to len(tmpstr) step 2
  cCompressed += chr(val(substr(tmpstr,k,2)))
next
return cCompressed

***** "раскрутить" число из строки
function ft_unsqzn(cCompressed,nSize,nDecimals)
local tmp := "", k, cValue, multi := 1
DEFAULT nSize TO 10, nDecimals TO 0
if cCompressed == space(len(cCompressed)) ; return 0 ; endif
if (nDecimals > 0 .and. nSize % 2 == 0) .or. ;
                   (nDecimals == 0 .and. nSize % 2 == 1)
  Inc(nSize)
endif
if asc(cCompressed) > 127
  tmp := str(asc(cCompressed)-128,2)
  multi := -1
else
  tmp := str(asc(cCompressed),2)
endif
for k := 2 to len(cCompressed)
  tmp += str(asc(substr(cCompressed,k,1)),2)
next
tmp := strtran(tmp," ","0")
cValue := substr(tmp,1,nSize-nDecimals-if(nDecimals==0,0,1))+"."+;
                                                 right(tmp,nDecimals)
k := val(cValue) * multi
if nDecimals == 0
  k := int(k)
endif
return k
