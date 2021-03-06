#include "set.ch"
#include "inkey.ch"
#include "function.ch"

*****
* ������ ��� ������ � 䠩�-�ࢥ� �� �६� ࠡ��� ��⥬�
* (���ਬ��, �ࠢ�筨��� - ��� ��७�� �� ��㣨� ���������)
* ����� ������� ���ᨢ� "arr" ����砥� ��� 䠩��:
* 1 - 䠩� �� �ࢥ�, 2 - �६���� 䠩� � ⥪�饬 ��⠫���
*****
Function DublArrDBF(arr)
Local i, adbf, fl_del, fl := .t., old_del := SET(_SET_DELETED, .F.)
for i := 1 to len(arr)
  if G_Use(arr[i,1],,"AA")
    adbf := dbstruct()
    dbcreate(arr[i,2],adbf)
    use (arr[i,2]) new alias BB
    select AA
    adbf := array(fcount())
    go top
    hGauge := GaugeNew(20,10,,"����஢���� 䠩�� "+StripPath(arr[i,1])+;
                       " ( "+lstr(i)+"/"+lstr(len(arr))+" )",.t.)
    GaugeDisplay( hGauge )
    do while !eof()
      GaugeUpdate( hGauge, recno()/ lastrec() )
      aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
      fl_del := deleted()
      select BB
      append blank
      aeval(adbf, {|x,i| fieldput(i,x) } )
      if fl_del
        delete
      endif
      select AA
      skip
    enddo
    close databases
    CloseGauge(hGauge)
  endif
  if !(fl := file(arr[i,2]))
    exit
  endif
next
SET(_SET_DELETED, old_del)
return fl
