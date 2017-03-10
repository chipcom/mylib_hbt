// Данные функции обычно исп-ся для создания имени файла по русской аббревиатуре
// rus_lat() - преобразование русской строки в латинскую
//             например: "ВОЛГОГРАД" ==> "VOLGOGRAD"

#include "function.ch"

Static mas_rl := {{"А","A"},;
                  {"Б","B"},;
                  {"В","V"},;
                  {"Г","G"},;
                  {"Д","D"},;
                  {"Е","E"},;
                  {"Ж","W"},;
                  {"З","Z"},;
                  {"И","I"},;
                  {"Й","J"},;
                  {"К","K"},;
                  {"Л","L"},;
                  {"М","M"},;
                  {"Н","N"},;
                  {"О","O"},;
                  {"П","P"},;
                  {"Р","R"},;
                  {"С","S"},;
                  {"Т","T"},;
                  {"У","U"},;
                  {"Ф","F"},;
                  {"Х","H"},;
                  {"Ц","C"},;
                  {"Ч","Q"},;
                  {"Ш","X"},;
                  {"Щ","~"},;
                  {"Ъ","!"},;
                  {"Ы","Y"},;
                  {"Ь","@"},;
                  {"Э","#"},;
                  {"Ю","$"},;
                  {"Я","&"}}

*****
Function rus_lat(s)
Local i, j, c, s1 := ""
s := upper(s)
for i := 1 to len(s)
  c := substr(s,i,1)
  if (j := ascan(mas_rl, {|x| x[1] == c})) > 0
    c := mas_rl[j,2]
  endif
  s1 += c
next
return s1

*****
Function cre_name_file(s,n)
Local i, s1 := "", nc
DEFAULT n TO 8
s := upper(rus_lat(alltrim(charone(" ",s))))
n := min(n,len(s))
for i := 1 to n
  c := substr(s,i,1) ; nc := asc(c)
  if !(between(nc,48,57) .or. between(nc,65,90))
    c := "_"
  endif
  s1 += c
next
return s1
