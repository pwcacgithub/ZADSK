**&---------------------------------------------------------------------*
**& Include          ZRPFI_ELEC_RPT_SP_TOP
**&---------------------------------------------------------------------*
*TABLES: bkpf, acdoca, bset, lfa1.
*
**----------------------------------------------------------------------*
** Declaration for Table Types
**----------------------------------------------------------------------*
*TYPES:
*  BEGIN OF ty_output,
*"Changed the column order
*    xblnr       TYPE xblnr,         "477670|D4SK907641
*    belnr       TYPE belnr_d,       "477670|D4SK907641
*    lifnr       TYPE lifnr,
*    exp_date    TYPE bldat,
*    opr_date    TYPE bldat,
*    budat       TYPE budat,
*    stceg       TYPE stceg,
*    name1       TYPE name1_gp,
*    pswbt       TYPE acdoca-tsl,
*    tax_base1   TYPE bset-fwbas,
*    vat%1       TYPE bset-kbetr,
*    vat_amount1 TYPE bset-fwste,
*    tax_base2   TYPE bset-fwbas,
*    vat%2       TYPE bset-kbetr,
*    vat_amount2 TYPE bset-fwste,
*    tax_base3   TYPE bset-fwbas,
*    vat%3       TYPE bset-kbetr,
*    vat_amount3 TYPE bset-fwste,
**Begin of changes 477670 |  D4SK907471
*    tax_base4   TYPE bset-fwbas,
*    vat%4       TYPE bset-kbetr,
*    vat_amount4 TYPE bset-fwste,
**End of changes 477670   |  D4SK907471
*    lokkt       TYPE acdoca-lokkt,
*  END OF ty_output,
*
*  BEGIN OF ty_bkpf,
*    bukrs TYPE bukrs,
*    belnr TYPE belnr_d,
*    gjahr TYPE gjahr,
*    xblnr TYPE xblnr,
*  END OF ty_bkpf,
*
*  BEGIN OF ty_acdoca,
*    rldnr  TYPE rldnr,
*    rbukrs TYPE bukrs,
*    gjahr  TYPE gjahr,
*    belnr  TYPE belnr_d,
*    tsl    TYPE acdoca-tsl,
*    budat  TYPE budat,
*    bldat  TYPE bldat,
*    buzei  TYPE buzei,
*    lokkt  TYPE lokkt,
*    lifnr  TYPE lifnr,
*  END OF ty_acdoca,
*
**Begin of changes 477670 |  D4SK907471
*  BEGIN OF ty_bset_temp,
*    bukrs       TYPE bukrs,
*    belnr       TYPE belnr_d,
*    gjahr       TYPE gjahr,
*    buzei       TYPE buzei,
*    txgrp       TYPE txgrp,
*    tax_base1   TYPE bset-fwbas,
*    vat%1       TYPE bset-kbetr,
*    vat_amount1 TYPE bset-fwste,
*    tax_base2   TYPE bset-fwbas,
*    vat%2       TYPE bset-kbetr,
*    vat_amount2 TYPE bset-fwste,
*    tax_base3   TYPE bset-fwbas,
*    vat%3       TYPE bset-kbetr,
*    vat_amount3 TYPE bset-fwste,
*    tax_base4   TYPE bset-fwbas,
*    vat%4       TYPE bset-kbetr,
*    vat_amount4 TYPE bset-fwste,
*  END OF ty_bset_temp.
**End of changes 477670   |  D4SK907471
**----------------------------------------------------------------------*
** Declaration for Internal tables
**----------------------------------------------------------------------*
*DATA:
*  gt_output           TYPE TABLE OF ty_output,
*  gt_acdoca           TYPE TABLE OF ty_acdoca,
*  gt_bkpf             TYPE TABLE OF ty_bkpf,
*  gt_fieldcat         TYPE slis_t_fieldcat_alv,
*  gt_pgm_const_values TYPE TABLE OF zspgm_const_values,
*  gt_error_const      TYPE TABLE OF zserror_const,
*  gt_bset_temp        TYPE TABLE OF ty_bset_temp,           "477670|D4SK907471
*  gt_tax              TYPE RANGE OF sy-tcode.               "477670|D4SK907641
*
**----------------------------------------------------------------------*
** Declaration for constants
**----------------------------------------------------------------------*
*CONSTANTS :
*  c_001 TYPE buzei VALUE '001',
*  c_002 TYPE buzei VALUE '002',
*  c_003 TYPE buzei VALUE '003',
*  c_e   TYPE char1 VALUE 'E',
*  c_x   TYPE char1 VALUE 'X',
*  c_a   TYPE char1 VALUE 'A'.
**----------------------------------------------------------------------*
** Declaration for Work Area
**----------------------------------------------------------------------*
*DATA:
*  gw_output    TYPE ty_output,
*  gw_fieldcat  TYPE slis_fieldcat_alv,
*  gw_bset_temp TYPE ty_bset_temp,                           "477670|D4SK907471
*  gw_tax       LIKE LINE OF gt_tax.                         "477670|D4SK907641
