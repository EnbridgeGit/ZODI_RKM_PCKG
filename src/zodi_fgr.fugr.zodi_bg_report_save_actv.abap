FUNCTION ZODI_BG_REPORT_SAVE_ACTV.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PROGNAME) TYPE  CPROG
*"     VALUE(IV_PACKAGE) TYPE  DEVCLASS
*"     VALUE(IV_PREFIX) TYPE  CHAR100 OPTIONAL
*"     VALUE(OBJECT) TYPE  TROBJTYPE OPTIONAL
*"     VALUE(IV_DESC) TYPE  AS4TEXT OPTIONAL
*"     VALUE(IV_TRAN_LAYER) TYPE  BAPISCTS02 OPTIONAL
*"  TABLES
*"      ET_FILE_RETURN STRUCTURE  BAPIRET2
*"--------------------------------------------------------------------


CONSTANTS: c_shorttext  TYPE trdevclass-ctext
VALUE 'ODI Package',
c_reqtext         TYPE e07t-as4text
VALUE 'ODI Transport Request',
c_request         TYPE e070-trfunction
VALUE 'K',
c_task            TYPE e070-trfunction
VALUE 'S'.
DATA:
trans_req_no        TYPE e070-trkorr,
task_number         TYPE e070-trkorr,
lt_ko200            TYPE TREDT_OBJECTS ,
wa_ko200            TYPE ko200.

DATA: lt_E07T TYPE TABLE OF E07T,
wa_E07T TYPE E07T,
lt_e070 TYPE TABLE OF e070,
lt_e071 TYPE TABLE OF e071,
wa_e071 TYPE e071,
wa_e070 TYPE e070,
lv_skip TYPE char1,
ls_e07t TYPE e07t.


DATA: ls_ret TYPE  BAPIRET2,
      ls_task TYPE BAPISCTS07,
      lt_task TYPE TABLE OF BAPISCTS07,
      ls_author TYPE BAPISCTS12,
      tran_layer type BAPISCTS02,
      lt_author TYPE TABLE OF BAPISCTS12.

CLEAR lv_skip.
IF NOT IV_PREFIX IS INITIAL.
CONCATENATE IV_PREFIX '%' INTO
IV_PREFIX.
ELSE.
IV_PREFIX = IV_PROGNAME.
ENDIF.

SELECT *
 FROM e071
 INTO TABLE lt_e071
 WHERE pgmid = 'R3TR' AND
 object = object AND
 obj_name LIKE IV_PREFIX AND
 lockflag = 'X'.
 IF sy-subrc IS INITIAL AND
  NOT lt_e071 IS INITIAL.
   READ TABLE lt_e071 INTO wa_e071
 INDEX 1.
 IF sy-subrc IS INITIAL.
 SELECT SINGLE * from e070 INTO wa_e070
 WHERE TRKORR = wa_e071-trkorr.
 IF sy-subrc is initial.
 IF NOT wa_e070-strkorr IS INITIAL.
 trans_req_no = wa_e070-strkorr.
 ELSE.
 trans_req_no = wa_e071-trkorr.
 ENDIF.
*Getting the transport description
 SELECT SINGLE * from e07t
 INTO ls_e07t
 WHERE langu = sy-langu
 AND trkorr = trans_req_no.
 IF sy-subrc IS INITIAL.
  IF ls_e07t-as4text <> iv_desc.
    ls_e07t-as4text = iv_desc.
    UPDATE e07t FROM ls_e07t.
    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
      CLEAR et_file_return.
      et_file_return-type = 'S'.
      et_file_return-message = 'TR Description Updated'.
      APPEND et_file_return.
     ENDIF.
  ENDIF.
 ENDIF.
 lv_skip = 'X'.
ENDIF.
ENDIF.
ENDIF.


IF lv_skip IS INITIAL.
CLEAR trans_req_no.

ls_task-type = 'K'.
ls_task-author = sy-uname.
APPEND ls_task TO lt_task.

ls_author-task_owner = sy-uname.
APPEND ls_author TO lt_author.

*tran_layer-LAYER_SET = 'X'.
*tran_layer-LAYER = iv_tran_layer.
tran_layer = iv_tran_layer.

 CALL FUNCTION 'BAPI_CTREQUEST_CREATE'
   EXPORTING
    REQUEST_TYPE       = 'K'
    AUTHOR             = sy-uname
    TEXT               = c_reqtext
    TRANSLAYER         = tran_layer
  IMPORTING
    REQUESTID          = trans_req_no
    RETURN             = ls_ret
   TABLES
     AUTHORLIST         = lt_author
     TASK_LIST          = lt_task.
  IF sy-subrc <> 0.
   et_file_return-type = 'E'.
   et_file_return-MESSAGE =  ls_ret-message.
   APPEND et_file_return.
   EXIT.
  ELSE.
   READ TABLE lt_task INTO ls_task INDEX 2.
   IF sy-subrc = 0.
    task_number = ls_task-taskid.
   ENDIF.
  ENDIF.

