#include "inkey.ch"
#include "function.ch"

**************************************************************************
* �㭪��    : SCANFILES()
* Copyright  : (c) 1990, 1991, 1992 Computer Associates International Inc.
*            : �� �ࠢ� ��࠭�����.
* ���       : 06/20/90
* ����      : Michael Peters / Lothar Bongartz
* �����頥� : �㭪�� �����頥� NIL
* �ਬ������ : �ᯮ���� ��� �㭪��, ����� ��ࠡ���� ᮤ�ন���
*              㪠������ ��४�ਨ � ��� �����४�਩. ��ࠡ�⪥
*              �����࣠���� �� 䠩��, 㪠����� � ��ࠬ��� FileSpec.
*              ����᪠���� 㪠����� 蠡����. ����� ��ࠧ�� �����
*              �࣠�������� �����筮 ᫮���� ��ࠡ��� 䠩���,
*              ������� XDEL ��� FILEFIND, ��אַ �� �ਪ������ �ணࠬ��.
*
* �ਬ��     : cFilespec  := "*.PRG"  // �� .PRG 䠩��
*              cStartPath := "\"      // ��稭�� � ��୥��� ��४�ਨ
*
* ������騥 ��ࠬ���� � ᮮ⢥�����騥 ��ࠢ����� � ���������� � �㭪樨
* ������� ������� �.�.
*          blk := {|x|QOUT(x)}
*          blk := {|x|deletefile(x)}  // ���� ���� ��� ������� 䠩��
*          if_delete := .t.           // 䫠� 㤠����� 䠩���
*                                     // .t., �᫨ � blk �⮨� deletefile,
*                                     //      ���� .f.
*          SCANFILES(cStartPath, cFilespec, blk, if_delete)
**************************************************************************
FUNCTION SCANFILES(cPath, cFilespec, blk, if_delete)
LOCAL cSeekEnv, cFile               // ��� ��࠭���� �।� FILESEEK
Local i                             // �� ४��ᨢ��� �맮���
DEFAULT cPath TO "", if_delete TO .f.
// ᭠砫� ��ࠡ��뢠���� �����४�ਨ
cFile := FILESEEK(cPath + "*.*", 16, .T.)
DO WHILE !EMPTY(cFile)
  IF LEFT(cFile,1) <> "."          // ".." � "." - "�����" ��४�ਨ
    IF ISBIT(FILEATTR(),5)         // �����४��� ?
      cSeekEnv := SAVEFSEEK()      // ��࠭���� �।� FILESEEK
      // ४��ᨢ�� �맮� � ���������� ��⥬ ����㯠
      SCANFILES(cPath + cFile + "\", cFilespec, blk, if_delete)
      if if_delete
        dirremove(cPath + cFile)
      endif
      RESTFSEEK(cSeekEnv)          // ����⠭������� �।�
    ENDIF
  ENDIF
  cFile := FILESEEK()              // ᫥����� �����४���
ENDDO
cFile := FILESEEK(cPath + cFileSpec , 32)
DO WHILE !EMPTY(cFile)
  eval(blk, cPath + cFile)         // �맮� ����� ���� ��� ������� 䠩��
  cFile := FILESEEK()              // ᫥���騩 䠩�
ENDDO
RETURN NIL                         // �����頥��� ���祭�� �������