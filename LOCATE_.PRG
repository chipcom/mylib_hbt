#include "function.ch"

***** Locate � ������� ��宦����� ����� ��ꥪ⮬ GAUGE
PROCEDURE dbLocateProgress( bFor, bWhile,              ;
                            nNext, nRec, lRest,        ;
                            lProcent, nRow, nCol, cColor ;
                          )
LOCAL hGauge
// �������� ��ꥪ� - ���� �⮡ࠦ���� �����
hGauge := GaugeNew(nRow,nCol,cColor,"... ���� ...",lProcent)
GaugeDisplay( hGauge )
/* �맮��� �⠭������ �㭪��: */
IF ( bWhile != NIL )
  __dbLocate( bFor,                                    ;
      { ||      ;// ���� ���� ��� �஢�ન �᫮���
        GaugeUpdate( hGauge, recno()/lastRec() ),;// �⮡ࠧ��� ���ﭨ�
        Eval( bWhile )                         ;
      },        ;// ���᫨�� ���祭��
      nNext, nRec, lRest                       ;
    )
ELSE
  __dbLocate( bFor,                                    ;
      { ||      ;// ���� ���� ��� �஢�ન �᫮���
        GaugeUpdate( hGauge, recno()/lastRec() ),;// �⮡ࠧ��� ���ﭨ�
        ( .T. )                                ;
      },        ;// �த������ �ᥣ��
      nNext, nRec, lRest                       ;
    )
ENDIF
CloseGauge(hGauge)               // ���஥� ���� �⮡ࠦ����
RETURN NIL
