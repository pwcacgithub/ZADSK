**&---------------------------------------------------------------------*
**& Include          ZRPFI_ROLL_FORWARD_RPT_FORM
**&---------------------------------------------------------------------*
**&-----------------------------------------------------------------------------------------------------------------------------------------*
**                                                          MODIFICATION HISTORY                                                            |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** Change Date |Developer           |RICEFW/Defect# |Transport#     |Description                                                            |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** 10-OCT-2019 |Sugeeth Sudhendran  |PTP.RPT.003    |D4SK907057     |Roll Forward Report - Asset Details with Group Currencies              |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** 24-OCT-2019 |Sneha Sharma        |PTP.RPT.003    |D4SK907321     |Roll Forward Report - changes done for period 1 :it should not take    |
**                                                                   the previous month data and CTA cost logic change-write up removed     |
**                                                                   Lable account determination changed to B/S account                     |
**                                                                   Write ups logic added to CTA Accum Dep                                 |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
** 30-OCT-2019 |Sneha Sharma        |PTP.RPT.003    |D4SK907446     |Roll Forward Report - making  depreciation posted key as checked       |              |
**&-----------------------------------------------------------------------------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Form F_GET_CONSTANTS
**&---------------------------------------------------------------------*
**& Fetch the constants for the program
**&---------------------------------------------------------------------*
*FORM f_get_constants USING lw_pgmid TYPE char40.
*
**** Call the FM to get the constants for the program
*  call function 'ZUTIL_PGM_CONSTANTS'
*    EXPORTING
*      im_pgmid               = lw_pgmid
*    TABLES
*      t_pgm_const_values     = gt_pgm_const_values
*      t_error_const          = gt_error_const
*    EXCEPTIONS
*      ex_no_entries_found    = 1
*      ex_const_entry_missing = 2
*      OTHERS                 = 3.
*  IF sy-subrc <> 0.
*    CASE sy-subrc.
*      WHEN 1.
*        MESSAGE e007(zfi_msgs) WITH 'TVARVC'(n01).    "No data found in TVARVC table
*      WHEN 2.
*        MESSAGE e010(zfi_msgs) WITH 'TVARVC'(n01).    "Atleast one constant entry missing in TVARVC table
*    ENDCASE.
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_COLLECT_CONSTANTS
**&---------------------------------------------------------------------*
**& Collect the value of the Constants in variables
**&---------------------------------------------------------------------*
*FORM f_collect_constants .
*
*  READ TABLE gt_pgm_const_values INTO DATA(lw_pgm_const_values) WITH KEY const_name = 'P_KURST_Z1'.
*  IF sy-subrc = 0.
*    gv_kurst_z1 = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025(zfi_msgs) WITH 'P_KURST_Z1'(p01).    "Constant P_KURST_Z1 not maintained in the ZTUTILITY_CONST table
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_KURST_M'.
*  IF sy-subrc = 0.
*    gv_kurst_m = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025(zfi_msgs) WITH 'P_KURST_M'(p02).     "Constant P_KURST_M not maintained in the ZTUTILITY_CONST table
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_WAERS_USD'.
*  IF sy-subrc = 0.
*    gv_waers_to = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025(zfi_msgs) WITH 'P_WAERS_USD'(p03).   "Constant P_WAERS_USD not maintained in the ZTUTILITY_CONST table
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_PERIV_A1'.
*  IF sy-subrc = 0.
*    gv_periv = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025(zfi_msgs) WITH 'P_PERIV_A1'(p04).    "Constant P_PERIV_A1 not maintained in the ZTUTILITY_CONST table
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_SRTVAR_0022'.
*  IF sy-subrc = 0.
*    gv_srtvar = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025(zfi_msgs) WITH 'P_SRTVAR_0022'(p05). "Constant P_SRTVAR_0022 not maintained in the ZTUTILITY_CONST table
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_AUTHORITY_CHECK
**&---------------------------------------------------------------------*
**& To check user's authorization
**&---------------------------------------------------------------------*
*FORM f_authority_check.
*
**** Get the valid Company Code from master table T001
*  IF s_bukrs[] IS NOT INITIAL.
*    SELECT bukrs
*      FROM t001
*      INTO TABLE @DATA(lt_t001)
*      WHERE bukrs IN @s_bukrs.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_t001 INTO DATA(lw_t001).
*        AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*          ID 'BUKRS' FIELD lw_t001-bukrs
*          ID 'ACTVT' FIELD '03'.
*        IF sy-subrc NE 0.
*          MESSAGE e064 WITH lw_t001-bukrs.    "No authorization to execute the report for company code &
*        ENDIF.
*        CLEAR lw_t001.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_FETCH_DATA
**&---------------------------------------------------------------------*
**& Fetch data
**&---------------------------------------------------------------------*
*FORM f_fetch_data.
*
**** Variable Declaration
*  DATA: lv_berdatum_prev TYPE dats,
*        lv_berdatum_curr TYPE dats,
*        lv_poper_prev    TYPE poper,
*        lv_poper_curr    TYPE poper,
*        lv_gjahr_prev    TYPE gjahr,
*        lv_gjahr_curr    TYPE gjahr.
*
**** Internal Table Declaration
*  DATA: lt_data_prev TYPE STANDARD TABLE OF fiaa_salvtab_ragitt,
*        lt_data_curr TYPE STANDARD TABLE OF fiaa_salvtab_ragitt,
*        lt_data      TYPE STANDARD TABLE OF fiaa_salvtab_ragitt.
*
**** Work Area Declaration
*  DATA: lw_data              TYPE fiaa_salvtab_ragitt,
*        lw_exch_rate_z1_prev TYPE bapi1093_0,
*        lw_exch_rate_z1      TYPE bapi1093_0,
*        lw_exch_rate_m       TYPE bapi1093_0.
*
**** Set Selection Screen Parameters
*  PERFORM f_set_sel_screen.
*
**** Set Period and Fiscal Year
*  lv_poper_curr = p_poper.
*  lv_gjahr_curr = p_gjahr.
*
*  lv_poper_prev = p_poper - 1.
*  lv_gjahr_prev = p_gjahr.
*  IF lv_poper_prev EQ 000.
*    lv_poper_prev = 012.
*    lv_gjahr_prev = p_gjahr - 1.
*  ENDIF.
*
*
**** Set the Report Date for previous Period
*  PERFORM f_get_last_date USING     lv_gjahr_prev
*                                    gv_periv        "A1
*                                    lv_poper_prev
*                          CHANGING  lv_berdatum_prev.
*
**When the period is 001 we dont need to consider the previous month details.
*IF p_poper NE c_001."Add of change : 479563:D4SK907321
*
**** Get ALV data from Asset History Sheet Report for previous Period
*  PERFORM f_get_alv_data  TABLES    lt_data_prev
*                          USING     lv_berdatum_prev.
*ENDIF. "Add of change : 479563:D4SK907321
*
**** Set the Report Date for entered Period
*  PERFORM f_get_last_date USING     lv_gjahr_curr
*                                    gv_periv        "A1
*                                    lv_poper_curr
*                          CHANGING  lv_berdatum_curr.
*
**** Get ALV data from Asset History Sheet Report for entered Period
*  PERFORM f_get_alv_data  TABLES    lt_data_curr
*                          USING     lv_berdatum_curr.
*
******Sort the internal tables as we will use Binary Search for the read table
*SORT lt_data_curr BY s1 s2.
*SORT lt_data_prev BY s1 s2.
*
**** Get the difference of previous and current data
*  IF lt_data_curr[] IS NOT INITIAL.
*    LOOP AT lt_data_curr INTO DATA(lw_data_curr).
*
*      MOVE-CORRESPONDING lw_data_curr TO lw_data.
*
***When the period is 001 we dont need to consider the previous month details.
*IF p_poper NE c_001."Add of change : 479563:D4SK907321
*
**** Calculate the final data using current and previous month data
*      READ TABLE lt_data_prev INTO DATA(lw_data_prev)
*        WITH KEY  s1 = lw_data_curr-s1
*                  s2 = lw_data_curr-s2 BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        lw_data-btr1  = lw_data_prev-btr7.      "APC FY start (LC) = Current APC (LC) of previous month
*        lw_data-btr8  = lw_data_prev-btr14.     "Dep. FY start (LC) = Accumul. dep. (LC) of previous month
*        lw_data-btr15 = lw_data_prev-btr16.     "Bk.val.FY strt (LC) = Curr.bk.val. (LC) of previous month
*
**** Below are the Diff. of current month and previous month
*        lw_data-btr2  = lw_data_curr-btr2 - lw_data_prev-btr2.      "Acquisition (LC)
*        lw_data-btr3  = lw_data_curr-btr3 - lw_data_prev-btr3.      "Retirement (LC)
*        lw_data-btr4  = lw_data_curr-btr4 - lw_data_prev-btr4.      "Transfer (LC)
*        lw_data-btr5  = lw_data_curr-btr5 - lw_data_prev-btr5.      "Post-capital. (LC)
*        lw_data-btr6  = lw_data_curr-btr6 - lw_data_prev-btr6.      "Invest.support (LC)
*
**** Below are the Diff. of current month and previous month
*        lw_data-btr9  = lw_data_curr-btr9 - lw_data_prev-btr9.      "Dep. for year (LC)
*        lw_data-btr10 = lw_data_curr-btr10 - lw_data_prev-btr10.    "Dep.retir. (LC)
*        lw_data-btr11 = lw_data_curr-btr11 - lw_data_prev-btr11.    "Dep.transfer (LC)
*        lw_data-btr12 = lw_data_curr-btr12 - lw_data_prev-btr12.    "Dep.post-cap. (LC)
*        lw_data-btr13 = lw_data_curr-btr13 - lw_data_prev-btr13.    "Write-ups (LC)
*
**** Below are same as the current month values
*        lw_data-btr7  = lw_data_curr-btr7.      "Current APC (LC)
*        lw_data-btr14 = lw_data_curr-btr14.     "Accumul. dep. (LC)
*        lw_data-btr16 = lw_data_curr-btr16.     "Curr.bk.val. (LC)
*
*ENDIF.
*
*"Begin of change : 479563:D4SK907321
***** If period is 001, don't consider the previous period / year values and only
***** get the data based on current period.
*ELSE.
*        lw_data-btr1  = lw_data_curr-btr1.      "APC FY start (LC) = Current APC (LC) of previous month
*        lw_data-btr8  = lw_data_curr-btr8.      "Dep. FY start (LC) = Accumul. dep. (LC) of previous month
*        lw_data-btr15 = lw_data_curr-btr15.     "Bk.val.FY strt (LC) = Curr.bk.val. (LC) of previous month
*
*        lw_data-btr2  = lw_data_curr-btr2 .      "Acquisition (LC)
*        lw_data-btr3  = lw_data_curr-btr3 .      "Retirement (LC)
*        lw_data-btr4  = lw_data_curr-btr4 .      "Transfer (LC)
*        lw_data-btr5  = lw_data_curr-btr5 .      "Post-capital. (LC)
*        lw_data-btr6  = lw_data_curr-btr6 .      "Invest.support (LC)
*
*        lw_data-btr9  = lw_data_curr-btr9  .      "Dep. for year (LC)
*        lw_data-btr10 = lw_data_curr-btr10 .     "Dep.retir. (LC)
*        lw_data-btr11 = lw_data_curr-btr11 .     "Dep.transfer (LC)
*        lw_data-btr12 = lw_data_curr-btr12 .     "Dep.post-cap. (LC)
*        lw_data-btr13 = lw_data_curr-btr13 .     "Write-ups (LC)
*
**** Below are same as the current month values
*        lw_data-btr7  = lw_data_curr-btr7.      "Current APC (LC)
*        lw_data-btr14 = lw_data_curr-btr14.     "Accumul. dep. (LC)
*        lw_data-btr16 = lw_data_curr-btr16.     "Curr.bk.val. (LC)
*ENDIF.
**End of change : 479563:D4SK907321
*
*
**** Find the Group currency value
*      IF lw_data-waers NE gv_waers_to.
*
**** Get the exchange rate value for type Z1 for previous period
*        PERFORM f_get_exch_rate USING     gv_kurst_z1
*                                          lw_data-waers
*                                          gv_waers_to
*                                          lv_berdatum_prev
*                                CHANGING  lw_exch_rate_z1_prev.
*
*
**** Get the exchange rate value for type Z1
*        PERFORM f_get_exch_rate USING     gv_kurst_z1
*                                          lw_data-waers
*                                          gv_waers_to
*                                          lv_berdatum_curr
*                                CHANGING  lw_exch_rate_z1.
*
*
**** Get the exchange rate value for type M
*        PERFORM f_get_exch_rate USING     gv_kurst_m
*                                          lw_data-waers
*                                          gv_waers_to
*                                          lv_berdatum_curr
*                                CHANGING  lw_exch_rate_m.
*
**** Add the Group Currency values to the final table
**** after the currency conversion
*        PERFORM f_curr_conv USING     lw_exch_rate_z1_prev
*                                      lw_data-btr1
*                            CHANGING  lw_data-zzbtr1_gc.    "APC FY start (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_z1_prev
*                                      lw_data-btr8
*                            CHANGING  lw_data-zzbtr8_gc.    "Dep. FY start (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_z1_prev
*                                      lw_data-btr15
*                            CHANGING  lw_data-zzbtr15_gc.   "Bk.val.FY strt (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr2
*                            CHANGING  lw_data-zzbtr2_gc.    "Acquisition (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr3
*                            CHANGING  lw_data-zzbtr3_gc.    "Retirement (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr4
*                            CHANGING  lw_data-zzbtr4_gc.    "Transfer (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr5
*                            CHANGING  lw_data-zzbtr5_gc.    "Post-capital. (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr6
*                            CHANGING  lw_data-zzbtr6_gc.    "Invest.support (GC)
*
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr9
*                            CHANGING  lw_data-zzbtr9_gc.    "Dep. for year (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr10
*                            CHANGING  lw_data-zzbtr10_gc.   "Dep.retir. (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr11
*                            CHANGING  lw_data-zzbtr11_gc.   "Dep.transfer (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr12
*                            CHANGING  lw_data-zzbtr12_gc.   "Dep.post-cap. (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_m
*                                      lw_data-btr13
*                            CHANGING  lw_data-zzbtr13_gc.   "Write-ups (GC)
*
*
*        PERFORM f_curr_conv USING     lw_exch_rate_z1
*                                      lw_data-btr7
*                            CHANGING  lw_data-zzbtr7_gc.    "Current APC (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_z1
*                                      lw_data-btr14
*                            CHANGING  lw_data-zzbtr14_gc.   "Accumul. dep. (GC)
*
*        PERFORM f_curr_conv USING     lw_exch_rate_z1
*                                      lw_data-btr16
*                            CHANGING  lw_data-zzbtr16_gc.   "Curr.bk.val. (GC)
*
*      ELSE.
*        lw_data-zzbtr1_gc   = lw_data-btr1.
*        lw_data-zzbtr2_gc   = lw_data-btr2.
*        lw_data-zzbtr3_gc   = lw_data-btr3.
*        lw_data-zzbtr4_gc   = lw_data-btr4.
*        lw_data-zzbtr5_gc   = lw_data-btr5.
*        lw_data-zzbtr6_gc   = lw_data-btr6.
*        lw_data-zzbtr7_gc   = lw_data-btr7.
*        lw_data-zzbtr8_gc   = lw_data-btr8.
*        lw_data-zzbtr9_gc   = lw_data-btr9.
*        lw_data-zzbtr10_gc  = lw_data-btr10.
*        lw_data-zzbtr11_gc  = lw_data-btr11.
*        lw_data-zzbtr12_gc  = lw_data-btr12.
*        lw_data-zzbtr13_gc  = lw_data-btr13.
*        lw_data-zzbtr14_gc  = lw_data-btr14.
*        lw_data-zzbtr15_gc  = lw_data-btr15.
*        lw_data-zzbtr16_gc  = lw_data-btr16.
*      ENDIF.
*
**** Show the Group Currency
*      lw_data-zzwaers_gc  = gv_waers_to.
*
**For the CTA cost write ups is not necessary based on the new formula
**so removing the write ups amount for this calculation
**** CTA Cost = Current APC (GC) - APC FY start (GC) - Acquisition (GC) -
****            Retirement (GC) - Transfer (GC) - Post-capital. (GC) -
****            Invest.support (GC)
*      lw_data-zzbtr17_gc_cost    = ( lw_data-zzbtr7_gc - lw_data-zzbtr1_gc - lw_data-zzbtr2_gc -
*                                     lw_data-zzbtr3_gc - lw_data-zzbtr4_gc - lw_data-zzbtr5_gc -
*                                     lw_data-zzbtr6_gc ).
*
**Adding the write ups amount in calculating CTA Acc Dep
**** CTA Acc Dep = Accumul. dep. (GC) - Dep. FY start (GC) - Dep. for year (GC) -
**** Dep.retir. (GC) - Dep.transfer (GC) - Dep.post-cap. (GC) - Write-ups (GC)
*      lw_data-zzbtr17_gc_dep  = ( lw_data-zzbtr14_gc - lw_data-zzbtr8_gc - lw_data-zzbtr9_gc -
*                                  lw_data-zzbtr10_gc - lw_data-zzbtr11_gc - lw_data-zzbtr12_gc
*                                  - lw_data-zzbtr13_gc ).
*
**** Remove leading zeroes from Account Determination
*      SHIFT lw_data-s2 LEFT DELETING LEADING '0'.
*
*      APPEND lw_data TO lt_data.
*      CLEAR lw_data.
*    ENDLOOP.
*  ENDIF.
*
**** Move the data to output table
*  gt_output = lt_data[].
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_SET_SEL_SCREEN
**&---------------------------------------------------------------------*
**& Set Selection Screen Parameters
**&---------------------------------------------------------------------*
*FORM f_set_sel_screen.
*
**** Work Area Declaration
*  DATA: lw_selscr TYPE rsparams.
*
**** Set Selection Screen Parameters
*  IF s_bukrs[] IS NOT INITIAL.
*    LOOP AT s_bukrs[] INTO s_bukrs.
*      lw_selscr-selname = 'BUKRS'(n02).        "Company Code
*      lw_selscr-kind    = 'S'.
*      lw_selscr-sign    = s_bukrs-sign.
*      lw_selscr-option  = s_bukrs-option.
*      lw_selscr-low     = s_bukrs-low.
*      lw_selscr-high    = s_bukrs-high.
*      APPEND lw_selscr TO gt_selscr.
*      CLEAR lw_selscr.
*    ENDLOOP.
*  ELSE.
*    lw_selscr-selname = 'BUKRS'(n02).          "Company Code
*    lw_selscr-kind    = 'S'.
*    lw_selscr-sign    = ''.
*    lw_selscr-option  = ''.
*    lw_selscr-low     = ''.
*    lw_selscr-high    = ''.
*    APPEND lw_selscr TO gt_selscr.
*    CLEAR lw_selscr.
*  ENDIF.
*
*  lw_selscr-selname = 'SRTVR'(n03).            "Sort Variant
*  lw_selscr-kind    = 'P'.
*  lw_selscr-sign    = ''.
*  lw_selscr-option  = ''.
*  lw_selscr-low     = gv_srtvar.    "'0022'
*  lw_selscr-high    = ''.
*  APPEND lw_selscr TO gt_selscr.
*  CLEAR lw_selscr.
*
*  lw_selscr-selname = 'SUMMB'(n04).            "... or group totals only
*  lw_selscr-kind    = 'P'.
*  lw_selscr-sign    = ''.
*  lw_selscr-option  = ''.
*  lw_selscr-low     = 'X'.
*  lw_selscr-high    = ''.
*  APPEND lw_selscr TO gt_selscr.
*  CLEAR lw_selscr.
*
*  lw_selscr-selname = 'P_GRID'(n05).           "Use ALV Grid
*  lw_selscr-kind    = 'P'.
*  lw_selscr-sign    = ''.
*  lw_selscr-option  = ''.
*  lw_selscr-low     = 'X'.
*  lw_selscr-high    = ''.
*  APPEND lw_selscr TO gt_selscr.
*  CLEAR lw_selscr.
*
**Begin of Insert 479563 :D4SK907446
*  lw_selscr-selname = 'PA_XGBAF'(n09).           "Depreciation posted
*  lw_selscr-kind    = 'P'.
*  lw_selscr-sign    = ''.
*  lw_selscr-option  = ''.
*  lw_selscr-low     = 'X'.
*  lw_selscr-high    = ''.
*  APPEND lw_selscr TO gt_selscr.
*  CLEAR lw_selscr.
**End of Insert 479563 :D4SK907446
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_GET_LAST_DATE
**&---------------------------------------------------------------------*
**& Get last date of the period
**&---------------------------------------------------------------------*
*FORM f_get_last_date USING iv_gjahr TYPE gjahr
*                              iv_periv TYPE periv
*                              iv_poper TYPE poper
*                     CHANGING iv_last_date TYPE dats.
*
**** Set the Report Date for previous Period
*  CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
*    EXPORTING
*      i_gjahr        = iv_gjahr
*      i_periv        = iv_periv
*      i_poper        = iv_poper
*    IMPORTING
*      e_date         = iv_last_date
*    EXCEPTIONS
*      input_false    = 1
*      t009_notfound  = 2
*      t009b_notfound = 3
*      OTHERS         = 4.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_GET_ALV_DATA
**&---------------------------------------------------------------------*
**& Get ALV Data from Report
**&---------------------------------------------------------------------*
*FORM f_get_alv_data TABLES lt_data TYPE STANDARD TABLE
*                    USING   lv_berdatum TYPE dats.
*
**** Object Declaration
*  DATA: lr_data TYPE REF TO data.
*
**** Field Symbol Declaration
*  FIELD-SYMBOLS: <lfs_data> TYPE ANY TABLE.
*
**** Internal Table and Work Area Declaration
*  DATA: lw_data TYPE fiaa_salvtab_ragitt.
*
**** Set the Class Parameters to read ALV data
*  CALL METHOD cl_salv_bs_runtime_info=>set
*    EXPORTING
*      display  = abap_false
*      metadata = abap_false
*      data     = abap_true.
*
**** Submit the Asset History Sheet Program to retrieve ALV
*  IF lv_berdatum IS NOT INITIAL.
*    SUBMIT ragitt_alv01
*      USING SELECTION-SET 'SAP&001'(n06)
*      WITH SELECTION-TABLE gt_selscr
*      WITH berdatum = lv_berdatum
*      AND RETURN.                                        "#EC CI_SUBMIT
*  ENDIF.
*
*  TRY.
**** Get the ALV data reference
*      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = lr_data ).
*      ASSIGN lr_data->* TO <lfs_data>.
*    CATCH cx_salv_bs_sc_runtime_info.
*      MESSAGE e032 WITH 'No Asset History Data retrieved'(t01).
*  ENDTRY.
*
**** Clear the Class Parameters
*  cl_salv_bs_runtime_info=>clear_all( ).
*
**** Get the ALV data to internal table
*  IF <lfs_data> IS ASSIGNED.
*    LOOP AT <lfs_data> ASSIGNING FIELD-SYMBOL(<lfs_data_wa>).
*      MOVE-CORRESPONDING <lfs_data_wa> TO lw_data.
*      APPEND lw_data TO lt_data.
*      CLEAR lw_data.
*    ENDLOOP.
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_GET_EXCH_RATE
**&---------------------------------------------------------------------*
**& Fetch the Exchange Rate
**&---------------------------------------------------------------------*
*FORM f_get_exch_rate USING iv_kurst TYPE kurst
*                               iv_fr_waers   TYPE waers
*                               iv_to_waers   TYPE waers
*                               iv_date       TYPE dats
*                     CHANGING  es_exch_rate  TYPE bapi1093_0.
*
**** Declaration for Workareas
*  DATA: lw_exch_rate TYPE bapi1093_0,
*        lw_return    TYPE bapiret1.
*
**** Call the FM to get the exchange rate value
*  CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*    EXPORTING
*      rate_type  = iv_kurst
*      from_curr  = iv_fr_waers
*      to_currncy = iv_to_waers
*      date       = iv_date
*    IMPORTING
*      exch_rate  = lw_exch_rate
*      return     = lw_return.
*  IF lw_exch_rate IS NOT INITIAL.
*    es_exch_rate = lw_exch_rate.
*  ELSE.
*    MESSAGE e032 WITH lw_return-message.
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_CURR_CONV
**&---------------------------------------------------------------------*
**& Currency Conversion
**&---------------------------------------------------------------------*
*FORM f_curr_conv USING VALUE(es_exch_rate) TYPE bapi1093_0
*                            VALUE(lv_input)     TYPE repbetrag
*                  CHANGING  lv_output           TYPE repbetrag.
*
**** Data Declaration
*  DATA: lv_input_conv TYPE bapicurr_d.
*
**** Convert to External Format
*  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*    EXPORTING
*      currency        = es_exch_rate-from_curr
*      amount_internal = lv_input
*    IMPORTING
*      amount_external = lv_input_conv.
*
**** Multiply with the Exchange Rate
*  lv_output = ( lv_input_conv * es_exch_rate-exch_rate ).
*
**** Divide by From Factor and multiply by To Factor
*  lv_output = ( lv_output / es_exch_rate-from_factor ) * es_exch_rate-to_factor.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_DISPLAY_DATA
**&---------------------------------------------------------------------*
**& Display Output Data
**&---------------------------------------------------------------------*
*FORM f_display_data.
*
**** Data Declaration
*  DATA: lw_tcollect TYPE fiaa_salvcollect.
*
**** Get the Sort Variant details from T086
*  SELECT SINGLE * FROM t086
*    INTO @DATA(lw_t086)
*    WHERE srtvar EQ @gv_srtvar.    "'0022'
*  IF sy-subrc EQ 0.
**** Initialize for add fields
*    IF lw_t086-anzuntnr IS INITIAL.
*      lw_t086-anzuntnr = 2.
*    ENDIF.
*  ENDIF.
*
**** Fill the Header Details for ALV
*  lw_tcollect-reportid = sy-repid.
*  lw_tcollect-list_title = 'Roll Forward Report'(t02).
**** Set the Report Date for ALV
*  PERFORM f_get_last_date USING     p_gjahr
*                                    gv_periv        "A1
*                                    p_poper
*                          CHANGING  lw_tcollect-berdatum.
*
**** Fill the sort table for ALV
*  REFRESH gt_sort_tab.
*  PERFORM f_fill_sort_tab USING lw_t086-tabln1  lw_t086-feldn1
*                                lw_t086-offset1 lw_t086-laenge1
*                                lw_t086-xsumm1  lw_t086-xaflg1
*                                lw_t086-xnewpg1.
*  PERFORM f_fill_sort_tab USING lw_t086-tabln2  lw_t086-feldn2
*                                lw_t086-offset2 lw_t086-laenge2
*                                lw_t086-xsumm2  lw_t086-xaflg2
*                                lw_t086-xnewpg2.
*  PERFORM f_fill_sort_tab USING lw_t086-tabln3  lw_t086-feldn3
*                                lw_t086-offset3 lw_t086-laenge3
*                                lw_t086-xsumm3  lw_t086-xaflg3
*                                lw_t086-xnewpg3.
*  PERFORM f_fill_sort_tab USING lw_t086-tabln4  lw_t086-feldn4
*                                lw_t086-offset4 lw_t086-laenge4
*                                lw_t086-xsumm4  lw_t086-xaflg4
*                                lw_t086-xnewpg4.
*  PERFORM f_fill_sort_tab USING lw_t086-tabln5  lw_t086-feldn5
*                                lw_t086-offset5 lw_t086-laenge5
*                                lw_t086-xsumm5  lw_t086-xaflg5
*                                lw_t086-xnewpg5.
*
**** Build Field Catlog for ALV
*  PERFORM f_build_fieldcat.
*
*** Call FM to display the ALV
*  CALL FUNCTION 'FIAA_ALV_DISPLAY'
*    EXPORTING
*      use_alv_grid   = 'X'
*      variante       = ''
*      tabname_header = ''
*      gitterbericht  = '0'
*      summen_bericht = 'X'
*      x_t086         = lw_t086
*      tcollect       = lw_tcollect
*    TABLES
*      itab_header    = gt_output[]
*      bukrs          = s_bukrs
*      sortfeld       = gt_sort_tab[].
*
*ENDFORM.
*
**---------------------------------------------------------------------*
** Form F_FILL_SORT_TAB
**---------------------------------------------------------------------*
** Fill the sort table for ALV as in standard FA Reports
**---------------------------------------------------------------------*
*FORM f_fill_sort_tab USING f_tabln f_feldn
*                            f_offset f_laenge
*                            f_xsumm  f_xaflg
*                            f_xnewpg.
*
**** Data Declaration
*  DATA: lv_char(10) TYPE c,
*        lv_ftext    TYPE dfies-reptext,
*        lv_position TYPE sy-fdpos.
*  DATA: lw_dfies        TYPE dfies.
*  DATA: lv_ddic_tabname   TYPE dfies-tabname,
*        lv_ddic_fieldname TYPE dfies-lfieldname.
*  DATA: lw_sort_tab TYPE fiaa_salvsort_felder.
*
*  IF f_tabln NE space.
*    CLEAR lw_sort_tab.
*
*    MOVE: f_tabln   TO lw_sort_tab-tabln,
*          f_feldn   TO lw_sort_tab-feldn,
*          f_offset  TO lw_sort_tab-foffset,
*          f_laenge  TO lw_sort_tab-laenge,
*          f_xsumm   TO lw_sort_tab-xsumm,
*          f_xaflg   TO lw_sort_tab-xaflg,
*          f_xnewpg  TO lw_sort_tab-xnewpg.
*
*    lv_ddic_tabname   = lw_sort_tab-tabln.
*    lv_ddic_fieldname = lw_sort_tab-feldn.
*    CALL FUNCTION 'DDIF_FIELDINFO_GET'
*      EXPORTING
*        tabname        = lv_ddic_tabname
*        lfieldname     = lv_ddic_fieldname
*      IMPORTING
*        dfies_wa       = lw_dfies
*      EXCEPTIONS
*        not_found      = 1
*        internal_error = 2
*        OTHERS         = 3.
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*
*    MOVE: lw_dfies-scrtext_m TO lw_sort_tab-ftext,
*          lw_dfies-headlen   TO lw_sort_tab-laeng,
*          lw_dfies-reptext   TO lw_sort_tab-spalt.
*
*    CONDENSE lv_char NO-GAPS.
*    IF lv_char CA ' '.
*    ENDIF.
*    lv_position = 20 - sy-fdpos.
*    lv_ftext = lw_sort_tab-ftext.
*    MOVE lv_ftext+lv_position TO  lv_char.
*
*    CONDENSE lv_ftext NO-GAPS.
*    lw_sort_tab-ftext = lv_ftext.
**** For offset and length: Correct LAENG.
*    IF NOT f_laenge IS INITIAL.
*      lw_sort_tab-laeng = f_laenge.
*    ENDIF.
*
*    APPEND lw_sort_tab TO gt_sort_tab.
*    CLEAR lw_sort_tab.
*  ENDIF.
*
*ENDFORM.
*
**---------------------------------------------------------------------*
** Form F_BUILD_FIELDCAT
**---------------------------------------------------------------------*
** Build Field Catlog for ALV
**---------------------------------------------------------------------*
*FORM f_build_fieldcat.
*
**** Build the field catalog for each column
**** Sequence for sub-routine f_build_fieldcat_line is as below
**** Column Name, Column Description, Column Output Length, Do Sum, Emphasize Column Value, Currency Field Name
*  PERFORM f_build_fieldcat_line USING 'S1'(f01)               'Company Code'(h01)         '6'  ''  ''     ''.
*  PERFORM f_build_fieldcat_line USING 'S2'(f02)               'B/S account'(h02)          '10' ''  ''     ''.
*  PERFORM f_build_fieldcat_line USING 'S2_TEXT'(f03)          ' '(h03)                    '20' ''  'C700' ''.
*  PERFORM f_build_fieldcat_line USING 'WAERS'(f04)            'Local Currency'(h04)       '5'  ''  'C700' ''.
*  PERFORM f_build_fieldcat_line USING 'BTR1'(f05)             'APC FY start'(h05)         '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR2'(f06)             'Acquisition'(h06)          '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR3'(f07)             'Retirement'(h07)           '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR4'(f08)             'Transfer'(h08)             '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR5'(f09)             'Post-capital'(h09)         '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR6'(f10)             'Invest.support'(h10)       '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR7'(f11)             'Current APC'(h11)          '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR8'(f12)             'Dep. FY start'(h12)        '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR9'(f13)             'Dep. for year'(h13)        '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR10'(f14)            'Dep.retir.'(h14)           '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR11'(f15)            'Dep.transfer'(h15)         '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR12'(f16)            'Dep.post-cap.'(h16)        '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR13'(f17)            'Write-ups'(h17)            '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR14'(f18)            'Accumul. dep.'(h18)        '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR15'(f19)            'Bk.val.FY strt'(h19)       '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'BTR16'(f20)            'Curr.bk.val.'(h20)         '10' 'X' ''     'WAERS'(n07).
*  PERFORM f_build_fieldcat_line USING 'ZZWAERS_GC'(f21)       'Group Currency'(h21)       '5'  ''  'C700' ''.
*  PERFORM f_build_fieldcat_line USING 'ZZBTR1_GC'(f22)        'APC FY start (GC)'(h22)    '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR2_GC'(f23)        'Acquisition (GC)'(h23)     '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR3_GC'(f24)        'Retirement (GC)'(h24)      '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR4_GC'(f25)        'Transfer (GC)'(h25)        '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR5_GC'(f26)        'Post-capital. (GC)'(h26)   '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR6_GC'(f27)        'Invest.support (GC)'(h27)  '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR7_GC'(f28)        'Current APC (GC)'(h28)     '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR8_GC'(f29)        'Dep. FY start (GC)'(h29)   '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR9_GC'(f30)        'Dep. for year (GC)'(h30)   '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR10_GC'(f31)       'Dep.retir. (GC)'(h31)      '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR11_GC'(f32)       'Dep.transfer (GC)'(h32)    '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR12_GC'(f33)       'Dep.post-cap. (GC)'(h33)   '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR13_GC'(f34)       'Write-ups (GC)'(h34)       '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR14_GC'(f35)       'Accumul. dep. (GC)'(h35)   '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR15_GC'(f36)       'Bk.val.FY strt (GC)'(h36)  '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR16_GC'(f37)       'Curr.bk.val. (GC)'(h37)    '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR17_GC_COST'(f38)  'CTA Cost (GC)'(h38)        '10' 'X' ''     'ZZWAERS_GC'(n08).
*  PERFORM f_build_fieldcat_line USING 'ZZBTR17_GC_DEP'(f39)   'CTA Acc Dep (GC)'(h39)     '10' 'X' ''     'ZZWAERS_GC'(n08).
*
*ENDFORM.
*
**---------------------------------------------------------------------*
** Form F_BUILD_FIELDCAT_LINE
**---------------------------------------------------------------------*
** Appends a field to the building block field catalog
**---------------------------------------------------------------------*
*FORM f_build_fieldcat_line USING iv_fieldname TYPE slis_fieldname
*                                  iv_seltext    TYPE scrtext_l
*                                  iv_outputlen  TYPE outputlen
*                                  iv_do_sum     TYPE char01
*                                  iv_emphasize  TYPE char04
*                                  iv_cfieldname TYPE slis_fieldname.
*
**** Data Declaration
*  DATA: lv_fieldcat_line TYPE slis_fieldcat_alv.
*
*  lv_fieldcat_line-fieldname  = iv_fieldname.
*  lv_fieldcat_line-cfieldname = iv_cfieldname.
*  lv_fieldcat_line-tabname    = 'FIAA_SALVTAB_RAGITT'.
*  lv_fieldcat_line-seltext_l  = iv_seltext.
*  lv_fieldcat_line-seltext_m  = iv_seltext.
*  lv_fieldcat_line-seltext_s  = iv_seltext.
*  lv_fieldcat_line-outputlen  = iv_outputlen.
*  lv_fieldcat_line-do_sum     = iv_do_sum.
*  lv_fieldcat_line-emphasize  = iv_emphasize.
*
**** Add the line to field catlog
*  PERFORM f_add_fieldcat_line USING lv_fieldcat_line.
*  CLEAR lv_fieldcat_line.
*
*ENDFORM.
*
**---------------------------------------------------------------------*
** Form F_ADD_FIELDCAT_LINE
**---------------------------------------------------------------------*
** Appends a field to the building block field catalog
**---------------------------------------------------------------------*
*FORM f_add_fieldcat_line USING iv_fieldcat_line TYPE slis_fieldcat_alv.
*
**** Call FM to Append a field to the building block field catalog
*  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
*    EXPORTING
*      fieldcat_line = iv_fieldcat_line
*    EXCEPTIONS
*      wrong_command = 1
*      OTHERS        = 2.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_CLEAR_GLOBAL_VAR
**&---------------------------------------------------------------------*
**& Clear Global Data
**&---------------------------------------------------------------------*
*FORM f_clear_global_var.
*
**** Clear global internal tables
*  REFRESH:  gt_selscr[],
*            gt_output[].
*
*ENDFORM.
