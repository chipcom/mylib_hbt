#include "function.ch"

***** �뢮� ���� � ᮮ�饭��� � �����६����� ࠡ�� � MENU TO
FUNCTION F_ALERT(cLine,;      // ���ᨢ ��ப ᮮ�饭��
                 cChoice,  ;  // ���ᨢ �롮஢ ����
                 nDef,     ;  // �롮� �� 㬮�砭��
                 cBorColor,;  // ��ப� 梥� ��� ࠬ��
                 cBoxColor,;  // ��ப� 梥� ��� ⥪��
                 nStartRow,;  // ���孨� �� ࠬ�� (99 - 業��஢���)
                 nStartCol,;  // ����� ������� ࠬ�� (99 - 業��஢���)
                 cMenuColor)  // 梥� ���� (�� 㬮�砭�� - �� ��⠭����������)
LOCAL nLLen, cOldColor, nLCol, nRCol, nTRow, nBRow, cSayStr, ;
      nSayRow, nSayCol, nNumRows, i, nAllLen := 0, nLCh, ;
      icur := SetCursor(0), buf_box := savescreen(), ;
      nMaxRow := maxrow(), nMaxCol := maxcol()
nLLen := int((nMaxCol+1)/2)
// ��।������ ��ࠬ��஢ �� 㬮�砭��
DEFAULT nDef TO 1
cBorColor := if(ischar(cBorColor),   cBorColor, color0)
cBoxColor := if(ischar(cBoxColor),   cBoxColor, color0)
nStartRow := if(isnumber(nStartRow), nStartRow, 99)
nStartCol := if(isnumber(nStartCol), nStartCol, 99)
cLine     := if(isarray(cLine),      cLine,     {cLine})
AEVAL( cChoice, {|x,i| nAllLen += (LEN(charrem("~",cChoice[i]))+1) })
Dec( nAllLen )
nNumRows := Min(len(cLine),8) // �.�. ���ᨬ� 8 ��ப � ���ᨢ�
cLine := asize(cLine,nNumRows)
aeval(cLine, {|x,i| cLine[i] := AllTrim(Left(x,74))})
aeval(cLine, {|x,i| nLLen := Max(nLLen,Len(x))})
// ���᫥��� ���न��� 㣫��
nLCol := if(nStartCol==99,Int((nMaxCol-3-nLLen)/2),Min(nStartCol,nMaxCol-5-nLLen))
nRCol := nLCol+nLLen+3
nTRow := if(nStartRow==99,INT((nMaxRow-nNumRows)/2),Min(nStartRow,nMaxRow-2-nNumRows))
nBRow := nTRow+nNumRows+2
nLCh := nLCol + INT((nRCol - nLCol - 1 - nAllLen)/2) + 1

cOldColor := SetColor(cBoxColor)
box_shadow(nTRow,nLCol,nBRow,nRCol,cBorColor)
aeval(cLine, { |cSayStr,i|;
               nSayRow := nTRow+i,;
               nSayCol := nLCol+2+(nLLen-Int(Len(cSayStr)))/2,;
               setpos(nSayRow,nSayCol), dispout(cSayStr);
             })
set cursor off
if cMenuColor != NIL
  setmtcolor(cMenuColor)
endif
@ nBRow-1, nLCh PROMPT cChoice[1]
FOR i := 2 TO LEN(cChoice)
  @ nBRow-1, (nLCh := nLCh+LEN(cChoice[i-1])+1) PROMPT cChoice[i]
NEXT
MENU TO nDef
restscreen(buf_box)
SetColor(cOldColor)
if icur > 0
  SETCURSOR()
endif
RETURN nDef
