*&---------------------------------------------------------------------*
*& Include          ZRPFI_INVOICEUPLOAD_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Declaration for Table Types
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_data,
    bukrs        TYPE bukrs,
    xblnr        TYPE xblnr1,
    lifnr        TYPE lifnr,
    bldat        TYPE char10,
    budat        TYPE char10,
    total_amount TYPE wrbtr,
    tax_amount   TYPE wrbtr,
    waers        TYPE waers,
    expense_type TYPE char2,
    approval     TYPE char3,
    header_txt   TYPE char50,
    sgtxt        TYPE char100,
    ebeln        TYPE ebeln,
    ebelp        TYPE ebelp,
    menge        TYPE menge_d,
    wrbtr        TYPE wrbtr,
    mwskz        TYPE mwskz,
    bupla        TYPE bupla,
    zterm        TYPE dzterm,
    rzawe        TYPE dzlsch,
    hbkid        TYPE hbkid,
    hktid        TYPE hktid,
    bvtyp        TYPE bvtyp,
    hkont        TYPE hkont,
    kostl        TYPE kostl,
    anln1        TYPE anln1,
    ps_posid     TYPE ps_posid,
    prctr        TYPE prctr,
    fkber        TYPE fkber,
    zuonr        TYPE dzuonr,
    smtp_addr    TYPE ad_smtpadr,
    gst_part     TYPE j_1ig_partner,        "CATALYST-1239  | D4SK907337
    gst_no       TYPE /opt/vim_gst_no_de,   "CATALYST-1239  | D4SK907558
    hsn_sac      TYPE j_1ig_hsn_sac,        "CATALYST-1239  | D4SK907337
  END OF ty_data,

  BEGIN OF ty_data1,
    bukrs        TYPE bukrs,
    xblnr        TYPE xblnr1,
    lifnr        TYPE lifnr,
    bldat        TYPE char10,
    budat        TYPE char10,
    total_amount TYPE char25,
    tax_amount   TYPE char25,
    waers        TYPE waers,
    expense_type TYPE char2,
    approval     TYPE char3,
    header_txt   TYPE char50,
    sgtxt        TYPE char100,
    ebeln        TYPE ebeln,
    ebelp        TYPE ebelp,
    menge        TYPE char10,
    wrbtr        TYPE char25,
    mwskz        TYPE mwskz,
    bupla        TYPE bupla,
    zterm        TYPE dzterm,
    rzawe        TYPE dzlsch,
    hbkid        TYPE hbkid,
    hktid        TYPE hktid,
    bvtyp        TYPE bvtyp,
    hkont        TYPE hkont,
    kostl        TYPE kostl,
    anln1        TYPE anln1,
    ps_posid     TYPE ps_posid,
    prctr        TYPE prctr,
    fkber        TYPE fkber,
    zuonr        TYPE dzuonr,
    smtp_addr    TYPE ad_smtpadr,
    gst_part     TYPE j_1ig_partner,        "CATALYST-1239  | D4SK907337
    gst_no       TYPE /opt/vim_gst_no_de,   "CATALYST-1239  | D4SK907639
    hsn_sac      TYPE j_1ig_hsn_sac,        "CATALYST-1239  | D4SK907337
  END OF ty_data1,

  BEGIN OF ty_error,
    bukrs   TYPE bukrs,
    xblnr   TYPE xblnr,
    lifnr   TYPE lifnr,
    doctype TYPE /opt/doctype,
    index   TYPE /opt/docid,
    type    TYPE bapi_mtype,
    message TYPE bapi_msg,
  END OF ty_error.

*----------------------------------------------------------------------*
* Declaration for Internal tables
*----------------------------------------------------------------------*
DATA:
  gt_data1            TYPE TABLE OF ty_data,
  gt_data2            TYPE TABLE OF ty_data,
  gt_data3            TYPE TABLE OF ty_data,
  gt_data4            TYPE TABLE OF ty_data,
  gt_data5            TYPE TABLE OF ty_data,
  gt_final            TYPE TABLE OF ty_data,
  gt_messages         TYPE TABLE OF ty_error,
  gt_header           TYPE TABLE OF /opt/vim_1head,
  gt_item             TYPE TABLE OF /opt/vim_1item,
  gt_pgm_const_values TYPE TABLE OF zspgm_const_values,
  gt_error_const      TYPE TABLE OF zserror_const,
  gt_main             TYPE TABLE OF ty_data1,
  gt_val              TYPE RANGE OF sy-tcode.            "CATALYST-1239  | D4SK907337

*----------------------------------------------------------------------*
* Declaration for work areas
*----------------------------------------------------------------------*
DATA:
  gw_final  TYPE ty_data,
  gw_error  TYPE ty_error,
  gw_header TYPE /opt/vim_1head,
  gw_item   TYPE /opt/vim_1item,
  gw_val    LIKE LINE OF gt_val.              "CATALYST-1239  | D4SK907337


*----------------------------------------------------------------------*
* Declaration for Variables
*----------------------------------------------------------------------*
DATA:
  gv_amount        TYPE wrbtr,
  gv_channel       TYPE /opt/channel_id,
  gv_check         TYPE char1,
  gv_count         TYPE i,
  gv_i             TYPE char1,
  gv_p             TYPE char1,
  gv_x             TYPE char1,
  gv_e             TYPE char1,
  gv_blart_kr      TYPE blart,
  gv_blart_re      TYPE blart,
  gv_doctype_nonpo TYPE /opt/doctype,
  gv_doctype_po    TYPE /opt/doctype,
  gv_w             TYPE char1,
  gv_s             TYPE char1,
  gv_koart_k       TYPE koart,
  gv_d1            TYPE saearchivi,
  gv_q1            TYPE saearchivi,
  gv_p1            TYPE saearchivi,
  gv_attach_ext    TYPE string,
  gv_bukrs         TYPE bukrs,       "CATALYST-1239  | D4SK907337
  gv_ind           TYPE char2.       "CATALYST-1239  | D4SK907558


*----------------------------------------------------------------------*
* Declaration for Reference Objects
*----------------------------------------------------------------------*
DATA:
  go_file TYPE REF TO zcl_ca_utility,
  go_alv  TYPE REF TO zcl_ca_utility.
