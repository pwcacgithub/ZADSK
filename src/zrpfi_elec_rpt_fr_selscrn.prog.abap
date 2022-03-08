*&---------------------------------------------------------------------*
*& Include          ZRPFI_ELEC_RPT_FR_SELSCRN
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs OBLIGATORY,
                s_hkont FOR acdoca-racct,
                s_lifnr FOR acdoca-lifnr,
                s_kunnr FOR acdoca-kunnr,
                s_blart FOR bkpf-blart.

PARAMETERS: p_gjahr TYPE acdoca-gjahr OBLIGATORY,
            p_rldnr TYPE acdoca-rldnr OBLIGATORY.

SELECT-OPTIONS: s_date FOR bkpf-budat OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.
