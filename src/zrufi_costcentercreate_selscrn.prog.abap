*&---------------------------------------------------------------------*
*& Include          ZRUFI_COSTCENTERCREATE_SELSCRN
*&---------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*
*PARAMETERS: p_kokrs TYPE kokrs MATCHCODE OBJECT csh_tka01 OBLIGATORY,
*            p_spras TYPE spras OBLIGATORY DEFAULT 'E'.
*SELECTION-SCREEN END OF BLOCK b1.
*
*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
*PARAMETERS: p_rad2 RADIOBUTTON GROUP grp1 USER-COMMAND ucomm DEFAULT 'X',
*            p_rad1 RADIOBUTTON GROUP grp1.
*
*PARAMETERS: p_fpath  TYPE string MODIF ID m1.
*SELECTION-SCREEN END OF BLOCK b2.
*
*SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
*PARAMETERS: p_test AS CHECKBOX.
*SELECTION-SCREEN END OF BLOCK b3.
