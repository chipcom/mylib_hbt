// ��६����, �ᯮ��㥬� ����� �-�� F_EDIT_SPR
#define A__NAME     1
#define A__TYPE     2
#define A__LEN      3
#define A__DEC      4
#define A__PICTURE  5
#define A__BLOCK    6
#define A__INIT     7
#define A__FIND     8
#define A__SAY      9
#define A__VALID   10
#define A__WHEN    11

// ��६���� ��� �-�� F_EDIT_SPR
#define A__VIEW     1
#define A__EDIT     2
#define A__APPEND   3
#define A__DELETE   4

// ��६���� ��� �-�� MENU_READER
#define A__MENUHORIZ       0  // ��ਧ���쭮� ���� �� ���ᨢ�
#define A__MENUVERT        1  // ���⨪��쭮� ���� �� ���ᨢ�
#define A__MENUVERT_SPACE 11  // ���⨪��쭮� ���� �� ���ᨢ�
                              // � �� �஡��� ������ {0,""}
#define A__MENUBIT         2  // ��⮢�� ����
#define A__POPUPBASE       3  // ���� �� �� - ���������� � ������ ����
                              // � �� �஡��� ������ {0,""}
#define A__POPUPBASE1     31  // ���� �� �� - ���������� � ������ ����
#define A__POPUPEDIT       4  // ���� �� �� - ������ ����
                              // � �� �஡��� ������ {0,""}
#define A__FUNCTION        5  // �맮� �㭪樨 �१ ���� ����
#define A__POPUPMENU       6  // ���� �� �� - ���� ������ ���� (��� �� popup)

// ��६���� ��� �-�� popup_edit (__regim_edit)
#define PE_EDIT       1 // (��� �� 㬮�砭��) - ����������, ।-�� � 㤠�����
#define PE_APP_SPACE  2 // ���������� � ������ ���� � �� �஡��� ������ {0,""}
#define PE_APP      2.5 // ���������� � ������ ����
#define PE_SPACE      3 // ������ ���� � �� �஡��� ������ {0,""}
                        // (� ०��� ।���஢���� f_edit_spr)
#define PE_RETURN     4 // ���� ������ ���� (��� �� popup)
#define PE_VIEW       5 // ��ᬮ��

// �����, �ᯮ��㥬� ����� �-�� F_EDIT_SPR
#xtranslate is_element(<mas>,<n>) => ;
         if(valtype(<mas>) == "A" .and. len(<mas>) >= <n>, <mas>\[<n>], NIL)

// ��६����, �ᯮ��㥬� ����� �-�� EDIT_BROWSE
#define BR_TOP              1   // |
#define BR_BOTTOM           2   // |
#define BR_LEFT             3   // |
#define BR_RIGHT            4   // ������� ����
#define BR_OPEN             5   // ���� ���� ��� ������ ��
#define BR_CLOSE            6   // ���� ���� ��� ������� ��
#define BR_SEMAPHORE        7   // ��ப� ᥬ��� (�᫨ ����室���)
#define BR_COLOR            8   // 梥� TBrowse
#define BR_TITUL            9   // ���������
#define BR_TITUL_COLOR     10   // 梥� ���������
#define BR_FL_INDEX        11   // �ந�����஢��� �� �� �� ��䠢���
#define BR_FL_NOCLEAR      12   // ����⠭�������� �� �࠭
#define BR_ARR_BLOCK       13   // ���ᨢ ������ ���� (Top, Bottom, Skip)
#define BR_STEP_FUNC       14   // ���� ����, �믮��塞� �� ������ 蠣�
#define BR_ARR_MOUSE       15   // ���ᨢ �����⥩ ��� ���
#define BR_ARR_BROWSE      16   // ���ᨢ ��㣨� ��ࠬ��஢ ��� TBrowse
#define BR_COLUMN          17   // ���ᨢ (�� 4 �-�) ��� �⮫�殢
#define BR_STAT_MSG        18   // ���� ���� - ��᫥ ���ᮢ�� TBrowse
#define BR_EDIT            19   // ���� ���� ��� ।���஢����
#define BR_ENTER           20   // ���� ���� - ��᫥ ������ ENTER � ����
#define BR_FREEZE          21   // ������⢮ ����஦����� �⮫�殢
#define BR_LEN             21   // ���� ����� ���ᨢ�

// ��६����, �ᯮ��㥬� ����� �-�� EDIT_U_SPR
#define US_TOP              1   // "N" |
#define US_BOTTOM           2   // "N" |
#define US_LEFT             3   // "N" |
#define US_RIGHT            4   // "N" ������� ����
#define US_BASE             5   // "C" ��� ��
#define US_SEMAPHORE        6   // "C" ��ப� ᥬ��� (�᫨ ����室���)
#define US_COLOR            7   // "C" 梥� TBrowse
#define US_TITUL            8   // "C" ���������
#define US_TITUL_COLOR      9   // "C" 梥� ���������
#define US_FL_INDEX        10   // "L" �ந�����஢��� �� �� �� ��䠢���
#define US_ARR_BROWSE      11   // ���ᨢ ��㣨� ��ࠬ��஢ ��� TBrowse
#define US_COLUMN          12   // "A" (�� 4 �-�) ��� �⮫�殢
#define US_EDIT_SPR        13   // "A" ���ᨢ ��६����� ��� ।���஢����
#define US_BLK_DEL         14   // "B" �஢�ઠ �� 㤠�����
#define US_BLK_DUBL        15   // "B" 㤠����� �㡫���⮢ � ��㣨� ��
#define US_ADD_MENU        16   // "A" ���ᨢ ��������� ���� {{pmt,msg,fun},...}
#define US_IM_PADEG        17   // "C" �����⥫�� �����
#define US_ROD_PADEG       18   // "C" த�⥫�� �����
#define US_FUNC_INPUT      19   // "C" ��� �-�� ��� �롮ન ��ப�
#define US_BLK_INDEX       20   // ���� ���� ��� ������஢���� ��
#define US_BLK_FILTER      21   // ���� ���� 䨫���樨 ��
#define US_BLK_WRITE       22   // ���� ���� ��� ����� ��㣨� �����
#define US_LEN             22   // ���� ����� ���ᨢ�
