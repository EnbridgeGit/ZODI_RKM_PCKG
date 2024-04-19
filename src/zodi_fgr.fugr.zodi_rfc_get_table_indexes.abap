FUNCTION ZODI_RFC_GET_TABLE_INDEXES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_QUERY_TABLE) TYPE  CHAR30
*"  TABLES
*"      ET_TABLE_INDEX_LIST STRUCTURE  ZODI_BAPI_S_TBL_INDEX_LIST
*"      ET_RETURN STRUCTURE  ZODIRETURN
*"  EXCEPTIONS
*"      TABLE_NOT_AVAILABLE
*"      SECONDARY_INDEX_NOT_AVAILABLE
*"--------------------------------------------------------------------


*"--------------------------------------------------------
* ODI Version Information:
*     KM: null
*     KM VERSION: null
*     OpenTool used during upload: 10.1.3.23
* SAP System Information used during Upload:
*     FF SAP_ABAP_VERSION: null
*"--------------------------------------------------------
DATA: lt_dd12l TYPE TABLE OF dd12l.
DATA: wa_dd12l LIKE LINE  OF lt_dd12l.
DATA: lt_dd17s TYPE TABLE OF dd17s.
DATA: wa_dd17s LIKE LINE  OF lt_dd17s.
SELECT * FROM dd12l  INTO TABLE lt_dd12l WHERE
sqltab = iv_query_table.
IF sy-subrc > 1.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc = 'table not available'.
APPEND et_return.
CLEAR et_return.
RAISE table_not_available.
ENDIF.
LOOP AT lt_dd12l INTO wa_dd12l.
SELECT * FROM dd17s  INTO TABLE lt_dd17s WHERE
sqltab = wa_dd12l-sqltab
AND indexname = wa_dd12l-indexname.
IF sy-subrc > 1.
et_return-stat_msg_type = 'E'.
et_return-stat_msg_desc ='sec index unavailable'.
APPEND et_return.
CLEAR et_return.
RAISE table_not_available.
ENDIF.
MOVE wa_dd12l-indexname TO
et_table_index_list-indexname.
LOOP AT lt_dd17s INTO wa_dd17s.
IF sy-tabix = 1.
MOVE wa_dd17s-fieldname TO
et_table_index_list-indexfields.
ELSE.
CONCATENATE et_table_index_list-indexfields
wa_dd17s-fieldname INTO
et_table_index_list-indexfields
SEPARATED BY ';'.
ENDIF.
ENDLOOP.
APPEND et_table_index_list.
ENDLOOP.



ENDFUNCTION.
