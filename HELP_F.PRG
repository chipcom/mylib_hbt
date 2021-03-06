#include "fileio.ch"
#include "function.ch"
#include "inkey.ch"

*****   ��楤�� �����
PROCEDURE help(call_prg, line_num, input_var)
Local htext, w, w1, tmp_color, tek_row, tek_col, tek_sost, ;
      s_msg, block_up, block_down, fl_mouse := IS_MOUSE_ON_SCREEN()
Private titul := ""
IF help_code < 0
  RETURN
ENDIF
htext := helptext()
IF EMPTY(htext)
  RETURN
ENDIF
FT_MHIDECRS(fl_mouse)
//tek_sost := CSETALL()
SET KEY K_F1 TO
block_up := SETKEY(K_UP, NIL)
block_down := SETKEY(K_DOWN, NIL)
  tek_row := ROW() ; tek_col := COL()
  tmp_color := SETCOLOR(cHelpCMain)
  w := save_box(help_top, help_left, help_bottom+1, help_right+2)
  s_msg := " <Esc>-��室 � �ணࠬ��"+;
            if(mlcount(htext,60) <= help_bottom-help_top,;
                               " ", ";  - ��६�饭�� ⥪�� ")
  PUT_SHADOW(help_top, help_left, help_bottom, help_right)
  SCROLL(help_top, help_left, help_bottom, help_right, 0)
  @ help_top, help_left, help_bottom, help_right BOX "�͸���Գ"
  SETCOLOR(cHelpCTitle)
  @ help_top, help_left+(help_right-help_left-len(titul))/2 SAY titul
  SETCOLOR(cHelpCStatus)
  @ help_bottom, help_left+(help_right-help_left-len(s_msg)+1)/2 SAY s_msg
  SETCURSOR(0)
  SETCOLOR(cHelpCMain)
  MEMOEDIT(htext, help_top+1, help_left+2, help_bottom-1, help_right-1, .F.)
  rest_box(w)
  SETCOLOR(tmp_color)
  @ tek_row,tek_col SAY ""
SETKEY(K_UP, block_up)
SETKEY(K_DOWN, block_down)
SET KEY K_F1 TO help
//CSETALL(tek_sost)
FT_MSHOWCRS(fl_mouse)
RETURN

***** �⥭�� "��᪠" ⥪�� ����� �� 䠩�� name_help
FUNCTION helptext
LOCAL htbuf := "", htbuf1, n, n1, n2, l1, l2, help_fp, fname, fl_file
if type("pr_name_help") == "C"  // Private-��६����� � �ணࠬ��
  fname := pr_name_help  // ��� ������饣� help-䠩��
else
  fname := name_help  // ����⠭���� �� define �� 䠩�� function.ch
endif
fname := search_file(fname)
IF help_code >= 0 .AND. fname != NIL
  help_fp := FOPEN(fname, FO_READ + FO_SHARED)
  IF FERROR() == 0
    htbuf := SPACE(4) ; htbuf1 := SPACE(2)
    FREAD(help_fp, @htbuf, 4) ; n  := bin2l(htbuf) + help_code*12
    fseek(help_fp,n,0)
    FREAD(help_fp, @htbuf, 4) ; n1 := bin2l(htbuf)
    FREAD(help_fp, @htbuf1,2) ; l1 := bin2i(htbuf1)
    FREAD(help_fp, @htbuf, 4) ; n2 := bin2l(htbuf)
    FREAD(help_fp, @htbuf1,2) ; l2 := bin2i(htbuf1) - 1
    htbuf := space(l1); titul := space(l2)
    fseek(help_fp,n1,0) ; FREAD(help_fp, @htbuf, l1)
    fseek(help_fp,n2,0) ; FREAD(help_fp, @titul, l2)
  ENDIF
  FCLOSE(help_fp)
ENDIF
RETURN htbuf
