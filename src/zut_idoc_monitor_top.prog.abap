*&---------------------------------------------------------------------*
*& Include          ZUT_IDOC_MONITOR_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Declaration for Tables
*----------------------------------------------------------------------*
TABLES : edidc, edids, adr6.
*----------------------------------------------------------------------*
* Declaration for Data Objects
*----------------------------------------------------------------------*
DATA : gv_exit            TYPE c,
       gv_repid           TYPE sy-repid,
       gv_variant         TYPE disvariant,
***    Variable for Email alert
       gv_fcat_tabix      TYPE sy-tabix,
       gv_tabix           TYPE sy-tabix,
       gv_fcat_lines(3)   TYPE n,
       gv_lines(3)        TYPE n,
       gv_text            TYPE c LENGTH 150,
       gv_string          TYPE string,
       gv_size            TYPE so_obj_len,
       gv_subject         TYPE so_obj_des,
       gv_email           TYPE string,
       gv_sys_client      TYPE char6,
       gv_msg             TYPE string,
       gv_email_body_text TYPE thead-tdname,
       gv_langu           TYPE thead-tdspras,
       gv_retcode         TYPE i,
       gv_err_str         TYPE string.

*----------------------------------------------------------------------*
* Declaration for Type POOLS
*----------------------------------------------------------------------*
TYPE-POOLS: slis.

*----------------------------------------------------------------------*
* Declaration for Table Types
*----------------------------------------------------------------------*
TYPES : BEGIN OF ty_edidc,
          docnum TYPE edidc-docnum,
          status TYPE edidc-status,
          doctyp TYPE edidc-doctyp,
          direct TYPE edidc-direct,
          rcvprt TYPE edidc-rcvprt,
          rcvprn TYPE edidc-rcvprn,
          sndprt TYPE edidc-sndprt,
          sndprn TYPE edidc-sndprn,
          credat TYPE edidc-credat,
          cretim TYPE edidc-cretim,
          mestyp TYPE edidc-mestyp,
          idoctp TYPE edidc-idoctp,
          rcvpfc TYPE edidc-rcvpfc,
          sndpfc TYPE edidc-sndpfc,
          upddat TYPE edidc-upddat,
          updtim TYPE edidc-updtim,
        END OF ty_edidc.

TYPES : BEGIN OF ty_edids,
          docnum TYPE edids-docnum,
          logdat TYPE edids-logdat,
          logtim TYPE edids-logtim,
          countr TYPE edids-countr,
          status TYPE edids-status,
          statxt TYPE edids-statxt,
          stapa1 TYPE edids-stapa1,
          stapa2 TYPE edids-stapa2,
          stapa3 TYPE edids-stapa3,
          stapa4 TYPE edids-stapa4,
          statyp TYPE edids-statyp,
          stamid TYPE edids-stamid,
          stamno TYPE edids-stamno,
        END OF ty_edids.

*----------------------------------------------------------------------*
* Declaration for Work Area
*----------------------------------------------------------------------*

DATA : gw_edidc     TYPE ty_edidc,
       gw_edids     TYPE ty_edids,
       gw_final     TYPE zsidoc_monitor_output,

       gs_fieldcat  TYPE lvc_s_fcat,
       gs_layout    TYPE slis_layout_alv,
       gs_line      TYPE tline,
       gs_mail_body TYPE so_text255.

*----------------------------------------------------------------------*
* Declaration for Internal Tables
*----------------------------------------------------------------------*
DATA : gt_edidc            TYPE TABLE OF ty_edidc,
       gt_edids            TYPE TABLE OF ty_edids,
       gt_final            TYPE TABLE OF zsidoc_monitor_output,

       gt_slis_fcat        TYPE slis_t_fieldcat_alv,  " Field Catalog
***       Field Catalog for Email
       gt_fieldcat         TYPE lvc_t_fcat,
***   Table for Email alert
       gt_solix            TYPE solix_tab,
       gt_mail_body        TYPE soli_tab,
       gt_line             TYPE TABLE OF tline,
       gt_attach_attr      TYPE TABLE OF zsca_packlist,
       gt_pgm_const_values TYPE TABLE OF zspgm_const_values,
       gt_error_const      TYPE TABLE OF zserror_const,
       gw_attach_attr      TYPE zsca_packlist.

*----------------------------------------------------------------------*
* Declaration for Cursors
*----------------------------------------------------------------------*
DATA : g_cursor_edidc TYPE cursor,
       g_cursor_edids TYPE cursor.

*----------------------------------------------------------------------*
* Declaration for Constants
*----------------------------------------------------------------------*
CONSTANTS : gc_x                              VALUE 'X',
            gc_a                              VALUE 'A',
            gc_str_name   TYPE dd02l-tabname  VALUE 'ZSIDOC_MONITOR_OUTPUT',
            gc_seperator  TYPE c              VALUE cl_abap_char_utilities=>horizontal_tab,
            gc_cret(2)    TYPE c              VALUE cl_abap_char_utilities=>cr_lf,
            gc_codepage   TYPE abap_encod     VALUE '4103',
            gc_addbom     TYPE os_boolean     VALUE 'X',
            gc_email_type TYPE so_obj_tp      VALUE 'RAW',
            gc_bin        TYPE char3          VALUE 'BIN',
            gc_under      TYPE c              VALUE '_',
            gc_hyphen     TYPE c              VALUE '-',
            gc_outbound   TYPE char10         VALUE 'Outbound',   "##NO_TEXT.
            gc_inbound    TYPE char10         VALUE 'Inbound',    "##NO_TEXT.
            gc_st         TYPE thead-tdid     VALUE 'ST',
            gc_object     TYPE thead-tdobject VALUE 'TEXT'.

*----------------------------------------------------------------------*
* Declaration for Field Symbols
*----------------------------------------------------------------------*
FIELD-SYMBOLS : <fs_final>    TYPE  zsidoc_monitor_output,
                <fs_value>    TYPE any,
                <fs_fieldcat> TYPE lvc_s_fcat.

*----------------------------------------------------------------------*
* Declaration for Local Class
*----------------------------------------------------------------------*
DATA : g_recipient    TYPE REF TO if_recipient_bcs,
       g_document_bcs TYPE REF TO cl_document_bcs,
       g_bcs          TYPE REF TO cl_bcs,
       g_excep_bcs    TYPE REF TO cx_document_bcs,
       g_excep_bcs1   TYPE REF TO cx_document_bcs.
