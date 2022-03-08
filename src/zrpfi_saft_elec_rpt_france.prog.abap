*&---------------------------------------------------------------------*
*& Report ZRPFI_SAFT_ELEC_RPT_FRANCE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRPFI_SAFT_ELEC_RPT_FRANCE.

* Data Declarations
INCLUDE zrpfi_elec_rpt_fr_top.

* Selection Screen Declarations
INCLUDE zrpfi_elec_rpt_fr_selscrn.

* Sub routine Definitions
INCLUDE zrpfi_elec_rpt_fr_form.

INITIALIZATION.
*** Initialize all global Variables
  PERFORM f_clear_global_var.

* Get the constants for the program
  PERFORM f_get_constants USING sy-cprog.

* Collect all constants
  PERFORM f_collect_constants.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.

*Authority check
  PERFORM f_authority_check.

* Extract data and populate final table
  PERFORM f_fetch_data.

END-OF-SELECTION.

* Display the result in ALV
  IF NOT gt_output[] IS INITIAL.
    PERFORM f_display_data.
  ELSE.
*    MESSAGE e024.     "No Data found for the given selection-screen Criteria
  ENDIF.

* Clear global variables
  PERFORM f_clear_global_var.
