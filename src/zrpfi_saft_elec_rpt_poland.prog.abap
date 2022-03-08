*&---------------------------------------------------------------------*
*& Report ZRPFI_SAFT_ELEC_RPT_POLAND
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrpfi_saft_elec_rpt_poland.

** Data Declaratons
*INCLUDE zrpfi_elec_rpt_pl_top.
*
** Selection Screen Declarations
*INCLUDE zrpfi_elec_rpt_pl_selscrn.
*
** Sub routine Definitions
*INCLUDE zrpfi_elec_rpt_pl_form.
*
*INITIALIZATION.
*
** Get the constants for the program
*  PERFORM f_get_constants USING sy-cprog.
*
** Collect all constants
*  PERFORM f_collect_constants.
*
*START-OF-SELECTION.
*
**Clear global variables
*  PERFORM f_clear_global_var.
*
** Authorization Object Check
*  PERFORM f_authority_check.
*
** Extract data and populate final table
*  PERFORM f_fetch_data.
*
** Display the result in ALV
*  IF NOT gt_output[] IS INITIAL.
*    PERFORM f_display_data.
*  ELSE.
*    "No Data found for the given selection-screen Criteria
**    MESSAGE s024 DISPLAY LIKE c_e.
*
*  ENDIF.
