#ifndef _FUNCTION_CH
#define _FUNCTION_CH

#define eos chr(13)+chr(10)   // ���⪨� ������ ���⪨
#define Hos chr(141)+chr(10)  // ��� ������ ���⪨
#define name_help "help.hlp"  // ��� 䠩�� �����

// 㤠���� i-� �-� ���ᨢ� (� 㬥����� ��� �����)
#xtranslate Del_Array( <array>, <i> ) ;
    => ADEL ( <array>, <i> )          ;
    ;  ASIZE( <array>, LEN( <array> ) - 1 )
// 㤠���� ��᫥���� �-� ���ᨢ� (� 㬥����� ��� �����)
#xtranslate Del_Array( <array> ) ;
    => ADEL ( <array>, LEN( <array> ) )        ;
    ;  ASIZE( <array>, LEN( <array> ) - 1 )
// �������� � ���ᨢ i-� �-�
#xtranslate Ins_Array( <array>, <i>, <element> ) ;
    => AADD ( <array>, nil )        ;
    ;  AINS ( <array>, <i> )        ;
    ;  <array>\[<i>\] := <element>

// �뤥���� �� �࠭� 梥⮬ <color> �� ��ப� �� ���ᨢ� <arr>
#xtranslate mark_keys( <arr> ) => ;
               aeval( <arr>, {|x| screenmark(x,cColorSt2Msg,.t.,.t.) } )
#xtranslate mark_keys( <arr>, <color> ) => ;
               aeval( <arr>, {|x| screenmark(x,<color>,.t.,.t.) } )

#xtranslate padl(<List,...>)  => padleft(<List>)
#xtranslate padr(<List,...>)  => padright(<List>)
#xtranslate padc(<s>,<l>)     => center(<s>,<l>,,.t.)
#xtranslate padc(<s>,<l>,<c>) => center(<s>,<l>,<c>,.t.)

#xtranslate lstr(<List,...>) =>  ltrim(str(<List>))

#xtranslate lpad(<s>,<m>)    =>  padleft(<s>,<m>)

// �஢�ઠ �⭮�� �᫠
#translate EVEN( <number> )   =>  ( (<number> % 2) == 0 )

// �஢�ઠ ���⭮�� �᫠
#translate ODD( <number> )    =>  ( (<number> % 2) != 0 )

// 㢥��祭�� �᫮��� ��६����� �� �������� ����稭�
#xtranslate Inc(<v>)      =>  ( ++<v> )
#xtranslate Inc(<v>,<n>)  =>  ( <v> += <n> )

// 㬥��襭�� �᫮��� ��६����� �� �������� ����稭�
#xtranslate Dec(<v>)      =>  ( --<v> )
#xtranslate Dec(<v>,<n>)  =>  ( <v> -= <n> )

