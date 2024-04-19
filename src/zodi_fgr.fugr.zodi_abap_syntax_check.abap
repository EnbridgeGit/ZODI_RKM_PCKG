FUNCTION ZODI_ABAP_SYNTAX_CHECK.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      PROGRAM STRUCTURE  PROGTAB
*"      ET_FILE_RETURN STRUCTURE  BAPIRET2
*"--------------------------------------------------------------------


DATA: mess(72),wrd(72).
DATA: lin TYPE int4.
DATA: wa_file_return TYPE bapiret2.

IF NOT program[] IS INITIAL.
SYNTAX-CHECK FOR program
MESSAGE mess LINE lin WORD wrd.
IF mess <> space.
wa_file_return-type = 'E'.
wa_file_return-message = mess.
wa_file_return-row = lin.
APPEND wa_file_return TO et_file_return.
CLEAR:wa_file_return.
EXIT.
ELSE.
wa_file_return-type = 'S'.
wa_file_return-message = 'No syntax error'.
APPEND wa_file_return TO et_file_return.
CLEAR:wa_file_return.
ENDIF.
ENDIF.



ENDFUNCTION.
