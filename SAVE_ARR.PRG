*******************************************************************************
*  save_arr(aArray, cFileName) - сохранение массива в файле на диске
*  rest_arr(cFileName,fl_NET) - востановление массива из файла на диске
*  saveNarr(aArray, cFileName, number) - сохранение массивов в файле на диске
*  restNarr(cFileName,number,fl_NET) - востановление массивов из файла на диске
*  save_arr_mem(aArray) - сохранение массива в символьной переменной
*  rest_arr_mem(sVar) - востановление массива из символьной переменной sVar
*******************************************************************************
#include "fileio.ch"
#include "function.ch"

#define COUNT_ARRAYS 1000 // max кол-во сохраняемых массивов

***********************************
*  save_arr - сохранение массива в файле на диске
*  FUNCTION save_arr(aArray, cFileName)
*       aArray - массив, (возможно вложенный) содержащий любые типы данных.
*    cFileName - имя файла.
*
*   Возврат: код ошибки.
*            -1    не записан тип элемента.
*            -2    не записана длина элемента.
*            -3    не записан элемент.
***********************************
FUNCTION SAVE_ARR(aArray, cFileName)
LOCAL nHandle, lRet := -1, i := 0
if file(cFileName)            // для правильной работы в сети, если массив
  do while ferase(cFileName) != 0 .and. i < 100  // сохраняется на сервере
    i++
  enddo
endif
i := 0
do while (nHandle := FCREATE(cFileName)) == -1 .and. i < 100
  i++
enddo
IF nHandle != -1
  lRet := _ftsavesub(aArray, nHandle)
  FCLOSE(nHandle)
ENDIF
RETURN lRet

*****
FUNCTION _ftsavesub(xMemVar, nHandle)
LOCAL cValType, nLen, cString, _i
PRIVATE lRet       // accessed in code block
lRet := 0
cValType := ValType(xMemVar)
if FWrite(nHandle, cValType, 1) == 1            // тип элемента массива
  DO CASE
    CASE cValType == "B"
      nLen := 3
      cString := "■B■"
    CASE cValType == "C"
      nLen := Len(xMemVar)
      cString := xMemVar
    CASE cValType == "D"
      nLen := 4
      cString := DTOC4(xMemVar)
    CASE cValType == "L"
      nLen := 1
      cString := IF(xMemVar, "T", "F")
    CASE cValType == "N"
      cString := ltrim(STR(xMemVar))
      nLen := LEN(cString)
    CASE cValType == "A"
      nLen := Len(xMemVar)
  ENDCASE
  if FWrite(nHandle, i2Bin(nLen), 2) == 2
    IF cValType == "A"    // рекурсивный вызов для массива
      for _i := 1 to nLen
        if (lRet := _ftsavesub(xMemVar[_i], nHandle)) < 0
          return lRet
        endif
      next _i
    else
      if FWrite(nHandle, cString) <> LEN(cString)   // записать элемент
        lRet := -3   // ошибка: не записан элемент
      ENDIF
    ENDIF
  else
    lRet := -2       // ошибка: не записана длина элемента
  ENDIF
ELSE
  lRet := -1         // ошибка: не записан тип элемента
ENDIF
RETURN lRet

*************************************************************
*  rest_arr - востановление массива из файла на диске
*  rest_arr(cFileName,fl_NET)
*    cFileName - имя файла, в котором сохранен массив.
*       fl_NET - логическое значение (открывается файл в сети или нет)
*                по умолчанию = .f.
*
*   Возврат: массив
*            в случае ошибки - пустой массив.
*************************************************************
FUNCTION REST_ARR(cFileName,fl_NET)
LOCAL nHandle, aArray := {}, i := 0, file_attr := FO_READ
DEFAULT fl_NET to .f.
if fl_NET
  file_attr += FO_SHARED
endif
do while (nHandle := FOPEN(cFileName,file_attr)) == -1 .and. i < 100
  i++
enddo
IF nHandle != -1
  aArray := _ftrestsub(nHandle)
  FCLOSE(nHandle)
ENDIF
RETURN aArray

*****
FUNCTION _ftrestsub(nHandle)
LOCAL cValType, nLen, cLenStr, xMemVar, cMemVar, nk
cValType := ' '
FREAD(nHandle, @cValType, 1)
cLenStr := SPACE(4)
FREAD(nHandle, @cLenStr, 2)
nLen = Bin2i(cLenStr)
DO CASE
  CASE cValType = "A"
    xMemVar := {}
    FOR nk := 1 TO nLen
      AADD(xMemVar, _ftrestsub(nHandle))  // рекурсивный вызов для массива
    NEXT
  CASE cValType = "B"
    xMemVar := SPACE(nLen)
    FREAD(nHandle, @xMemVar, nLen)
  CASE cValType = "C"
    xMemVar := SPACE(nLen)
    FREAD(nHandle, @xMemVar, nLen)
  CASE cValType = "D"
    cMemVar = SPACE(4)
    FREAD(nHandle, @cMemVar,nLen)
    xMemVar := C4TOD(cMemVar)
  CASE cValType = "L"
    cMemVar := ' '
    FREAD(nHandle, @cMemVar, nLen)
    xMemVar := (cMemVar == "T")
  CASE cValType = "N"
    cMemVar := SPACE(nLen)
    FREAD(nHandle, @cMemVar, nLen)
    xMemVar = VAL(cMemVar)
ENDCASE
RETURN xMemVar

