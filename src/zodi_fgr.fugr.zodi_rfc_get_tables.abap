FUNCTION ZODI_RFC_GET_TABLES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_FLAG) TYPE  CHAR1
*"     VALUE(IV_VIEW_FLAG) TYPE  CHAR1
*"     VALUE(IV_TABLE) TYPE  CHAR30
*"     VALUE(IV_PACKG) TYPE  CHAR30
*"     VALUE(IV_AP_COMP) TYPE  CHAR30
*"     VALUE(IV_DESC) TYPE  CHAR80
*"  TABLES
*"      ET_TBL_LIST STRUCTURE  ZODI_BAPI_S_TBL_LIST
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      TABLES_NOT_AVAILABLE
*"      TABLE_NOT_AVAILABLE
*"      DESCRIPTION_NOT_MATCHING
*"      PACKAGE_NOT_AVAILABLE
*"      APPL_COMP_NOT_AVAILABLE
*"      PACKAGE_TABLE_NOT_AVAILABLE
*"--------------------------------------------------------------------


*"--------------------------------------------------------
* ODI Version Information:
*     KM: null
*     KM VERSION: null
*     OpenTool used during upload: 10.1.3.23
* SAP System Information used during Upload:
*     FF SAP_ABAP_VERSION: null
*"--------------------------------------------------------
*{   INSERT         EI6K900116               1
*Data Declaration
*Variables
DATA: gc_msgclass(15) TYPE c VALUE 'ZODI_MSG'.
DATA: gc_error VALUE 'E'.
DATA: gc_success VALUE 'S'.
DATA: BEGIN OF gt_message,
msgty LIKE sy-msgty,
msgid LIKE sy-msgid,
message LIKE sy-msgli,
msgno LIKE sy-msgno,
msgv1 LIKE sy-msgv1,
msgv2 LIKE sy-msgv2,
msgv3 LIKE sy-msgv3,
msgv4 LIKE sy-msgv4,
END OF gt_message.
DATA: lv_devclass        TYPE devclass.
DATA: lv_component       TYPE uffctr.
DATA: lv_module_name(24) TYPE c.
DATA: lv_comments(100)   TYPE c.
DATA: lv_tabclass        TYPE tabclass.
DATA: lv_tabname         TYPE tabname.
DATA: lv_count           TYPE i.
*Internal Tables
DATA: it_tbl_detls TYPE TABLE OF dd02l WITH
HEADER LINE.
DATA: it_tadir     TYPE TABLE OF tadir WITH
HEADER LINE.
DATA: it_tdevc     TYPE TABLE OF tdevc WITH
HEADER LINE.
DATA: lt_dd02t     TYPE TABLE OF dd02t WITH
HEADER LINE.
DATA: lt_df14l     TYPE TABLE OF df14l WITH
HEADER LINE.
DATA : gt_return  TYPE bapiret2.
FIELD-SYMBOLS: <fs1> TYPE ANY.
DATA:          oref1 TYPE REF TO data.
DATA: t_version           TYPE cvers.
IF iv_flag = ' ' .
if IV_VIEW_FLAG  = 'X'.
SELECT * FROM dd02l INTO TABLE it_tbl_detls
WHERE tabclass = 'VIEW'
AND as4local = 'A'
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'.
endif.
***For error message on table
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return-message TO et_return.
ENDIF.
****end of error message
LOOP AT it_tbl_detls .
Clear : lv_comments,lv_devclass,
lv_component,lv_module_name.
SELECT SINGLE ddtext INTO lv_comments
FROM dd02t
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage = sy-langu.
SELECT SINGLE devclass FROM tadir INTO
lv_devclass
WHERE pgmid ='R3TR'
AND   object = 'TABL'
AND obj_name = it_tbl_detls-tabname.
SELECT SINGLE component FROM tdevc INTO
lv_component
WHERE devclass = lv_devclass.
SELECT SINGLE ps_posid FROM df14l INTO
lv_module_name
WHERE fctr_id  = lv_component
AND   as4local = 'A'.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE lv_devclass           TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
SORT et_tbl_list BY module_name ASCENDING.
ELSE.
DO.
REPLACE '*' WITH '%' INTO iv_table.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '+' WITH '_' INTO iv_table.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '*' WITH '%' INTO iv_packg.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '+' WITH '_' INTO iv_packg.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '*' WITH '%' INTO iv_desc.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '+' WITH '_' INTO iv_desc.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '*' WITH '%' INTO iv_ap_comp.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
DO.
REPLACE '+' WITH '_' INTO iv_ap_comp.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDDO.
IF iv_table NE space.
IF iv_packg NE space.
IF iv_ap_comp NE space.
IF iv_desc NE space.
*Get based upon table,package,application
*component and table desc.
IF IV_VIEW_FLAG = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
ELSE.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
ENDIF.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tbl_detls .
SELECT * FROM dd02t INTO
TABLE lt_dd02t
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu
AND ddtext     LIKE iv_desc.
****for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
SELECT * FROM tadir INTO
TABLE it_tadir
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name =
it_tbl_detls-tabname
AND devclass LIKE iv_packg.
****for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
Clear : lv_component.
SELECT SINGLE component FROM
tdevc INTO lv_component
WHERE devclass =
it_tadir-devclass.
SELECT * FROM df14l INTO
TABLE lt_df14l
WHERE fctr_id  = lv_component
AND  as4local = 'A'
AND  ps_posid LIKE iv_ap_comp.
****for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_df14l.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext       TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
***********Endif for wrong Application comp.
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong package
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong table descritption
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong table name
ENDIF.
************************************
ELSE.
*Get based upon table, package and application
*component name.
IF IV_VIEW_FLAG = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
ELSE.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
ENDIF.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tbl_detls .
Clear : lv_comments.
SELECT SINGLE ddtext FROM dd02t
INTO lv_comments
WHERE tabname =
it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu.
SELECT * FROM tadir INTO
TABLE it_tadir
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name = it_tbl_detls-tabname
AND devclass LIKE iv_packg.
****for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
Clear : lv_component.
SELECT SINGLE component FROM
tdevc INTO lv_component
WHERE devclass =
it_tadir-devclass.
SELECT * FROM df14l INTO
TABLE lt_df14l
WHERE fctr_id  = lv_component
AND   as4local = 'A'
AND ps_posid LIKE iv_ap_comp.
****for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_df14l.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
***********Endif for wrong application component
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong package
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong table name
ENDIF.
************************************
ENDIF.
ELSEIF iv_desc NE space.
*Get based upon table, package and
*table descritption.
IF IV_VIEW_FLAG = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
endif.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tbl_detls .
SELECT * FROM dd02t INTO TABLE
lt_dd02t
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu
AND ddtext LIKE iv_desc.
****for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
SELECT * FROM tadir INTO TABLE
it_tadir
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name = it_tbl_detls-tabname
AND devclass LIKE iv_packg.
****for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
Clear : lv_component,
lv_module_name.
SELECT SINGLE component FROM
tdevc INTO lv_component
WHERE devclass =
it_tadir-devclass.
SELECT SINGLE ps_posid FROM
df14l INTO lv_module_name
WHERE fctr_id  = lv_component
AND   as4local = 'A'.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext       TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
***********Endif for wrong package
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong table description
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong table name
ENDIF.
************************************
ELSE.
*Get based upon table and package name.
if iv_view_flag = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
endif.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
***************
LOOP AT it_tbl_detls .
Clear : lv_comments.
SELECT SINGLE ddtext FROM dd02t INTO
lv_comments
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu.
SELECT * FROM tadir INTO TABLE
it_tadir
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name = it_tbl_detls-tabname
AND devclass LIKE iv_packg.
****for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
Clear : lv_component,
lv_module_name.
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = it_tadir-devclass.
SELECT SINGLE ps_posid FROM df14l
INTO lv_module_name
WHERE fctr_id  = lv_component
AND   as4local = 'A'.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
***********Endif for wrong package
ENDIF.
************************************
ENDLOOP.
***********Endif for wrong table name
ENDIF.
************************************
ENDIF.
ELSEIF iv_ap_comp NE space.
IF iv_desc NE space.
*Get based upon table, application component
*and Description
if iv_view_flag = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
endif.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
***************
LOOP AT it_tbl_detls .
SELECT * FROM dd02t INTO TABLE
lt_dd02t
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu
AND ddtext LIKE iv_desc.
****for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
Clear : lv_devclass,lv_component.
SELECT SINGLE devclass FROM tadir
INTO lv_devclass
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name =
it_tbl_detls-tabname.
SELECT SINGLE component FROM
tdevc INTO lv_component
WHERE devclass = lv_devclass.
SELECT * FROM df14l INTO TABLE
lt_df14l
WHERE fctr_id  = lv_component
AND   as4local = 'A'
AND ps_posid LIKE iv_ap_comp.
****for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_df14l.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE lv_devclass           TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext       TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
******endif for wrong applicaion comp.
ENDIF.
************************
ENDLOOP.
******endif for wrong description
ENDIF.
************************
ENDLOOP.
******endif for wrong table
ENDIF.
************************
ELSE.
*Get based upon table and application component.
if iv_view_flag = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
endif.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
***************
LOOP AT it_tbl_detls .
clear : lv_comments,lv_devclass.
SELECT SINGLE ddtext FROM dd02t INTO
lv_comments
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu.
SELECT SINGLE devclass FROM tadir
INTO lv_devclass
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name = it_tbl_detls-tabname
..
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = lv_devclass.
SELECT * FROM df14l INTO TABLE
lt_df14l
WHERE fctr_id  = lv_component
AND   as4local = 'A'
AND ps_posid LIKE iv_ap_comp.
****for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_df14l.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE lv_devclass           TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
********endif for worng application comp.
ENDIF.
*************************
ENDLOOP.
********endif for worng table name
ENDIF.
*************************
ENDIF.
ELSEIF iv_desc NE space.
*Get based upon TABLE and table description.
if iv_view_flag = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
endif.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
***************
LOOP AT it_tbl_detls .
SELECT * FROM dd02t INTO TABLE
lt_dd02t
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu
AND ddtext LIKE iv_desc.
****for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
Clear : lv_devclass, lv_component,
lv_module_name.
SELECT SINGLE devclass FROM tadir
INTO lv_devclass
WHERE pgmid = 'R3TR'
AND   object = 'TABL'
AND obj_name = it_tbl_detls-tabname.
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = it_tadir-devclass.
SELECT SINGLE ps_posid FROM df14l
INTO lv_module_name
WHERE fctr_id  = lv_component
AND   as4local = 'A'.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE lv_devclass           TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext       TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
********endif for wrong table description
ENDIF.
***************************
ENDLOOP.
********endif for wrong table name
ENDIF.
***************************
ELSE.
*Get based upon table name.
if iv_view_flag = 'X'.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN ('VIEW')
AND as4local = 'A'
AND tabname LIKE iv_table
AND viewclass IN ('D','P').
else.
SELECT * FROM dd02l INTO TABLE
it_tbl_detls
WHERE tabclass IN
('POOL','CLUSTER','TRANSP')
AND as4local = 'A'
AND tabname LIKE iv_table.
endif.
****for Wrong table name
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 000.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
***************
LOOP AT it_tbl_detls .
Clear : lv_comments,lv_devclass,
lv_component,lv_module_name.
SELECT SINGLE ddtext FROM dd02t INTO
lv_comments
WHERE tabname = it_tbl_detls-tabname
AND ddlanguage LIKE sy-langu.
SELECT SINGLE devclass FROM tadir
INTO lv_devclass
WHERE pgmid = 'R3TR'
AND (  object = 'TABL' or object = 'VIEW' )
AND obj_name = it_tbl_detls-tabname.
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = lv_devclass.
SELECT SINGLE ps_posid FROM df14l
INTO lv_module_name
WHERE fctr_id  = lv_component
AND   as4local = 'A'.
MOVE it_tbl_detls-tabname  TO
et_tbl_list-tabname.
MOVE it_tbl_detls-tabclass TO
et_tbl_list-tabclass.
MOVE lv_devclass           TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
CLEAR it_tbl_detls.
ENDLOOP.
******endif for wrong table name
ENDIF.
******************
ENDIF.
ELSEIF iv_packg NE space.
IF iv_ap_comp NE space.
IF iv_desc NE space.
*Get based upon package, application component
*and description.
SELECT * FROM tadir INTO TABLE it_tadir
WHERE pgmid ='R3TR'
AND   object = 'TABL'
AND devclass LIKE iv_packg.
***for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
SELECT * FROM dd02t INTO TABLE
lt_dd02t
WHERE tabname  = it_tadir-obj_name
AND ddlanguage = sy-langu
AND ddtext LIKE iv_desc.
****for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
exit.
ELSE.
********************
LOOP AT lt_dd02t.
Clear : lv_component.
SELECT SINGLE component FROM
tdevc INTO lv_component
WHERE devclass = it_tadir-devclass.
SELECT * FROM df14l INTO
TABLE lt_df14l
WHERE fctr_id  = lv_component
AND as4local = 'A'
AND ps_posid LIKE iv_ap_comp.
***for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ENDIF.
********************
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM
dd02l INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM
dd02l INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
LOOP AT lt_df14l.
MOVE it_tadir-obj_name     TO
et_tbl_list-tabname.
MOVE lv_tabclass           TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext     TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name .
APPEND et_tbl_list.
ENDLOOP.
ENDIF.
ENDLOOP.
********endif for wrong description
ENDIF.
************************
ENDLOOP.
********endif for wrong package
ENDIF.
************************
ELSE.
*Get based upon package and
*application component name.
SELECT * FROM tadir INTO TABLE it_tadir
WHERE pgmid ='R3TR'
AND   object = 'TABL'
AND devclass LIKE iv_packg.
***for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
clear : lv_comments,lv_component.
SELECT SINGLE ddtext FROM dd02t
INTO lv_comments
WHERE tabname  = it_tadir-obj_name
AND ddlanguage = sy-langu.
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = it_tadir-devclass.
SELECT * FROM df14l INTO
TABLE lt_df14l
WHERE fctr_id  = lv_component
AND as4local = 'A'
AND ps_posid LIKE iv_ap_comp.
***for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
exit.
ENDIF.
********************
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM dd02l
INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM dd02l
INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
LOOP AT lt_df14l.
MOVE it_tadir-obj_name     TO
et_tbl_list-tabname.
MOVE lv_tabclass           TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
ENDLOOP.
ENDIF.
ENDLOOP.
*******endif for wrong package
ENDIF.
********************
ENDIF.
ELSEIF iv_desc NE space.
*Get based upon package and description.
SELECT * FROM tadir INTO TABLE it_tadir
WHERE pgmid ='R3TR'
AND   object = 'TABL'
AND devclass
LIKE iv_packg.
***for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
SELECT * FROM dd02t INTO TABLE lt_dd02t
WHERE tabname  = it_tadir-obj_name
AND ddlanguage = sy-langu
AND ddtext LIKE iv_desc.
***for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
Clear : lv_component,lv_module_name,
lv_tabclass.
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = it_tadir-devclass.
SELECT SINGLE ps_posid FROM
df14l INTO lv_module_name
WHERE fctr_id  = lv_component
AND as4local = 'A'.
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM dd02l
INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM dd02l
INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
MOVE it_tadir-obj_name     TO
et_tbl_list-tabname.
MOVE lv_tabclass           TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext       TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
ENDIF.
ENDLOOP.
****endif for wrong description
ENDIF.
*************
ENDLOOP.
****endif for wrong packae
ENDIF.
*************
ELSE.
*Get based upon package name.
SELECT * FROM tadir INTO TABLE it_tadir
WHERE pgmid ='R3TR'
AND   object = 'TABL'
AND devclass LIKE iv_packg.
***for Wrong Package
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 002.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT it_tadir.
Clear : lv_comments,lv_component,
lv_module_name,lv_tabclass.
SELECT SINGLE ddtext FROM dd02t INTO
lv_comments
WHERE tabname  = it_tadir-obj_name
AND ddlanguage = sy-langu.
SELECT SINGLE component FROM tdevc
INTO lv_component
WHERE devclass = it_tadir-devclass.
SELECT SINGLE ps_posid FROM df14l
INTO lv_module_name
WHERE fctr_id  = lv_component
AND as4local = 'A'.
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM dd02l
INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM dd02l
INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
MOVE it_tadir-obj_name     TO
et_tbl_list-tabname.
MOVE lv_tabclass           TO
et_tbl_list-tabclass.
MOVE it_tadir-devclass     TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lv_module_name        TO
et_tbl_list-module_name.
APPEND et_tbl_list.
ENDIF.
ENDLOOP.
*******endif for wrong package
ENDIF.
***************************
ENDIF.
ELSEIF iv_ap_comp NE space.
IF iv_desc NE space.
*Get based upon application component and
*table description.
SELECT * FROM df14l INTO TABLE
lt_df14l
WHERE ps_posid  LIKE iv_ap_comp
AND   as4local  = 'A'.
***for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT  lt_df14l.
SELECT * FROM tdevc INTO TABLE it_tdevc
WHERE component = lt_df14l-fctr_id.
LOOP AT it_tdevc.
SELECT * FROM tadir INTO TABLE
it_tadir
WHERE pgmid  ='R3TR'
AND   object = 'TABL'
AND devclass = it_tdevc-devclass.
LOOP AT it_tadir.
SELECT * FROM dd02t INTO TABLE
lt_dd02t
WHERE tabname  = it_tadir-obj_name
AND ddlanguage = sy-langu
AND ddtext LIKE iv_desc.
***for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
Clear : lv_tabclass.
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM
dd02l INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM
dd02l INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
MOVE it_tadir-obj_name     TO
et_tbl_list-tabname.
MOVE lv_tabclass           TO
et_tbl_list-tabclass.
MOVE it_tdevc-devclass     TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext       TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
ENDIF.
ENDLOOP.
******endif for wrong description
ENDIF.
*********************
ENDLOOP.
ENDLOOP.
ENDLOOP.
******endif for wrong application comp
ENDIF.
*********************
ELSE.
*Get based upon application component.
SELECT * FROM df14l INTO TABLE lt_df14l
WHERE ps_posid  LIKE iv_ap_comp
AND   as4local  = 'A'.
***for Wrong Application component
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 003.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT  lt_df14l.
SELECT * FROM tdevc INTO TABLE
it_tdevc
WHERE component = lt_df14l-fctr_id.
LOOP AT it_tdevc.
SELECT * FROM tadir INTO TABLE
it_tadir
WHERE pgmid  ='R3TR'
AND ( object = 'TABL' OR
      object = 'VIEW' )
AND devclass = it_tdevc-devclass.
LOOP AT it_tadir.
Clear : lv_comments, lv_tabclass.
SELECT SINGLE ddtext INTO
lv_comments FROM dd02t
WHERE tabname  = it_tadir-obj_name
AND ddlanguage = sy-langu.
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM
dd02l INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM
dd02l INTO lv_tabclass
WHERE tabname = it_tadir-obj_name
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
MOVE it_tadir-obj_name     TO
et_tbl_list-tabname.
MOVE lv_tabclass           TO
et_tbl_list-tabclass.
MOVE it_tdevc-devclass     TO
et_tbl_list-devclass.
MOVE lv_comments           TO
et_tbl_list-comments.
MOVE lt_df14l-ps_posid     TO
et_tbl_list-module_name.
APPEND et_tbl_list.
ENDIF.
ENDLOOP.
ENDLOOP.
ENDLOOP.
******endif for wrong application comp.
ENDIF.
************************
ENDIF.
ELSE.
*Get based upon table description.
SELECT * FROM dd02t INTO TABLE lt_dd02t
WHERE ddtext   LIKE iv_desc
AND ddlanguage = sy-langu.
***for Wrong table description
IF sy-subrc <> 0.
CLEAR gt_message.
gt_message-msgty = gc_error.
gt_message-msgid = gc_msgclass.
gt_message-msgno = 001.
CALL FUNCTION 'BALW_BAPIRETURN_GET2'
EXPORTING
type   = gt_message-msgty
cl     = gt_message-msgid
number = gt_message-msgno
IMPORTING
return = gt_return.
APPEND gt_return TO et_return.
ELSE.
********************
LOOP AT lt_dd02t.
Clear : lv_devclass,lv_component,
lv_module_name,lv_tabclass.
SELECT SINGLE devclass FROM tadir INTO
lv_devclass
WHERE pgmid  ='R3TR'
AND   object = 'TABL'
AND obj_name = lt_dd02t-tabname.
SELECT SINGLE component FROM tdevc INTO
lv_component
WHERE devclass = lv_devclass.
SELECT SINGLE ps_posid FROM df14l INTO
lv_module_name
WHERE fctr_id  = lv_component
AND   as4local = 'A'.
if iv_view_flag = 'X'.
SELECT SINGLE tabclass FROM dd02l INTO
lv_tabclass
WHERE tabname = lt_dd02t-tabname
AND tabclass IN ('VIEW')
AND viewclass IN ('D','P').
else.
SELECT SINGLE tabclass FROM dd02l INTO
lv_tabclass
WHERE tabname = lt_dd02t-tabname
AND tabclass IN
('POOL','CLUSTER','TRANSP').
endif.
IF sy-subrc = 0.
MOVE lt_dd02t-tabname     TO
et_tbl_list-tabname.
MOVE lv_tabclass          TO
et_tbl_list-tabclass.
MOVE lv_devclass          TO
et_tbl_list-devclass.
MOVE lt_dd02t-ddtext      TO
et_tbl_list-comments.
MOVE lv_module_name       TO
et_tbl_list-module_name.
APPEND et_tbl_list.
ENDIF.
ENDLOOP.
*********endif for wrong table description
ENDIF.
**********************
ENDIF.
ENDIF.
IF NOT et_tbl_list IS INITIAL.
SORT et_tbl_list by tabname devclass.
DELETE ADJACENT DUPLICATES FROM et_tbl_list
COMPARING tabname devclass.
ENDIF.



ENDFUNCTION.
