*&---------------------------------------------------------------------*
*& Report ZRUFI_COSTCENTERCREATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRUFI_COSTCENTERCREATE.

** Data Declarations
*INCLUDE zrufi_costcentercreate_top.
*
** Selection Screen Declarations
*INCLUDE zrufi_costcentercreate_selscrn.
*
** Sub routine Definitions
*INCLUDE zrufi_costcentercreate_form.
*
*INITIALIZATION.
*
** Get the constants for the program
*  PERFORM f_get_constants TABLES   gt_pgm_const_values
*                                   gt_error_const
*                          USING    sy-cprog
*                          CHANGING gw_error_msg..
*
** Collect all constants
*  PERFORM f_collect_constants.
*
**----------------------------------------------------------------------*
** At Selection Screen On Value Request
**----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath.
*  PERFORM f4_filename CHANGING p_fpath.
*
**----------------------------------------------------------------------*
** At Selection Screen
**----------------------------------------------------------------------*
*AT SELECTION-SCREEN.
*  PERFORM f_validate_data.
*
**----------------------------------------------------------------------*
** Start of Selection
**----------------------------------------------------------------------*
*START-OF-SELECTION.
*
** Read the file from Application Server/Presentation Server
*  PERFORM f_read_file.
*
** Call the bapi to create the costcenters
*  PERFORM f_call_bapi.
*
** Display the results in ALV Report format
*  PERFORM f_display_alv.
*
*END-OF-SELECTION.
