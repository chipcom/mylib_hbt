#include "inkey.ch"
#include "function.ch"

*****
Function my_achoice(r1,c1,r2,c2,;  // габариты
                    ar,;           // указатель на массив строк
                    CURRENT,;      // текущий элемент
                    CURRENT_1ST,;  // первый элемент в окне
                    mcolor,;       // цвет (минимум две составляющих)
                    func_key,;     // функция обработки дополнительных клавиш
                    func_out;      // вывод сообщений для каждой строки
                   )
Local NSTR := r2-r1+1, COUNT := len(ar), v, flag := .f., ch, flag_alpha, ;
      i, k, uu, MT_color1, MT_color2, tmp_color := setcolor(mcolor)
DEFAULT CURRENT TO 1, CURRENT_1ST TO 1, mcolor TO setcolor(), ;
        func_key TO "", func_out TO ""
if COUNT == 0 ; return NIL ; endif
MT_color1 := token(mcolor,",",1)  // основной цвет
MT_color2 := token(mcolor,",",2)  // выделенный цвет
if CURRENT <= 0 ; CURRENT := 1 ; endif
if CURRENT_1ST <= 0 ; CURRENT_1ST := 1 ; endif
if CURRENT > COUNT ; CURRENT := COUNT ; endif
if CURRENT_1ST > CURRENT ; CURRENT_1ST := CURRENT ; endif
NSTR := if(COUNT < NSTR, COUNT, NSTR)
if (CURRENT_1ST > COUNT-NSTR+1) ; CURRENT_1ST := COUNT-NSTR+1 ; endif
do while !flag
  Scroll( r1, c1, r2, c2 )
  i := 1 ; k := CURRENT_1ST
  do while i <= NSTR .and. k <= COUNT
    @ r1+i-1,c1 say ar[k]
    i++ ; k++
  enddo
  v := CURRENT-CURRENT_1ST+1  // номер строки в окне
  colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
  if !empty(func_out)
    k := &(func_out+"("+lstr(CURRENT)+")")
  endif
  do while .t.
    ch := inkeytrap(0)
    if !empty(func_key)
      k := &(func_key+"("+lstr(CURRENT)+","+lstr(ch)+")")
      flag := k[2]  // лог.параметр для выхода из ACHOICE
      if k[1]  // лог.параметр - отработала ли клавиша
        exit
      endif
    endif
    if (ch == K_DOWN .and. CURRENT < COUNT)
      if (v < NSTR)
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        v++ ;  CURRENT++
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      else
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        Scroll( r1, c1, r2, c2, 1 )
        CURRENT++ ; CURRENT_1ST++
        @ r1+v-1,c1 say ar[CURRENT_1ST+v-1]
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      endif
    elseif (ch == K_UP .and. CURRENT > 1)
      if (v > 1)
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        v--;  CURRENT--
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      else
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        Scroll( r1, c1, r2, c2, -1 )
        CURRENT-- ; CURRENT_1ST--
        @ r1,c1 say ar[CURRENT_1ST]
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      endif
    elseif (ch == K_PGUP .and. CURRENT > 1)
      if (CURRENT_1ST == 1)
        if (v > 1)
          colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
          v := 1;  CURRENT := 1
          colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
          if !empty(func_out)
            k := &(func_out+"("+lstr(CURRENT)+")")
          endif
        endif
      else
        CURRENT_1ST -= (NSTR - 1)
        if (CURRENT_1ST < 1) ; CURRENT_1ST := 1 ; endif
        CURRENT -= (NSTR - 1)
        if (CURRENT < 1) ; CURRENT := 1 ; endif
        exit
      endif
    elseif (ch == K_PGDN .and. CURRENT < COUNT)
      if COUNT - CURRENT_1ST < NSTR
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        v := NSTR;  CURRENT := COUNT
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      else
        CURRENT_1ST += (NSTR - 1);  CURRENT += (NSTR - 1)
        if (CURRENT_1ST > COUNT-NSTR+1) ; CURRENT_1ST := COUNT-NSTR+1 ; endif
        if CURRENT > COUNT ; CURRENT := COUNT ; endif
        exit
      endif
    elseif (ch == K_HOME .or. ch == K_CTRL_PGUP) .and. CURRENT > 1
      if (CURRENT_1ST > 1)
        CURRENT := CURRENT_1ST := 1;  exit
      elseif (v > 1)
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        CURRENT := 1;  v := 1
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      endif
    elseif (ch == K_END .or. ch == K_CTRL_PGDN) .and. CURRENT < COUNT
      if (CURRENT_1ST+NSTR-1 < COUNT)
        CURRENT_1ST := COUNT - NSTR + 1;  CURRENT := COUNT;  exit
      elseif (CURRENT_1ST+NSTR-1 == COUNT .and. v < NSTR)
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
        CURRENT := COUNT;  v := NSTR
        colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
        if !empty(func_out)
          k := &(func_out+"("+lstr(CURRENT)+")")
        endif
      endif
    elseif (ch == K_ESC .or. ch == K_ENTER)
      flag := .t. ; exit
    elseif between(ch,48,57) .or. ch > 64  // поиск по начальной букве
      k := asc(upper(chr(ch))) ; flag_alpha := .f.
      for i := 1 to COUNT
        uu := asc(upper(left(ar[i],1)))
        if uu >= k
          if (i == CURRENT) ; exit ; endif
          if (i >= CURRENT_1ST .and. i - CURRENT_1ST < NSTR)
            colorwin(r1+v-1,c1,r1+v-1,c2,MT_color1)
            CURRENT := i ; v := CURRENT - CURRENT_1ST + 1
            colorwin(r1+v-1,c1,r1+v-1,c2,MT_color2)
            if !empty(func_out)
              k := &(func_out+"("+lstr(CURRENT)+")")
            endif
          else
            CURRENT := CURRENT_1ST := i
            if (CURRENT_1ST > COUNT-NSTR)
              CURRENT_1ST := COUNT - NSTR + 1
            endif
            flag_alpha := .t.
          endif
          exit
        endif
      next
      if flag_alpha ; exit ; endif
    endif
  enddo
enddo
setcolor(tmp_color)
return if(ch == K_ESC, NIL, {CURRENT,CURRENT_1ST})
