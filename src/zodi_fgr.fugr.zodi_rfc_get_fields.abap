FUNCTION ZODI_RFC_GET_FIELDS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(QUERY_TABLE) TYPE  CHAR30
*"     VALUE(DELIMITER) TYPE  CHAR1
*"     VALUE(NO_DATA) TYPE  CHAR1
*"     VALUE(ROWSKIPS) TYPE  SOID-ACCNT
*"     VALUE(ROWCOUNT) TYPE  SOID-ACCNT
*"  TABLES
*"      OPTIONS STRUCTURE  RFC_DB_OPT
*"      FIELDS STRUCTURE  ZODI_RFC_DB_FLD
*"      DATA STRUCTURE  TAB512
*"      ET_RETURN STRUCTURE  ZODIRETURN
*"  EXCEPTIONS
*"      TABLE_NOT_AVAILABLE
*"      TABLE_WITHOUT_DATA
*"      OPTION_NOT_VALID
*"      FIELD_NOT_VALID
*"      NOT_AUTHORIZED
*"      DATA_BUFFER_EXCEEDED
*"--------------------------------------------------------------------


*"--------------------------------------------------------
* ODI Version Information:
*     KM: null
*     KM VERSION: null
*     OpenTool used during upload: 10.1.3.23
* SAP System Information used during Upload:
*     FF SAP_ABAP_VERSION: null
*"--------------------------------------------------------
CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
EXPORTING
view_action                    = 'S'
view_name                      =
query_table
EXCEPTIONS
no_authority                   = 2
no_clientindependent_authority = 3
table_not_found                = 4.
IF sy-subrc = 2 OR sy-subrc = 3.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc = 'Not Authorized'.
APPEND et_return.
CLEAR et_return.
RAISE not_authorized.
ELSEIF sy-subrc = 1.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc = 'table not available'.
APPEND et_return.
CLEAR et_return.
RAISE table_not_available.
ENDIF.
DATA BEGIN OF table_structure OCCURS 10.
INCLUDE STRUCTURE dntab.
DATA END OF table_structure.
DATA table_header LIKE x030l.
DATA: BEGIN OF it_dd03l OCCURS 0,
tabname     TYPE   tabname,
fieldname   TYPE fieldname,
notnull     TYPE notnull,
leng        TYPE leng,
END OF it_dd03l .
CALL FUNCTION 'NAMETAB_GET'
EXPORTING
tabname             = query_table
IMPORTING
header              = table_header
TABLES
nametab             = table_structure
EXCEPTIONS
table_has_no_fields = 01
table_not_activ     = 02
internal_error      = 03
no_texts_found      = 04.
IF sy-subrc > 1.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc = 'table not available'.
APPEND et_return.
CLEAR et_return.
RAISE table_not_available.
ENDIF.
IF sy-subrc = 1 OR table_header-tabform CN
'TCPV'.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc = 'table without data'.
APPEND et_return.
CLEAR et_return.
RAISE table_without_data.
ENDIF.
DATA line_length TYPE i.
FIELD-SYMBOLS <d>.
ASSIGN COMPONENT 0 OF STRUCTURE data TO <d>.
DATA number_of_fields TYPE i.
DESCRIBE TABLE fields LINES number_of_fields.
IF number_of_fields = 0.
SELECT tabname fieldname notnull
INTO TABLE it_dd03l
FROM dd03l
WHERE tabname = query_table.
LOOP AT table_structure.
MOVE table_structure-fieldname TO
fields-fieldname.
READ TABLE it_dd03l WITH KEY tabname   =
table_structure-tabname
fieldname = table_structure-fieldname.
fields-notnull = it_dd03l-notnull.
APPEND fields.
CLEAR: table_structure, it_dd03l.
ENDLOOP.
ENDIF.
TYPES : BEGIN OF ty_field_int.
INCLUDE STRUCTURE ZODI_RFC_DB_FLD.
TYPES inttype.
TYPES: END OF ty_field_int.
DATA : it_output_fields TYPE TABLE OF
ty_field_int WITH HEADER LINE.
DATA : lv_leng TYPE dd03l-leng.
DATA : lv_rollname TYPE dd03l-rollname.
DATA: BEGIN OF fields_int OCCURS 10,
type LIKE
table_structure-inttype,
decimals   LIKE
table_structure-decimals,
length_src LIKE
table_structure-intlen,
length_dst LIKE
table_structure-ddlen,
offset_src LIKE
table_structure-offset,
offset_dst LIKE
table_structure-offset,
END OF fields_int,
line_cursor TYPE i.
line_cursor = 0.
LOOP AT fields.
SELECT SINGLE rollname
INTO lv_rollname
FROM dd03l
WHERE fieldname = fields-fieldname
and tabname = query_table .
IF lv_rollname IS NOT INITIAL.
SELECT SINGLE leng
INTO lv_leng
FROM dd04l
WHERE rollname = lv_rollname .
ELSE.
SELECT SINGLE leng
INTO lv_leng
FROM dd03l
WHERE TABNAME = QUERY_TABLE
AND FIELDNAME = fields-fieldname
AND as4vers = 'A'.
ENDIF.
READ TABLE table_structure WITH KEY
fieldname = fields-fieldname.
IF sy-subrc NE 0.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc =
'field not valid'.
APPEND et_return.
CLEAR et_return.
RAISE field_not_valid.
ENDIF.
IF line_cursor <> 0.
IF no_data EQ space AND delimiter NE space.
MOVE delimiter TO data+line_cursor.
ENDIF.
line_cursor = line_cursor +
STRLEN( delimiter ).
ENDIF.
fields_int-length_src =
table_structure-intlen.
fields_int-length_dst =
table_structure-ddlen.
fields_int-offset_src =
table_structure-offset.
fields_int-offset_dst =
line_cursor.
fields_int-decimals   =
table_structure-decimals.
line_cursor = line_cursor +
table_structure-ddlen.
IF line_cursor > line_length AND no_data
EQ space.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc =
'data buffer exceeded'.
APPEND et_return.
CLEAR et_return.
RAISE data_buffer_exceeded.
ENDIF.
APPEND fields_int.
fields-fieldtext   =
table_structure-fieldtext.
fields-datatype    =
table_structure-datatype.
fields-decimals    = fields_int-decimals  .
fields-offset      = fields_int-offset_dst.
fields-length      = lv_leng.
MODIFY fields.
CLEAR : lv_rollname, lv_leng.
ENDLOOP.
IF no_data EQ space.
DATA: BEGIN OF work, buffer(30000),
END OF work.
FIELD-SYMBOLS <f>.
IF rowcount > 0.
rowcount = rowcount + rowskips.
ENDIF.
SELECT * FROM (query_table) INTO work
WHERE (options).
IF sy-dbcnt GT rowskips.
LOOP AT fields_int.
IF fields_int-type = 'P'.
ASSIGN
work+fields_int-offset_src(fields_int-length_src)
TO <f>
TYPE     fields_int-type
DECIMALS fields_int-decimals.
ELSE.
ASSIGN
work+fields_int-offset_src(fields_int-length_src)
TO <f>
TYPE     fields_int-type.
ENDIF.
MOVE <f> TO
<d>+fields_int-offset_dst(fields_int-length_dst).
ENDLOOP.
APPEND data.
IF rowcount > 0 AND sy-dbcnt GE rowcount.
EXIT.
ENDIF.
ENDIF.
ENDSELECT.
ENDIF.



ENDFUNCTION.
