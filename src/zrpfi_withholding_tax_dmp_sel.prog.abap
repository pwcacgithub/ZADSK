*&---------------------------------------------------------------------*
*& Include          ZRPFI_WITHHOLDING_TAX_DMP_SEL
*&---------------------------------------------------------------------*

DATA: lv_umskz TYPE bsik-umskz,
      lv_gjahr TYPE bsik-gjahr,
      lv_budat TYPE bsik-budat,
*//-- Start of Changes INC2732452 D4SK907855
      lv_augdt TYPE bsik-augdt,
      lv_hkont TYPE bsik-hkont.
*//-- End of Changes INC2732452 D4SK907855

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-004.
SELECT-OPTIONS :s_lifnr FOR lfa1-lifnr,
                s_bukrs FOR t001-bukrs.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1.

PARAMETERS: p_rad1 RADIOBUTTON GROUP grp1 USER-COMMAND ucomm DEFAULT 'X',
            p_rad2 RADIOBUTTON GROUP grp1.

SELECTION-SCREEN END OF BLOCK b1.


*Selection screen for withholding tax exemption report
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME .
PARAMETERS     : p_exto  TYPE wt_exdf MODIF ID b1,
                 p_check AS CHECKBOX MODIF ID b1.
SELECTION-SCREEN END OF BLOCK b3.

**Selection screen for Withholding tax posting information
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME .
SELECT-OPTIONS: s_gjahr FOR lv_gjahr  MODIF ID b2,
                s_budat FOR lv_budat  MODIF ID b2,
                s_umskz FOR lv_umskz  MODIF ID b2,
*//-- Start of Changes INC2732452 D4SK907855
                s_augdt FOR lv_augdt MODIF ID b2,
                s_hkont FOR lv_hkont MODIF ID b2.
*//-- End of Changes INC2732452 D4SK907855

PARAMETERS: p_ckey  TYPE t001-land1 MODIF ID b2,
            p_langu TYPE char2 DEFAULT 'EN' MODIF ID b2,
            p_email AS CHECKBOX MODIF ID b2.
SELECTION-SCREEN END OF BLOCK b4.
