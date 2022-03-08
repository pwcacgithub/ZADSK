**&---------------------------------------------------------------------*
**& Include          ZRUFI_COSTCENTERCREATE_FORM
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Form READ_FILE
**&---------------------------------------------------------------------*
**& Read the file from Application/Presentation Server
**&---------------------------------------------------------------------*
*FORM f_read_file.
*
*** Get the source of file
*  IF p_rad1 = gv_x.
*    gv_s = gv_a.
*  ELSEIF p_rad2 = gv_x.
*    gv_s = gv_p.
*  ENDIF.
*
*  CLEAR: gv_hdr.
*  gv_hdr = gv_x.
*
*  CREATE OBJECT go_file.
*
** Read the file based on the source of the file
*  CALL METHOD go_file->read_file
*    EXPORTING
*      i_filename        = p_fpath
*      i_source          = gv_s
*      i_delimiter       = ','
*      i_hdr             = gv_hdr
*    CHANGING
*      e_datatab         = gt_data
*    EXCEPTIONS
*      cannot_open_file  = 1
*      invalid_delimeter = 2
*      error_in_read     = 3
*      invalid_source    = 4
*      OTHERS            = 5.
*  IF sy-subrc <> 0.
*    CASE sy-subrc.
*      WHEN 1 OR 3 OR 4.
*        MESSAGE e013 WITH'check the path or authorization'(011).
*      WHEN 2.
*        MESSAGE e012 WITH 'valid delimiter'(010).
*      WHEN 5.
*        MESSAGE e018.
*    ENDCASE.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form CALL_BAPI
**&---------------------------------------------------------------------*
**& Call the BAPI BAPI_COSTCENTER_CREATEMULTIPLE to create cost centers
**&---------------------------------------------------------------------*
*FORM f_call_bapi .
*
*  DATA : lv_datefrom TYPE char8,
*         lv_dateto   TYPE char8.
*
*  CLEAR: gv_test.
*
*  gv_test = p_test.
*
*** Populate the bapi table based on the data read from the file
*  LOOP AT gt_data INTO DATA(lw_data).
*    REFRESH: gt_costcenterlist, gt_return.
*    CLEAR: gw_costcenterlist.
*
*    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*      EXPORTING
*        date_external            = lw_data-datab
*      IMPORTING
*        date_internal            = lv_datefrom
*      EXCEPTIONS
*        date_external_is_invalid = 1
*        OTHERS                   = 2.
*
*    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*      EXPORTING
*        date_external            = lw_data-datbi
*      IMPORTING
*        date_internal            = lv_dateto
*      EXCEPTIONS
*        date_external_is_invalid = 1
*        OTHERS                   = 2.
*
*    gw_costcenterlist-costcenter                    = lw_data-kostl.
*    gw_costcenterlist-valid_from                    = lv_datefrom.
*    gw_costcenterlist-valid_to                      = lv_dateto.
*    gw_costcenterlist-name                          = lw_data-ktext.
*    gw_costcenterlist-descript                      = lw_data-kltxt.
*    gw_costcenterlist-person_in_charge_user         = lw_data-verak_user.
*    gw_costcenterlist-person_in_charge              = lw_data-verak.
*    gw_costcenterlist-department                    = lw_data-abtei.
*    gw_costcenterlist-costcenter_type               = lw_data-kosar.
*    gw_costcenterlist-costctr_hier_grp              = lw_data-khinr.
*    gw_costcenterlist-comp_code                     = lw_data-bukrs.
*    gw_costcenterlist-bus_area                      = lw_data-gsber.
*    gw_costcenterlist-func_area                     = lw_data-func_area.
*    gw_costcenterlist-currency                      = lw_data-waers.
*    gw_costcenterlist-profit_ctr                    = lw_data-prctr.
*    gw_costcenterlist-record_quantity               = lw_data-mgefl.
*    gw_costcenterlist-lock_ind_actual_primary_costs = lw_data-bkzkp.
*    gw_costcenterlist-lock_ind_plan_primary_costs   = lw_data-pkzkp.
*    gw_costcenterlist-lock_ind_act_secondary_costs  = lw_data-bkzks.
*    gw_costcenterlist-lock_ind_plan_secondary_costs = lw_data-pkzks.
*    gw_costcenterlist-lock_ind_actual_revenues      = lw_data-bkzer.
*    gw_costcenterlist-lock_ind_plan_revenues        = lw_data-pkzer.
*    gw_costcenterlist-lock_ind_commitment_update    = lw_data-bkzob.
*    gw_costcenterlist-acty_indep_template           = lw_data-cpi_templ.
*    gw_costcenterlist-acty_dep_template             = lw_data-cpd_templ.
*    gw_costcenterlist-acty_indep_template_alloc_cc  = lw_data-sci_templ.
*    gw_costcenterlist-acty_dep_template_alloc_cc    = lw_data-scd_templ.
*    gw_costcenterlist-acty_indep_template_sk        = lw_data-ski_templ.
*    gw_costcenterlist-acty_dep_template_sk          = lw_data-skd_templ.
*    gw_costcenterlist-cstg_sheet                    = lw_data-kalsm.
*    gw_costcenterlist-addr_title                    = lw_data-anred.
*    gw_costcenterlist-addr_name1                    = lw_data-name1.
*    gw_costcenterlist-addr_name2                    = lw_data-name2.
*    gw_costcenterlist-addr_name3                    = lw_data-name3.
*    gw_costcenterlist-addr_name4                    = lw_data-name4.
*    gw_costcenterlist-addr_street                   = lw_data-stras.
*    gw_costcenterlist-addr_po_box                   = lw_data-pfach.
*    gw_costcenterlist-addr_city                     = lw_data-ort01.
*    gw_costcenterlist-addr_postl_code               = lw_data-pstlz.
*    gw_costcenterlist-addr_district                 = lw_data-ort02.
*    gw_costcenterlist-addr_pobx_pcd                 = lw_data-pstl2.
*    gw_costcenterlist-addr_country                  = lw_data-land1.
*    gw_costcenterlist-addr_region                   = lw_data-regio.
*    gw_costcenterlist-addr_taxjurcode               = lw_data-txjcd.
*    gw_costcenterlist-telco_langu                   = lw_data-spras.
*    gw_costcenterlist-telco_telephone               = lw_data-telf1.
*    gw_costcenterlist-telco_telephone2              = lw_data-telf2.
*    gw_costcenterlist-telco_telebox                 = lw_data-telbx.
*    gw_costcenterlist-telco_telex                   = lw_data-telx1.
*    gw_costcenterlist-telco_fax_number              = lw_data-telfx.
*    gw_costcenterlist-telco_teletex                 = lw_data-teltx.
*    gw_costcenterlist-telco_printer                 = lw_data-drnam.
*    gw_costcenterlist-telco_data_line               = lw_data-datlt.
*
*    APPEND gw_costcenterlist TO gt_costcenterlist.
*    CLEAR: gw_costcenterlist.
*
*** Populate the bapi structure
*    gw_language-langu = p_spras.
*
*** Call the BAPI to create the cost centers
*    CALL FUNCTION 'BAPI_COSTCENTER_CREATEMULTIPLE'
*      EXPORTING
*        controllingarea = p_kokrs
*        testrun         = gv_test
*        language        = gw_language
*      TABLES
*        costcenterlist  = gt_costcenterlist
*        return          = gt_return.
*
*** If Test Run is initial on the selection screen then commit
*** the bapi data else do not commit the bapi data
*    IF p_test IS INITIAL.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*    ENDIF.
*
*    IF gt_return IS INITIAL.
*      gw_final-kostl   = lw_data-kostl.
*      gw_final-ktext   = lw_data-ktext.
*      gw_final-type    = gv_success.
*      IF gv_test = abap_true.
*        gw_final-message = TEXT-013.
*      ELSE.
*        gw_final-message = TEXT-005.
*      ENDIF.
*
*      APPEND gw_final TO gt_final.
*    ELSE.
*      LOOP AT gt_return INTO DATA(gw_return).
*        gw_final-kostl   = lw_data-kostl.
*        gw_final-ktext   = lw_data-ktext.
*        gw_final-type    = gw_return-type.
*        gw_final-message = gw_return-message.
*
*        APPEND gw_final TO gt_final.
*      ENDLOOP.
*    ENDIF.
*
*    CLEAR: gw_language, gw_final, gw_return.
*  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form DISPLAY_ALV
**&---------------------------------------------------------------------*
**Display the data in a report format for the users
**&---------------------------------------------------------------------*
*FORM f_display_alv .
*
*  CREATE OBJECT go_alv.
*
** Call the method to display the results in ALV Report format
*  CALL METHOD go_alv->display_alv
*    CHANGING
*      c_datatab = gt_final.
*
*  REFRESH gt_final.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F4_FILENAME
**&---------------------------------------------------------------------*
**&  F4 help to select the file from presentation/application server
**&---------------------------------------------------------------------*
**&      <-- P_FPATH  - Selected file path
**&---------------------------------------------------------------------*
*FORM f4_filename CHANGING p_fpath.
*
*  DATA: lv_source TYPE c.
*
*** Get the source of file
*  IF p_rad1 = gv_x.
*    lv_source = gv_a.
*  ELSEIF p_rad2 = gv_x.
*    lv_source = gv_p.
*  ENDIF.
*
*** Call the method for F4 help
*  CALL METHOD zcl_ca_utility=>select_file
*    EXPORTING
*      i_source       = lv_source
*      i_apppath_type = gv_a
*    IMPORTING
*      e_filename     = p_fpath.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form GET_CONSTANTS
**&---------------------------------------------------------------------*
**& Fetch the constants for the program
**&---------------------------------------------------------------------*
**&      --> lt_pgm_const_values  Constant Value Table
**&      --> lt_error_const       Error Table
**&      --> lw_pgmid             Program Name
**&      --> lw_error_msg         Error Message
**&---------------------------------------------------------------------*
*FORM f_get_constants  TABLES   lt_pgm_const_values STRUCTURE zspgm_const_values
*                               lt_error_const      STRUCTURE zserror_const
*                      USING    lw_pgmid            TYPE      char40
*                      CHANGING lw_error_msg        TYPE      string.
*
*  CLEAR lw_error_msg.
*  CALL FUNCTION 'ZUTIL_PGM_CONSTANTS'
*    EXPORTING
*      im_pgmid               = lw_pgmid
*    TABLES
*      t_pgm_const_values     = lt_pgm_const_values
*      t_error_const          = lt_error_const
*    EXCEPTIONS
*      ex_no_entries_found    = 1
*      ex_const_entry_missing = 2
*      OTHERS                 = 3.
*  IF sy-subrc <> 0.
*    CASE sy-subrc.
*      WHEN 1.
*        MESSAGE e007 WITH 'TVARVC'(012).
*      WHEN 2.
*        MESSAGE e010 WITH 'TVARVC'(012).
*      WHEN OTHERS.
*    ENDCASE.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_COLLECT_CONSTANTS
**&---------------------------------------------------------------------*
**& Collect the value of the Constants into variables
**&---------------------------------------------------------------------*
*FORM f_collect_constants .
*
*  READ TABLE gt_pgm_const_values INTO DATA(lw_pgm_const_values) WITH KEY const_name = 'P_A'.
*  IF sy-subrc = 0.
*    gv_a = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025 WITH 'P_A'(014).
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values  WITH KEY const_name = 'P_X'.
*  IF sy-subrc = 0.
*    gv_x = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025 WITH 'P_X'(015).
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_P'.
*  IF sy-subrc = 0.
*    gv_p = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025 WITH 'P_P'(016).
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_S'.
*  IF sy-subrc = 0.
*    gv_success = lw_pgm_const_values-low.
*  ELSE.
*    MESSAGE e025 WITH 'P_S'(017).
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_VALIDATE_DATA
**&---------------------------------------------------------------------*
**& Validate the selection screen values
**&---------------------------------------------------------------------*
*FORM f_validate_data.
*
**If controlling area is not valid, display an error message
*  SELECT SINGLE kokrs
*    FROM tka01
*    INTO @DATA(gv_kokrs)
*    WHERE kokrs = @p_kokrs.
*  IF sy-subrc = 0.
*  ELSE.
*    MESSAGE e003 WITH 'Controlling Area'(009).
*  ENDIF.
*
**If file path is blank
*  IF p_fpath IS INITIAL.
*    MESSAGE e003 WITH 'File Path'(004).
*  ENDIF.
*
*ENDFORM.
