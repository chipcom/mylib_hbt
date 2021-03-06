#include "inkey.ch"
#include "function.ch"

*****
Function rtf_create()
Static is_first := .t.
Static name_dbf := "dbf_rtf"
Static dbf_rl := {;
  {"rs_simv","C",1,0},;
  {"rt_simv","C",2,0};
 }
Static mas_rl := {{"�","c0"},;
                  {"�","c1"},;
                  {"�","c2"},;
                  {"�","c3"},;
                  {"�","c4"},;
                  {"�","c5"},;
                  {"�","c6"},;
                  {"�","c7"},;
                  {"�","c8"},;
                  {"�","c9"},;
                  {"�","ca"},;
                  {"�","cb"},;
                  {"�","cc"},;
                  {"�","cd"},;
                  {"�","ce"},;
                  {"�","cf"},;
                  {"�","d0"},;
                  {"�","d1"},;
                  {"�","d2"},;
                  {"�","d3"},;
                  {"�","d4"},;
                  {"�","d5"},;
                  {"�","d6"},;
                  {"�","d7"},;
                  {"�","d8"},;
                  {"�","d9"},;
                  {"�","da"},;
                  {"�","db"},;
                  {"�","dc"},;
                  {"�","dd"},;
                  {"�","de"},;
                  {"�","df"},;
                  {"�","a8"},;
                  {"�","e1"},;
                  {"�","e2"},;
                  {"�","e3"},;
                  {"�","e4"},;
                  {"�","e5"},;
                  {"�","b8"},;
                  {"�","e6"},;
                  {"�","e7"},;
                  {"�","e8"},;
                  {"�","e9"},;
                  {"�","e0"},;
                  {"�","ea"},;
                  {"�","eb"},;
                  {"�","ec"},;
                  {"�","ed"},;
                  {"�","ee"},;
                  {"�","ef"},;
                  {"�","f0"},;
                  {"�","f1"},;
                  {"�","f2"},;
                  {"�","f3"},;
                  {"�","f4"},;
                  {"�","f5"},;
                  {"�","f6"},;
                  {"�","f7"},;
                  {"�","f8"},;
                  {"�","f9"},;
                  {"�","fa"},;
                  {"�","fb"},;
                  {"�","fc"},;
                  {"�","fd"},;
                  {"�","fe"},;
                  {"�","ff"}}
Local i
if is_first  // ᮧ���� ���� ࠧ �� ��ࢮ� �맮��
  dbcreate(name_dbf,dbf_rl)
  use (name_dbf) new
  for i := 1 to len(mas_rl)
    append blank
    replace rs_simv with mas_rl[i,1],;
            rt_simv with mas_rl[i,2]
  next
  index on rs_simv to (name_dbf)
  use
  is_first := .f.
endif
use (name_dbf) index (name_dbf) new alias _RTF
return NIL

*****
Function rtf_close()
_rtf->(dbclosearea())
return NIL

*

*****
Function dos2rtf(txt_dos)
Local i, j, c, s1 := "", s2 := "", cur_asc
Local tmp_select := select(), len_str := len(txt_dos)
for i := 1 to len_str
  c := substr(txt_dos,i,1)
  cur_asc := ASC(c)
  if between(cur_asc,176,223)
    if between(cur_asc,176,182)     // |
      cur_asc := 124
    elseif between(cur_asc,183,184) // +
      cur_asc := 43
    elseif between(cur_asc,185,186) // |
      cur_asc := 124
    elseif between(cur_asc,187,194) // +
      cur_asc := 43
    elseif cur_asc == 195           // |
      cur_asc := 124
    elseif cur_asc == 196           // -
      cur_asc := 150
    elseif cur_asc == 197           // +
      cur_asc := 43
    elseif between(cur_asc,198,199) // |
      cur_asc := 124
    elseif between(cur_asc,200,203) // +
      cur_asc := 43
    elseif cur_asc == 204           // |
      cur_asc := 124
    elseif cur_asc == 205           // -
      cur_asc := 150
    elseif between(cur_asc,206,218) // +
      cur_asc := 43
    elseif cur_asc == 219           // |
      cur_asc := 124
    elseif cur_asc == 220           // _
      cur_asc := 95
    elseif between(cur_asc,221,222) // |
      cur_asc := 124
    elseif cur_asc == 223           // ~
      cur_asc := 126
    endif
    s1 += CHR(cur_asc)
  elseif between(cur_asc,242,255)
    s1 += " "
  elseif cur_asc == 123
    s1 += CHR(91)                   // [
  elseif cur_asc == 125
    s1 += CHR(93)                   // ]
  elseif c == "\"
    s1 += "\\"
  else
    select _RTF
    find (c)
    if found()
      s1 += "\'" + _rtf->rt_simv
    else
      s1 += c
    endif
  endif
next
select(tmp_select)
return s1