// �筮� �ࠢ����� �� ࠢ���⢮ �ᥫ � ������饩 �窮�
#xtranslate FPEqual(<nVal1>,<nVal2>)  => ;
           ( VAL(STR(<nVal1>)) == VAL(STR(<nVal2>) )
*******************************************************************************
*������������������Ŀ
*� MAX(a, b, c,...) � ���᫥��� ���ᨬ㬠
*��������������������

*  (1�) �� 3 �� 5 ��㬥�⮢ - �������� �맮�� MAX()

#translate MAX(<a>,<b>,<c>)         => MAX(MAX(<a>,<b>),<c>)
#translate MAX(<a>,<b>,<c>,<d>)     => MAX(MAX(MAX(<a>,<b>),<c>),<d>)
#translate MAX(<a>,<b>,<c>,<d>,<e>) => MAX(MAX(MAX(MAX(<a>,<b>),<c>),<d>),<e>)

*  (1�) ����� 5 ��㬥�⮢ - ���।�⢮� AEVAL

#translate MAX( <xV1>, <xV2>, <xV3>, <xV4>, <xV5>, <xV6> [, <xV7,...> ] ) ;
       => ;
  (temp__arr_ := { <xV1>, <xV2>, <xV3>, <xV4>, <xV5>, <xV6> [, <xV7> ] }, ;
   temp__var_ := temp__arr_\[1\],  ;
   AEVAL( temp__arr_,  ;
          { |e,eNum| temp__var_ := IF(e>temp__var_, e, temp__var_) }  ;
        ),  ;
   temp__var_ )
*******************************************************************************
*������������������Ŀ
*� MIN(a, b, c,...) � ���᫥��� �����㬠
*��������������������

*  (1�) �� 3 �� 5 ��㬥�⮢ - �������� �맮�� MIN()

#translate MIN(<a>,<b>,<c>)         => MIN(MIN(<a>,<b>),<c>)
#translate MIN(<a>,<b>,<c>,<d>)     => MIN(MIN(MIN(<a>,<b>),<c>),<d>)
#translate MIN(<a>,<b>,<c>,<d>,<e>) => MIN(MIN(MIN(MIN(<a>,<b>),<c>),<d>),<e>)

*  (1�) ����� 5 ��㬥�⮢- ���।�⢮� AEVAL()

#translate MIN( <xV1>, <xV2>, <xV3>, <xV4>, <xV5>, <xV6> [, <xV7,...> ] ) ;
       => ;
  (temp__arr_ := { <xV1>, <xV2>, <xV3>, <xV4>, <xV5>, <xV6> [, <xV7> ] }, ;
   temp__var_ := temp__arr_\[1\],  ;
   AEVAL( temp__arr_,  ;
          { |e,eNum| temp__var_ := IF(e \< temp__var_, e, temp__var_) }  ;
        ),  ;
   temp__var_ )
*******************************************************************************

// ��⠭���� ��᮪�� ��⥭ᨢ���� �࠭�
#xtranslate HighVideo() => SETBLINK(.F.)

// ��⠭���� ������ (���筮�) ��⥭ᨢ���� �࠭�
#xtranslate LowVideo() => SETBLINK(.T.)

/*===================== ���������� �࠭� ��� ��ப� =======================*/

// ���������� �࠭� �ॡ㥬� ᨬ����� ⥪�饣� ��� ��������� 梥�
#xtranslate  FillScreen(<char>[,<color>]) ;
 =>;
  DispBox(0, 0, MAXROW(), MAXCOL(), REPLICATE(<char>,9), <color>)

// ���������� ������ �࠭� �ॡ㥬� ᨬ����� ⥪�饣� ��� ��������� 梥�
#xtranslate  FillScrArea(<rowtop>,<coltop>,<rowbot>,<colbot>,<char>[,<color>]) ;
 =>;
  DispBox(<rowtop>,<coltop>,<rowbot>,<colbot>, REPLICATE(<char>,9), <color>)

// ���������� ��ப� �࠭� �ॡ㥬� ᨬ����� ⥪�饣� ��� ��������� 梥�
#xtranslate  FillScrLine(<row>,<char>[,<color>]) ;
 =>;
  DispBox(<row>, 0, <row>, MAXCOL(), REPLICATE(<char>,9), <color>)


// �८�ࠧ����� ᥪ㭤� � ��ப� "��:��"
#xtranslate hour_min(<n>)    =>  padr(sectotime(<n>),5)

// ������ ��� 䠩�� ��� ���
#xtranslate StripPath(<f>)   =>  ;
                   If("\" $ <f>, SUBSTR(<f>,RAT("\",<f>)+1), <f>)

// ������ ���� ��� ����� 䠩��
#xtranslate KeepPath(<f>)    =>  ;
                   If("\" $ <f>, SUBSTR(<f>,1,RAT("\",<f>)-1), "")

// ��⠭����� ����� "����ન�����" ��� <Ins> � ������ ���㡫�� ��� <Ovr>
#xtranslate SETCURSOR() => SETCURSOR(iif(READINSERT(),1,2))

// ���⪠ � ��ப� top �� ���� �࠭�
#xtranslate myclear(<top>) => Scroll( <top>, 0 ) ; SetPos( <top>, 0 )

// ������
#xtranslate MyBell()     =>  QQOut(CHR(7))
#xtranslate MyBell(<k>)  =>  QQOut(CHR(7)) ; INKEY(<k>)
#xtranslate MyBell(<k>,<x:OK,ERROR,ERR,&>)  =>  music_m(<(x)>) ; INKEY(<k>)

//   ��������� ᨬ���쭮�� �।�⠢����� �������� �����
#define COMPILE(ExpC)   &( "{|| " + ExpC + "}" )

// �஢�ઠ �宦����� ���祭�� ��६����� � ������� ��������
// (��� ����஫� ⨯� ��६�����)
#xtranslate BETWEEN( <V>, <L>, <H> ) => ( <V> \>= <L> .and. <V> \<= <H> )
// ��������� �᫠ � ��������
#define Range( xVar, xExpr1, xExpr2 ) ;
    ( xVar >= MIN( xExpr1, xExpr2 ) .AND. xVar <= MAX( xExpr1, xExpr2 ) )

// ���⪠ �ᥩ ��ப� �࠭� ⥪�騬 ��� ������� 梥⮬
#xtranslate ClrLine(<row>[,<color>]) ;
 => ;
  ( IF(<.color.>, ;
       EVAL( {|_c| _c:=SETCOLOR(<color>), Scroll(<row>,0,<row>), SETCOLOR(_c)} ),;
       SCROLL(<row>,0,<row>)     ;
      ),                         ;
    SETPOS(<row>,0)              ;
  )

// ���⪠ 㪠������ ᬥ���� ��ப �࠭� ⥪�騬 ��� ������� 梥⮬
#xtranslate ClrLines(<row1>, <row2> [,<color>]) ;        // row1 <= row2 !
 => ;
  ( IF(<.color.>, ;
       EVAL( {|_c| _c:=SETCOLOR(<color>), Scroll(<row1>,0,<row2>,MAXCOL()), SETCOLOR(_c)} ),;
       SCROLL(<row1>,0,<row2>,MAXCOL()) ;
      ),                                ;
    SETPOS(<row1>,0)                    ;
  )

// �஢�ઠ ⨯� ����� ��� ��᪮�쪨� ��६�����

* �஢�ઠ �ਭ��������� ������ �� �������� ��६����� � ᨬ���쭮�� ⨯�
#xtranslate ISCHAR( <x1> [, <x2> ] ) => ( VALTYPE( <x1> ) == 'C' [ .and. VALTYPE( <x2> ) == 'C' ] )

* �஢�ઠ �ਭ��������� ������ �� �������� ��६����� � �᫮���� ⨯�
#xtranslate ISNUMBER( <x1> [, <x2> ] ) => ( VALTYPE( <x1> ) == 'N' [ .and. VALTYPE( <x2> ) == 'N' ] )

* �஢�ઠ �ਭ��������� ������ �� �������� ��६����� � �����᪮�� ⨯�
#xtranslate ISLOGIC( <x1> [, <x2> ] ) => ( VALTYPE( <x1> ) == 'L' [ .and. VALTYPE( <x2> ) == 'L' ] )

* �஢�ઠ �ਭ��������� ������ �� �������� ��६����� � ⨯� "���"
#xtranslate ISDATE( <x1> [, <x2> ] ) => ( VALTYPE( <x1> ) == 'D' [ .and. VALTYPE( <x2> ) == 'D' ] )

* �஢�ઠ �ਭ��������� ������ �� �������� ��६����� � ⨯� "���ᨢ"
#xtranslate ISARRAY( <x1> [, <x2> ] ) => ( VALTYPE( <x1> ) == 'A' [ .and. VALTYPE( <x2> ) == 'A' ] )

* �஢�ઠ �ਭ��������� ������ �� �������� ��६����� � ⨯� "���� ����"
#xtranslate ISBLOCK( <x1> [, <x2> ] ) => ( VALTYPE( <x1> ) == 'B' [ .and. VALTYPE( <x2> ) == 'B' ] )

* �஢�ઠ �ਭ��������� ��ࢮ�� ᨬ���� ��ப� � ���᪮�� ��䠢���
#xtranslate ISRALPHA( <s> ) => ;
    EVAL( { |_c| _c:=ASC(<s>), ( BETWEEN(_c,128,175) .or. BETWEEN(_c,224,241) ) } )

* �஢�ઠ ������ �㪢� (���/���) � ��ࢮ� ᨬ���� ��ப�
#xtranslate ISLETTER( <s> ) => ( ISALPHA( <s> ) .or. ISRALPHA( <s> ) )


// �஢�ઠ �� ������ ���祭�� ����� ��� ��᪮�쪨� ��६�����

* �஢�ઠ �����६������ ������ ���⮣� ���祭�� � �������� ��६�����
#xtranslate EMPTYALL( <x1> [, <x2> ] ) => ( EMPTY(<x1>) [ .and. EMPTY(<x2>) ] )

* �஢�ઠ ������ ���⮣� ���祭�� � ����� �� �������� ��६�����
#xtranslate EMPTYANY( <x1> [, <x2> ] ) => ( EMPTY(<x1>) [ .or. EMPTY(<x2>) ] )

* �஢�ઠ ࠢ���⢠ ��६����� ������ �� �������� ���祭��
#xtranslate EQUALANY( <v>, <x1> [, <x2> ] ) => ( <v> == <x1> [ .or. <v> == <x2> ] )

#xcommand SAVE GETS TO <array>       =>  <array> := GetList; GetList := {}
#xcommand RESTORE GETS FROM <array>  =>  GetList := <array>

#xcommand DEFAULT <p> TO <v> [, <p2> TO <v2> ] => ;
          <p> := IF(<p> == NIL, <v>, <p>) ;
          [; <p2> := IF(<p2> == NIL, <v2>, <p2>) ]

#xcommand VALDEFAULT <p1>,<t1> TO <v1> [, <p2>,<t2> TO <v2> ] => ;
                     <p1> := IF(valtype(<p1>) != <t1>, <v1>, <p1>) ;
                  [; <p2> := IF(valtype(<p2>) != <t2>, <v2>, <p2>) ]

// ᮡ�⢥���� ॠ������ MENU TO
#command @ <PrRow>, <PrCol> PROMPT <Prompt>             ;
                            [MESSAGE <Message> ]        ;
                            [MSGROW <MsgRow> ]          ;
                            [MSGCOL <MsgCol> ]          ;
                            [MSGCOLOR <MsgColor> ]      ;
                            [UP <Up> ]                  ;
                            [DOWN <Down> ]              ;
                            [RIGHT <Right> ]            ;
                            [LEFT <Left> ]              ;
      => FT_Prompt( <PrRow>, <PrCol>, <Prompt>,         ;
         <MsgRow>, <MsgCol>, <Message>, <(MsgColor)>,   ;
         <Up>, <Down>, <Right>, <Left> )

#command MENU TO <v> [REGION <r> ] [BLOCK <b>];
      => <v> := FT_MenuTo({|_1| IF(_1==NIL, <v>, <v>:=_1)}, #<v>, <r>, <b>)

// reader ��� ���筮�� GET'�
#command  @ <row>, <col> GET <var>                                ;
                         [<clauses,...>]                          ;
                         READER <mreader>                         ;
                         [<moreClauses,...>]                      ;
       => @ <row>, <col> GET <var>                                 ;
                         [<clauses>]                               ;
                         [<moreClauses>]                           ;
       ; ATail(GetList):reader := <mreader>

// ॠ������ LOCATE c �⮡ࠦ����� ����� ���᪠ ��ꥪ⮬ GAUGE
#command LOCATE                                                         ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
         PROGRESS [<color>]                                       ;
         [<p: NUMPROCENT>]                                        ;
         [AT <row>, <col> ]                                       ;
         [COLOR <color>]                                          ;
      => dbLocateProgress( <{for}>, <{while}>, <next>, <rec>, <.rest.>, ;
                           if( <.p.>, .T., NIL ),                       ;
                           [<row>], [<col>] [,<color>] )

// ॠ������ INDEX ON c �⮡ࠦ����� ����� ������樨 ��ꥪ⮬ GAUGE

#command INDEX ON <key> [TAG <(cOrderName)> ] TO <(cOrderBagName)>      ;
         [FOR <for>]                                                    ;
         [<all:ALL>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [EVAL <eval>]                                                  ;
         [EVERY <every>]                                                ;
         [<unique: UNIQUE>]                                             ;
         [<ascend: ASCENDING>]                                          ;
         [<descend: DESCENDING>]                                        ;
         PROGRESS [<color>]                                       ;
         [<p: NUMPROCENT>]                                        ;
         [AT <row>, <col> ]                                       ;
         [COLOR <color>]                                          ;
 => db1IndexProgress(                                         ;
                     <"for">, <{for}>,                                  ;
                     [<.all.>],                                         ;
                     <{while}>,                                         ;
                     <{eval}>, <every>,                                 ;
                     RECNO(), <next>, <rec>,                            ;
                     [<.rest.>], [<.descend.>],                         ;
                   <(cOrderBagName)>, <(cOrderName)>,                   ;
                   <"key">, <{key}>, [<.unique.>],                      ;
                      if( <.p.>, .T., NIL ),                   ;
                      [<row>],[<col>][,<color>]                ;
                     )

#command INDEX ON <key> TAG <(cOrderName)> [TO <(cOrderBagName)>]       ;
         [FOR <for>]                                                    ;
         [<all:ALL>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [EVAL <eval>]                                                  ;
         [EVERY <every>]                                                ;
         [<unique: UNIQUE>]                                             ;
         [<ascend: ASCENDING>]                                          ;
         [<descend: DESCENDING>]                                        ;
         PROGRESS [<color>]                                       ;
         [<p: NUMPROCENT>]                                        ;
         [AT <row>, <col> ]                                       ;
         [COLOR <color>]                                          ;
 => db1IndexProgress(                                         ;
                     <"for">, <{for}>,                                  ;
                     [<.all.>],                                         ;
                     <{while}>,                                         ;
                     <{eval}>, <every>,                                 ;
                     RECNO(), <next>, <rec>,                            ;
                     [<.rest.>], [<.descend.>],                         ;
                   <(cOrderBagName)>, <(cOrderName)>,                   ;
                   <"key">, <{key}>, [<.unique.>],                      ;
                      if( <.p.>, .T., NIL ),                   ;
                      [<row>],[<col>][,<color>]                ;
                     )

// ��࠭���� ��᫥���� ��ப� � ��६�����
#xtranslate save_maxrow()     => save_row(maxrow())
// ��࠭���� �࠭� � ��६�����
#xtranslate savescreen()      => savescreen(0,0,maxrow(),maxcol())
// ���� ����⠭������� �࠭�
#xtranslate restscreen(<buf>) => restscreen(0,0,maxrow(),maxcol(),<buf>)

#command @ <row>, <col> VSAY <sayxpr>                                   ;
                        [<sayClauses,...>]                              ;
                        VGET <var>                                      ;
                        [<getClauses,...>]                              ;
                                                                        ;
      => @ <row>, <col> VSAY <sayxpr> [<sayClauses>]                    ;
       ; @ <row>, VCOL() VGET <var> [<getClauses>]

#command @ <row>, <col> VSAY <sayxpr>                                   ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => _1s := <sayxpr>                                                ;
       ; _1l := len(_1s)                                                ;
       ;  AAdd( vGetBG, { <row>, <col>, _1s, [<color>] } )              ;
       ; vGetCol := <col> + _1l + 1

#command @ <row>, <col> VGET <var>                                      ;
                        [PICTURE <pic>]                                 ;
                        [READER <mreader>]                              ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [COLOR <color>]                                 ;
                        [SEND <msg>]                                    ;
                                                                        ;
      =>  AAdd(                                                         ;
            vGetlist,                                                   ;
            GetNew( <row>, <col>,                                       ;
                    {|_nv| iif(_nv == NIL, <var>, <var> := _nv) },      ;
                    <(var)>, <pic>, <color>)                            ;
             )                                                          ;
       ; vGetCol := <col> + varlen( <var>, <pic> )                      ;
      [; ATail(vGetlist):PostBlock := <{valid}>]                        ;
      [; ATail(vGetlist):PreBlock  :=  <{when}>]                        ;
      [; ATail(vGetList):reader := <mreader>   ]                        ;
      [; ATail(vGetlist):<msg>]

#endif
