#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"

#define K_UNDO          K_CTRL_U

***** замена процедуры GetReader для чтения любого поля
PROCEDURE MyGetReader( oGet, blkFunc )
// Read the GET if the WHEN condition is satisfied
IF ( GetPreValidate( oGet ) )
  // Activate the GET for reading
  oGet:setFocus()
  DO WHILE ( oGet:exitState == GE_NOEXIT )
    // Check for initial typeout (no editable positions)
    IF ( oGet:typeOut )
      oGet:exitState := GE_ENTER
    ENDIF
    // Apply keystrokes until exit
    DO WHILE ( oGet:exitState == GE_NOEXIT )
      MyGetApplyKey( oGet, inkey( 0 ), blkFunc )
    ENDDO
    // Disallow exit if the VALID condition is not satisfied
    IF ( !GetPostValidate( oGet ) )
      oGet:exitState := GE_NOEXIT
    ENDIF
  ENDDO
  // De-activate the GET
  oGet:killFocus()
ENDIF
RETURN

***** замена процедуры GetApplyKey для чтения любого поля
PROCEDURE MyGetApplyKey( oGet, nKey, blkFunc )
LOCAL cKey, bKeyBlock
// Check for SET KEY first
IF !( ( bKeyBlock := setkey( nKey ) ) == NIL )
  GetDoSetKey( bKeyBlock, oGet )
  RETURN                           // NOTE
ENDIF
DO CASE
  CASE ( nKey == K_UP )
    oGet:exitState := GE_UP
  CASE ( nKey == K_SH_TAB )
    oGet:exitState := GE_UP
  CASE ( nKey == K_DOWN )
    oGet:exitState := GE_DOWN
  CASE ( nKey == K_TAB )
    oGet:exitState := GE_DOWN
  CASE ( nKey == K_ENTER )
    oGet:exitState := GE_ENTER
  CASE ( nKey == K_ESC )
    IF ( SET( _SET_ESCAPE ) )
      oGet:undo()
      oGet:exitState := GE_ESCAPE
    ENDIF
  CASE ( nKey == K_PGUP )
    oGet:exitState := GE_WRITE
  CASE ( nKey == K_PGDN )
    oGet:exitState := GE_WRITE
  CASE ( nKey == K_CTRL_HOME )
    oGet:exitState := GE_TOP
  CASE ( nKey == K_CTRL_W )
    oGet:exitState := GE_WRITE
  CASE ( nKey == K_INS )
    SET( _SET_INSERT, !SET( _SET_INSERT ) )
  CASE ( nKey == K_UNDO )
    oGet:undo()
  CASE ( nKey == K_HOME )
    oGet:home()
  CASE ( nKey == K_END )
    oGet:end()
  CASE ( nKey == K_RIGHT )
    oGet:right()
  CASE ( nKey == K_LEFT )
    oGet:left()
  CASE ( nKey == K_CTRL_RIGHT )
    oGet:wordRight()
  CASE ( nKey == K_CTRL_LEFT )
    oGet:wordLeft()
  CASE ( nKey == K_BS )
    oGet:backSpace()
  CASE ( nKey == K_DEL )
    oGet:delete()
  CASE ( nKey == K_CTRL_T )
    oGet:delWordRight()
  CASE ( nKey == K_CTRL_Y )
    oGet:delEnd()
  CASE ( nKey == K_CTRL_BS )
    oGet:delWordLeft()
  OTHERWISE
    if valtype(blkFunc) == "B"
      eval(blkFunc, oGet, nKey)
    else
      IF ( nKey >= 32 .AND. nKey <= 255 )
        cKey := CHR( nKey )
        IF ( oGet:type == "N" .AND. ( cKey == "." .OR. cKey == "," ) )
          oGet:toDecPos()
        ELSE
          IF ( SET( _SET_INSERT ) )
            oGet:insert( cKey )
          ELSE
            oGet:overstrike( cKey )
          ENDIF
          IF ( oGet:typeOut )
            IF ( SET( _SET_BELL ) )
              ?? CHR(7)
            ENDIF
            IF ( !SET( _SET_CONFIRM ) )
              oGet:exitState := GE_ENTER
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    endif
ENDCASE
RETURN
