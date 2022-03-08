*&---------------------------------------------------------------------*
*& Report ZRPFI_WITHHOLDING_TAX_DMP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRPFI_WITHHOLDING_TAX_DMP.

*- All data declarations
INCLUDE zrpfi_withholding_tax_dmp_top.

*- Selection Screen Declarations
INCLUDE zrpfi_withholding_tax_dmp_sel.

*- Sub Routine Definitions
INCLUDE zrpfi_withholding_tax_dmp_form.

INITIALIZATION.
* Get constants for the program.
  PERFORM f_get_constants USING sy-cprog.
* Collect all constants
  PERFORM f_collect_constants.

*----------------------------------------------------------------------*
* At Selection Screen
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_check.
  PERFORM f_help_request.

AT SELECTION-SCREEN OUTPUT.
* Hide the screen for which radio button is not selected
  PERFORM f_radio_visible.

AT SELECTION-SCREEN.
*Authority check
  PERFORM f_authority_check.
*Validate data on selection screen
  PERFORM f_validate_data.
*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
*Clear global data
  PERFORM f_clear_global_data.

*To pass the error message if the mandatory fields are not filled
*in the selection screen
  PERFORM f_validate_mandfields.

  IF p_rad1 = abap_true.
*Get withholding tax exemption data
    PERFORM f_get_whtexemption.
* Display data
    PERFORM f_disp_out USING gt_output.

* If the user wants to send output via email
    IF p_check IS NOT INITIAL.
*Send alert to the user through email
      PERFORM f_send_email_alert.
    ENDIF.

  ELSEIF p_rad2 = abap_true.
*Get Withholding tax posting data
    PERFORM f_data_selection.
*Process Withholding tax posting data
    PERFORM f_data_processing.
*Display data
    PERFORM f_disp_out USING gt_output1.

* 463912
* If the user wants to send output via email
    IF p_email IS NOT INITIAL.
*Send alert to the user through email
      PERFORM f_send_email_alert_wht.
* 463912
    ENDIF.


  ENDIF.
