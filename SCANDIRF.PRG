#include "inkey.ch"
#include "function.ch"

***** � ��, �� � ScanFiles, �� �� ����� ��४�ਨ cPath
FUNCTION SCANDIRFILES(cPath, cFilespec, blk)
LOCAL cFile
DEFAULT cPath TO "", cFilespec TO "*.*"
cFile := FILESEEK(cPath + cFileSpec , 32)
DO WHILE !EMPTY(cFile)
  eval(blk, cPath + cFile)         // �맮� ����� ���� ��� ������� 䠩��
  cFile := FILESEEK()              // ᫥���騩 䠩�
ENDDO
RETURN NIL                         // �����頥��� ���祭�� �������
