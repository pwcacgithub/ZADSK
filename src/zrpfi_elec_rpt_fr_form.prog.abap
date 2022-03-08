*&---------------------------------------------------------------------*
*& Include          ZRPFI_ELEC_RPT_FR_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form GET_CONSTANTS
*&---------------------------------------------------------------------*
*& Fetch the constants for the program
*&---------------------------------------------------------------------*
FORM f_get_constants USING fp_pgmid TYPE char40.

  CALL FUNCTION 'ZUTIL_PGM_CONSTANTS'
    EXPORTING
      im_pgmid               = fp_pgmid
    TABLES
      t_pgm_const_values     = gt_pgm_const_values
      t_error_const          = gt_error_const
    EXCEPTIONS
      ex_no_entries_found    = 1
      ex_const_entry_missing = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
*        MESSAGE e007 WITH 'TVARVC'(046).
      WHEN 2.
*        MESSAGE e010 WITH 'TVARVC'(046).
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_COLLECT_CONSTANTS
*&---------------------------------------------------------------------*
*& Collect the value of the Constants in variables
*&---------------------------------------------------------------------*
FORM f_collect_constants .

*---------------- Begin of changes 477670 | D4SK907115 --------------------
  LOOP AT gt_pgm_const_values INTO DATA(lw_pgm_const_values) WHERE const_name = 'S_BLART_FRANCE'.
    IF sy-subrc = 0.
      s_blart-sign   = lw_pgm_const_values-sign.
      s_blart-option = lw_pgm_const_values-opti.
      s_blart-low    = lw_pgm_const_values-low.
      s_blart-high   = lw_pgm_const_values-high.
      APPEND s_blart.
      CLEAR s_blart.
    ELSE.
*      MESSAGE e025 WITH 'S_BLART_FRANCE'(049).
    ENDIF.
  ENDLOOP.
*------------------ End of changes 477670 | D4SK907115 --------------------

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_A'.
  IF sy-subrc = 0.
    gv_a = lw_pgm_const_values-low.
  ELSE.
*    MESSAGE e025 WITH 'P_A'(042).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_H'.
  IF sy-subrc = 0.
    gv_h = lw_pgm_const_values-low.
  ELSE.
*    MESSAGE e025 WITH 'P_H'(043).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_S'.
  IF sy-subrc = 0.
    gv_s = lw_pgm_const_values-low.
  ELSE.
*    MESSAGE e025 WITH 'P_S'(044).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_X'.
  IF sy-subrc = 0.
    gv_x = lw_pgm_const_values-low.
  ELSE.
*    MESSAGE e025 WITH 'P_X'(045).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_E'.
  IF sy-subrc = 0.
    gv_e = lw_pgm_const_values-low.
  ELSE.
*    MESSAGE e025 WITH 'P_E'(048).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_FETCH_DATA
*&---------------------------------------------------------------------*
*& Fetch the data from different tables for processing
*&---------------------------------------------------------------------*
FORM f_fetch_data .

  DATA : l_cursor_bkpf   TYPE cursor,
         l_cursor_acdoca TYPE cursor.

* fetch the data BKPF
  CLEAR : l_cursor_bkpf.

  REFRESH: gt_bkpf.
  OPEN CURSOR l_cursor_bkpf FOR
  SELECT bukrs belnr gjahr blart bldat
         budat cpudt xblnr waers
    FROM bkpf
    WHERE bukrs IN s_bukrs
    AND   gjahr = p_gjahr
    AND   budat IN s_date
    AND   blart IN s_blart.
  DO.
    FETCH NEXT CURSOR l_cursor_bkpf APPENDING TABLE gt_bkpf PACKAGE SIZE 500.
    IF sy-subrc = 0.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

  CLOSE CURSOR l_cursor_bkpf.

  IF NOT gt_bkpf[] IS INITIAL.
    SORT gt_bkpf BY bukrs belnr gjahr.

* Fetch data from acdoca table
    CLEAR : l_cursor_acdoca.

    REFRESH: gt_acdoca[].
    OPEN CURSOR l_cursor_acdoca FOR
    SELECT rldnr rbukrs gjahr belnr racct wsl hsl
      drcrk budat bldat blart buzei
      lokkt sgtxt lifnr kunnr augdt augbl
      FROM acdoca
      FOR ALL ENTRIES IN gt_bkpf
      WHERE rbukrs = gt_bkpf-bukrs
      AND   belnr = gt_bkpf-belnr
      AND   gjahr = gt_bkpf-gjahr
      AND   rldnr = p_rldnr.

    DO.
      FETCH NEXT CURSOR l_cursor_acdoca APPENDING TABLE gt_acdoca PACKAGE SIZE 500.
      IF sy-subrc = 0.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    CLOSE CURSOR l_cursor_acdoca.


    IF NOT gt_acdoca[] IS INITIAL.
      SORT gt_acdoca BY rldnr rbukrs gjahr belnr.

      DATA(lt_acdoca) = gt_acdoca[].
      SORT lt_acdoca BY rbukrs belnr gjahr.
      DELETE ADJACENT DUPLICATES FROM gt_acdoca COMPARING rldnr rbukrs gjahr belnr racct.