*******************************************************************************
*  saveNarr - сохранение массивов в файле на диске
*  FUNCTION saveNarr(aArray, cFileName, number)
*       aArray - массив, (возможно вложенный) содержащий
*                любые типы данных,
*                или NIL, если записывается заголовок файла
*    cFileName - имя файла.
*       number - номер записываемого массива,
*                или 0, если записывается заголовок файла
***********************************
FUNCTION SaveNarr(aArray, cFileName, number)
LOCAL nHandle, lRet := -1, i := 0, fl_first := (aArray == NIL .or. number == 0)
if fl_first
  if file(cFileName)            // для правильной работы в сети, если массив
    do while ferase(cFileName) != 0 .and. i < 100  // сохраняется на сервере
      i++
    enddo
  endif
  i := 0
  do while (nHandle := FCREATE(cFileName)) == -1 .and. i < 100
    i++
  enddo
  if (lRet := (nHandle != -1))
    fwrite(nHandle,replicate(chr(0),COUNT_ARRAYS*4))
    FCLOSE(nHandle)
  endif
else
  nHandle := FOPEN(cFileName,FO_READWRITE)
  IF nHandle != -1
    i := fseek(nHandle,0,FS_END)
    lRet := _ftsavesub(aArray, nHandle)
    fseek(nHandle,number*4,FS_SET)
    fwrite(nHandle,l2bin(i),4)
    FCLOSE(nHandle)
  ENDIF
endif
RETURN lRet

*************************************************************
*  restNarr - востановление массивов из файла на диске
*  restNarr(cFileName,number,fl_NET)
*    cFileName - имя файла, в котором сохранен массив.
*       number - номер читаемого массива
*       fl_NET - логическое значение (открывается файл в сети или нет)
*                по умолчанию = .f.
*
*   Возврат: массив
*            в случае ошибки - пустой массив.
*************************************************************
FUNCTION RestNarr(cFileName,number,fl_NET)
LOCAL nHandle, aArray := {}, i := 0, s := space(4), file_attr := FO_READ
DEFAULT fl_NET to .f.
if fl_NET
  file_attr += FO_SHARED
endif
do while (nHandle := FOPEN(cFileName,file_attr)) == -1 .and. i < 100
  i++
enddo
IF nHandle != -1
  fseek(nHandle,number*4,FS_SET)
  if fread(nHandle,@s,4) == 4
    i := bin2l(s)
    fseek(nHandle,i,FS_SET)
    aArray := _ftrestsub(nHandle)
  endif
  FCLOSE(nHandle)
ENDIF
RETURN aArray

*

***********************************
*  save_arr_mem(aArray) - сохранение массива в символьной переменной
*    aArray - массив, (возможно вложенный) содержащий любые типы данных.
***********************************
FUNCTION SAVE_ARR_MEM(aArray)
LOCAL sRet := ""
_ftsavesub_mem(aArray,@sRet)
RETURN sRet

*****
Static FUNCTION _ftsavesub_mem(xMemVar,/*@*/sOut)
LOCAL cValType, nLen, cString, _i
cValType := ValType(xMemVar)
sOut += cValType
DO CASE
  CASE cValType == "B"
    nLen := 3
    cString := "■B■"
  CASE cValType == "C"
    nLen := Len(xMemVar)
    cString := xMemVar
  CASE cValType == "D"
    nLen := 4
    cString := DTOC4(xMemVar)
  CASE cValType == "L"
    nLen := 1
    cString := IF(xMemVar, "T", "F")
  CASE cValType == "N"
    cString := ltrim(STR(xMemVar))
    nLen := LEN(cString)
  CASE cValType == "A"
    nLen := Len(xMemVar)
ENDCASE
sOut += i2Bin(nLen)
if cValType == "A"    // рекурсивный вызов для массива
  for _i := 1 to nLen
    _ftsavesub_mem(xMemVar[_i],@sOut)
  next _i
else
  sOut += cString
endif
RETURN nil

*************************************************************
*  rest_arr_mem(sVar) - востановление массива из символьной переменной sVar
*   Возврат: массив (в случае ошибки - пустой массив)
*************************************************************
FUNCTION REST_ARR_MEM(sVar)
LOCAL aArray := {}
if !empty(sVar)
  aArray := _ftrestsub_mem(sVar,1)
endif
RETURN aArray

*****
Static FUNCTION _ftrestsub_mem(sVar,nUk)
Static nV := 1
LOCAL cValType, nLen, cLenStr, xMemVar, cMemVar, nk
if nUk != NIL
  nV := nUk
endif
cValType := substr(sVar,nV,1) ; nV += 1
cLenStr := substr(sVar,nV,2) ; nV += 2
nLen = Bin2i(cLenStr)
DO CASE
  CASE cValType = "A"
    xMemVar := {}
    FOR nk := 1 TO nLen
      AADD(xMemVar, _ftrestsub_mem(sVar))  // рекурсивный вызов для массива
    NEXT
  CASE cValType = "B"
    xMemVar := substr(sVar,nV,nLen) ; nV += nLen
  CASE cValType = "C"
    xMemVar := substr(sVar,nV,nLen) ; nV += nLen
  CASE cValType = "D"
    cMemVar := substr(sVar,nV,nLen) ; nV += nLen
    xMemVar := C4TOD(cMemVar)
  CASE cValType = "L"
    cMemVar := substr(sVar,nV,nLen) ; nV += nLen
    xMemVar := (cMemVar == "T")
  CASE cValType = "N"
    cMemVar := substr(sVar,nV,nLen) ; nV += nLen
    xMemVar = VAL(cMemVar)
ENDCASE
RETURN xMemVar
