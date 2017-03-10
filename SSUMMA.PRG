#include "function.ch"

***** вывести в текстовом виде сумму в руб.
function srub(n)
Local i, s, s1
if valtype(n) == "N"
  n := str(n,19,2)
endif
s := ssumma(n) + " руб."
return s

***** вывести в числовом виде сумму в руб. и коп.
function nrub_kop(n)
Local s := lstr(n,19,2)
return beforatnum(".",s)+" руб. "+afteratnum(".",s)+" коп."

***** вывести в текстовом виде сумму в руб. и коп.
function srub_kop(n,fl)
Local i, s, s1
DEFAULT fl TO .f.
s := ssumma(n)+" "
if fl
  s := upper(left(s,1))+substr(s,2)+rublej(n)
else
  s += "руб."
endif
if valtype(n) == "N"
  n := str(n,19,2)
endif
if (i := at(".",n)) > 0
  n += "00"
  s1 := substr(n, i+1, 2)
elseif !(left(right(n,3),1) $ "0123456789")
  s1 := right(n,2)
else
  s1 := "00"
endif
if fl
  s1 += " "+kopeek(s1)
else
  s1 += " коп."
endif
return s + " " + s1

***** вывести в текстовом виде число n
function ssumma(n,r,fl_upper)
// r - род ("м", "ж" или "с")
local k := 0, t := "", s, l, msign := ""
DEFAULT r TO "м", fl_upper TO .f.
if valtype(n) == "C"
  n := val(n)
endif
n := int(n)
s := lstr(n,15,0)
if left(s,1) == "-"
  msign := "минус " ; s := substr(s,2)
endif
Private rod_m_w := lower(r)
if n == 0
  return "нуль"
endif
do while .t.
  l := len(s)
  ++k
  t := ssummaF(right(s,3),k)+t
  if l <= 3
    exit
  endif
  s := left(s,l-3)
enddo
t := alltrim(t)
if fl_upper
  t := upper(left(t,1))+substr(t,2)
endif
return msign + t

***** вывести в текстовом виде число s (женский род)
function ssumma_g(s)
return ssumma(s,"ж")

*****
Static function ssumma2(ch)
local n := int(val(ch)),;
      mas := {"десять", "одиннадцать", "двенадцать", "тринадцать",;
              "четырнадцать", "пятнадцать", "шестнадцать",;
              "семнадцать", "восемнадцать", "девятнадцать"}
return " "+mas[n+1]

*****
Static function ssumma20(ch)
local n := int(val(ch)),;
      mas := {"двадцать", "тридцать", "сорок", "пятьдесят",;
              "шестьдесят", "семьдесят", "восемьдесят",;
              "девяносто"}
return " "+mas[n-1]

*****
Static function ssumma3(ch,m)
local n := int(val(ch)),;
      mas := {"один", "два", "три", "четыре", "пять",;
              "шесть", "семь", "восемь", "девять"}
if m == 2 .or. (m == 1 .and. rod_m_w == "ж")
  mas[1] := "одна"
  mas[2] := "две"
elseif m == 1 .and. rod_m_w == "с"
  mas[1] := "одно"
endif
return " "+mas[n]

*****
Static function ssumma1(ch)
local n := int(val(ch)),;
      mas := {"сто", "двести", "триста", "четыреста","пятьсот",;
              "шестьсот", "семьсот", "восемьсот", "девятьсот"}
return " "+mas[n]

*****
Static function ssummaN(kk, n3, flag)
local mast := {"тысяча", "тысячи", "тысяч"},;
      masM := {"миллион", "миллиона", "миллионов"},;
      masB := {"миллиард", "миллиарда", "миллиардов"},;
      i := 3, s := " "
if !flag
  if n3 == 1
    i := 1
  elseif n3 < 5
    i := 2
  endif
endif
do case
  case kk == 1
    s += masT[i]
  case kk == 2
    s += masM[i]
  case kk == 3
    s += masB[i]
endcase
return s

******
Static function ssummaF(s,k)
local fl := .t., l := len(s), t := "", s1 := " ", s2 := " ",;
      s3 := right(s,1)
if l > 1
  s2 := left(right(s,2),1)
endif
if l > 2
  s1 := left(s,1)
endif
if s2 == "1"
  t := ssumma2(s3)
elseif s3 == "0"
  if s2 != "0"
    t := ssumma20(s2)
  endif
else
  t := ssumma3(s3,k)
  fl := .f.
  if s2 != "0" .and. s2 != " "
    t := ssumma20(s2)+t
  endif
endif
if s1 != " " .and. s1 != "0"
  t := ssumma1(s1)+t
endif
if k > 1 .and. !(s1 == "0" .and. s2 == "0" .and. s3 == "0")
  t += ssummaN(k-1,int(val(s3)),fl)
endif
return t
