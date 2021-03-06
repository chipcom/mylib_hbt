*******************************************************************************
*  save_arr(aArray, cFileName) - ��࠭���� ���ᨢ� � 䠩�� �� ��᪥
*  rest_arr(cFileName,fl_NET) - ���⠭������� ���ᨢ� �� 䠩�� �� ��᪥
*  saveNarr(aArray, cFileName, number) - ��࠭���� ���ᨢ�� � 䠩�� �� ��᪥
*  restNarr(cFileName,number,fl_NET) - ���⠭������� ���ᨢ�� �� 䠩�� �� ��᪥
*  save_arr_mem(aArray) - ��࠭���� ���ᨢ� � ᨬ���쭮� ��६�����
*  rest_arr_mem(sVar) - ���⠭������� ���ᨢ� �� ᨬ���쭮� ��६����� sVar
*******************************************************************************
#include "fileio.ch"
#include "function.ch"

#define COUNT_ARRAYS 1000 // max ���-�� ��࠭塞�� ���ᨢ��

***********************************
*  save_arr - ��࠭���� ���ᨢ� � 䠩�� �� ��᪥
*  FUNCTION save_arr(aArray, cFileName)
*       aArray - ���ᨢ, (�������� ��������) ᮤ�ঠ騩 ��� ⨯� ������.
*    cFileName - ��� 䠩��.
*
*   ������: ��� �訡��.
*            -1    �� ����ᠭ ⨯ �������.
*            -2    �� ����ᠭ� ����� �������.
*            -3    �� ����ᠭ �������.
***********************************
FUNCTION SAVE_ARR(aArray, cFileName)
LOCAL nHandle, lRet := -1, i := 0
if file(cFileName)            // ��� �ࠢ��쭮� ࠡ��� � ��, �᫨ ���ᨢ
  do while ferase(cFileName) != 0 .and. i < 100  // ��࠭���� �� �ࢥ�
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
if FWrite(nHandle, cValType, 1) == 1            // ⨯ ������� ���ᨢ�
  DO CASE
    CASE cValType == "B"
      nLen := 3
      cString := "�B�"
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
    IF cValType == "A"    // ४��ᨢ�� �맮� ��� ���ᨢ�
      for _i := 1 to nLen
        if (lRet := _ftsavesub(xMemVar[_i], nHandle)) < 0
          return lRet
        endif
      next _i
    else
      if FWrite(nHandle, cString) <> LEN(cString)   // ������� �������
        lRet := -3   // �訡��: �� ����ᠭ �������
      ENDIF
    ENDIF
  else
    lRet := -2       // �訡��: �� ����ᠭ� ����� �������
  ENDIF
ELSE
  lRet := -1         // �訡��: �� ����ᠭ ⨯ �������
ENDIF
RETURN lRet

*************************************************************
*  rest_arr - ���⠭������� ���ᨢ� �� 䠩�� �� ��᪥
*  rest_arr(cFileName,fl_NET)
*    cFileName - ��� 䠩��, � ���஬ ��࠭�� ���ᨢ.
*       fl_NET - �����᪮� ���祭�� (���뢠���� 䠩� � �� ��� ���)
*                �� 㬮�砭�� = .f.
*
*   ������: ���ᨢ
*            � ��砥 �訡�� - ���⮩ ���ᨢ.
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
      AADD(xMemVar, _ftrestsub(nHandle))  // ४��ᨢ�� �맮� ��� ���ᨢ�
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
*  saveNarr - ��࠭���� ���ᨢ�� � 䠩�� �� ��᪥
*  FUNCTION saveNarr(aArray, cFileName, number)
*       aArray - ���ᨢ, (�������� ��������) ᮤ�ঠ騩
*                ��� ⨯� ������,
*                ��� NIL, �᫨ �����뢠���� ��������� 䠩��
*    cFileName - ��� 䠩��.
*       number - ����� �����뢠����� ���ᨢ�,
*                ��� 0, �᫨ �����뢠���� ��������� 䠩��
***********************************
FUNCTION SaveNarr(aArray, cFileName, number)
LOCAL nHandle, lRet := -1, i := 0, fl_first := (aArray == NIL .or. number == 0)
if fl_first
  if file(cFileName)            // ��� �ࠢ��쭮� ࠡ��� � ��, �᫨ ���ᨢ
    do while ferase(cFileName) != 0 .and. i < 100  // ��࠭���� �� �ࢥ�
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
*  restNarr - ���⠭������� ���ᨢ�� �� 䠩�� �� ��᪥
*  restNarr(cFileName,number,fl_NET)
*    cFileName - ��� 䠩��, � ���஬ ��࠭�� ���ᨢ.
*       number - ����� �⠥���� ���ᨢ�
*       fl_NET - �����᪮� ���祭�� (���뢠���� 䠩� � �� ��� ���)
*                �� 㬮�砭�� = .f.
*
*   ������: ���ᨢ
*            � ��砥 �訡�� - ���⮩ ���ᨢ.
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
*  save_arr_mem(aArray) - ��࠭���� ���ᨢ� � ᨬ���쭮� ��६�����
*    aArray - ���ᨢ, (�������� ��������) ᮤ�ঠ騩 ��� ⨯� ������.
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
    cString := "�B�"
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
if cValType == "A"    // ४��ᨢ�� �맮� ��� ���ᨢ�
  for _i := 1 to nLen
    _ftsavesub_mem(xMemVar[_i],@sOut)
  next _i
else
  sOut += cString
endif
RETURN nil

*************************************************************
*  rest_arr_mem(sVar) - ���⠭������� ���ᨢ� �� ᨬ���쭮� ��६����� sVar
*   ������: ���ᨢ (� ��砥 �訡�� - ���⮩ ���ᨢ)
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
      AADD(xMemVar, _ftrestsub_mem(sVar))  // ४��ᨢ�� �맮� ��� ���ᨢ�
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
