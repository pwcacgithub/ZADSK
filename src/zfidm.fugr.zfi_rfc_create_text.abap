*&---------------------------------------------------------------------*
*& Function Module: ZFI_RFC_CREATE_TEXT
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------------------------------------------------------*
*                                                          MODIFICATION HISTORY                                                           |
*-----------------------------------------------------------------------------------------------------------------------------------------*
* Change Date | Developer           | RICEFW/Defect# | Transport#   | Description                                                         |
*-----------------------------------------------------------------------------------------------------------------------------------------*
* 03-AUG-2020 | Sugeeth Sudhendran  | CF.CNV.054     | DFDK900167   | Create Text through RFC                                             |
*-----------------------------------------------------------------------------------------------------------------------------------------*

FUNCTION zfi_rfc_create_text.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FID) TYPE  THEAD-TDID
*"     VALUE(FLANGUAGE) TYPE  THEAD-TDSPRAS
*"     VALUE(FNAME) TYPE  THEAD-TDNAME
*"     VALUE(FOBJECT) TYPE  THEAD-TDOBJECT
*"     VALUE(SAVE_DIRECT) TYPE  CHAR01 DEFAULT 'X'
*"     VALUE(FFORMAT) TYPE  TLINE-TDFORMAT DEFAULT '*'
*"  TABLES
*"      FLINES STRUCTURE  TLINE
*"  EXCEPTIONS
*"      NO_INIT
*"      NO_SAVE
*"----------------------------------------------------------------------

*** Call the 'CREATE_TEXT' FM to update the text to the system
  CALL FUNCTION 'CREATE_TEXT'
    EXPORTING
      fid         = fid
      flanguage   = flanguage
      fname       = fname
      fobject     = fobject
      save_direct = save_direct
      fformat     = fformat
    TABLES
      flines      = flines[]
    EXCEPTIONS
      no_init     = 1
      no_save     = 2
      OTHERS      = 3.
  IF sy-subrc <> 0.
*** Raise the Exceptions
    CASE sy-subrc.
      WHEN '1'.
        RAISE no_init.
      WHEN '2'.
        RAISE no_save.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
