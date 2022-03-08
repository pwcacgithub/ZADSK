*&---------------------------------------------------------------------*
*& Include          ZRPFI_INVOICEUPLOAD_SELSCR
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_fpath1 TYPE string OBLIGATORY,
            p_atach1 TYPE string.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_fpath2 TYPE string,
            p_atach2 TYPE string.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_fpath3 TYPE string,
            p_atach3 TYPE string.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_fpath4 TYPE string,
            p_atach4 TYPE string.

SELECTION-SCREEN SKIP 1.

PARAMETERS: p_fpath5 TYPE string,
            p_atach5 TYPE string.

SELECTION-SCREEN END OF BLOCK b1.
