#include "inkey.ch"
#include "function.ch"

*****
Function hard_err(p)
// k = 1 - �஢�ઠ ��᪠ �� ����稥 �६������ 䠩�� hard_err.meh
//         �, �᫨ �� ����, �뢮� ⥪�� � ����室����� ��२�����஢����;
//         ᮧ����� �६������ 䠩�� hard_err.meh "CREATE"
// k = 2 - 㤠����� �६������ 䠩�� hard_err.meh "DELETE"
Local k := 3, arr := {}
if valtype(p) == "N"
  k := p
elseif valtype(p) == "C"
  p := upper(p)
  do case
    case p == "CREATE"
      k := 1
    case p == "DELETE"
      k := 2
  endcase
endif
do case
  case k == 1
    if file("hard_err.meh")
      FillScreen(p_char_screen,p_color_screen)
      aadd(arr,"1. ������ ����⭮, �� �� �����⨫� ������ ����� �����!")
      aadd(arr,"� �⮬ ��砥 �멤�� �� �����.")
      aadd(arr,". . .")
      aadd(arr,"2. ��᫥���� ࠧ �� ��室� �� ����� �� ᡮ� �� ��⠭��.")
      aadd(arr,"� �⮬ ��砥 ��� �����⥫쭮 ४��������� �믮�����")
      aadd(arr,'०�� "��२�����஢����", �.�. ������ ����⭮, ��')
      aadd(arr,"������� ������� 䠩�� �뫨 �ᯮ�祭� ��� ࠧ��襭�.")
      keyboard ""
      f_message(arr,,color1,color8,,,color1)
      if f_alert({padc("�롥�� ����⢨�",60,".")},;
               {" ��室 �� ����� "," �த������� ࠡ��� "},;
               1,"W+/N","N+/N",20,,"W+/N,N/BG" ) != 2
        SET COLOR TO
        SET CURSOR ON
        CLS
        QUIT
      endif
      FillScreen(p_char_screen,p_color_screen)
    endif
    strfile("hard_error","hard_err.meh")
  case k == 2
    delete file hard_err.meh
endcase
return NIL
