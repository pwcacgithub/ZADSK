*&---------------------------------------------------------------------*
*& Report ZRPFI_SAFT_ELEC_RPT_SPAIN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRPFI_SAFT_ELEC_RPT_SPAIN.

* Data Declarations
*INCLUDE zrpfi_elec_rpt_sp_top.
*
** Selection Screen Declarations
*INCLUDE zrpfi_elec_rpt_sp_selscrn.
*
** Sub routine Definitions
*INCLUDE zrpfi_elec_rpt_sp_form.
*
**----------------------------------------------------------------------*
** Initialization Event
**----------------------------------------------------------------------*
*INITIALIZATION.
*
**** Initialize all global Variables
*  PERFORM f_clear_global_var.
**** Get constants for the program.
*  PERFORM f_get_constants USING sy-cprog.
**** Collect all the constant values
*  PERFORM f_collect_constants.
*
**----------------------------------------------------------------------*
** At Selection screen
**----------------------------------------------------------------------*
*AT SELECTION-SCREEN.
**Authority check
*  PERFORM f_authority_check.
**----------------------------------------------------------------------*
** Start of Selection
**----------------------------------------------------------------------*
*START-OF-SELECTION.
*
** Extract data and populate final table
*  PERFORM f_fetch_data.
*
*END-OF-SELECTION.
*
** Display the result in ALV
*  IF NOT gt_output[] IS INITIAL.
*    PERFORM f_display_data.
*  ELSE.
*    MESSAGE e024.     "No Data found for the given selection-screen Criteria
*  ENDIF.
*
**Clear global variables
*  PERFORM f_clear_global_var.