* fetch the document type description from T003T table
      SELECT blart, ltext
        FROM t003t
        INTO TABLE @DATA(gt_t003t)
        FOR ALL ENTRIES IN @lt_acdoca
        WHERE blart = @lt_acdoca-blart
        AND spras = @sy-langu.
      IF sy-subrc = 0.
        SORT gt_t003t BY blart.
      ENDIF.

* fetch the GL Account Description from SKAT table
      SELECT saknr, txt50
        FROM skat
        INTO TABLE @DATA(gt_skat)
        FOR ALL ENTRIES IN @lt_acdoca
        WHERE saknr = @lt_acdoca-racct
        AND spras = @sy-langu.
      IF sy-subrc = 0.
        SORT gt_skat BY saknr.
      ENDIF.

* fetch the matchcode search data from KNA1 table
      SELECT kunnr, mcod1
        FROM kna1
        INTO TABLE @DATA(gt_kna1)
        FOR ALL ENTRIES IN @lt_acdoca
        WHERE kunnr = @lt_acdoca-kunnr.
      IF sy-subrc = 0.
        SORT gt_kna1 BY kunnr.
      ENDIF.

* fetch the matchcode search data from LFA1 table
      SELECT lifnr, mcod1
        FROM lfa1
        INTO TABLE @DATA(gt_lfa1)
        FOR ALL ENTRIES IN @lt_acdoca
        WHERE lifnr = @lt_acdoca-lifnr.
      IF sy-subrc = 0.
        SORT gt_lfa1 BY lifnr.
      ENDIF.
    ENDIF.
  ELSE.
*    MESSAGE s033 DISPLAY LIKE gv_e.   "No data found for the entered selections
    LEAVE LIST-PROCESSING.
  ENDIF.

* Populate the data into final internal table
  REFRESH: gt_output.

  LOOP AT gt_acdoca INTO DATA(lw_acdoca).     "477670 | D4SK907115

    gw_output-belnr = lw_acdoca-belnr.
    gw_output-budat = lw_acdoca-budat.
    gw_output-lokkt = lw_acdoca-lokkt.
    gw_output-bldat = lw_acdoca-bldat.
    gw_output-gjahr = lw_acdoca-gjahr.
    gw_output-bukrs = lw_acdoca-rbukrs.
    gw_output-blart = lw_acdoca-blart.
    gw_output-sgtxt = lw_acdoca-sgtxt.
    gw_output-hkont = lw_acdoca-racct.
    gw_output-augbl = lw_acdoca-augbl.
    gw_output-augdt = lw_acdoca-augdt.
    gw_output-wrbtr = lw_acdoca-wsl.

    READ TABLE gt_bkpf INTO DATA(lw_bkpf) WITH KEY bukrs = lw_acdoca-rbukrs
                                                   belnr = lw_acdoca-belnr
                                                   gjahr = lw_acdoca-gjahr BINARY SEARCH.
    IF sy-subrc = 0.
      gw_output-xblnr = lw_bkpf-xblnr.
      gw_output-cpudt = lw_bkpf-cpudt.
      gw_output-waers = lw_bkpf-waers.
    ENDIF.

    READ TABLE gt_t003t INTO DATA(lw_t003t) WITH KEY blart = lw_acdoca-blart BINARY SEARCH.
    IF sy-subrc = 0.
      gw_output-ltext = lw_t003t-ltext.
    ENDIF.


    CASE lw_acdoca-drcrk.
      WHEN gv_h.
        gw_output-credit = lw_acdoca-hsl.
      WHEN gv_s.
        gw_output-debit = lw_acdoca-hsl.
      WHEN OTHERS.
    ENDCASE.

    READ TABLE gt_skat INTO DATA(lw_skat) WITH KEY saknr = lw_acdoca-racct BINARY SEARCH.
    IF sy-subrc = 0.
      gw_output-txt50 = lw_skat-txt50.
    ENDIF.

    READ TABLE gt_kna1 INTO DATA(lw_kna1) WITH KEY kunnr = lw_acdoca-kunnr BINARY SEARCH.
    IF sy-subrc = 0.
      gw_output-mcod1 = lw_kna1-mcod1.
      gw_output-auxnum = lw_acdoca-kunnr.
    ELSE.
      READ TABLE gt_lfa1 INTO DATA(lw_lfa1) WITH KEY lifnr = lw_acdoca-lifnr BINARY SEARCH.
      IF sy-subrc = 0.
        gw_output-mcod1 = lw_lfa1-mcod1.
        gw_output-auxnum = lw_acdoca-lifnr.
      ENDIF.
    ENDIF.
    APPEND gw_output TO gt_output.
    CLEAR: gw_output.

  ENDLOOP.

  SORT gt_output.
  DELETE ADJACENT DUPLICATES FROM gt_output COMPARING ALL FIELDS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISPLAY_DATA
