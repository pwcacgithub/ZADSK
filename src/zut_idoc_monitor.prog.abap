*&---------------------------------------------------------------------*
*& Report ZUT_IDOC_MONITOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZUT_IDOC_MONITOR.

*- All data declarations
INCLUDE zut_idoc_monitor_top.
*- Selection Screen Declarations
INCLUDE zut_idoc_monitor_sel.
*- Sub Routine Definitions
INCLUDE zut_idoc_monitor_form.
*----------------------------------------------------------------------*
* Initialization Event
*----------------------------------------------------------------------*
INITIALIZATION.
*** Get constants for the program.
  PERFORM f_get_constants USING sy-cprog.
*** Collect all the constant values
  PERFORM f_collect_constants.
*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
*** Initialize all global Variables
  PERFORM f_refresh_objects.
***  Validate doc date.
  PERFORM f_validate_date.
  CHECK gv_exit IS INITIAL.
*** Get the Required data
  PERFORM f_get_data.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF NOT gt_edids[] IS INITIAL.
**** Collect the Data to show in ALV
    PERFORM f_collect_error_messages.

    IF NOT s_email[] IS INITIAL.
      PERFORM f_send_email_alert.
    ENDIF.
*** Show Output in ALV
    PERFORM f_display_output.
  ENDIF.
