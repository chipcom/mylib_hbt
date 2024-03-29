#include 'function.ch'
#include 'edit_spr.ch'

//
Function verify_sprav(_fname)
  Local arr := {}, hGauge, smes, cMessage

  smes := '�஢�ઠ �� 楫��⭮��� �ࠢ�筨�� ' + upper(_fname)
  hGauge := GaugeNew( , , , smes, .t.)
  GaugeDisplay( hGauge )
  G_Use(dir_server + _fname, , '_VS')
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno() / lastrec() )
    if _vs->kod > 0 .and. _vs->kod != recno() .and. len(arr) < 4000
      aadd(arr, recno())
    endif
    skip
  enddo
  CloseGauge(hGauge)
  _vs->(dbCloseArea())
  if len(arr) > 0
    cMessage := dtoc(date()) + '  ' + sectotime(seconds()) + '  ' + StripPath(exename()) + eos
    cMessage += smes + eos
    aeval(arr, {|x| cMessage += '- ������ ����� ' + lstr(x) + eos})
    cMessage += replicate('*', 79) + eos
    strfile(cMessage, dir_server + 'error.txt', .t.)
    n_message({smes, '� � � � � �', '��室 �� �����!'}, , cColorStMsg, cColorSt2Msg, , , 'BG+/R')
    f_end()
  endif
  return NIL
