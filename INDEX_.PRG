#include "function.ch"

***** 21.04.15 индексирование с показом прохождения процесса объектом GAUGE
FUNCTION db1IndexProgress( cfor, bfor, ;
                           lall, ;
                           bwhile, ;
                           beval, nevery, ;
                           _1, nnext, nrec, ;
                           lrest, ldescend, ;
                           cOrderBagName, cOrderName, ;
                           ckey, bkey, lunique, ;
                           lProcent, nRow, nCol, cColor )
Static name_file := ""
LOCAL hGauge, c1name := "", ccount := 0, clen := lastrec(), buf
if cOrderBagName != NIL
  name_file := StripPath(cOrderBagName)
endif
c1name := name_file
if cOrderName != NIL
  c1name += "/"+cOrderName
endif
c1name := upper(c1name)
if clen < 1000 // создание индекса без Gauge
  buf := box_shadow(20,10,22,69,color0)
  str_center(21,"Создание индекса "+c1Name,color0)
  ordCondSet(  cfor, bfor, ;
               lall, ;
               bwhile, ;
               beval, nevery, ;
               RECNO(), nnext, nrec, ;
               lrest, ldescend )
  ordCreate( cOrderBagName, cOrderName, ;
             ckey, bkey, lunique )
  rest_box(buf)
else
  nevery := 1
  do while clen > 100
    clen := int(clen/10)
    nevery *= 10
  enddo
  beval := {|| GaugeUpdate( hGauge, ++ccount/clen ), .t. }
  // Создадим объект - окно отображения процесса
  hGauge := GaugeNew(nRow,nCol,cColor,"Создание индекса "+c1Name,lProcent)
  GaugeDisplay( hGauge )
  ordCondSet(  cfor, bfor, ;
               lall, ;
               bwhile, ;
               beval, nevery, ;
               RECNO(), nnext, nrec, ;
               lrest, ldescend )
  ordCreate( cOrderBagName, cOrderName, ;
             ckey, bkey, lunique )
  CloseGauge(hGauge)               // Закроем окно отображения
endif
return NIL
