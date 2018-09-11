#include "function.ch"

***** превратить строку s1 в отформатированный абзац шириной ll
Function para_format(s1,ll,r_margin)
// r_margin - выравнивать (не выравнивать) по правой границе
Local ss := "", i, j, k, l, ll1 := ll, mn, kol, first_space, ;
      t_len, t := {}, tmp, b1, b2, b, tmp_len
DEFAULT r_margin TO .t.
if right(s1,2) == eos
  s1 := substr(s1,1,len(s1)-2)
endif
if empty(s1 := rtrim(s1))
  aadd(t,"")
else
  do while !empty(s1)
    if (tmp_len := len(s1)) <= ll
      aadd(t,s1)
      exit
    else
      if substr(s1,ll+1,1) == " " .or. substr(s1,ll,1) == "-"
        aadd(t,left(s1,ll))
        s1 := ltrim(substr(s1,ll+1))
      elseif substr(s1,ll,2) == "__"
        b1 := .f.
        for i := ll to ll-5 step -1
          if substr(s1,i,1) == " "
            b1 := .t.
            exit
          endif
        next
        if b1
          aadd(t,left(s1,i-1))
          s1 := substr(s1,i+1)
        else
          b := .f.
          k := i := 0
          for j := ll+1 to min(ll+5,tmp_len)
            i := j
            if substr(s1,j,1) != "_"
              b := .t.
              k := j-ll-1
              exit
            endif
          next
          if i == tmp_len
            b := .t.
            k := tmp_len-ll
          endif
          if b
            s1 := stuff(s1,ll+1,k,"")
          else
            aadd(t,left(s1,ll))
            s1 := substr(s1,ll+1)
          endif
        endif
      elseif substr(s1,ll,1) == "_"
        b := .f.
        k := i := 0
        for j := ll+1 to min(ll+5,tmp_len)
          i := j
          if substr(s1,j,1) == " "
            b := .t.
            k := j-ll-1
            exit
          endif
        next
        if i == tmp_len
          b := .t.
          k := tmp_len-ll
        endif
        if b .and. substr(s1,ll-k+1,k) == replicate("_",k)
          s1 := stuff(s1,ll-k+1,k,"")
        else
          aadd(t,left(s1,ll))
          s1 := substr(s1,ll+1)
        endif
      else
        tmp := left(s1,ll)
        b1 := rat(" ",tmp)
        b2 := rat("-",tmp)
        if b1 == 0 .and. b2 == 0
          aadd(t,tmp)
          s1 := substr(s1,ll+1)
        else
          if b1 > 0
            b := b1
          endif
          if b2 > 0
            b := if(b1 == 0, b2, max(b1,b2))
          endif
          aadd(t,left(tmp,if(b == b1, b-1, b)))
          s1 := substr(s1,b+1)
        endif
      endif
    endif
  enddo
endif
for i := 1 to len(t)-1
  if empty(t[i]) .or. len(t[i]) == ll1
    loop
  endif
  //  разбить строку на слова
  first_space := if((j := countleft(t[i])) == 0, "", space(j))
  ll := ll1 - j
  if (kol := numtoken(t[i]," ")) == 1
    loop
  endif
  t_len := 0
  mn := kol-1
  private tt[kol], k_s[mn]
  for j := 1 to kol
    tt[j] := token(t[i]," ",j)
    t_len += len(tt[j])
  next
  if r_margin  // выравнивание по правой границе
    afill(k_s, int((ll - t_len) / mn))
    j = (ll - t_len) % mn
    l = if( ODD(i), mn, 1)
    do while j > 0
      Inc( k_s[l] )
      if ODD(i)  // если i нечетное
        Dec( l )
      else
        Inc( l )
      endif
      Dec( j )
    enddo
  else
    afill(k_s,1)
  endif
  t[i] := first_space
  for j := 1 to kol
    t[i] += tt[j] + if(j < kol, space(k_s[j]), "")
  next
next
ss := ""
for i := 1 to len(t)
  if len(t[i] := rtrim(t[i])) > ll1-5 .and. right(t[i],2) == "__"
    t[i] := padr(t[i],ll1,"_")
  endif
  ss += t[i] + eos
next
return ss
