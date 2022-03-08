***&---------------------------------------------------------------------*
**& Include          ZRPFI_ELEC_RPT_SP_SELSCRN
**&---------------------------------------------------------------------*
**----------------------------------------------------------------------*
** Selection Screen
**----------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*
*SELECT-OPTIONS: s_bukrs FOR acdoca-rbukrs,
*                s_lifnr FOR acdoca-lifnr,
*                s_belnr FOR acdoca-belnr,
*                s_date  FOR acdoca-budat OBLIGATORY,
*                s_blart FOR acdoca-blart.
*
*PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY,
*            p_rldnr TYPE acdoca-rldnr OBLIGATORY.
*
*SELECTION-SCREEN END OF BLOCK b1.
