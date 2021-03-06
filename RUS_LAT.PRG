// ����� �㭪樨 ���筮 ��-�� ��� ᮧ����� ����� 䠩�� �� ���᪮� ���ॢ�����
// rus_lat() - �८�ࠧ������ ���᪮� ��ப� � ��⨭���
//             ���ਬ��: "���������" ==> "VOLGOGRAD"

#include "function.ch"

Static mas_rl := {{"�","A"},;
                  {"�","B"},;
                  {"�","V"},;
                  {"�","G"},;
                  {"�","D"},;
                  {"�","E"},;
                  {"�","W"},;
                  {"�","Z"},;
                  {"�","I"},;
                  {"�","J"},;
                  {"�","K"},;
                  {"�","L"},;
                  {"�","M"},;
                  {"�","N"},;
                  {"�","O"},;
                  {"�","P"},;
                  {"�","R"},;
                  {"�","S"},;
                  {"�","T"},;
                  {"�","U"},;
                  {"�","F"},;
                  {"�","H"},;
                  {"�","C"},;
                  {"�","Q"},;
                  {"�","X"},;
                  {"�","~"},;
                  {"�","!"},;
                  {"�","Y"},;
                  {"�","@"},;
                  {"�","#"},;
                  {"�","$"},;
                  {"�","&"}}

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