ENDIF.
wa_ko200-trkorr = trans_req_no.
wa_ko200-pgmid = 'R3TR'.
wa_ko200-object = 'PROG'.
wa_ko200-obj_name = IV_PROGNAME.
wa_ko200-devclass = IV_PACKAGE.
wa_ko200-operation = 'I'.
APPEND wa_ko200 TO lt_ko200.
CLEAR wa_ko200.

CALL FUNCTION 'TR_EDIT_CHECK_OBJECTS_KEYS'
 EXPORTING
    WI_ORDER                             = trans_req_no
    WI_WITH_DIALOG                       = 'X'
    WI_SEND_MESSAGE                      = 'X'
    IV_APPEND_TO_ORDER                   = 'X'
  TABLES
    WT_E071                              = lt_ko200
 EXCEPTIONS
   CANCEL_EDIT_APPEND_ERROR_KEYS        = 1
   CANCEL_EDIT_APPEND_ERROR_OBJCT       = 2
   CANCEL_EDIT_APPEND_ERROR_ORDER       = 3
   CANCEL_EDIT_BUT_SE01                 = 4
   CANCEL_EDIT_NO_HEADER_OBJECT         = 5
   CANCEL_EDIT_NO_ORDER_SELECTED        = 6
   CANCEL_EDIT_REPAIRED_OBJECT          = 7
   CANCEL_EDIT_SYSTEM_ERROR             = 8
   CANCEL_EDIT_TADIR_MISSING            = 9
   CANCEL_EDIT_TADIR_UPDATE_ERROR       = 10
   CANCEL_EDIT_UNKNOWN_DEVCLASS         = 11
   CANCEL_EDIT_UNKNOWN_OBJECTTYPE       = 12
   SHOW_ONLY_CLOSED_SYSTEM              = 13
   SHOW_ONLY_CONSOLIDATION_LEVEL        = 14
   SHOW_ONLY_DDIC_IN_CUSTOMER_SYS       = 15
   SHOW_ONLY_DELIVERY_SYSTEM            = 16
   SHOW_ONLY_DIFFERENT_ORDERTYPES       = 17
   SHOW_ONLY_DIFFERENT_TASKTYPES        = 18
   SHOW_ONLY_ENQUEUE_FAILED             = 19
   SHOW_ONLY_GENERATED_OBJECT           = 20
   SHOW_ONLY_ILL_LOCK                   = 21
   SHOW_ONLY_LOCK_ENQUEUE_FAILED        = 22
   SHOW_ONLY_MIXED_ORDERS               = 23
   SHOW_ONLY_MIX_LOCAL_TRANSP_OBJ       = 24
   SHOW_ONLY_NO_SHARED_REPAIR           = 25
   SHOW_ONLY_OBJECT_LOCKED              = 26
   SHOW_ONLY_REPAIRED_OBJECT            = 27
   SHOW_ONLY_SHOW_CLIENT                = 28
   SHOW_ONLY_TADIR_MISSING              = 29
   SHOW_ONLY_UNKNOWN_DEVCLASS           = 30
   CANCEL_EDIT_NO_CHECK_CALL            = 31
   CANCEL_EDIT_CATEGORY_MIXTURE         = 32
   SHOW_ONLY_CLOSED_CLIENT              = 33
   SHOW_ONLY_CLOSED_ALE_OBJECT          = 34
   SHOW_ONLY_UNALLOWED_SUPERUSER        = 35
   CANCEL_EDIT_CUSTOM_OBJ_AT_SAP        = 36
   CANCEL_EDIT_ACCESS_DENIED            = 37
   SHOW_ONLY_NO_REPAIR_SYSTEM           = 38
   SHOW_ONLY_NO_LICENSE                 = 39
   SHOW_ONLY_CENTRAL_BASIS              = 40
   SHOW_ONLY_USER_AFTER_ERROR           = 41
   CANCEL_EDIT_USER_AFTER_ERROR         = 42
   SHOW_ONLY_OBJECT_NOT_PATCHABLE       = 43
   OTHERS                               = 44.
IF SY-SUBRC <> 0.
 CLEAR et_file_return.
 et_file_return-type = 'E'.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
 INTO et_file_return-message
 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
 APPEND et_file_return.
 EXIT.
ELSE.
 et_file_return-type = 'S'.
 et_file_return-message = 'Program added  to package'.
 APPEND et_file_return.
ENDIF.



ENDFUNCTION.
