#include "function.ch"

***** ����⨥ 䠩�� ���� ������ � �� ������ ��� ������
FUNCTION R_Use( cFile, cIndices, cAlias, lTryForever, lExcluUse)
return G_Use( cFile, cIndices, cAlias, lTryForever, lExcluUse, .T.)

***** �������쭮� ����⨥ 䠩�� ���� ������
FUNCTION E_Use( cFile, cIndices, cAlias)
return G_Use( cFile, cIndices, cAlias, , .T.)

***** ����⨥ 䠩�� ���� ������ � ��
FUNCTION G_Use( cFile, cIndices, cAlias, lTryForever, lExcluUse, lREADONLY )
// cFile - 䠩� ��
// cIndices - ᯨ᮪ �����ᮢ (��� ��ப� � ��砥 ������ ������)
// cAlias - ��ப� �����
// lTryForever - �����᪠� ����稭� (.T. - ������� ��᪮��筮)
// lExcluUse - �����᪠� ����稭� (.T. - �������쭮� ����⨥ ��)
// lREADONLY - �����᪠� ����稭� (.T. - ����⨥ �� ⮫쪮 ��� �⥭��)
LOCAL cMessage, lRetValue, UpcFile, c1Array := {"��������� ᭮��"}, cArray
if ".DBF" == Upper(right(cFile,4))
  cFile := substr(cFile,1,len(cFile)-4)
endif
UpcFile := StripPath(cFile)
// �⮡� �� 䠩�� � ������ ���㫥 ���뢠���� ⮫쪮 ��� �⥭��,
// ��।���� PRIVATE-��६������ "PRIVATE use_readonly := .T."
if lREADONLY == NIL .and. type("use_readonly") == "L" .and. use_readonly
  lREADONLY := .t.
endif
DEFAULT cIndices TO {}, cAlias TO UpcFile, lTryForever TO .F., ;
        lExcluUse TO .F., lREADONLY TO .f.
IF !FILE(cFile + ".DBF") // �஢�ઠ �� ����稥 䠩��
  cMessage := "������: ���� "+UpcFile+" �� �������!"
  cMessage += ";������ �४�饭�"
  ALERT(cMessage,{"��������"},color0)
  lRetValue := .F.
ELSE
  // ����⪨ ������ ���� ������ �� �ᯥ� ��� �⪠��
  DO WHILE lRetValue == NIL
    dbUseArea( .T.,;          // new
               , ;            // rdd
               cFile, ;       // db
               cAlias, ;      // alias
               !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
               lREADONLY, ;   // readonly
               "RU866")
    IF !NETERR()
      if EMPTY(cIndices)  // ��� �����ᮢ �� �맮�� �-��
        lRetValue := .T.
        DbClearIndex()  // �� ࠢ�� ������� - ��� FOXPRO
      elseif !(lRetValue := G_Index(cIndices))
        Use  // ������� �� �� ������⢨� ������(��)
      endif
    ELSE
      IF !lTryForever
        cMessage := "���������� ������ 䠩� "+UpcFile
        cMessage += ";�� ����� ��㣨� ���짮��⥫��"
        cArray := aclone(c1Array)
        aadd(cArray,"��������")
        IF ALERT(cMessage,cArray,color0) != 1
          lRetValue := .F.
        ENDIF
      ENDIF
    ENDIF
  ENDDO
ENDIF
RETURN (lRetValue)
