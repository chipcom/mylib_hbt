#define  FUNC__NAME   1
#define  FUNC_BEG     2
#define  FUNC_END     3
//
//    ������� ���ᠭ�� ��ப
//
#define S__LINE       1
#define S__TYPE       2
#define S__CONT       3
#define S__NEXT       4
#define S__JUMP       5
//
//   ���� �����஢
//
#define T__STM        0
#define T__DEF        1
#define T__DO         2
#define T__ENDDO      3
#define T__EXIT       4
#define T__LOOP       5
#define T__IF         6
#define T__ELIF       7
#define T__ELSE       8
#define T__ENDIF      9
#define T__RET       10
#define T__FUNC      11
#define T__GO        12  // �����誠 ��। ELSEIF � ELSE ��� ���室� �� ENDIF
//
//    ���� �訡��
//
#define ERR__NO       0     // ��� �訡��
#define ERR__CTRL     1     // �०���६����� ������ FUNCTION
#define ERR__ENDDO    2     // �०���६����� ������ ENDDO
#define ERR__ENDIF    3     // �०���६����� ������ ELSE, ELSEIF, ENDIF
#define ERR__LIB      4     // �訡�� ����� � 䠩� ������⥪�
#define ERR__FUNC     5     // ��� FUNCTION
#define ERR__NAME     6     // ����୮� ��� �㭪樨

*
* ���ᨢ ��⮨� �� ᫥����� ������⮢:
*
*   mas[1,i,FUNC__NAME] - ��� �㭪樨
*   mas[1,i,FUNC_BEG]   - ��砫쭠� ��ப� �㭪樨
*   mas[1,i,FUNC_END]   - ����筠� ��ப� �㭪樨
* ---------------------------------------
*   mas[2,i] - ���ᠭ�� ������ i-⮩ �㭪樨
*   mas[2,i,S__LINE] - ����� ��ப� � ��室��� 䠩��
*   mas[2,i,S__TYPE] - ⨯ ������ (do while, exit, if � �.�.)
*                         T__STM    - ���� �ᯮ��塞� ������
*                         T__DEF    - ������� ��६�����
*                         T__DO     - do while
*                         T__ENDDO  - enddo
*                         T__EXIT   - exit
*                         T__LOOP   - loop
*                         T__IF     - if
*                         T__ELSE   - elseif ��� else
*                         T__ENDIF  - endif
*                         T__RET    - return
*   mas[2,i,S__CONT] - ���稬�� ���� ��ப�,
*                          - ��� ������� ��६����� - ���ᨢ ����;
*                          - ��� �ᯮ��塞�� �����஢ - ��� ��ப�;
*                          - ��� �����஢ 横�� � ���室�� - �᫮���.
*   mas[2,i,S__NEXT] - ��� �����஢ - ᫥�. �ᯮ��塞� ������,
*                          - ��� �����஢ 横�� � ���室�� - �� .t.
*   mas[2,i,S__JUMP] - ⮫쪮 ��� �����஢ 横�� � ���室�� - �� .f.
*
