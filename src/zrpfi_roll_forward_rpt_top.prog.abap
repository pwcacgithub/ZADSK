***&---------------------------------------------------------------------*
**& Include          ZRPFI_ROLL_FORWARD_RPT_TOP
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
** Constants
**----------------------------------------------------------------------*
*constants: c_001(3) type c value '001'.
**----------------------------------------------------------------------*
** Declaration for Global Variables
**----------------------------------------------------------------------*
*  DATA: gv_kurst_z1 TYPE kurst,
*        gv_kurst_m  TYPE kurst,
*        gv_waers_to TYPE waers,
*        gv_periv    TYPE periv,
*        gv_srtvar   TYPE srtvar.
*
**----------------------------------------------------------------------*
** Declaration for Internal tables
**----------------------------------------------------------------------*
*  DATA: gt_pgm_const_values TYPE STANDARD TABLE OF zspgm_const_values,
*        gt_error_const      TYPE STANDARD TABLE OF zserror_const,
*        gt_selscr           TYPE STANDARD TABLE OF rsparams,
*        gt_output           TYPE STANDARD TABLE OF fiaa_salvtab_ragitt,
*        gt_sort_tab         TYPE STANDARD TABLE OF fiaa_salvsort_felder." OCCURS 5 WITH HEADER LINE.
