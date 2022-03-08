*&---------------------------------------------------------------------*
*& Include          ZRPFI_ELEC_RPT_FR_TOP
*&---------------------------------------------------------------------*

TABLES: bkpf, acdoca.

*----------------------------------------------------------------------*
* Declaration for Table Types
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_output,
    blart  TYPE blart,
    ltext  TYPE ltext_003t,
    belnr  TYPE belnr_d,
    budat  TYPE budat,
    hkont  TYPE hkont,
    txt50  TYPE txt50_skat,
    auxnum TYPE lifnr,
    mcod1  TYPE mcdd1,
    xblnr  TYPE xblnr,
    bldat  TYPE bldat,
    sgtxt  TYPE sgtxt,
    credit TYPE acdoca-hsl,
    debit  TYPE acdoca-hsl,
    augbl  TYPE augbl,
    augdt  TYPE augdt,
    cpudt  TYPE cpudt,
    wrbtr  TYPE acdoca-wsl,
    waers  TYPE waers,
    bukrs  TYPE bukrs,
    gjahr  TYPE gjahr,
    lokkt  TYPE lokkt,
  END OF ty_output,

  BEGIN OF ty_bkpf,
    bukrs TYPE bukrs,
    belnr TYPE belnr_d,
    gjahr TYPE gjahr,
    blart TYPE blart,
    bldat TYPE bldat,
    budat TYPE budat,
    cpudt TYPE cpudt,
    xblnr TYPE xblnr1,
    waers TYPE waers,
  END OF ty_bkpf,

  BEGIN OF ty_acdoca,
    rldnr  TYPE rldnr,
    rbukrs TYPE bukrs,
    gjahr  TYPE gjahr,
    belnr  TYPE belnr_d,
    racct  TYPE racct,
    wsl    TYPE acdoca-wsl,
    hsl    TYPE acdoca-hsl,
    drcrk  TYPE acdoca-drcrk,
    budat  TYPE budat,
    bldat  TYPE bldat,
    blart  TYPE blart,
    buzei  TYPE buzei,
    lokkt  TYPE altkt_skb1,
    sgtxt  TYPE sgtxt,
    lifnr  TYPE lifnr,
    kunnr  TYPE kunnr,
    augdt  TYPE augdt,
    augbl  TYPE augbl,
  END OF ty_acdoca.

*----------------------------------------------------------------------*
* Declaration for Internal tables
*----------------------------------------------------------------------*
DATA:
  gt_output           TYPE STANDARD TABLE OF ty_output,
  gt_bkpf             TYPE STANDARD TABLE OF ty_bkpf,
  gt_acdoca           TYPE STANDARD TABLE OF ty_acdoca,
  gt_pgm_const_values TYPE STANDARD TABLE OF zspgm_const_values,
  gt_error_const      TYPE STANDARD TABLE OF zserror_const,
  gt_fieldcat         TYPE slis_t_fieldcat_alv.

*----------------------------------------------------------------------*
* Declaration for Work Area
*----------------------------------------------------------------------*
DATA:
  gw_output   TYPE ty_output,
  gw_fieldcat TYPE slis_fieldcat_alv.

*----------------------------------------------------------------------*
* Declaration for Variables
*----------------------------------------------------------------------*
DATA:
  gv_h TYPE char1,
  gv_s TYPE char1,
  gv_x TYPE char1,
  gv_a TYPE char1,
  gv_e TYPE char1.
