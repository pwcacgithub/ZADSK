*&---------------------------------------------------------------------*
*& Include          ZRPFI_ELEC_RPT_PL_SELSCRN
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*
*SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr OBLIGATORY,
*                s_bukrs FOR bkpf-bukrs OBLIGATORY ,
*                s_xblnr FOR bkpf-xblnr OBLIGATORY.
*
*PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY ,
*            p_rldnr TYPE acdoca-rldnr OBLIGATORY." Added :479563 :D4SK907123
*
*SELECT-OPTIONS: s_date FOR bkpf-budat ,
*                s_blart FOR acdoca-blart. "" Added :479563 :D4SK907123
*
*SELECTION-SCREEN END OF BLOCK b1.
