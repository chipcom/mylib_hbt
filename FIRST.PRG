#include "inkey.ch"

*****
FUNCTION f_first()

Public sys_date := DATE()
Public cur_dir := ""//GetStartupFolder()

REQUEST HB_CODEPAGE_RU866
HB_CDPSELECT("RU866")
REQUEST HB_LANG_RU866
HB_LANGSELECT("RU866")

REQUEST DBFNTX
RDDSETDEFAULT("DBFNTX")

SET SCOREBOARD OFF
SET EXACT ON
SET DATE GERMAN
SET WRAP ON
SET CENTURY ON
SET EXCLUSIVE ON
SET DELETED ON
setblink(.f.)

PUBLIC help_code := -1, nhelp_code := ""
PUBLIC help_top := 7
PUBLIC help_left := 13
PUBLIC help_bottom := 18
PUBLIC help_right := 66

PUBLIC color0, color1, cColorWait, cColorStMsg, cColorSt2Msg,  ;
       cCalcMain, cHelpCMain, cHelpCVagno, cColorText,     ;
       cHelpCTitle, cHelpCStatus, cDataCScr, cDataCGet, cDataCSay,    ;
       cDataCMenu, color13, cColorSt1Msg, cDataPgDn,      ;
       color5,color8,col1menu:="",col2menu:=""
Public forever := "forever"
Public n_list := 1, tek_stroke := 0, fp, c__cw := "W/N"  // цвет теней
Public p_color_screen := "W/N*", p_char_screen := " "
color0  := "N/BG,W+/N"
color1  := "W+/B,W+/R"
col1menu := color0+",B/BG,BG+/N"
col2menu := color0+",B/BG,BG+/N"

cColorStMsg := "W+/R,,,,B/W"                  //    Stat_msg
cColorSt1Msg:= "W+/R,,,,B/W"                //    Stat_msg
cColorSt2Msg:= "GR+/R,,,,B/W"                //    Stat_msg
cColorWait  := "W+/R*,,,,B/W"                 //    Ждите

cCalcMain   := "N/W,GR+/R"             //    Калькулятор

cColorText  := "W+/N,BG+/N,,,B/W"

cHelpCMain  := "N/BG,W+/N"              //    Помощь
cHelpCVagno := "R/BG,W+/R"              //    выделение в экране помощи
cHelpCTitle := "BG+/N"
cHelpCStatus:= "6/3"

                                              //     Ввод данных
cDataCScr   := "W+/B,B/BG"              // 1
cDataCGet   := "W+/B,W+/R,,,BG+/B"            // 1_1
cDataCSay   := "BG+/B,W+/R,,,BG+/B"           // 11
cDataCMenu  := "N/BG,W+/N,,,B/W"              // 0
cDataPgDn   := "G+/B"
color5      := "N/W,GR+/R"
color8      := "GR+/B,W+/R"
color13     := "BG+/RB,W+/R,,,BG+/B"          // некотоpое выделение

Public exe_dir := exename()  // каталог запуска задачи
if "\" $ exe_dir
  exe_dir := substr(exe_dir,1,RAT("\",exe_dir))
else
  exe_dir := ""
endif
Public dir_server := "", p_name_comp := ""

SET KEY K_ALT_F3 TO calendar
SET KEY K_ALT_F2 TO calc
SET KEY K_ALT_X TO f_end
READINSERT(.T.)        // режим редактирования по умолчанию Insert
KEYBOARD ""
ksetnum(.t.)
SETCURSOR(0)
SETCLEARB(" ")
SET COLOR TO
RETURN NIL
