#include "inkey.ch"
#include "function.ch"

*****
Function need_index(blk)
Local i, k, arr_f := {}
Local fl := .f., buf, r1 := 8, r2 := 17
if valtype(blk) != "B"
  err_msg("������ �맮� �㭪樨 Need_Index()")
endif
scanfiles("", "*.", {| x | aadd(arr_f,x) } )
k := len(arr_f)
for i := k to 1 step -1
  if filesize(arr_f[i],32) != 0
    adel(arr_f,i) ; k--
  endif
next
if k > 0
  set cursor off
  FillScreen(p_char_screen,p_color_screen)
  buf := box_shadow(r1,5,r2,74,,"�।�०�����!",color8)
  setcolor(color8)
  str_center(r1+2,"��᫥���� ࠧ �� ��室� �� ����� �� ᡮ� �� ��⠭��.")
  str_center(r1+3,"��᫥ ���⢥ত���� �⮣� ०��� �� ���� ������")
  str_center(r1+4,"���� ��२�����஢���, �.�. ������ ����⭮, ��")
  str_center(r1+5,"������� ������� 䠩�� �뫨 �ᯮ�祭� ��� ࠧ��襭�.")
  setcolor(color1)
  str_center(r2-2,"�롥�� ����⢨�:")
  setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
  @ r2-1,13 prompt " ~��室 �� ����� "
  @ r2-1,32 prompt " ~���⢥ত���� ��२�����஢���� "
  i := 2
  menu to i
  fl := (i == 2)
  setcolor(color0)
  if i == 2
    eval(blk)
    for i := 1 to k
      delete file (arr_f[i])
    next
  else
    f_end()
  endif
  FillScreen(p_char_screen,p_color_screen)
  setcolor(color0)
endif
return NIL
