FUNCTION ZODI_RFC_TABLE_KEYS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TABLE_NAME) TYPE  CHAR30
*"     VALUE(IV_ALL_KEYS) TYPE  CHAR1
*"  TABLES
*"      ET_PRI_KEYS_TABLE STRUCTURE  ZODI_S_PK
*"      ET_FOR_KEYS_TABLE STRUCTURE  ZODI_S_FK
*"      ET_RETURN STRUCTURE  ZODIRETURN
*"--------------------------------------------------------------------


*"--------------------------------------------------------
* ODI Version Information:
*     KM: null
*     KM VERSION: null
*     OpenTool used during upload: 10.1.3.23
* SAP System Information used during Upload:
*     FF SAP_ABAP_VERSION: null
*"--------------------------------------------------------
DATA BEGIN OF table_structure OCCURS 10.
INCLUDE STRUCTURE dntab.
DATA END OF table_structure.
DATA table_header LIKE x030l.
DATA : table_dd05m TYPE STANDARD TABLE OF
dd05m WITH HEADER LINE.
DATA table LIKE dcobjdef-name.
table  = iv_table_name.
CALL FUNCTION 'NAMETAB_GET'
EXPORTING
tabname             = iv_table_name
IMPORTING
header              = table_header
TABLES
nametab             = table_structure
EXCEPTIONS
table_has_no_fields = 01
table_not_activ     = 02
internal_error      = 03
no_texts_found      = 04.
LOOP AT table_structure WHERE keyflag = 'X'
OR checktable NE space.
IF iv_all_keys = space.
IF table_structure-keyflag = 'X'.
et_pri_keys_table-pri_key_tabnam =
table_structure-tabname.
et_pri_keys_table-pri_key_field  =
table_structure-fieldname.
APPEND et_pri_keys_table.
CLEAR: table_structure,
et_pri_keys_table.
ENDIF.
ELSE.
*      IF table_structure-keyflag = 'X'.
IF NOT table_structure-checktable IS
INITIAL.
et_for_keys_table-table_name  =
table_structure-tabname.
et_for_keys_table-field_name  =
table_structure-fieldname.
et_for_keys_table-fk_table_name =
table_structure-checktable.
*       et_for_keys_table-fk_field_name =
*       table_structure-fieldname.
SELECT SINGLE ddtext INTO
et_for_keys_table-fk_table_text FROM dd02t
WHERE tabname = table_structure-checktable
and ddlanguage = sy-langu.
CALL FUNCTION 'DD_FKEYS_GET'
EXPORTING
name                 = table
state                = 'A'
langu                = 'E'
TABLES
*   DD03P_TAB            =
dd05m_tab            = table_dd05m
*   DD08V_TAB            =
EXCEPTIONS
illegal_input        = 1
not_found            = 2
expand_failure       = 3
OTHERS               = 4.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY
*  NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3
* SY-MSGV4.
ENDIF.
READ TABLE table_dd05m WITH KEY
fieldname = table_structure-fieldname
forkey   = table_structure-fieldname.
IF sy-subrc = 0.
et_for_keys_table-fk_field_name =
table_dd05m-checkfield.
ENDIF.
APPEND et_for_keys_table.
ENDIF.
CLEAR: table_structure, et_for_keys_table.
ENDIF.
ENDLOOP.
IF sy-subrc NE 0.
*    RAISE table_not_available.
ENDIF.



ENDFUNCTION.
