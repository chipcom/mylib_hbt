#include 'function.ch'
#include 'inkey.ch'

// 18.08.13 �뢮� ����᭮� ��ப� (��᫥���� ��ப�, ���� 梥�)
FUNCTION stat_msg(s, fl)
  LOCAL tmp_color := SETCOLOR()

  DEFAULT fl TO .t. // "ࠧ���稢������" ��ப�
  if type('cColorSt2Msg') != 'C'
    Public cColorSt2Msg := cColorStMsg
  endif
  SETCOLOR(cColorStMsg)
  if len(s) > maxcol() + 1
    s := left(s, maxcol() + 1)
  endif
  if fl
    @ maxrow(), 0
    str_center(maxrow(), alltrim(s))
  else
    @ maxrow(), 0 say padc(s, maxcol() + 1)
  endif
  @ 2,0 say ''
  SETCOLOR(tmp_color)
  SETCURSOR(0)
  RETURN NIL

// 18.08.13 �뢮� ᮮ�饭�� �� ��������
FUNCTION MyWait(s)

  DEFAULT s TO '��������, ࠡ��� ...'
  if len(s) > maxcol() + 1
    s := left(s, maxcol() + 1)
  endif
  @ maxrow(), 0 say padc(s, maxcol() + 1) color cColorWait
  @ 2,0 say ''
  RETURN NIL
