*&---------------------------------------------------------------------*
*& Report ZRPFI_INVOICEUPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRPFI_INVOICEUPLOAD.

INCLUDE zrpfi_invoiceupload_top.

INCLUDE zrpfi_invoiceupload_selscr.

INCLUDE zrpfi_invoiceupload_form.

INITIALIZATION.
* Get constants for the program
  PERFORM f_get_constants USING sy-cprog.

* Collect all constants
  PERFORM f_collect_constants.

*----------------------------------------------------------------------*
* At Selection Screen On Value Request
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath1.
  PERFORM f4_filename CHANGING p_fpath1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath2.
  PERFORM f4_filename CHANGING p_fpath2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath3.
  PERFORM f4_filename CHANGING p_fpath3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath4.
  PERFORM f4_filename CHANGING p_fpath4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath5.
  PERFORM f4_filename CHANGING p_fpath5.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_atach1.
  perform f4_filename CHANGING p_atach1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_atach2.
  PERFORM f4_filename CHANGING p_atach2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_atach3.
  PERFORM f4_filename CHANGING p_atach3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_atach4.
  PERFORM f4_filename CHANGING p_atach4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_atach5.
  PERFORM f4_filename CHANGING p_atach5.

*----------------------------------------------------------------------*
* At Selection Screen
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM f_validate_data.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_read_file.

  PERFORM f_process_data.

END-OF-SELECTION.

  PERFORM f_display_data.
