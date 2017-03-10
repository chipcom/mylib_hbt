#include "function.ch"

***** Locate с показом прохождения процесса объектом GAUGE
PROCEDURE dbLocateProgress( bFor, bWhile,              ;
                            nNext, nRec, lRest,        ;
                            lProcent, nRow, nCol, cColor ;
                          )
LOCAL hGauge
// Создадим объект - окно отображения процесса
hGauge := GaugeNew(nRow,nCol,cColor,"... Поиск ...",lProcent)
GaugeDisplay( hGauge )
/* Вызовем стандартную функцию: */
IF ( bWhile != NIL )
  __dbLocate( bFor,                                    ;
      { ||      ;// Блок кода для проверки условия
        GaugeUpdate( hGauge, recno()/lastRec() ),;// Отобразить состояние
        Eval( bWhile )                         ;
      },        ;// Вычислить значение
      nNext, nRec, lRest                       ;
    )
ELSE
  __dbLocate( bFor,                                    ;
      { ||      ;// Блок кода для проверки условия
        GaugeUpdate( hGauge, recno()/lastRec() ),;// Отобразить состояние
        ( .T. )                                ;
      },        ;// Продолжать всегда
      nNext, nRec, lRest                       ;
    )
ENDIF
CloseGauge(hGauge)               // Закроем окно отображения
RETURN NIL
