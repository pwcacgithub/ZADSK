**&---------------------------------------------------------------------*
**& Include          ZRPFI_ELEC_RPT_PL_FORM
**&---------------------------------------------------------------------*
*
**&---------------------------------------------------------------------*
**& Form F_AUTHORITY_CHECK
**&---------------------------------------------------------------------*
**& To check user's authorization
**&---------------------------------------------------------------------*
*FORM f_authority_check .
*
*  TYPES : BEGIN OF lty_t001 ,
*            bukrs TYPE  t001-bukrs,
*          END OF lty_t001.
*  DATA : lt_t001 TYPE STANDARD TABLE OF lty_t001 INITIAL SIZE 0,
*         lw_t001 TYPE lty_t001.
*
*  IF s_bukrs IS NOT INITIAL.
*    SELECT bukrs
*        FROM t001
*        INTO TABLE lt_t001
*        WHERE bukrs IN s_bukrs .
*
*    LOOP AT lt_t001 INTO lw_t001.
*      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*             ID 'BUKRS' FIELD lw_t001-bukrs
*             ID 'ACTVT' FIELD '03'.
*
*      IF sy-subrc NE 0.
**        MESSAGE e032 WITH 'No Authorization to Execute Report'(024).
*      ENDIF.
*      CLEAR :lw_t001.
*    ENDLOOP.
*  ENDIF.
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_FETCH_DATA
**&---------------------------------------------------------------------*
**&  Fetch the data from different tables for processing
**&---------------------------------------------------------------------*
*FORM f_fetch_data .
*
*  DATA : l_cursor_bkpf   TYPE cursor,
*         l_cursor_bseg   TYPE cursor,
*         l_cursor_acdoca TYPE cursor,
*         lv_date         TYPE i,
*         lv_date_bsak    TYPE i.
**Fetch Accounting document header
**Open Cursor for the Extract
*  CLEAR : l_cursor_bkpf, l_cursor_bseg.
*  OPEN CURSOR l_cursor_bkpf FOR
*    SELECT bukrs belnr gjahr blart bldat
*           budat monat cpudt xblnr stblg rldnr
*    FROM bkpf
*      WHERE bukrs IN s_bukrs
*      AND   gjahr EQ p_gjahr
*      AND   budat IN s_date
*      AND   xblnr IN s_xblnr.
*
*
*  DO.
** Fetch Data based on the Selection based on package size
*    FETCH NEXT CURSOR l_cursor_bkpf APPENDING TABLE gt_bkpf PACKAGE SIZE 500.
*    IF sy-subrc NE 0.
*      EXIT.
*    ENDIF.
*  ENDDO.
*  CLOSE CURSOR l_cursor_bkpf.
*
**Begin of 479563 : D4SK907123
** Fetch data from acdoca table
*  CLEAR : l_cursor_acdoca.
*
*  REFRESH: gt_acdoca[].
*  OPEN CURSOR l_cursor_acdoca FOR
*  SELECT rldnr rbukrs gjahr belnr blart bschl
*  lokkt  lifnr augdt anln1 netdt   "added asset number - anln1 : D4SK907704
*    FROM acdoca
*    FOR ALL ENTRIES IN gt_bkpf
*    WHERE rbukrs = gt_bkpf-bukrs
*    AND   belnr =  gt_bkpf-belnr
*    AND   gjahr =  gt_bkpf-gjahr
*    AND   rldnr =  p_rldnr
*    AND   blart IN s_blart
*    AND   lifnr IN s_lifnr.
*
*
*  DO.
*    FETCH NEXT CURSOR l_cursor_acdoca APPENDING TABLE gt_acdoca PACKAGE SIZE 500.
*    IF sy-subrc = 0.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.
*
*  CLOSE CURSOR l_cursor_acdoca.
*  SORT gt_acdoca BY rbukrs belnr gjahr rldnr.
*
**End of 479563 : D4SK907123
*
*  DATA(lt_acdoca) = gt_acdoca[].
*  SORT lt_acdoca BY lifnr.
*  DELETE ADJACENT DUPLICATES FROM lt_acdoca COMPARING lifnr.
*
*  IF lt_acdoca[] IS NOT INITIAL.
**Fetch from LFA1 for vat and name
*    SELECT lifnr, land1, name1,
*           regio, adrnr, stceg
*      FROM lfa1
*      INTO TABLE @DATA(gt_lfa1)
*      FOR ALL ENTRIES IN @lt_acdoca
*      WHERE lifnr = @lt_acdoca-lifnr.
*    IF sy-subrc = 0.
*      SORT gt_lfa1 BY lifnr.
*      DATA(lt_lfa1) = gt_lfa1.
*      SORT lt_lfa1 BY adrnr.
*      DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING adrnr.
*
**Fetch from ADRC for street and city
*      SELECT addrnumber, city1, street
*        FROM adrc
*        INTO TABLE @DATA(gt_adrc)
*        FOR ALL ENTRIES IN @lt_lfa1
*        WHERE addrnumber = @lt_lfa1-adrnr.
*      IF sy-subrc = 0.
*        SORT gt_adrc BY addrnumber.
*      ENDIF.
*    ENDIF.
*
**If tax number is not present in LFA1 pick from dfkkbptaxnum
*    SELECT partner,taxtype,taxnum
*      FROM dfkkbptaxnum
*      INTO TABLE @DATA(gt_dfkk)
*      FOR ALL ENTRIES IN @lt_acdoca
*      WHERE partner = @lt_acdoca-lifnr.
*    IF sy-subrc = 0.
*      SORT gt_dfkk BY partner.
*    ENDIF.
*
*  ENDIF.
*
*  IF gt_bkpf[] IS NOT INITIAL.
*    DATA(lt_bkpf) = gt_bkpf.
*    SORT lt_bkpf BY bukrs belnr gjahr.
*    DELETE ADJACENT DUPLICATES FROM lt_bkpf COMPARING bukrs belnr gjahr.
*
**Fetch Tax Data Document Segment
*    SELECT bukrs, belnr, gjahr, buzei,
*           fwbas, kbetr, fwste
*      FROM bset INTO TABLE @DATA(gt_bset)
*      FOR ALL ENTRIES IN @lt_bkpf
*      WHERE bukrs = @lt_bkpf-bukrs
*      AND belnr = @lt_bkpf-belnr
*      AND gjahr = @lt_bkpf-gjahr.
*
*    IF sy-subrc EQ 0.
*      SORT gt_bset BY bukrs belnr buzei.
*    ENDIF.
*
**  To fetch paid invoices
*    SELECT bukrs, lifnr, gjahr, belnr, buzei, mwsts
*     FROM bsik
*     INTO TABLE @DATA(gt_bsik)
*     FOR ALL ENTRIES IN @lt_bkpf
*     WHERE bukrs   = @lt_bkpf-bukrs
*     AND   lifnr  IN @s_lifnr
*     AND   gjahr   = @lt_bkpf-gjahr
*     AND   belnr   = @lt_bkpf-belnr
*     AND blart IN @s_blart.
*    IF sy-subrc = 0.
*      SORT gt_bsik BY bukrs gjahr belnr.
*    ENDIF.
*
**To fetch the paid invoices.
*    SELECT bukrs, lifnr, gjahr, belnr,
*           buzei, blart, mwsts
*      FROM bsak
*      INTO TABLE @DATA(gt_bsak)
*      FOR ALL ENTRIES IN @lt_bkpf
*      WHERE bukrs  = @lt_bkpf-bukrs
*      AND lifnr   IN @s_lifnr
*      AND gjahr    = @lt_bkpf-gjahr
*       AND belnr   = @lt_bkpf-belnr
*      AND blart IN @s_blart .
*
*    IF sy-subrc = 0.
*      SORT gt_bsik BY bukrs gjahr belnr.
*    ENDIF.
*  ENDIF.
*
*  DATA(gt_acdoc_temp) = gt_acdoca[].
*
*  SORT gt_acdoc_temp BY rbukrs belnr gjahr lifnr.
**  Populate data in final table
*
*  REFRESH : gt_output.
*
*  SORT gt_bkpf BY bukrs belnr gjahr.
*
*  LOOP AT gt_acdoca INTO DATA(lw_acdoca).
*
*    READ TABLE gt_bset INTO DATA(lw_bset) WITH KEY bukrs = lw_acdoca-rbukrs
*                                                   belnr = lw_acdoca-belnr
*                                                   gjahr = lw_acdoca-gjahr
*                                                   BINARY SEARCH.
*    IF sy-subrc = 0.
*      DATA(lv_index) = sy-tabix.
*
*      LOOP AT gt_bset INTO lw_bset FROM lv_index.
*        IF lw_acdoca-belnr  <> lw_bset-belnr.
*          EXIT.
*        ENDIF.
*
*        READ TABLE gt_bkpf INTO DATA(lw_bkpf) WITH KEY  bukrs = lw_bset-bukrs
*                                                        belnr = lw_bset-belnr
*                                                        gjahr = lw_bset-gjahr BINARY SEARCH.
*        IF sy-subrc = 0.
**  Pass the document and reference document number
*          gw_output-belnr = lw_bkpf-belnr.
*          gw_output-xblnr = lw_bkpf-xblnr.
*
**  Pass the document date and posting date
*          gw_output-bldat = lw_bkpf-bldat.
*          gw_output-budat = lw_bkpf-budat.
*
**Begin of change 477670 : D4SK907704
**Amounts for assets and goods should be based on asset number
*          IF lw_acdoca-anln1 IS NOT INITIAL.
** Purchase of Fixed Assets-Net Amount
*            gw_output-fxnetamt = lw_bset-fwbas.
** Purchase of fixed assets - VAT amount
*            gw_output-fxvatamt = lw_bset-fwste.
*          ELSE.
*** Purchase of goods - net amount
*            gw_output-gdnetamt = lw_bset-fwbas.
** Purchase of goods - VAT amount
*            gw_output-gdvatamt = lw_bset-fwste.
*          ENDIF.
**End of change 477670 : D4SK907704
*
*          READ TABLE gt_lfa1 INTO DATA(lw_lfa1) WITH KEY lifnr = lw_acdoca-lifnr BINARY SEARCH.
*          IF sy-subrc EQ 0.
**     Pass the vendor name and taxid
*            gw_output-name1 = lw_lfa1-name1.
*            gw_output-stceg = lw_lfa1-stceg.
*
*            IF  gw_output-stceg IS INITIAL.
**           If the tax id is initial than  fecth  from DFKKBPTAXNUM
*              READ TABLE gt_dfkk INTO DATA(lw_dfkk) WITH KEY partner = lw_acdoca-lifnr BINARY SEARCH.
*              IF sy-subrc = 0.
**              Tax id
*                gw_output-stceg = lw_dfkk-taxnum.
*              ENDIF.
*            ENDIF.
*
*            READ TABLE gt_adrc INTO DATA(lw_adrc) WITH KEY addrnumber = lw_lfa1-adrnr BINARY SEARCH.
*            IF sy-subrc EQ 0.
**     Pass the address by concatenating street and city from ADRC
*              CONCATENATE lw_adrc-street '  ' ',' lw_adrc-city1  INTO gw_output-address.
*            ENDIF.
*          ENDIF.
**      ENDIF.
*
*
**      logic for paid and non paid invoices.
*          IF lw_bkpf-stblg IS INITIAL.
** To read from BSIK for non paid invoices
*            READ TABLE gt_bsik INTO DATA(lw_bsik) WITH KEY bukrs = lw_bkpf-bukrs
*                                                           gjahr = lw_bkpf-gjahr
*                                                           belnr = lw_bkpf-belnr.
*            IF sy-subrc = 0.
*
*              READ TABLE gt_acdoc_temp INTO DATA(lw_acdoc1) WITH KEY rbukrs = lw_bsik-bukrs
*                                                      belnr = lw_bsik-belnr
*                                                      gjahr = lw_bsik-gjahr
*                                                      lifnr = lw_bsik-lifnr
*                                                      BINARY SEARCH.
*              IF sy-subrc = 0.
**     Calculation for due date.
*                lv_date =  sy-datum -  lw_acdoc1-netdt .
*                IF lv_date GE 90.
*                  IF lw_acdoc1-augdt IS INITIAL.
*                    IF lw_acdoc1-bschl = gv_31 OR lw_acdoc1-bschl = gv_21.
**           Logic for not paid invoices
*                      gw_output-notpaidinv = lw_bsik-mwsts.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*
**To read from BSAK for paid invoices
*            READ TABLE gt_bsak INTO DATA(lw_bsak) WITH KEY bukrs = lw_bkpf-bukrs
*                                                                   gjahr = lw_bkpf-gjahr
*                                                                   belnr = lw_bkpf-belnr.
*            IF sy-subrc = 0.
*
*              READ TABLE gt_acdoc_temp INTO DATA(lw_acdoc2) WITH KEY rbukrs = lw_bsak-bukrs
*                                                      belnr = lw_bsak-belnr
*                                                      gjahr = lw_bsak-gjahr
*                                                      lifnr = lw_bsak-lifnr
*                                                      BINARY SEARCH.
*              IF sy-subrc = 0.
**     Calculation for due date.
*                lv_date_bsak = sy-datum -  lw_acdoc2-netdt .
*                IF lv_date_bsak GE 90.
*                  IF lw_acdoc2-augdt IS NOT INITIAL.
*                    IF lw_acdoc2-bschl = gv_31 OR lw_acdoc2-bschl = gv_21 OR lw_acdoc2-bschl = gv_22 .
**           Paid invoices
*                      gw_output-paidinv = lw_bsak-mwsts.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
**Begin of 479563 : D4SK907123
**   to display the ledger
*          gw_output-lokkt = lw_acdoca-lokkt.
**End of 479563 : D4SK907123
*        ENDIF.
*
*        APPEND gw_output TO gt_output.
*        CLEAR: gw_output, lw_lfa1, lw_bset, lw_bkpf , lw_acdoc1,
*               lw_acdoc2 ,lw_bsik , lw_bsak , lv_date , lv_date_bsak.
*      ENDLOOP.
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
*  CONSTANTS : lc_x TYPE char1 VALUE 'X',
*              lc_a TYPE char1 VALUE 'A'.
*
*  DATA: lv_repid  TYPE sy-repid,
*        lw_layout TYPE slis_layout_alv.
*
*  PERFORM f_field_cat.
*
*  lw_layout-zebra = lc_x.
*  lw_layout-colwidth_optimize = lc_x.
*
*  lv_repid = sy-cprog.
*
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      i_callback_program = lv_repid
*      it_fieldcat        = gt_fieldcat[]
*      i_structure_name   = 'TY_OUTPUT'
*      is_layout          = lw_layout
*      i_default          = lc_x
*      i_save             = lc_a
*    TABLES
*      t_outtab           = gt_output[]
*    EXCEPTIONS
*      OTHERS             = 4.
*  IF sy-subrc = 0.
*    "No Data found for the given selection-screen Criteria
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_FIELD_CAT
**&---------------------------------------------------------------------*
**&  Field Catalog for Internal Table
**&---------------------------------------------------------------------*
*
*FORM f_field_cat .
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '1'.
*  gw_fieldcat-fieldname = TEXT-002.
*  gw_fieldcat-seltext_m = TEXT-003.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '2'.
*  gw_fieldcat-fieldname = TEXT-004.
*  gw_fieldcat-seltext_m = TEXT-005.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '3'.
*  gw_fieldcat-fieldname = TEXT-006.
*  gw_fieldcat-seltext_m = TEXT-007.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '4'.
*  gw_fieldcat-fieldname = TEXT-008.
*  gw_fieldcat-seltext_m = TEXT-009.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '5'.
*  gw_fieldcat-fieldname = TEXT-010.
*  gw_fieldcat-seltext_m = TEXT-011.
*  gw_fieldcat-seltext_l = TEXT-011.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '6'.
*  gw_fieldcat-fieldname = TEXT-012.
*  gw_fieldcat-seltext_m = TEXT-013.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '7'.
*  gw_fieldcat-fieldname = TEXT-014.
*  gw_fieldcat-seltext_m = TEXT-015.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '8'.
*  gw_fieldcat-fieldname = TEXT-016.
*  gw_fieldcat-seltext_s = TEXT-017.
*  gw_fieldcat-seltext_m = TEXT-017.
*  gw_fieldcat-seltext_l = TEXT-017.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '9'.
*  gw_fieldcat-fieldname = TEXT-018.
*  gw_fieldcat-seltext_s = TEXT-019.
*  gw_fieldcat-seltext_m = TEXT-019.
*  gw_fieldcat-seltext_l = TEXT-019.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '10'.
*  gw_fieldcat-fieldname = TEXT-020.
*  gw_fieldcat-seltext_s = TEXT-021.
*  gw_fieldcat-seltext_m = TEXT-021.
*  gw_fieldcat-seltext_l = TEXT-021.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '11'.
*  gw_fieldcat-fieldname = TEXT-022.
*  gw_fieldcat-seltext_s = TEXT-023.
*  gw_fieldcat-seltext_m = TEXT-023.
*  gw_fieldcat-seltext_l = TEXT-023.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '12'.
*  gw_fieldcat-fieldname = TEXT-027.
*  gw_fieldcat-seltext_s = TEXT-025.
*  gw_fieldcat-seltext_m = TEXT-025.
*  gw_fieldcat-seltext_l = TEXT-025.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '13'.
*  gw_fieldcat-fieldname = TEXT-028.
*  gw_fieldcat-seltext_s = TEXT-026.
*  gw_fieldcat-seltext_m = TEXT-026.
*  gw_fieldcat-seltext_l = TEXT-026.
*  APPEND gw_fieldcat TO gt_fieldcat.
*
**Begin of 479563 : D4SK907123
*  CLEAR: gw_fieldcat.
*  gw_fieldcat-col_pos = '14'.
*  gw_fieldcat-fieldname = TEXT-030.
*  gw_fieldcat-seltext_s = TEXT-029.
*  gw_fieldcat-seltext_m = TEXT-029.
*  gw_fieldcat-seltext_l = TEXT-029.
*  APPEND gw_fieldcat TO gt_fieldcat.
**End of 479563 : D4SK907123
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_CLEAR_GLOBAL_VAR
**&---------------------------------------------------------------------*
**& Clear global variables
**&---------------------------------------------------------------------*
*
*FORM f_clear_global_var .
*  REFRESH: gt_output,
*           gt_bkpf,
*           gt_acdoca,
*           gt_fieldcat.
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_GET_CONSTANTS
**&---------------------------------------------------------------------*
**& Fetch the constants for the program
**&---------------------------------------------------------------------*
*
*FORM f_get_constants  USING   fp_pgmid TYPE char40.
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
**        MESSAGE e007 WITH 'TVARVC'(046).
*      WHEN 2.
**        MESSAGE e010 WITH 'TVARVC'(046).
*      WHEN OTHERS.
*    ENDCASE.
*  ENDIF.
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form F_COLLECT_CONSTANTS
**&---------------------------------------------------------------------*
**& Collect the value of the Constants in variables
**&---------------------------------------------------------------------*
*
*FORM f_collect_constants .
*
*  REFRESH s_blart[].
*  LOOP AT gt_pgm_const_values INTO DATA(gs_pgm_const_values) WHERE const_name = 'S_BLART_POLAND'.
*    IF sy-subrc = 0.
*      s_blart-sign   = gs_pgm_const_values-sign.
*      s_blart-option = gs_pgm_const_values-opti.
*      s_blart-low    = gs_pgm_const_values-low.
*      s_blart-high   = gs_pgm_const_values-high.
*      APPEND s_blart.
*      CLEAR s_blart.
*    ELSE.
**      MESSAGE e025 WITH 'S_BLART_POLAND'(052).
*    ENDIF.
*  ENDLOOP.
*
*  READ TABLE gt_pgm_const_values INTO DATA(lw_pgm_const_values) WITH KEY const_name = 'P_31'.
*  IF sy-subrc = 0.
*    gv_31 = lw_pgm_const_values-low.
*  ELSE.
**    MESSAGE e025 WITH 'P_31'(049).
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_21'.
*  IF sy-subrc = 0.
*    gv_21 = lw_pgm_const_values-low.
*  ELSE.
**    MESSAGE e025 WITH 'P_21'(050).
*  ENDIF.
*
*  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_22'.
*  IF sy-subrc = 0.
*    gv_22 = lw_pgm_const_values-low.
*  ELSE.
**    MESSAGE e025 WITH 'P_22'(051).
*  ENDIF.
*ENDFORM.