*&---------------------------------------------------------------------*
*& Display the final output data
*&---------------------------------------------------------------------*
FORM f_display_data .

  DATA: lv_repid  TYPE sy-repid,
        lw_layout TYPE slis_layout_alv.

  PERFORM f_field_cat.

  lw_layout-zebra = gv_x.
  lw_layout-colwidth_optimize = gv_x.

  lv_repid = sy-cprog.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = lv_repid
      it_fieldcat        = gt_fieldcat[]
      is_layout          = lw_layout
      i_default          = gv_x
      i_save             = gv_a
    TABLES
      t_outtab           = gt_output[]
    EXCEPTIONS
      OTHERS             = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_FIELD_CAT
*&---------------------------------------------------------------------*
*& Field Catalog for Internal Table
*&---------------------------------------------------------------------*
FORM f_field_cat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '1'.
  gw_fieldcat-fieldname = TEXT-002.
  gw_fieldcat-seltext_m = TEXT-003.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '2'.
  gw_fieldcat-fieldname = TEXT-004.
  gw_fieldcat-seltext_m = TEXT-005.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '3'.
  gw_fieldcat-fieldname = TEXT-006.
  gw_fieldcat-seltext_m = TEXT-007.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '4'.
  gw_fieldcat-fieldname = TEXT-008.
  gw_fieldcat-seltext_m = TEXT-009.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '5'.
  gw_fieldcat-fieldname = TEXT-010.
  gw_fieldcat-seltext_m = TEXT-011.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '6'.
  gw_fieldcat-fieldname = TEXT-012.
  gw_fieldcat-seltext_m = TEXT-013.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '7'.
  gw_fieldcat-fieldname = TEXT-014.
  gw_fieldcat-seltext_m = TEXT-015.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '8'.
  gw_fieldcat-fieldname = TEXT-016.
  gw_fieldcat-seltext_m = TEXT-017.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '9'.
  gw_fieldcat-fieldname = TEXT-018.
  gw_fieldcat-seltext_m = TEXT-019.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '10'.
  gw_fieldcat-fieldname = TEXT-020.
  gw_fieldcat-seltext_m = TEXT-021.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '11'.
  gw_fieldcat-fieldname = TEXT-022.
  gw_fieldcat-seltext_m = TEXT-023.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '12'.
  gw_fieldcat-fieldname = TEXT-026.
  gw_fieldcat-seltext_m = TEXT-027.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '13'.
  gw_fieldcat-fieldname = TEXT-024.
  gw_fieldcat-seltext_m = TEXT-025.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '14'.
  gw_fieldcat-fieldname = TEXT-028.
  gw_fieldcat-seltext_m = TEXT-029.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '15'.
  gw_fieldcat-fieldname = TEXT-030.
  gw_fieldcat-seltext_m = TEXT-031.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '16'.
  gw_fieldcat-fieldname = TEXT-032.
  gw_fieldcat-seltext_m = TEXT-033.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '17'.
  gw_fieldcat-fieldname = TEXT-034.
  gw_fieldcat-seltext_m = TEXT-035.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '18'.
  gw_fieldcat-fieldname = TEXT-036.
  gw_fieldcat-seltext_m = TEXT-037.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '19'.
  gw_fieldcat-fieldname = TEXT-038.
  gw_fieldcat-seltext_m = TEXT-039.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '20'.
  gw_fieldcat-fieldname = TEXT-040.
  gw_fieldcat-seltext_m = TEXT-041.
  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR: gw_fieldcat.
  gw_fieldcat-col_pos = '21'.
  gw_fieldcat-fieldname = TEXT-050.
  gw_fieldcat-seltext_m = TEXT-051.
  APPEND gw_fieldcat TO gt_fieldcat.

ENDFORM.
*& Form F_CLEAR_GLOBAL_VAR.
*&---------------------------------------------------------------------*
*& Clear all global variables.
*&---------------------------------------------------------------------*
FORM f_clear_global_var.

  REFRESH: gt_output,
           gt_bkpf,
           gt_acdoca,
           gt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& Authority check for Company code
*&---------------------------------------------------------------------*
FORM f_authority_check .

  TYPES: BEGIN OF ty_t001,
           bukrs TYPE  bukrs,
         END OF ty_t001.

  DATA: lt_t001 TYPE TABLE OF ty_t001.

  SELECT bukrs
     FROM t001
     INTO TABLE lt_t001
     WHERE bukrs IN s_bukrs .

  LOOP AT lt_t001 INTO DATA(lw_t001).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'ACTVT' FIELD '03'
    ID 'BUKRS' FIELD lw_t001-bukrs.
    IF sy-subrc <> 0.
*      MESSAGE e064 WITH lw_t001-bukrs.
    ENDIF.
  ENDLOOP.

ENDFORM.
