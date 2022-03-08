***&---------------------------------------------------------------------*
**& Include          ZRPFI_ROLL_FORWARD_RPT_SEL
**&---------------------------------------------------------------------*
**&-----------------------------------------------------------------------------------------------------------------------------------------*
**                                                          MODIFICATION HISTORY                                                            |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** Change Date |Developer           |RICEFW/Defect# |Transport#     |Description                                                            |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** 10-OCT-2019 |Sugeeth Sudhendran  |PTP.RPT.003    |D4SK907057     |Roll Forward Report - Asset Details with Group Currencies              |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** 24-OCT-2019 |Sneha Sharma        |PTP.RPT.003    |D4SK907321     |Roll Forward Report - changes done for period 1 :it should not take    |
**                                                                   the previous month data and CTA cost logic change                      |
**                                                                   Lable account determination changed to B/S account                     |
**                                                                   Write ups logic added to CTA Accum Dep                                 |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** 30-OCT-2019 |Sneha Sharma        |PTP.RPT.003    |D4SK907446     |Roll Forward Report - making  depreciation posted key as checked       |              |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
**----------------------------------------------------------------------*
** Tables
**----------------------------------------------------------------------*
*TABLES: anlav.
*
**----------------------------------------------------------------------*
** Selection Screen
**----------------------------------------------------------------------*
**** Custom Selections
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
*SELECT-OPTIONS: s_bukrs FOR anlav-bukrs.
*PARAMETERS: p_poper TYPE anlav-zuper OBLIGATORY,
*            p_gjahr TYPE anlav-zujhr OBLIGATORY.
*SELECTION-SCREEN END OF BLOCK b1.
