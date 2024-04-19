FUNCTION ZODI_GET_SAP_MODULES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      ET_FILE_RETURN STRUCTURE  BAPIRET2
*"      IT_APPLN STRUCTURE  ZODI_APPL_COMP
*"--------------------------------------------------------------------


*"--------------------------------------------------------
* ODI Version Information:
*     KM: null
*     KM VERSION: null
*     OpenTool used during upload: 10.1.3.23
* SAP System Information used during Upload:
*     FF SAP_ABAP_VERSION: null
*"--------------------------------------------------------
TYPES:BEGIN OF lt_comp,
id    TYPE ufps_posid,
desc  TYPE udtext,
END OF lt_comp.
DATA: wa_comp   TYPE lt_comp,
it_comp   TYPE STANDARD TABLE OF lt_comp,
wa_appl   TYPE df14l,
it_appl   TYPE STANDARD TABLE OF df14l,
wa_df14t  TYPE df14t,
it_df14t  TYPE STANDARD TABLE OF df14t,
wa_appln  TYPE zodi_appl_comp.
SELECT * FROM df14l
INTO TABLE it_appl.
IF NOT it_appl IS INITIAL.
SELECT * FROM df14t
INTO TABLE it_df14t
FOR ALL ENTRIES IN it_appl
WHERE langu  = 'EN'
AND   addon  = ' '
AND   fctr_id  = it_appl-fctr_id
AND   as4local = 'A'.
ENDIF.
SORT it_df14t BY fctr_id.
SORT it_appl  BY fctr_id.
LOOP AT it_appl INTO wa_appl.
READ TABLE it_df14t INTO wa_df14t WITH KEY
fctr_id  = wa_appl-fctr_id
BINARY SEARCH.
IF sy-subrc EQ 0.
wa_comp-id    = wa_appl-ps_posid.
wa_comp-desc  = wa_df14t-name.
APPEND wa_comp TO it_comp.
ENDIF.
ENDLOOP.
SORT it_comp BY id ASCENDING.
LOOP AT it_comp INTO wa_comp.
SEARCH wa_comp-id FOR '-'.
IF sy-subrc NE 0.
wa_appln  = wa_comp.
APPEND wa_appln TO it_appln.
ENDIF.
ENDLOOP.
DELETE ADJACENT DUPLICATES FROM
it_appln COMPARING appl_comp.
SORT it_appln BY appl_comp ASCENDING.



ENDFUNCTION.
