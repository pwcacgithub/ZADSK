**&---------------------------------------------------------------------*
**& Include          ZRPFI_ELEC_RPT_PL_TOP
**&---------------------------------------------------------------------*
*
*TABLES : bkpf, lfa1, acdoca.
**----------------------------------------------------------------------*
** Declaration for Table Types
**----------------------------------------------------------------------*
*TYPES: BEGIN OF ty_output,
*         stceg      TYPE stceg,
*         name1      TYPE name1,
*         address    TYPE char100,
*         belnr      TYPE belnr_d,
*         xblnr      TYPE xblnr1,
*         bldat      TYPE bldat,
*         budat      TYPE budat,
*         fxnetamt   TYPE fwbas_bses,
*         fxvatamt   TYPE fwste,
*         gdnetamt   TYPE fwbas_bses,
*         gdvatamt   TYPE fwste,
*         notpaidinv TYPE wrbtr,
*         paidinv    TYPE wrbtr,
*         lokkt      TYPE lokkt, "Added 479563 : D4SK907123
*       END OF ty_output,
*
*
*       BEGIN OF ty_bkpf,
*         bukrs TYPE bukrs,                       "Company code
*         belnr TYPE belnr_d,                     "Accounting document
*         gjahr TYPE gjahr,                       "Fiscal year
*         blart TYPE bkpf-blart,                  "Document type
*         bldat TYPE bkpf-bldat,                  "Document date in document
*         budat TYPE bkpf-budat,                  "Posting date in document
*         monat TYPE monat,                       "Fiscal Period
*         cpudt TYPE bkpf-cpudt,                  "Day Accounting Document Was Entered
*         xblnr TYPE bkpf-xblnr,                  "Reference document number
*         stblg TYPE stblg,                       "Reverse Document Number
*         rldnr TYPE fins_ledger,
*       END OF ty_bkpf,
*
**Begin of 479563 : D4SK907123
*       BEGIN OF ty_acdoca,
*         rldnr  TYPE rldnr,
*         rbukrs TYPE bukrs,
*         gjahr  TYPE gjahr,
*         belnr  TYPE belnr_d,
*         blart  TYPE blart,
*         bschl  TYPE bschl,
*         lokkt  TYPE lokkt,
*         lifnr  TYPE lifnr,
*         augdt  TYPE augdt,
*         anln1  TYPE anln1,
*         netdt TYPE netdt,
*       END OF ty_acdoca.
**End of 479563 : D4SK907123
*
**----------------------------------------------------------------------*
** Declaration for Constants
**----------------------------------------------------------------------*
*CONSTANTS : c_e  TYPE char1 VALUE 'E',
*            c_i  TYPE char1 VALUE 'I',
*            c_eq TYPE char2 VALUE 'EQ'.
**----------------------------------------------------------------------*
** Declaration for Internal tables
**----------------------------------------------------------------------*
*DATA:
*  gt_output           TYPE STANDARD TABLE OF ty_output,
*  gt_bkpf             TYPE STANDARD TABLE OF  ty_bkpf,
*  gt_pgm_const_values TYPE TABLE OF zspgm_const_values,
*  gt_error_const      TYPE TABLE OF zserror_const,
*  gt_fieldcat         TYPE slis_t_fieldcat_alv,
*  gt_acdoca           TYPE TABLE OF ty_acdoca. "Added 479563 : D4SK907123
*
**----------------------------------------------------------------------*
** Declaration for Work Area
**----------------------------------------------------------------------*
*DATA:
*  gw_output   TYPE ty_output,
*  gw_fieldcat TYPE slis_fieldcat_alv.
*
**----------------------------------------------------------------------*
** Declaration for Variables
**----------------------------------------------------------------------*
*DATA:
*  gv_re TYPE char2,
*  gv_kr TYPE char2,
*  gv_kg TYPE char2,
*  gv_ka TYPE char2,
*  gv_31 TYPE char2,
*  gv_21 TYPE char2,
*  gv_22 TYPE char2.
