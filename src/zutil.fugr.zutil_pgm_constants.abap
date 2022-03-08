FUNCTION ZUTIL_PGM_CONSTANTS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_PGMID) TYPE  ZPGMID
*"  TABLES
*"      T_PGM_CONST_VALUES STRUCTURE  ZSPGM_CONST_VALUES
*"      T_ERROR_CONST STRUCTURE  ZSERROR_CONST
*"  EXCEPTIONS
*"      EX_NO_ENTRIES_FOUND
*"      EX_CONST_ENTRY_MISSING
*"----------------------------------------------------------------------

**** Select constant Values

  REFRESH : t_pgm_const_values[], t_error_const[].

  SELECT a~pgmid
         a~const_name
         b~sign
         b~opti
         b~low
         b~high
    INTO TABLE t_pgm_const_values
    FROM ztutility_const AS a LEFT OUTER JOIN
         tvarvc AS b
    ON a~const_name = b~name
    WHERE a~pgmid = im_pgmid.

  IF t_pgm_const_values[] IS INITIAL.

    MESSAGE i368(00) WITH 'No entries found in TVARVC table for the Program'(002)
    im_pgmid RAISING ex_no_entries_found.

  ELSE.

*** Collect missing Constant values in TVARVC table
    LOOP AT t_pgm_const_values INTO gw_pgm_const_values WHERE low IS INITIAL.

      CLEAR : gw_error_const.
      gw_error_const-const_name = gw_pgm_const_values-const_name.
      APPEND gw_error_const TO t_error_const.

    ENDLOOP.

    IF NOT t_error_const[] IS INITIAL.

      CLEAR : gv_msg.

      LOOP AT t_error_const INTO gw_error_const.

        CONCATENATE gw_error_const-const_name gv_msg INTO gv_msg SEPARATED BY gc_comma.

      ENDLOOP.

      CONCATENATE 'The constants'(001) gv_msg 'are missing in TVARVC table. Add them.'(003)
      INTO gv_msg SEPARATED BY space.

      MESSAGE i368(00) WITH gv_msg
      RAISING ex_const_entry_missing.

    ENDIF.

  ENDIF.

ENDFUNCTION.
