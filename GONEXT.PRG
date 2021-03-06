************************************************************* 
* ����� �।�⠢��� ����� �㭪権 ��� ��������筮�� Tbrowse
* �� ���� ������. �ਬ�� �ᯮ�짮�����:
*
* Private _sh := n, _t_adres := "", _t_vlad := "", ;
*         blk_rr := {|| f3_poisk_disl() },;
*         nAddrLine := 1 // ����� ��ᬠ�ਢ����� ���᭮� ��ப�
* t_arr[BR_ARR_BLOCK] := {{|| goFirst(@nAddrLine,blk_rr) },;
*                         {|| goLast(@nAddrLine,blk_rr) },;
*                         {|x| goNext(x,@nAddrLine,blk_rr) },;
*                         "",".t.";
*                        }
*  aadd(t_arr[BR_COLUMN], { padc("������������",n),;
*                           {|| f4_poisk_disl(nAddrLine)}, blk })
* 
* ***** ������ ������⢠ �뢮����� ��ப � TBrowse
* Function f3_poisk_disl()
* Local k := 1
* _t_adres := _t_vlad := ""
* _t_adres := pr_adres(2,.f.)
* select VL
* find (str(disl->vlad,6))
* if found()
*   _t_vlad := alltrim(vl->vl_name)
* endif
* if !empty(_t_adres)
*   ++k
* endif
* if !empty(_t_vlad)
*   ++k
* endif
* select DISL
* return k
* 
* ***** �⮡ࠦ���� ��ப � TBrowse
* Function f4_poisk_disl(line)
* Local s := "", n := 5
* if line == 1
*   s := padr(disl->name,_sh)
* elseif line == 2
*   if !empty(_t_adres)
*     s := padr(space(n)+_t_adres,_sh)
*   elseif !empty(_t_vlad)
*     s := padr(space(n)+_t_vlad,_sh)
*   endif
* elseif line == 3
*   s := padr(space(n)+_t_vlad,_sh)
* endif
* return s
************************************************************* 
#include "inkey.ch"
#include "function.ch"

*****
FUNCTION goNext(nToSkip, line, blk_rr)
LOCAL nSkipped := 0, nDirection := iif(nToSkip >= 0, 1, -1)
DO WHILE nSkipped != nToSkip .AND. !eof() .AND. !bof()
  IF nDirection = 1
    //���砫� �஢�ਬ, ����� �� ��३� � ᫥���饬� ����
    IF line < eval(blk_rr)
      line++
    ELSE
      line := 1
      SKIP
    ENDIF
  ELSE
    //���砫� �஢�ਬ, ����� �� ��३� � �।��饬� ����
    IF line != 1
      line--
    ELSE
      SKIP -1
      if !bof()
        //����� ����� ������ ���� ��-�� bof()!!!
        line := eval(blk_rr)
      end
    ENDIF
  ENDIF
  nSkipped += nDirection
ENDDO
IF bof()
  nSkipped++
  GOTO recno()      //���� �⮡� ����� bof()
  line := 1
ELSEIF eof()
  SKIP -1
  nSkipped--
  line := eval(blk_rr)
ENDIF
RETURN nSkipped

*****
FUNCTION goFirst(line,blk_rr)
go top
line := 1
RETURN NIL

*****
FUNCTION goLast(line,blk_rr)
go bottom
line := eval(blk_rr)
RETURN NIL
