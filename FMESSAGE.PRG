#include 'inkey.ch'
#include 'function.ch'

** 27.03.17 �뢮� ��אַ㣮�쭨�� � ᮮ�饭���
FUNCTION F_MESSAGE(cLine,;      // ���ᨢ ��ப (���ᨬ� 8 ��ப)
                   cRetWait, ;  // "W" - ����� ������ �� ������ (���� - ᪮�쪮 ᥪ㭤)
                   cBorColor,;  // ��ப� 梥� ��� ࠬ��
                   cBoxColor,;  // ��ப� 梥� ��� ⥪��
                   nStartRow,;  // ���孨� �� ࠬ�� (99 - 業��஢���)
                   nStartCol,;  // ����� ������� ࠬ�� (99 - 業��஢���)
                   fl_runstr,;  // ��᫥���� ��ப� ������ ��� ���
                   cRunColor)   // ��ப� 梥� ��� ����饩 ��ப�
  LOCAL nLLen := 40, cOldColor, nLCol, nRCol, nTRow, nBRow, cSayStr, ;
      nSayRow, nSayCol, nNumRows, buf, icur := SetCursor(0), count_s, ;
      ndelay := 0, cMaxRow := maxrow(), cMaxCol := maxcol()

  // ��।������ ��ࠬ��஢ �� 㬮�砭��
  cRetWait  := iif(ischar(cRetWait),   Upper(cRetWait), '')
  cBorColor := iif(ischar(cBorColor),  cBorColor,       color0)
  cBoxColor := iif(ischar(cBoxColor),  cBoxColor,       color0)
  nStartRow := iif(isnumber(nStartRow),nStartRow,       99)
  nStartCol := iif(isnumber(nStartCol),nStartCol,       99)
  cLine     := iif(isarray(cLine),     cLine,           {cLine})
  fl_runstr := iif(islogic(fl_runstr), fl_runstr,       .f.)
  // �᫨ ����� �㪢� "W" ��ன ��ࠬ��� - ��� (� ����窠�)
  if !empty(cRetWait) .and. !(cRetWait == 'W')
    ndelay := val(cRetWait)
    cRetWait := 'W'
  endif

  nNumRows := Min(len(cLine), 8)
  cLine := asize(cLine, nNumRows)
  aeval(cLine, {|x, i| cLine[i] := AllTrim(Left(x, cMaxCol - 5))})
  aeval(cLine, {|x, i| nLLen := Max(nLLen, Len(x))})
  // ���᫥��� ���न��� 㣫��
  nLCol := if(nStartCol == 99, Int((cMaxCol - 3 - nLLen) / 2), Min(nStartCol, cMaxCol - 5 - nLLen))
  nRCol := nLCol + nLLen + 3
  nTRow := if(nStartRow == 99, INT((cMaxRow - nNumRows) / 2), Min(nStartRow, cMaxRow - 2 - nNumRows))
  nBRow := nTRow + nNumRows + 1
  count_s := len(cLine)
  if fl_runstr
    Dec( count_s )
  endif

  cOldColor := SetColor(cBoxColor)
  buf := save_box(nTRow, nLCol, nBRow + 1, nRCol + 2)
  PUT_SHADOW(nTRow, nLCol, nBRow, nRCol)
  @ nTRow, nLCol Clear to nBRow, nRCol
  DispBox(nTRow, nLCol, nBRow, nRCol, 2, cBorColor)
  aeval(cLine, { |cSayStr, i| nSayRow := nTRow + i, nSayCol := nLCol + 2 + (nLLen - Int(Len(cSayStr))) / 2, ;
                           setpos(nSayRow, nSayCol), dispout(cSayStr) ;
              }, 1, count_s)
  set cursor off
  IF cRetWait == 'W'
    mybell(0.1, OK)
    if fl_runstr
      setcolor(cRunColor)
      nLLen := RUNSTR(atail(cLine), nTRow + count_s + 1, nLCol + 1, nRCol - 1)
    else
      nLLen := Inkey_Mouse(ndelay)
    endif
    rest_box(buf)
  ENDIF
  SetColor(cOldColor)
  if icur > 0
    SETCURSOR()
  endif
  RETURN nLLen
