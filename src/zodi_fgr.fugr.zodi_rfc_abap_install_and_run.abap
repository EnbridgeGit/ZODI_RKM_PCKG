FUNCTION ZODI_RFC_ABAP_INSTALL_AND_RUN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MODE) TYPE  SY-MSGTY
*"     VALUE(PROGRAMNAME) TYPE  SY-REPID
*"     VALUE(FUNCTION) TYPE  STRING
*"     VALUE(EXEC_AND_DEL) TYPE  CHAR1 OPTIONAL
*"     VALUE(IV_BACKGROUND) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(ERRORMESSAGE) LIKE  SY-MSGV1
*"  TABLES
*"      PROGRAM STRUCTURE  PROGTAB
*"      WRITES STRUCTURE  LISTZEILE
*"      ET_FILE_RETURN STRUCTURE  BAPIRET2
*"--------------------------------------------------------------------


DATA: BEGIN OF listobj OCCURS 20.
INCLUDE STRUCTURE abaplist.
DATA: END OF listobj.
DATA: mess(72),wrd(72),flag.
DATA: lin TYPE int4.
DATA: wa_file_return TYPE bapiret2.

DATA: systemedit  LIKE tadir-edtflag,
sys_cliinddep_edit LIKE t000-ccnocliind.
CALL FUNCTION 'TR_SYS_PARAMS'
IMPORTING
systemedit          = systemedit
sys_cliinddep_edit  = sys_cliinddep_edit
EXCEPTIONS
OTHERS                   = 1.
IF sy-subrc <> 0.
errormessage = 'Error in TR_SYS_PARAMS'.
wa_file_return-type = 'E'.
wa_file_return-message = errormessage.
APPEND wa_file_return TO et_file_return.
EXIT.
ENDIF.
IF systemedit EQ 'N'.
errormessage = 'SAP System has status not modifiable'.
wa_file_return-type = 'E'.
wa_file_return-message = errormessage.
APPEND wa_file_return TO et_file_return.
CLEAR:wa_file_return.
*MESSAGE e102(tk).
ENDIF.
IF sys_cliinddep_edit CA '23'.
errormessage = 'Changes to Repository not allowed'.
wa_file_return-type = 'E'.
wa_file_return-message = errormessage.
APPEND wa_file_return TO et_file_return.
CLEAR:wa_file_return.
*MESSAGE e729(tk).
ENDIF.
IF mode = 'F'.
SYNTAX-CHECK FOR program
MESSAGE mess LINE lin WORD wrd.
ENDIF.
IF mess <> space.
errormessage = mess.
wa_file_return-type = 'E'.
wa_file_return-message = errormessage.
wa_file_return-row = lin.
APPEND wa_file_return TO et_file_return.
CLEAR:wa_file_return.
EXIT.
ENDIF.
IF mode = 'F'.
INSERT REPORT programname FROM program.
ENDIF.
COMMIT WORK AND WAIT.
IF exec_and_del NE 'X'.
SUBMIT (programname) AND RETURN .
DATA lv_function TYPE rs38l_fnam.
DO 300 TIMES.
CLEAR lv_function.
SELECT SINGLE funcname FROM tfdir INTO
lv_function WHERE  funcname  = function.
IF sy-subrc = 0.
flag = 'X'.
EXIT.
ELSE.
WAIT UP TO 1 SECONDS.
ENDIF.
ENDDO.
IF flag NE 'X'.
et_file_return-type = 'E'.
et_file_return-message =
 'ABAP_INSTALL_RUN failed to Execute Uploader Report'.
errormessage = et_file_return-message.
APPEND et_file_return.
CLEAR et_file_return.
EXIT.
ENDIF.
IF iv_background NE 'X'.
 DELETE REPORT programname.
ENDIF.
DATA lv_func TYPE trobj_name.
lv_func = function.
CALL FUNCTION 'FUNC_OBJECT_ACTIVATE'
  EXPORTING
   object_name = lv_func
  EXCEPTIONS
  cancelled   = 1
  OTHERS      = 2.
IF sy-subrc <> 0.
MESSAGE ID sy-msgid
TYPE sy-msgty NUMBER sy-msgno INTO mess
WITH sy-msgv1 sy-msgv2
sy-msgv3 sy-msgv4 .
errormessage = mess.
wa_file_return-type = 'E'.
wa_file_return-message = errormessage.
APPEND wa_file_return TO et_file_return.
CLEAR:wa_file_return.
ENDIF.
WAIT UP TO 5 SECONDS.
ENDIF.



ENDFUNCTION.
