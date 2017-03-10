#include "inkey.ch"
#include "edit_spr.ch"
#include "function.ch"
#include "kassa.ch"

Static str_err := "!!! ОШИБКА !!! "

//  17 - возврат состояния
//  ++18 - вывод стороки (до 18 символов)
//  ++19 - гудок
//  20 - установка параметров обмена
//  21 - чтение параметров обмена
//  ++23 - вывод стороки (до 40 символов)
//  ++33 - установка времени
//  ++34 и 35 - программирование даты
//  ++37 - отрезка ленты
//  ++41 - протяжка
//  ++64 - снятие отчета без гашения
//  ++65 - снятие отчета с гашением
// ++128 - продажа
// ++130 - возврат продажи
// ++133 - закрытие чека
// ++136 - анулирование чека до закрытия
// ++176 - Продолжение печати
// 06.07.14 FRCH_d_registr(n_port,registr) -запрос денежного регистра

*

***** Возвращает текущий номер чека
//Function FR_ret_chek(n_port)
//Local num_chek := 0, tt := FR_ret_dan(n_port)
//if !empty(tt)
//  num_chek := tt[FR_R_NOMER]
//endif
//return num_chek

*

***** Возвращает состояние
Function FR_ret_error(n_port)
// n_port - номер порта
* возврат
// 0 все в порядке
// 1 заканчивается контрольная лента
// 2 заканчивается чековая лента
Local num_error := 0, sost, tt := FR_ret_dan(n_port), ar := {"Внимание !!!",""}
if !empty(tt)
  sost := tt[FR_R_FLAG]
  if !isbit(sost,9)
    ar[2] := "Заканчивается КОНТРОЛЬНАЯ лента."
    FR_gudok(1)
    n_message(ar,,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
    num_error := 1
  endif
  if !isbit(sost,10)
    ar[2] := "Заканчивается ЧЕКОВАЯ лента."
    FR_gudok(1)
    n_message(ar,,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
    num_error := 2
  endif
endif
return num_error


*

***** Возвращает в виде массива состояние ФР
//Function FR_ret_dan(n_port)
// 11H - 17
/*Local t, t2, vozvrat := space(60), mas_vozvr := {}, i, vr1, vr2, vr3,;
      buf := save_maxrow()
mywait()
t2 := FR_slovo(chr(17)+FR_10_2_value(oper_parol,4))
if FR_w_read(n_port,t2,@vozvrat,1) != 0
  rest_box(buf)
  return ""
endif
if !(left(vozvrat,1) == chr(17))
  rest_box(buf)
  return ""
endif
for i := 1 to FR_R_LEN
  do case
    case i == FR_R_ERROR
      t := ""
    case i == FR_R_KASSIR
      t := ""
    case i == FR_R_VERSIAFR
      t := ""
    case i == FR_R_SBORKAFR
      t := ""
    case i == FR_R_POFR_DATE
      t := ""
    case i == FR_R_ZAL_NOM
      t := ""
    case i == FR_R_NOMER
      t2 := iif(old_version(), 11, 12)
      t := FR_2_10_value(substr(vozvrat,t2,2))  // было 11
    case i == FR_R_FLAG
      t2 := iif(old_version(), 13, 14)
      t := FR_2_10_value(substr(vozvrat,t2,2))  // было 13
    case i == FR_R_REGIM
      t := ""
    case i == FR_R_PODREGIM
      t := ""
    case i == FR_R_PORT
      t := ""
    case i == FR_R_VERSIAFP
      t := ""
    case i == FR_R_SBORKAFP
      t := ""
    case i == FR_R_POFP_DATE
      t := ""
    case i == FR_R_DATE
      vr1 := FR_2_10_value(substr(vozvrat,26,1))
      vr2 := FR_2_10_value(substr(vozvrat,27,1))
      vr3 := FR_2_10_value(substr(vozvrat,28,1))
      t := lstr(vr1)+"-"+lstr(vr2)+"-"+lstr(2000+vr3)
      t := ctod(t)
    case i == FR_R_TIME
      vr1 := lstr(FR_2_10_value(substr(vozvrat,29,1)))
      if len(vr1) == 1
        vr1 := "0"+vr1
      endif
      vr2 := lstr(FR_2_10_value(substr(vozvrat,30,1)))
      if len(vr2) == 1
        vr2 := "0"+vr2
      endif
      vr3 := lstr(FR_2_10_value(substr(vozvrat,31,1)))
      if len(vr3) == 1
        vr3 := "0"+vr3
      endif
      t := vr1+":"+vr2+":"+vr3
    case i == FR_R_FLAGFP
      t := ""
    case i == FR_R_ZAVNOMER
      t := ""
    case i == FR_R_SMEN_NOM
      t := ""
    case i == FR_R_FREE_FP
      t := ""
    case i == FR_R_KOL_FISK
      t := ""
    case i == FR_R_FREE_FISK
      t := ""
    case i == FR_R_INN
      t := ""
  endcase
  aadd(mas_vozvr,t)
next
rest_box(buf)
return mas_vozvr
*/

*

***** Установка параметров обмена
function FR_wspeed(n_port,fr_port,speed,time_out)
/* 14H - 20
   n_port - номер порта
   fr_port - порт фискального регистратора по умолчанию 0
*/
local t1 := space(5), t2, t3, t4
DEFAULT fr_port TO 0, time_out to 50
t2 := chr(20)+FR_10_2_value(oper_parol,4)+chr(fr_port)+;
      chr(speed)+chr(time_out)
return FR_work(n_port,t2,@t1)

*

***** Чтение параметров обмена
function FR_rspeed(n_port,fr_port)
/* 15H - 21
   n_port - номер порта
   fr_port - порт фискального регистратора по умолчанию 0
   Возвращает код скорости порта
   mas_sp := {2400,4800,9600,19200,38400,57600,115200}
*/
local t1 := space(5), t2, t3, t4, t5
DEFAULT fr_port TO 0
t2 := chr(21)+FR_10_2_value(oper_parol,4)+chr(fr_port)
t5 := FR_work(n_port,t2,@t1)
if len(t5) == 0
  t3 := asc(substr(t1,3,1))
//  t4 := asc(substr(t1,4,1))
  return t3
endif
return t5

*

***** Установка времени
//function FR_set_time(n_port,time)
/*  21H - 33
    n_prot - номер порта
    time   - время в формате ЧЧ:ММ:СС
*/
//local t1 := space(3), t2, v1, v2, v3
//v1 := int(val(substr(time,1,2)))
//v2 := int(val(substr(time,4,2)))
//v3 := int(val(substr(time,7,2)))
//t2 := chr(33)+FR_10_2_value(oper_parol,4)+;
//          FR_10_2_value(v1,1)+;
//          FR_10_2_value(v2,1)+;
//          FR_10_2_value(v3,1)
//return FR_work(n_port,t2,@t1)

*

***** Программирование даты (подтверждение программирования даты)
//Function FR_set_date(n_port,ldate)
/*  22H - 34 и 23H -35
    n_prot - номер порта
    ldate  - дата в формате даты
*/
//local t1 := space(3), t2, v1, v2, v3, t
//t := dtos(ldate)
//v1 := int(val(substr(t,3,2)))
//v2 := int(val(substr(t,5,2)))
//v3 := int(val(substr(t,7,2)))
//t2 := chr(34)+FR_10_2_value(oper_parol,4)+;
//          FR_10_2_value(v3,1)+;
//          FR_10_2_value(v2,1)+;
//          FR_10_2_value(v1,1)
//t := FR_work(n_port,t2,@t1)
//if !empty(t)
//  return t
//endif
//t2 := chr(35)+FR_10_2_value(oper_parol,4)+;
//          FR_10_2_value(v3,1)+;
//          FR_10_2_value(v2,1)+;
//          FR_10_2_value(v1,1)
//return FR_work(n_port,t2,@t1)

*

***** отрезка чековой ленты
//function FR_otrezka(n_port,flag,timeout)
/* 25H - 37
   n_port - номер порта
   flag - 0 полная отрезка
          1 частичный отрез
*/
//Local t, t2 := space(4)
//DEFAULT timeout TO 0
//if timeout > 0
//  waitperiod(timeout)
//  do while waitperiod()
    //
//  enddo
//endif
//t := chr(37)+FR_10_2_value(oper_parol,4)+chr(flag)
//return FR_work(n_port,t,@t2)

*

***** Протяжка
//function FR_progon(n_port,flag,kol_str)
/*  29H - 41
    n_prot - номер порта
    flag - 0 контрольная лента
           1 чековая лента
           2 обе ленты
    kol_str количество прогоняемых строк
    0 бит - контрольная лента
    1 бит - чековая лента
*/
//local t1 := space(3), t2, flag1
//if flag == 0
//  flag1 := chr(1)
//elseif flag == 1
//  flag1 := chr(2)
//else
//  flag1 := chr(3)
//endif
//t2 := chr(41)+FR_10_2_value(oper_parol,4)+flag1+chr(kol_str)
//return FR_work(n_port,t2,@t1)

*

***** Снятие суточного отчета
//Function FR_normgach(n_port,flag)
/*
    n_prot - номер порта
    flag == 0 - без гашения 40H - 64
            1   c гашением   41H - 65
*/
//local t1 := space(3), t2
//t2 := iif(flag==1,chr(65),chr(64))+FR_10_2_value(oper_parol,4)
//return FR_work(n_port,t2,@t1)

*

***** Продажа товара
//function FRCH_registr(n_port,cena,kol_vo,sekcia,name,t_nds)
/*  80H - 128
    n_prot - номер порта
    cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
//local t1 := space(3), t2, t3 := 0
//@ 10,10 say "kod_NDS"
//@ 11,10 get t3
//myread()
//t2 := chr(128)+FR_10_2_value(oper_parol,4)+;
//      FR_10_2_value(round_5(kol_vo*1000.0,0),5)+;
//      FR_10_2_value(round_5(cena*100.0,0),5)+;
//      chr(sekcia)+chr(t_nds)+replicate(chr(0),3)+;
//      padr(FR_asckkm(upper(name),1),40)
//return FR_work(n_port,t2,@t1)

*

***** Возврат продажи (для аннулирования чека)
//function FRCH_vozvrat(n_port,cena,kol_vo,sekcia,name)
/*  82H - 130
    n_prot - номер порта
    cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
/*local t1 := space(3), t2
DEFAULT kol_vo TO 1, sekcia TO 1, name TO ""
t2 := chr(130)+FR_10_2_value(oper_parol,4)+;
      FR_10_2_value(round_5(kol_vo*1000.0,0),5)+;
      FR_10_2_value(round_5(cena*100.0,0),5)+;
      chr(sekcia)+replicate(chr(0),4)+;
      padr(FR_asckkm(upper(name),1),40)
return FR_work(n_port,t2,@t1)
  */
*

***** Закрытие чека
//function FRCH_close(n_port,summa,summa1,name,t_nds)
/*  85H - 133
    n_port - номер порта
    summa  - сумма наличных
    summa1 - по кредитной карте
    name   - текст
*/
//local t1 := space(8), t2
//DEFAULT name TO " "
//t2 := chr(133)+FR_10_2_value(oper_parol,4)+;
//      FR_10_2_value(round_5(summa*100.0,0),5)+;
//     replicate(chr(0),5)+;
//      replicate(chr(0),5)+;
//      FR_10_2_value(round_5(summa1*100.0,0),5)+;
//      replicate(chr(0),2)+;
//      chr(t_nds)+;
//      replicate(chr(0),3)+;
//      padr(FR_asckkm(upper(name),1),40)
//return FR_work(n_port,t2,@t1)

*

***** Аннулирование всего чека до его закрытия
//function FRCH_annul(n_port)
/*  88H - 136
    n_prot - номер порта
    1 - аннулирование неудачно
    0 - аннулирование удачно завершено
*/
/*local t1 := space(32), t2, i, t, ret := 1
t2 := FR_slovo(chr(136)+FR_10_2_value(oper_parol,4))
t := FR_w_read(n_port,t2,@t1,1)
if t == 0    // успешно
  ret := 0
endif
return ret
  */
*

***** продолжение печати
//function FR_prodol(n_port)
// B0H  -  176
// n_port - номер порта
/*local t, t2 := space(4)
t := chr(176)+FR_10_2_value(oper_parol,4)
return FR_work(n_port,t,@t2)
  */
*

***** перекодировка из кассовых кодов в ASCII (и наоборот)
Function FR_asckkm(stroka,kuda)
/* stroka - перекодируемая строка
   kuda   - 1 из ASCII в ФР
          - 2 из ФР в ASCII
*/
Static key_tran := ;
  {{"А",192},{"Б",193},{"В",194},{"Г",195},{"Д",196},{"Е",197},{"Ж",198},;
   {"З",199},{"И",200},{"Й",201},{"К",202},{"Л",203},{"М",204},{"Н",205},;
   {"О",206},{"П",207},{"Р",208},{"С",209},{"Т",210},{"У",211},{"Ф",212},;
   {"Х",213},{"Ц",214},{"Ч",215},{"Ш",216},{"Щ",217},{"Ъ",218},{"Ы",219},;
   {"Ь",220},{"Э",221},{"Ю",222},{"Я",223};
  }
local i, j, itog := "",t
DEFAULT kuda TO 2
if kuda == 1  // из ASCII в ФР
  for i := 1 to len(stroka)
    t := substr(stroka,i,1)
    if (j := ascan(key_tran, {|x| t == x[1] } )) > 0
      itog += chr(key_tran[j,2])
    else
      itog += t
    endif
  next
else  // из ФР в ASCII
  for i := 1 to len(stroka)
    t := substr(stroka,i,1)
    if (j := ascan(key_tran, {|x| asc(t) == x[2] } )) > 0
      itog += key_tran[j,1]
    else
      itog += t
    endif
  next
endif
return itog

*

***** Обработка передачи и возврата данных
Function FR_work(n_port,out_data,in_data)
/*
   n_port - номер порта
   out_data - отправляемые данные
   in_data - возвращаемые данные
*/
local t, t2
DEFAULT out_data TO space(9)
t2 := FR_slovo(out_data)
t := FR_w_read(n_port,t2,@in_data,1)
if t != 0
  to_log_file(str_err+FR_funcerr(0,t))
  return FR_funcerr(0,t)
endif
kod_err := asc(substr(in_data,2,1))
if substr(in_data,1,1) != substr(out_data,1,1)
  to_log_file(str_err+FR_funcerr(0,700))
  return FR_funcerr(0,700)
endif
if kod_err == 0
  return ""
endif
to_log_file(str_err+FR_funcerr(kod_err,0))
return FR_funcerr(kod_err,0)

*

***** подготовка кадра из строки
function FR_slovo(vh_slovo)
local vih_slovo := "", i, t3, mas_vr := {}
vih_slovo := chr(len(vh_slovo)) + vh_slovo
// Подсчитываем CRC
for i := 1 to len(vih_slovo)
  aadd(mas_vr,asc(substr(vih_slovo,i,1)))
next
t3 := numxor(mas_vr[1],mas_vr[2])
for i := 3 to len(mas_vr)
  t3 := numxor(t3,mas_vr[i])
next
// Добавляем в начало STX и в конец CRC
vih_slovo := FR_COM_STX + vih_slovo + chr(t3)
return vih_slovo

*

***** служебная функция расшифровки строки
function FR_sslovo(vh_slovo,vih_slovo)
/* vh_slovo - пришедший кадр
   vih_slovo - возврат по ссылке расшифрованной строки
   Возвращает
   .T. - при отсутствии ошибок в пришедшем кадре
   .F. - при наличии ошибок в пришедшем кадре
   Функция обратная FR_slovo
*/
local crc, slovo, vrem, i, mas_vr := {}, t3, kol_vo
// Выделяем с конца CRC
// И удаляем его из строки
vrem  := len(vh_slovo)
crc   := right(vh_slovo,1)
slovo := substr(vh_slovo,1,(vrem-1))
// Удаляем из начало STX
slovo := substr(slovo,2,100)
// Подсчитываем CRC
for i := 1 to len(slovo)
  aadd(mas_vr,asc(substr(slovo,i,1)))
next
// Выделяем байт с кол-вом символов
kol_vo := substr(slovo,1,1)
if (len(slovo)-1) != asc(kol_vo)
  return .F.
endif
t3 := numxor(mas_vr[1],mas_vr[2])
for i := 3 to len(mas_vr)
  t3 := numxor(t3,mas_vr[i])
next
if !(chr(t3) == crc)
  return .F.
endif
// Удаляем байт с кол-вом символов
vrem := len(slovo)
vih_slovo := substr(slovo,2,(vrem-1))
return .T.


*

***** Отправляем данные в порт и получаем обратно
function FR_w_read(n_port,FR_slovo,in_data)
local vozvr, FR_ERROR := 900, ii, priem := "", t_simv, kol_vo, i, tt, ti
local fl_read := 1
//     fl_read  - 1 выполнять чтение
//                0 невыполнять чтение
//  ВНИМАНИЕ !!! FR_LOG_FLAG должен быть описан выше
//  T - включить LOG фаил
//  F - не включать LOG фаил
/*
     n_port   - номер порта
     FR_slovo - отправляемый блок данных
     in_data  - параметр по ссылке данные пришедшие из кассы
                возвращаемое значение
     возвращаемое значение
     0 - данные отправлены
     остальное коды ошибки (900)
*/
Private time_chek
time_chek := seconds()
to_log_file(time()+"  << "+lstr(asc(substr(FR_slovo,3,1)))+" >>"+replicate("-",10)+;
            " Новая команда "+replicate("-",10)+" "+lstr(seconds()-time_chek))
// сначала опрашиваем ФР на желание ответить на предыдущую команду
// иначе он не принимает
for ii := 1 to 11
  if ii == 11
    com_send(n_port,FR_COM_EOT)
    to_log_file("Не удалось установить связь с 10 попыток => закрываем сеанс"+" "+lstr(seconds()-time_chek))
    return FR_ERROR+1
  endif
  // очищаем буфер приема
  com_flush(n_port)
  // посылаем запрос о готовности к связи ENQ
  to_log_file(space(ii-1)+"1ПК -> ФР    FR_COM_ENQ"+" "+lstr(seconds()-time_chek))
  if com_send(n_port,FR_COM_ENQ) == 0
    waitperiod(FR_TIME_1)
    // ожидаем ответа  ACK или NAK
    // NAK - ФР ожидает очередную команду
    // ACK - ФР готовит ответное сообщение
    do while waitperiod() .and. com_count(n_port) == 0
      //
    enddo
    // проверяем что получили если получили
    if com_count(n_port) != 0
      vozvr := com_read(n_port,1)
      to_log_file(space(ii-1)+"1ФР -> ПК    "+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
      if vozvr == FR_COM_NAK // выходим из приема и ниже начнем передачу
        to_log_file(space(ii-1)+"1ФР -> ПК (NAK)"+" "+lstr(seconds()-time_chek))
        EXIT
      elseif vozvr == FR_COM_ACK
        to_log_file(space(ii-1)+"1ФР -> ПК (ACK)"+" "+lstr(seconds()-time_chek))
        // касса сама что-то передает - принимаем и очищаем
        waitperiod(FR_TIME_1)
        do while waitperiod() .and. com_count(n_port) == 0
          //
        enddo
        vozvr := com_read(n_port,1)
        to_log_file(space(ii-1)+"1ФР -> ПК (ACK)"+ chr_16(vozvr)+" "+lstr(seconds()-time_chek))
        if vozvr == FR_COM_STX //передается нормальный пакет
          waitperiod(FR_TIME_1)
          do while waitperiod() .and. com_count(n_port) == 0
            //
          enddo
          vozvr := com_read(n_port,1)
          kol_vo := asc(vozvr)
         // to_log_file(space(ii-1)+"ФР -> ПК (ACK) кол-во "+ str(kol_vo))
          for i := 1 to kol_vo+1
            waitperiod(FR_TIME_1)
            do while waitperiod() .and. com_count(n_port) == 0
              //
            enddo
            vozvr += com_read(n_port,1)
          next
          to_log_file(space(ii-1)+"1ФР -> ПК (ACK)"+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
          com_send(n_port,FR_COM_ACK)
          to_log_file(space(ii-1)+"1ПК -> ФР   FR_COM_ACK"+" "+lstr(seconds()-time_chek))
        else
          to_log_file("1ФР -> ПК (STX-ошибка)"+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
        endif
      endif
    endif
  else
    to_log_file("1ПК -> ФР    данные не ушли !!!"+" "+lstr(seconds()-time_chek))
    waitperiod(FR_TIME_1)  // По алгоритму задержку не ставят
    do while waitperiod()
      //
    enddo
  endif
next
/////////////////////////////////////////////////////////////////////////
// передача данных в кассу
priem := "" //09.07.08
for ii := 1 to 11
  if ii == 11
    to_log_file("2Не удалось передать данные с 10 попыток => закрываем сеанс"+" "+lstr(seconds()-time_chek))
    return FR_ERROR+5
  endif
  vozvr := ""
  // передаем данные в ФР
  to_log_file(space(ii-1)+"2Данные в кассу - "+chr_16(FR_slovo)+" "+lstr(seconds()-time_chek))
  tt := 0
  if (tt :=com_send(n_port,FR_slovo)) > 0
   // to_log_file("2ПК -> ФР    данные не ушли !!!("+lstr(tt)+")  "+lstr(seconds()-time_chek))
  //  return FR_ERROR+5
  endif
  // дополнение
  ti := 0 //количество циклов
  FR1_slovo := FR_slovo
  do while tt > 0
    to_log_file("2ПК -> ФР    данные не ушли !!!("+lstr(tt)+")  "+lstr(seconds()-time_chek))
    ti++
    if ti > 50
      return FR_ERROR+5
    endif
    FR1_slovo := right(FR1_slovo,tt)
    tt :=com_send(n_port,FR1_slovo)
  enddo
  // ожидаем ответа  ACK
  waitperiod(FR_TIME_1)
  do while waitperiod() .and. com_count(n_port) == 0
    //
  enddo
  // проверяем что получили
  // М если ACK неполучен или получено непонятно -
  // что то считаем что получен NAK
  if com_count(n_port) != 0
    vozvr := com_read(n_port,1)
    to_log_file("2ФР -> ПК   подтверждение закрытия передачи ПК->ФР "+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
    //vozvr := iif(len(vozvr) == 1,vozvr,substr(vozvr,1,1))
    if vozvr == FR_COM_ACK
      // закрываем связь
      exit
    endif
  endif
next
///////////////////////////////////////////////////////////////
// прием ответа из кассы
for ii := 1 to 11
  if ii == 11
    to_log_file("3Не принят ответ от кассы с 10 попыток => закрываем сеанс"+" "+lstr(seconds()-time_chek))
    return FR_ERROR+60
  endif
  priem := ""
  // Выбираем данные из порта
  waitperiod(FR_TIME_1)
  do while waitperiod() .and. com_count(n_port) == 0
    //
  enddo
  priem := com_read(n_port,1)
  to_log_file(space(ii-1)+"3ФР -> ПК (ACK)"+ chr_16(priem)+" "+lstr(seconds()-time_chek))
  if priem == FR_COM_STX //передается нормальный пакет
    waitperiod(FR_TIME_1)
    do while waitperiod() .and. com_count(n_port) == 0
      //
    enddo
    kol_vo := com_read(n_port,1)
    priem += kol_vo
    kol_vo := asc(kol_vo)
//    to_log_file(space(ii-1)+"ФР -> ПК (ACK) кол-во "+ str(kol_vo))
    for i := 1 to kol_vo+1
      waitperiod(FR_TIME_1)
      do while waitperiod() .and. com_count(n_port) == 0
        //
      enddo
      priem += com_read(n_port,1)
    next
    to_log_file(space(ii-1)+"3ФР -> ПК (ACK)"+chr_16(priem)+" "+lstr(seconds()-time_chek))
 //   com_send(n_port,FR_COM_NAK)
 //   to_log_file(space(ii-1)+"ПК -> ФР   FR_COM_NAK")
  endif
  // прием данных закончен
  // проверяем CRC
//  to_log_file(space(ii-1)+"Данные из кассы - "+chr_16(priem))
  if FR_sslovo(priem,@in_data)
    exit
  else
    // отправляем NAK
    if ii > 1
      to_log_file("3ПК -> ФР    FR_COM_ENQ"+" "+lstr(seconds()-time_chek))
      if com_send(n_port,FR_COM_ENQ) > 0
        to_log_file("3ПК -> ФР    данные не ушли !!!"+" "+lstr(seconds()-time_chek))
        return FR_ERROR+60
      endif
    else
      to_log_file("3ПК -> ФР    FR_COM_NAK"+" "+lstr(seconds()-time_chek))
      if com_send(n_port,FR_COM_NAK) > 0
        to_log_file("3ПК -> ФР    данные не ушли !!!"+" "+lstr(seconds()-time_chek))
        return FR_ERROR+60
      endif
    endif
  endif
next
// закрытие связи
// отправляем АСК
to_log_file("3ПК -> ФР    FR_COM_ACK"+" "+lstr(seconds()-time_chek))
if com_send(n_port,FR_COM_ACK) > 0
  to_log_file("3ПК -> ФР    данные не ушли !!!"+" "+lstr(seconds()-time_chek))
  return FR_ERROR+50
endif
//waitperiod(FR_TIME_4)
// ожидаем ответа EOT
/*do while waitperiod() .and. com_count(n_port) == 0
  //
enddo
vozvr := com_read(n_port)
to_log_file("ФР -> ПК    "+chr_16(vozvr))
*/
// закрываем порт
//com_close(n_port)
return 0

*

***** открыть COM-порт
//function FR_open(n_port,speed)
/*  функция включает порт номер N_PORT со скоростью speed
    с заранее прописанными пораметами
    Возвращает .T. если открытие удачно иначе .F.
*/
/*local vr := .f., buf := save_maxrow(), ret := .f.
DEFAULT speed TO meS_speed
com_flush(n_port)  // очистили буфера
if com_dtr() .and. !com_rts()
  if com_init(n_port,speed,"N",8,1)
    rest_box(buf)
    return .T.
  endif
endif
*/waitperiod(50)
// попытка открыть порт в течении 0.5 секунд
// время произвольное
/*do while waitperiod() // в цикле пробуем открыть с нужными параметрами
  if com_open(n_port,500,500)
     // открыть порт номер n_port
     // и навсякий случий очищаем буфер приема
    if com_init(n_port,speed,"N",8,1)
      // Инициалицируем парамерты порта с проверкой
      // на то-что параметры установленны
      // 1 - номер порта
      // 2 - скорость порта
      // 3 - контроль передачи - "N" - без проверки на четность
      // 4 - кол-во битов данных - 8
      // 1 - кол-во стоповых бит - 1
      if com_dtr()
        com_rts(n_port,.F.)
        // Установить RTS
        // 1 - номер порта
        // 2 - значание RTS - 1(.T.), 0(.F.)
        ret := .T. ; exit
      else
        waitperiod(50) // время произвольно
        do while !(vr := com_dtr(n_port,.T.)) .and. waitperiod()
          // Устанавливаем DTR
          // 1 - номер порта
          // 2 - значение DTR - 1(.T.), 0(.F.)
        enddo
        if vr
          com_rts(n_port,.F.)
          // Установить RTS
          // 1 - номер порта
          // 2 - значание RTS - 1(.T.), 0(.F.)
          ret := .T. ; exit
        endif
      endif
    endif
  endif
enddo
rest_box(buf)
return ret
*/
*

***** вернуть строку с ошибкой
Function FR_funcerr(err_kas,err_my)
// err_kas - код ошибки кассового аппарата
// err_my  - код нашей ошибки
Static mm_err_1 := {;  // наши ошибки
  {"Неизвестная ошибка в кассе"                                , 700 },;
  {"Не удалось установить связь W"                             , 901 },;
  {"Данные не отправлены W"                                    , 905 },;
  {"Нет запроса от кассы R"                                    , 910 },;
  {"Не отправлено подтверждение на прием R"                    , 930 },;
  {"Данные не получены R"                                      , 940 },;
  {"Не отправлено подтверждение приема R"                      , 950 },;
  {"Не отправлен запрос повтора R"                             , 960 };
 }
Local mm_err_2 := {;  // для ФР Штрих
  {"Нет ошибок"                                                ,   0 },;
  {"Неисправен накопитель ФП1, ФП2 или часы"                   ,   1 },;
  {"Отсутствует ФП1"                                           ,   2 },;
  {"Отсутствует ФП1"                                           ,   3 },;
  {"Некорректные параметры в команде обращения к ФП"           ,   4 },;
  {"Нет запрошенных данных в ФП"                               ,   5 },;
  {"ФП в режиме выхода данных"                                 ,   6 },;
  {"Некорректные параметры в команде для данной реализации ФП" ,   7 },;
  {"Команда не поддерживается в данной реализации ФП"          ,   8 },;
  {"Некорректная длина команды ФП"                             ,   9 },;
  {"Не введена лицензия"                                       ,  17 },;
  {"Заводской номер уже введен"                                ,  18 },;
  {"Текущая дата меньше даты последней записи в ФП"            ,  19 },;
  {"Области сменных итогов ФП переполнена"                     ,  20 },;
  {"Смена уже открыта"                                         ,  21 },;
  {"Смена не открыта"                                          ,  22 },;
  {"Номер первой смены больше номера последней смены"          ,  23 },;
  {"Дата первой смены позже даты последней смены"              ,  24 },;
  {"Нет данных в ФП"                                           ,  25 },;
  {"Заводской номер не введен"                                 ,  27 },;
  {"В заданном диапазоне есть поврежденная запись"             ,  28 },;
  {"Повреждена последняя запись сменных итогов"                ,  29 },;
  {"Область перерегистрации в ФП переполнена"                  ,  30 },;
  {"Переполнение денежного регистра при добавлении"            ,  32 },;
  {"Вычитаемая сумма больше содержимого денежного регистра"    ,  33 }}
Local mm_err_21 := {;  // для ФР Штрих
  {"Неверная дата"                                             ,  34 },;
  {"Вносимая клиентом сумма меньше суммы чека"                 ,  38 },;
  {"Невозможно отменить предыдущую команду"                    ,  43 },;
  {"Обнуленная касса (повторное гашение невозможно)"           ,  44 },;
  {"Сумма чека по секции меньше суммы сторно"                  ,  45 },;
  {"В ФР нет денег для выплаты"                                ,  46 },;
  {"ФР заблокирован, ждет ввода пароля налогового инспектора"  ,  48 },;
  {"Требуется выполнение общего гашения"                       ,  50 },;
  {"Некорректные параметры в команде"                          ,  51 },;
  {"Нет данных"                                                ,  52 },;
  {"Нкорректный параметр при данных настройках"                ,  53 },;
  {"Некорректные параметры в команде для данной реализации ФР" ,  54 },;
  {"Команда не поддерживается в данной реализации ФР"          ,  55 },;
  {"Ошибка в ПЗУ"                                              ,  56 },;
  {"Внутренняя ошибка ПО ФР"                                   ,  57 },;
  {"Переполнение накопления по надбивкам в смене"              ,  58 },;
  {"Переполнение накопления в смене"                           ,  59 },;
  {"Смена открыта - операция невозможна"                       ,  60 },;
  {"Смена не открыта - операция невозможна"                    ,  61 },;
  {"Переполнение итога чека"                                   ,  72 },;
  {"Операция невозможна в открытом чеке данного типа"          ,  73 },;
  {"Открыт чек - операция невозможна"                          ,  74 },;
  {"Буфер чека переполнен"                                     ,  75 },;
  {"Вносимая безналичной оплатой сумма больше суммы чека"      ,  77 },;
  {"Смена превысила 24 часа"                                   ,  78 },;
  {"Неверный пароль"                                           ,  79 },;
  {"Идет печать предыдущей команды"                            ,  80 },;
  {"Чек закрыт - операция невозможна"                          ,  85 },;
  {"Ожидание команды продолжения печати"                       ,  88 },;
  {"Документ открыт другим оператором"                         ,  89 },;
  {"Скидка превышает накопления в чеке"                        ,  90 },;
  {"Таблица не определена"                                     ,  93 },;
  {"ФП отсутствует"                                            , 100 },;
  {"Ошибка связи с ФП"                                         , 103 },;
  {"Нет чековой ленты"                                         , 107 },;
  {"Нет контрольной ленты"                                     , 108 },;
  {"Переполнение ФП"                                           , 112 },;
  {"Ошибка отрезчика бумаги"                                   , 113 },;
  {"Команда не поддерживается в данном подрежиме"              , 114 },;
  {"Команда не поддерживается в данном режиме"                 , 115 },;
  {"Ошибка оперативной памяти ФР"                              , 116 }}
Local s1 := "", s2 := "", s := "", i, k
if err_my > 0
  if (k := ascan(mm_err_1, {|x| x[2] == err_my } )) > 0
    s1 := alltrim(mm_err_1[k,1])
  else
    s1 := "Неизвестная ошибка передачи номер "+lstr(err_my)
  endif
endif
if err_kas > 0
  aeval(mm_err_21, {|x| aadd(mm_err_2, x) } )
  if (k := ascan(mm_err_2, {|x| x[2] == err_kas } )) > 0
    s2 := alltrim(mm_err_2[k,1])
  else
    s2 := "Неизвестная ошибка ФР номер "+lstr(err_kas)
  endif
endif
if !empty(s1)
  s := s1
  if !empty(s2)
    s += " / "
  endif
endif
if !empty(s2)
  s += s2
endif
return s

*

***** перевод числа в двоичную систему счисления
Function FR_10_2_value(Price,out_len)
// Price   - преобразуемое число
// out_len - длина, к которой приводится число
// Задействуем первые 4 байта 4.300.000.000
local sout := "", sout1 := "", temp, t1,t2
local mas := {16777216,65536,256,1}
for i := 1 to 4
  if i == 4
    sout += chr(price)
  else
    if price >= mas[i]
       t1 := int(price/mas[i])
       sout += chr(t1)
       price := price-int(t1*mas[i])
    else
      sout += chr(0)
    endif
  endif
next
// переворачиваем
for i := 4 to 1 step -1
  sout1 += substr(sout,i,1)
next
sout1 := padr(sout1,out_len,chr(0))
return sout1

*

***** перевод числа из двоичной системы счисления
Function FR_2_10_value(Price)
// Price - преобразуемое число (строка)
Local in_len := len(Price), sout := 0
local mas := {1,256,65536,16777216,0,0}
for i := 1 to in_len
  sout += mas[i]*asc(substr(Price,i,1))
next
return sout

*

*****
Static Function to_log_file(s)
if type("FR_LOG_FLAG") == "L" .and. FR_LOG_FLAG
//  s := s+" "+lstr(seconds()-time_chek)
  strfile(s+eos,"__kassa_.log",.t.)
endif
return NIL

*****
Static Function chr_16(t2)
local i, t := ""
for i:= 1 to len(t2)
  t += lstr(asc(substr(t2,i,1)))+" "
next
return t+"("+FR_asckkm(t2,2)+")"

*****
Static Function old_version()
Static is_old
if is_old == NIL
  is_old := (type("yes_fr_old")=="L" .and. yes_fr_old)
endif
return is_old

*

***** Запрос денежного регистра
//function FRCH_d_registr(n_port,registr)
/*  1AH - 26
    n_prot  - номер порта
    registr - номер регистра
*/
//local t1 := space(8), t2, t3 := 0
//t2 := chr(26)+FR_10_2_value(oper_parol,4)+;
//      FR_10_2_value(registr,1)

//t := FR_work(n_port,t2,@t1)
//return FR_2_10_value(substr(t1,4,6))/100
