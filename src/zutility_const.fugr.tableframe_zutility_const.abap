*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZUTILITY_CONST
*   generation date: 29.11.2019 at 02:21:12
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZUTILITY_CONST     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
