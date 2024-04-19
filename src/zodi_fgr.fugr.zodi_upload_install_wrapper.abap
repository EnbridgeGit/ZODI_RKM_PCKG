FUNCTION ZODI_UPLOAD_INSTALL_WRAPPER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MODE) TYPE  SY-MSGTY
*"     VALUE(PROGRAMNAME) TYPE  SY-REPID
*"     VALUE(LV_TASK) TYPE  TABNAME
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


DATA: lv_grp    TYPE rzlli_apcl,
wait_bfr  TYPE i  VALUE 1,
wait_afr  TYPE i  VALUE 1,
des       TYPE rfcdest.
CALL FUNCTION 'ZODI_RFC_ABAP_INSTALL_AND_RUN'
EXPORTING
mode           = mode
programname    = programname
function    = function
exec_and_del = exec_and_del
iv_background = iv_background
TABLES
program        = program
writes         = writes
et_file_return = et_file_return.



ENDFUNCTION.
