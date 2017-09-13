#include "function.ch"

***** конвертирует WINDOWS-строку в DOS-строку
Function win2dos(win_str)
Local dos_str := win_ANSIToOEM(win_str)
/*Local len_str, i, cur_char, dos_str := ""
len_str := len(win_str)
for i := 1 to len_str
  cur_asc := ASC(substr(win_str,i,1))
  do case
    case between(cur_asc,192,239)
      cur_asc := cur_asc - 64
    case between(cur_asc,240,255)
      cur_asc := cur_asc - 16
    case cur_asc == 168
      cur_asc := 240
    case cur_asc == 184
      cur_asc := 241
    case cur_asc == 185
      cur_asc := 252
  end case
  dos_str += CHR(cur_asc)
next*/
return dos_str

***** конвертирует DOS-строку в WINDOWS-строку
Function dos2win(dos_str)
Local win_str := win_OEMToANSI(dos_str)
/*Local len_str, i, cur_char, win_str := ""
len_str := len(dos_str)
for i := 1 to len_str
  cur_asc := ASC(substr(dos_str,i,1))
  do case
    case between(cur_asc,128,175)
      cur_asc := cur_asc + 64
    case between(cur_asc,176,223)
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
    case between(cur_asc,224,239)
      cur_asc := cur_asc + 16
    case cur_asc == 240
      cur_asc := 168
    case cur_asc == 241
      cur_asc := 184
    case cur_asc == 252
      cur_asc := 185
  end case
  win_str += CHR(cur_asc)
next*/
return win_str
