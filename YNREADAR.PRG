#include 'function.ch'

//
function yn_Read_arhiv()
  Local buf, r1 := 6, r2 := 17, i, tmp_color := setcolor(color1)

  buf := box_shadow(r1, 5, r2, 74, , '�⥭�� १�ࢭ�� ����� � ��᪥��', 'W/B')
  setcolor(color8)
  str_center(r1 + 2, '�।�०�����!')
  str_center(r1 + 3, '��� ०�� �।�����祭 ��� �⥭�� � ��᪥�� १�ࢭ�� �����')
  str_center(r1 + 4, '��� ��� ������, ��࠭����� ࠭�� � ०��� "������ �� ��᪥��".')
  str_center(r1 + 5, '��᫥ ���⢥ত���� �⮣� ०��� �� ���� ������ � ⥪�饬')
  str_center(r1 + 6, '��⠫��� �� ���⪮� ��᪥ ���� �����, � ��⥬ � ��᪥��')
  str_center(r1 + 7, '���� ��⠭� ���� ���� ������.')
  mark_keys({'"������ �� ��᪥��"'}, 'G+/B')
  setcolor(color1)
  str_center(r2 - 2, '�롥�� ����⢨�:')
  setmtcolor('BG+/B, W+/R, GR+/B, GR+/R')
  @ r2 - 1, 15 prompt ' ~�⪠� �� ����樨 '
  @ r2 - 1, 36 prompt ' ~���⢥ত���� ����஢���� '
  menu to i
  setcolor(tmp_color)
  rest_box(buf)
  return (i == 2)
