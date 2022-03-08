**&---------------------------------------------------------------------*
**& Include          ZRPFI_ELEC_RPT_SP_FORM
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Form F_GET_CONSTANTS
**&---------------------------------------------------------------------*
**& Fetch the constants for the program
**&---------------------------------------------------------------------*
**& -->  fp_pgmid        Program Name
**&---------------------------------------------------------------------*
*FORM f_get_constants USING fp_pgmid TYPE char40.
*
**** Call ZUTIL_PGM_CONSTANTS Utility FM to fetch the constants
*  CALL FUNCTION 'ZUTIL_PGM_CONSTANTS'
*    EXPORTING
*      im_pgmid               = fp_pgmid
*    TABLES
*      t_pgm_const_values     = gt_pgm_const_values
*      t_error_const          = gt_error_const
*    EXCEPTIONS
*      ex_no_entries_found    = 1
*      ex_const_entry_missing = 2
*      OTHERS                 = 3.
*  IF sy-subrc <> 0.
*    CASE sy-subrc.
*      WHEN 1.
*        MESSAGE e007 WITH 'TVARVC'(001).    "No data found in TVARVC table
*      WHEN 2.
*        MESSAGE e010 WITH 'TVARVC'(001).    "Atleast one constant entry missing in TVARVC table
*      WHEN OTHERS.
*    ENDCASE.
*  ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form F_COLLECT_CONSTANTS
**&---------------------------------------------------------------------*
**& Collect the value of the Constants in variables
**&---------------------------------------------------------------------*
*FORM f_collect_constants.
*
*  REFRESH s_blart[].
*  LOOP AT gt_pgm_const_values INTO DATA(gs_pgm_const_values) WHERE const_name = 'S_BLART_SPAIN'.
*    IF sy-subrc = 0.
*      s_blart-sign   = gs_pgm_const_values-sign.
*      s_blart-option = gs_pgm_const_values-opti.
*      s_blart-low    = gs_pgm_const_values-low.
*      s_blart-high   = gs_pgm_const_values-high.
*      APPEND s_blart.
*      CLEAR s_blart.
*    ELSE.
*      MESSAGE e025 WITH 'S_BLART_SPAIN'(036).    "Constant S_BLART_SPAIN not maintained in the ZTUTILITY_CONST table
*    ENDIF.
*  ENDLOOP.
**Start of Change - 477670 | D4SK907641
*  LOOP AT gt_pgm_const_values INTO gs_pgm_const_values WHERE const_name = 'ZTAX_CODE'.
*    gw_tax-sign   = 'I'.
*    gw_tax-option = 'EQ'.
*    gw_tax-low    = gs_pgm_const_values-low.
*    APPEND gw_tax TO gt_tax.
*  ENDLOOP.
**End of Change - 477670 | D4SK907641
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_FETCH_DATA
**&---------------------------------------------------------------------*
**& Fetch the data from different tables for processing
**&---------------------------------------------------------------------*
*FORM f_fetch_data .
*
*  DATA : l_cursor_bkpf   TYPE cursor,
*         l_cursor_acdoca TYPE cursor.
*
*  DATA : lv_tax_base   TYPE fwbas_bses,
*         lv_tax_amount TYPE fwste,
*         lv_count(1)   TYPE n.
*
** Fetch data from bkpf table
*  CLEAR : l_cursor_bkpf, l_cursor_acdoca.
*
*  REFRESH: gt_bkpf[].
*  OPEN CURSOR l_cursor_bkpf FOR
*  SELECT bukrs belnr gjahr xblnr
*    FROM bkpf
*    WHERE bukrs IN s_bukrs
*    AND   gjahr = p_gjahr
*    AND   budat IN s_date
*    AND   belnr IN s_belnr
*    AND   blart IN s_blart.
*
*  DO.
*    FETCH NEXT CURSOR l_cursor_bkpf APPENDING TABLE gt_bkpf PACKAGE SIZE 500.
*    IF sy-subrc = 0.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.
*
*  CLOSE CURSOR l_cursor_bkpf.
*
*  IF NOT gt_bkpf[] IS INITIAL.
*    SORT gt_bkpf BY bukrs belnr gjahr.
** Fetch data from acdoca table
*    REFRESH: gt_acdoca[].
*    OPEN CURSOR l_cursor_acdoca FOR
*    SELECT rldnr rbukrs gjahr belnr tsl
*      budat bldat buzei lokkt lifnr
*      FROM acdoca
*      FOR ALL ENTRIES IN gt_bkpf
*      WHERE rbukrs = gt_bkpf-bukrs
*      AND   belnr = gt_bkpf-belnr
*      AND   gjahr = gt_bkpf-gjahr
*      AND   lifnr IN s_lifnr
*      AND   rldnr = p_rldnr.
*
*    DO.
*      FETCH NEXT CURSOR l_cursor_acdoca APPENDING TABLE gt_acdoca PACKAGE SIZE 500.
*      IF sy-subrc = 0.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
*
*    CLOSE CURSOR l_cursor_acdoca.
*
*    IF NOT gt_acdoca[] IS INITIAL.
*      SORT gt_acdoca BY rbukrs gjahr belnr.
*      DATA(lt_acdoca) = gt_acdoca[].
*      SORT lt_acdoca BY rbukrs gjahr belnr.
*      DELETE ADJACENT DUPLICATES FROM lt_acdoca COMPARING rbukrs gjahr belnr.
*
**Fetch Tax Data Document Segment
*      IF NOT lt_acdoca[] IS INITIAL.
*
**Start of Change - 477670 | D4SK907471
*
**Changed by 477670 | D4SK907641
**Tax fields fetched based on condition record instead of condition types
** and GL should not be empty. We are only considering 4 condition records
** for taxes and sum of each condition record should be populated to
** VAT1, VAT2, VAT3 & VAT4 fields.
*
*        SELECT bukrs, gjahr, belnr, mwskz, knumh, fwbas, kbetr, fwste, hkont
*          FROM bset INTO TABLE @DATA(gt_bset)
*          FOR ALL ENTRIES IN @lt_acdoca
*          WHERE bukrs = @lt_acdoca-rbukrs
*          AND belnr = @lt_acdoca-belnr
*          AND gjahr = @lt_acdoca-gjahr
*          AND hkont NE ' '.
*
*        IF sy-subrc EQ 0.
*          SORT gt_bset BY bukrs gjahr belnr knumh.
*          LOOP AT gt_bset INTO DATA(lw_bset_temp).
*            DATA(lw_bset)      = lw_bset_temp.
*            gw_bset_temp-bukrs = lw_bset-bukrs.
*            gw_bset_temp-belnr = lw_bset-belnr.
*            gw_bset_temp-gjahr = lw_bset-gjahr.
**Start of Change - 477670 | D4SK907641
**If Tax code is SR, populate Tax fields to 0
*            IF lw_bset-mwskz IN gt_tax.
*
*              gw_bset_temp-tax_base1       =  gw_bset_temp-vat%1    =   gw_bset_temp-vat_amount1    = 0.
*              gw_bset_temp-tax_base2       =  gw_bset_temp-vat%2    =   gw_bset_temp-vat_amount2    = 0.
*              gw_bset_temp-tax_base3       =  gw_bset_temp-vat%3    =   gw_bset_temp-vat_amount3    = 0.
*              gw_bset_temp-tax_base4       =  gw_bset_temp-vat%4    =   gw_bset_temp-vat_amount4    = 0.
*
*            ELSE.
**End of Change - 477670 | D4SK907641
*
*              AT NEW knumh.
****** Counting the number of condition records for each line based on
****** subsequent code will be used to calculate the tax output field.
*                lv_count = lv_count + 1.
*              ENDAT.
*
*              lv_tax_base   = lv_tax_base + lw_bset-fwbas.
*              lv_tax_amount = lv_tax_amount + lw_bset-fwste.
*
*              AT END OF knumh.          "477670 | D4SK907641
*                CASE lv_count.
*                  WHEN 1.                                              "Tax1
*                    gw_bset_temp-tax_base1       =  lv_tax_base.
*                    gw_bset_temp-vat%1           =  lw_bset-kbetr / 10.
*                    gw_bset_temp-vat_amount1     =  lv_tax_amount.
*                  WHEN 2.                                              "Tax2
*                    gw_bset_temp-tax_base2       =  lv_tax_base.
*                    gw_bset_temp-vat%2           =  lw_bset-kbetr / 10.
*                    gw_bset_temp-vat_amount2     =  lv_tax_amount.
*                  WHEN 3.                                              "Tax3
*                    gw_bset_temp-tax_base3       =  lv_tax_base.
*                    gw_bset_temp-vat%3           =  lw_bset-kbetr / 10.
*                    gw_bset_temp-vat_amount3     =  lv_tax_amount.
*                  WHEN 4.                                              "Tax4
*                    gw_bset_temp-tax_base4       =  lv_tax_base.
*                    gw_bset_temp-vat%4           =  lw_bset-kbetr / 10.
*                    gw_bset_temp-vat_amount4     =  lv_tax_amount.
*                  WHEN OTHERS.
*                ENDCASE.
*                CLEAR: lv_tax_base, lv_tax_amount.
*              ENDAT.
*            ENDIF.                                   "477670 | D4SK907641
*            AT END OF belnr.
*              APPEND gw_bset_temp TO gt_bset_temp.
*              CLEAR: gw_bset_temp, lv_count,lw_bset.
*            ENDAT.
*          ENDLOOP.
**End of Change - 477670 |D4SK907471
*
*        ENDIF.
*      ENDIF.
*
*      REFRESH:lt_acdoca[].
*      lt_acdoca[] = gt_acdoca[].
*      SORT lt_acdoca BY lifnr.
*      DELETE ADJACENT DUPLICATES FROM lt_acdoca COMPARING lifnr.
*
**Fetch European cif & supplier name from LFA1 table
*      IF NOT lt_acdoca IS INITIAL.
*        SELECT lifnr, name1, stceg
*            FROM lfa1
*            INTO TABLE @DATA(gt_lfa1)
*            FOR ALL ENTRIES IN @lt_acdoca
*            WHERE lifnr = @lt_acdoca-lifnr.
*
*        IF sy-subrc EQ 0.
*          SORT gt_lfa1 BY lifnr.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSE.
*    MESSAGE s033 DISPLAY LIKE c_e.   "No data found for the entered selections
*    LEAVE LIST-PROCESSING.
*  ENDIF.
*
** Populate the data into final internal table
*  REFRESH: gt_output.
*  LOOP AT gt_acdoca INTO DATA(lw_acdoca) WHERE lifnr IS NOT INITIAL.
*
*    gw_output-belnr    = lw_acdoca-belnr.
*    gw_output-exp_date = lw_acdoca-bldat.
*    gw_output-opr_date = lw_acdoca-bldat.
*    gw_output-budat    = lw_acdoca-budat.
*    gw_output-lokkt    = lw_acdoca-lokkt.
*    gw_output-pswbt    = lw_acdoca-tsl.
*
*    READ TABLE gt_bkpf INTO DATA(lw_bkpf) WITH KEY bukrs = lw_acdoca-rbukrs
*                                                   belnr = lw_acdoca-belnr
*                                                   gjahr = lw_acdoca-gjahr BINARY SEARCH.
*    IF sy-subrc = 0.
*      "Populate the reference number from BKPF table as this field is not in ACDOCA
*      gw_output-xblnr = lw_bkpf-xblnr.
*    ENDIF.
*
*    READ TABLE gt_lfa1 INTO DATA(lw_lfa1) WITH KEY lifnr = lw_acdoca-lifnr BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      " Populate the vendor details from vendor master table
*      gw_output-lifnr = lw_lfa1-lifnr.
*      gw_output-name1 = lw_lfa1-name1.
*      gw_output-stceg = lw_lfa1-stceg.
*    ENDIF.
*
**Tax data
**Start of Changes - 477670 | D4SK907471
**Tax fields fetched based on condition type
*    READ TABLE gt_bset_temp INTO gw_bset_temp WITH KEY bukrs = lw_acdoca-rbukrs
*                                                       belnr = lw_acdoca-belnr
*                                                       gjahr = lw_acdoca-gjahr BINARY SEARCH.
*
*    IF sy-subrc EQ 0.
*
*      LOOP AT gt_bset_temp INTO gw_bset_temp FROM sy-tabix.
*        IF gw_bset_temp-bukrs NE lw_acdoca-rbukrs
*          OR gw_bset_temp-belnr NE lw_acdoca-belnr
*          OR gw_bset_temp-gjahr NE lw_acdoca-gjahr.
*          EXIT.
*        ENDIF.
*        gw_output-tax_base1     =  gw_bset_temp-tax_base1.
*        gw_output-vat%1         =  gw_bset_temp-vat%1.
*        gw_output-vat_amount1   =  gw_bset_temp-vat_amount1.
*
*        gw_output-tax_base2     =  gw_bset_temp-tax_base2.
*        gw_output-vat%2         =  gw_bset_temp-vat%2.
*        gw_output-vat_amount2   =  gw_bset_temp-vat_amount2.
*
*        gw_output-tax_base3     =  gw_bset_temp-tax_base3.
*        gw_output-vat%3         =  gw_bset_temp-vat%3.
*        gw_output-vat_amount3   =  gw_bset_temp-vat_amount3.
*
*        gw_output-tax_base4     =  gw_bset_temp-tax_base4.
*        gw_output-vat%4         =  gw_bset_temp-vat%4.
*        gw_output-vat_amount4   =  gw_bset_temp-vat_amount4.
**End of Changes - 477670 | D4SK907471
*        APPEND gw_output TO gt_output.
*      ENDLOOP.
*    ENDIF.
*
*    CLEAR: gw_output, lw_lfa1, lw_bset, lw_bkpf.
*  ENDLOOP.
*
*  REFRESH: gt_bset[], gt_lfa1[].
*  DELETE ADJACENT DUPLICATES FROM gt_output COMPARING ALL FIELDS.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_AUTHORITY_CHECK
**&---------------------------------------------------------------------*
**& Authority check for Company code
**&---------------------------------------------------------------------*
*FORM f_authority_check .
*
*  TYPES: BEGIN OF ty_t001,
*           bukrs TYPE  bukrs,
*         END OF ty_t001.
*
*  DATA: lt_t001 TYPE TABLE OF ty_t001.
*
*  SELECT bukrs
*     FROM t001
*     INTO TABLE lt_t001
*     WHERE bukrs IN s_bukrs .
*
*  LOOP AT lt_t001 INTO DATA(lw_t001).
*    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*    ID 'ACTVT' FIELD '03'
*    ID 'BUKRS' FIELD lw_t001-bukrs.
*    IF sy-subrc <> 0.
*      MESSAGE e064 WITH lw_t001-bukrs.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_DISPLAY_DATA
**&---------------------------------------------------------------------*
**& Display data
**&---------------------------------------------------------------------*
*
*FORM f_display_data .
*
*  DATA: lv_repid  TYPE sy-repid,
*        lw_layout TYPE slis_layout_alv.
*
*  PERFORM f_field_cat.
*
*  lw_layout-zebra = c_x.
*  lw_layout-colwidth_optimize = c_x.
*
*  lv_repid = sy-cprog.
*
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      i_callback_program = lv_repid
*      it_fieldcat        = gt_fieldcat[]
*      i_structure_name   = 'TY_OUTPUT'
*      is_layout          = lw_layout
*      i_default          = c_x
*      i_save             = c_a
*    TABLES
*      t_outtab           = gt_output[]
*    EXCEPTIONS
*      OTHERS             = 4.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_FIELD_CAT
**&---------------------------------------------------------------------*
**& Field Catalog for Internal Table
**&---------------------------------------------------------------------*
*FORM f_field_cat .
**Start of Change - 477670 | D4SK907641
**Change in the order of columns
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '1'.
*  gw_fieldcat-fieldname = TEXT-002. " Change by 475950 D4SK907661
*  gw_fieldcat-seltext_m = TEXT-040. " Change by 475950 D4SK907661
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '2'.
*  gw_fieldcat-fieldname = TEXT-039. " Change by 475950 D4SK907661
*  gw_fieldcat-seltext_m = TEXT-003. " Change by 475950 D4SK907661
*  APPEND gw_fieldcat TO gt_fieldcat.
**End of Change - 477670 | D4SK907641
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '3'.
*  gw_fieldcat-fieldname = TEXT-004.
*  gw_fieldcat-seltext_m = TEXT-005.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '4'.
*  gw_fieldcat-fieldname = TEXT-035.
*  gw_fieldcat-seltext_m = TEXT-006.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '5'.
*  gw_fieldcat-fieldname = TEXT-007.
*  gw_fieldcat-seltext_m = TEXT-008.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '6'.
*  gw_fieldcat-fieldname = TEXT-009.
*  gw_fieldcat-seltext_m = TEXT-010.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '7'.
*  gw_fieldcat-fieldname = TEXT-041.
*  gw_fieldcat-seltext_m = TEXT-042.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '8'.
*  gw_fieldcat-fieldname = TEXT-011.
*  gw_fieldcat-seltext_m = TEXT-012.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '9'.
*  gw_fieldcat-fieldname = TEXT-013.
*  gw_fieldcat-seltext_m = TEXT-014.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '10'.
*  gw_fieldcat-fieldname = TEXT-015.
*  gw_fieldcat-seltext_m = TEXT-016.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '11'.
*  gw_fieldcat-fieldname = TEXT-017.
*  gw_fieldcat-seltext_m = TEXT-018.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '12'.
*  gw_fieldcat-fieldname = TEXT-019.
*  gw_fieldcat-seltext_m = TEXT-020.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '13'.
*  gw_fieldcat-fieldname = TEXT-021.
*  gw_fieldcat-seltext_m = TEXT-022.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '14'.
*  gw_fieldcat-fieldname = TEXT-023.
*  gw_fieldcat-seltext_m = TEXT-024.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '15'.
*  gw_fieldcat-fieldname = TEXT-025.
*  gw_fieldcat-seltext_m = TEXT-026.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '16'.
*  gw_fieldcat-fieldname = TEXT-027.
*  gw_fieldcat-seltext_m = TEXT-028.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '17'.
*  gw_fieldcat-fieldname = TEXT-029.
*  gw_fieldcat-seltext_m = TEXT-030.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '18'.
*  gw_fieldcat-fieldname = TEXT-031.
*  gw_fieldcat-seltext_m = TEXT-032.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '19'.
*  gw_fieldcat-fieldname = TEXT-043.
*  gw_fieldcat-seltext_m = TEXT-044.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '20'.
*  gw_fieldcat-fieldname = TEXT-045.
*  gw_fieldcat-seltext_m = TEXT-046.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '21'.
*  gw_fieldcat-fieldname = TEXT-047.
*  gw_fieldcat-seltext_m = TEXT-048.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '22'.
*  gw_fieldcat-fieldname = TEXT-037.
*  gw_fieldcat-seltext_m = TEXT-038.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**& Form F_CLEAR_GLOBAL_VAR
**&---------------------------------------------------------------------*
**& *& Clear all global variables.
**&---------------------------------------------------------------------*
*FORM f_clear_global_var .
*
*  REFRESH: gt_output,
*           gt_bkpf,
*           gt_acdoca,
*           gt_fieldcat.
*ENDFORM.
