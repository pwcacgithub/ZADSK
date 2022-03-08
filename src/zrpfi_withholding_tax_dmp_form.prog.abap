*&---------------------------------------------------------------------*
*& Include          ZRPFI_WITHHOLDING_TAX_DMP_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_GET_WHTEXEMPTION
*&---------------------------------------------------------------------*
*& Fetch the data for WHT Exemption Report
*&---------------------------------------------------------------------*
FORM f_get_whtexemption .

  IF  p_exto IS NOT INITIAL .
*Get Exemption certificate data
    SELECT lifnr bukrs witht wt_subjct
           qsrec wt_wtstcd wt_withcd
           wt_exnr wt_exrt wt_exdf wt_exdt
           wt_wtexrs
       INTO TABLE gt_output
       FROM lfbw
       WHERE lifnr IN s_lifnr
       AND bukrs IN s_bukrs
       AND wt_exdt LE p_exto.

  ELSE.
    SELECT lifnr bukrs witht wt_subjct
           qsrec wt_wtstcd wt_withcd
          wt_exnr wt_exrt wt_exdf wt_exdt
          wt_wtexrs
      INTO TABLE gt_output
      FROM lfbw
      WHERE lifnr IN s_lifnr
      AND bukrs IN s_bukrs.

  ENDIF.

  IF sy-subrc = 0.
    SORT gt_output BY bukrs.
  ENDIF.

*Deleting  entries when date holds no value
  DELETE gt_output WHERE wt_exdf IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*& Validate the fields on the selection screen
*&---------------------------------------------------------------------*
FORM f_validate_data .

  TYPES : BEGIN OF ty_lifnr,
            lifnr TYPE lifnr,
          END OF ty_lifnr,

          BEGIN OF ty_bukrs,
            bukrs TYPE bukrs,
          END OF ty_bukrs.

  DATA: lt_lfa1  TYPE STANDARD TABLE OF ty_lifnr INITIAL SIZE 0,
        lt_bukrs TYPE STANDARD TABLE OF ty_bukrs INITIAL SIZE 0.

*Validation on vendor
  IF s_lifnr[] IS NOT INITIAL.
    SELECT lifnr FROM lfa1 INTO TABLE lt_lfa1
      WHERE lifnr IN s_lifnr.
    IF sy-subrc NE 0.
      MESSAGE e007 WITH s_lifnr-low.
    ENDIF.
  ENDIF.

*Validation for company code
  IF s_bukrs[] IS NOT INITIAL.
    SELECT bukrs FROM t001 INTO TABLE lt_bukrs
      WHERE bukrs IN s_bukrs.
    IF sy-subrc NE 0.
      MESSAGE e005 WITH s_bukrs-low.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_RADIO_VISIBLE
*&---------------------------------------------------------------------*
*& Control the radio button display on the selection screen
*&---------------------------------------------------------------------*
FORM f_radio_visible .

  LOOP AT SCREEN.
    IF p_rad1 = abap_true.
      IF screen-group1 = 'B1'.
        screen-active = 1.
      ELSEIF screen-group1 = 'B2'.
        screen-active = 0.

        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF p_rad2 = abap_true.
      IF screen-group1 = 'B2'.
        screen-active = 1.
      ELSEIF screen-group1 = 'B1'.
        screen-active = 0.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DATA_SELECTION
*&---------------------------------------------------------------------*
*& Fetch teh data for the WHT Post Report
*&---------------------------------------------------------------------*
FORM f_data_selection .

  DATA : l_cursor_bkpf TYPE cursor,
         l_cursor_bseg TYPE cursor.

*Fetch company code based on currency key and language
  SELECT bukrs land1 spras FROM t001 INTO TABLE gt_t001
    WHERE bukrs IN s_bukrs
    AND land1 = p_ckey
    AND spras = p_langu.

  IF sy-subrc NE 0.
    MESSAGE i039 WITH s_bukrs-low p_ckey.
  ELSE.
    DATA(lt_t001) = gt_t001.
    SORT lt_t001 BY bukrs.
    DELETE ADJACENT DUPLICATES FROM lt_t001 COMPARING bukrs.

*Fetch Accounting document header
*Open Cursor for the Extract
    CLEAR : l_cursor_bkpf, l_cursor_bseg.
    OPEN CURSOR l_cursor_bkpf FOR
      SELECT bukrs
             belnr
             gjahr
             blart
             bldat
             budat
             monat
             cpudt
             xblnr
      FROM bkpf
      FOR ALL ENTRIES IN lt_t001
      WHERE bukrs = lt_t001-bukrs
        AND gjahr IN s_gjahr
        AND budat IN s_budat.
    DO.
* Fetch Data based on the Selection based on package size
      FETCH NEXT CURSOR l_cursor_bkpf APPENDING TABLE gt_bkpf PACKAGE SIZE 500.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDDO.

    CLOSE CURSOR l_cursor_bkpf.

    IF gt_bkpf[] IS INITIAL.
      MESSAGE i040 WITH s_bukrs-low s_gjahr-low.
    ELSE.
      DATA(lt_bkpf) = gt_bkpf.
      SORT lt_bkpf BY bukrs belnr gjahr.
      DELETE ADJACENT DUPLICATES FROM lt_bkpf COMPARING bukrs belnr gjahr.
    ENDIF.

  ENDIF.

*//-- Start of Insert INC2613809 D4SK906959
  SELECT currkey currdec
    INTO TABLE gt_tcurx
    FROM tcurx.
*//-- End of Insert INC2613809 D4SK906959

  IF lt_bkpf[] IS NOT INITIAL.
*Fetch Accounting document item data
*Open Cursor for the Extract
    OPEN CURSOR l_cursor_bseg FOR
        SELECT bseg~bukrs
           bseg~belnr
           bseg~gjahr
           bseg~buzei
           bseg~augbl
           bseg~koart
           bseg~augdt
           bseg~umskz
           bseg~lifnr
           bseg~bupla
           bseg~secco
           bseg~zlspr
*//-- Start of Insert INC2613809 D4SK906959
           bseg~h_waers
           bseg~h_hwaer
*//-- End of Insert INC2613809 D4SK906959
           with_item~witht
           with_item~wt_withcd
           with_item~wt_qsshh
           with_item~wt_qsshb
           with_item~wt_qbshh
           with_item~wt_qbshb
           with_item~hkont
           with_item~qsrec
           with_item~ctnumber
           with_item~j_1icertdt
      FROM ( bseg INNER JOIN with_item
      ON   bseg~bukrs = with_item~bukrs
      AND  bseg~belnr = with_item~belnr
      AND  bseg~gjahr = with_item~gjahr
      AND  bseg~buzei = with_item~buzei )
      FOR ALL ENTRIES IN lt_bkpf
      WHERE bseg~bukrs = lt_bkpf-bukrs
      AND bseg~belnr   = lt_bkpf-belnr
      AND bseg~gjahr   = lt_bkpf-gjahr
      AND bseg~lifnr   IN s_lifnr
      AND bseg~umskz   IN s_umskz
*//-- Start of Changes INC2732452 D4SK907855
      AND bseg~augdt   IN s_augdt.
*//-- End of Changes INC2732452 D4SK907855

    DO.
      FETCH NEXT CURSOR l_cursor_bseg APPENDING TABLE gt_bseg PACKAGE SIZE 500.

      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDDO.

    CLOSE CURSOR l_cursor_bseg.

    IF gt_bseg[] IS INITIAL.
      MESSAGE i041 WITH s_lifnr-low.
    ELSE.
      DATA(lt_bseg) = gt_bseg.
      SORT lt_bseg BY bukrs witht wt_withcd qsrec.
      DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING bukrs witht wt_withcd qsrec.
    ENDIF.
  ENDIF.


  IF lt_bseg[] IS NOT INITIAL.
*Derivation of Surchage rate
    SELECT bukrs witht wt_withcd qsrec j_1isurrat
    FROM j_1iewt_surc1
      INTO TABLE gt_j_liewt_surc1
     FOR ALL ENTRIES IN lt_bseg
     WHERE   bukrs     =  lt_bseg-bukrs
       AND   witht     =  lt_bseg-witht
       AND   wt_withcd =  lt_bseg-wt_withcd.
*       AND   qsrec     =  lt_bseg-qsrec  .

    IF sy-subrc EQ 0.
      SORT gt_j_liewt_surc1 BY witht wt_withcd.
    ENDIF.

*Derivation of Education Cess Rate
    SELECT bukrs witht wt_withcd qsrec j_1iecessrt
    FROM j_1iewt_ecess1
      INTO  TABLE gt_j_1iewt_ecess1
     FOR ALL ENTRIES IN lt_bseg
     WHERE   bukrs     =  lt_bseg-bukrs
       AND   witht     =  lt_bseg-witht
       AND   wt_withcd =  lt_bseg-wt_withcd.
*       AND   qsrec     =  lt_bseg-qsrec  .

    IF sy-subrc EQ 0.
      SORT gt_j_1iewt_ecess1 BY witht wt_withcd.
    ENDIF.

*Fetch vendor details
    REFRESH lt_bseg[].
    lt_bseg[] = gt_bseg[].
    SORT lt_bseg BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING lifnr.

    SELECT lfa1~lifnr lfa1~land1 lfa1~name1 lfa1~adrnr lfa1~regio
       lfa1~ktokk lfa1~j_1ipanno lfa1~stcd1 lfa1~stcd2 lfa1~stceg
       lfa1~txjcd lfb1~qland
       INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
       FROM ( lfa1 INNER JOIN lfb1
       ON lfa1~lifnr = lfb1~lifnr )
       FOR ALL ENTRIES IN lt_bseg
       WHERE lfa1~lifnr = lt_bseg-lifnr.

    IF sy-subrc EQ 0.
      SORT gt_lfa1 BY lifnr.
    ENDIF.

*Fetch Withholding tax code
    REFRESH lt_bseg[].
    lt_bseg[] = gt_bseg[].
    SORT lt_bseg BY witht wt_withcd.
    DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING witht wt_withcd.

    SELECT witht wt_withcd qscod
      INTO TABLE gt_t059z
      FROM t059z
      FOR ALL ENTRIES IN lt_bseg
      WHERE witht   = lt_bseg-witht
      AND wt_withcd = lt_bseg-wt_withcd.

    IF sy-subrc EQ 0.
      SORT gt_t059z BY witht wt_withcd.
    ENDIF.
*//-- Start of Insert INC2732452 D4SK907855
*Fetch GL Acounts not existing in WITH_ITEM, get it from BSEG
    REFRESH lt_bseg[].
    lt_bseg[] = gt_bseg[].
    SORT lt_bseg BY bukrs belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING belnr.

    IF lt_bseg[] IS NOT INITIAL.

      SELECT bukrs belnr gjahr hkont ktosl
        INTO TABLE gt_hkont
        FROM bseg
        FOR ALL ENTRIES IN lt_bseg
       WHERE bukrs EQ lt_bseg-bukrs
         AND belnr EQ lt_bseg-belnr
         AND gjahr EQ lt_bseg-gjahr
         AND koart = c_s
         AND xbilk = c_x
         AND ( ktosl = c_wit OR ktosl = space ).

      SORT gt_hkont BY bukrs belnr gjahr.
    ENDIF.
*//-- End of Insert INC2732452 D4SK907855
  ENDIF.

  IF gt_lfa1[] IS NOT INITIAL.

    DATA(lt_lfa1) = gt_lfa1.
    SORT lt_lfa1 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.

*Fetch Tax type and Tax number
    SELECT partner taxtype taxnum FROM dfkkbptaxnum INTO TABLE gt_dfkkbptaxnum
      FOR ALL ENTRIES IN lt_lfa1 WHERE partner = lt_lfa1-lifnr.

    IF sy-subrc EQ 0.
      SORT gt_dfkkbptaxnum BY partner.
    ENDIF.

*Fetch vendor address
    REFRESH lt_lfa1.
    lt_lfa1[] = gt_lfa1[].
    SORT lt_lfa1 BY adrnr.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING adrnr.

    SELECT adrc~addrnumber adrc~city1 adrc~city2 adrc~post_code1
      adrc~post_code2 adrc~tel_number adr6~smtp_addr
      INTO TABLE gt_adrc
      FROM ( adrc INNER JOIN adr6
      ON adrc~addrnumber = adr6~addrnumber )
      FOR ALL ENTRIES IN lt_lfa1
      WHERE adrc~addrnumber = lt_lfa1-adrnr.

    IF sy-subrc EQ 0.
      SORT gt_adrc BY addrnumber.
    ENDIF.
  ENDIF.

  REFRESH: lt_t001, lt_bkpf, lt_bseg, lt_lfa1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DATA_PROCESSING
*&---------------------------------------------------------------------*
*& Process data for WHT Report to be displayed
*&---------------------------------------------------------------------*
FORM f_data_processing .

*Local data declarations
  DATA: lw_bseg    TYPE ty_bseg,
        lw_bkpf    TYPE ty_bkpf,
        lw_output1 TYPE ty_output1,
        lw_tcurx   TYPE tcurx,
        lw_hkont   TYPE ty_hkont. "*//-- Start of Insert INC2732452 D4SK907855

  SORT gt_bkpf BY bukrs belnr gjahr.
  SORT gt_bseg BY bukrs belnr buzei.
  SORT gt_t001 BY bukrs.
  SORT gt_lfa1 BY lifnr.
  SORT gt_t059z BY witht wt_withcd.
  SORT gt_adrc BY addrnumber.
  SORT gt_dfkkbptaxnum BY partner.
  SORT gt_j_liewt_surc1 BY witht wt_withcd.
  SORT gt_j_1iewt_ecess1 BY witht wt_withcd.

*//-- Start of Insert INC2732452 D4SK907855
*//-- Filter GL Account
  IF s_hkont[] IS NOT INITIAL.
    DELETE gt_bseg WHERE hkont NOT IN s_hkont.
  ENDIF.
*//-- End of Insert INC2732452 D4SK907855

*Loop through all the Accounting document items
  LOOP AT gt_bseg INTO lw_bseg.
    lw_output1-bukrs      =  lw_bseg-bukrs.
    lw_output1-belnr      =  lw_bseg-belnr.
    lw_output1-gjahr      =  lw_bseg-gjahr.
    lw_output1-augbl      =  lw_bseg-augbl.
    lw_output1-koart      =  lw_bseg-koart.
    lw_output1-umskz      =  lw_bseg-umskz.
    lw_output1-lifnr      =  lw_bseg-lifnr.
    lw_output1-augdt      =  lw_bseg-augdt.
    lw_output1-witht      =  lw_bseg-witht.
    lw_output1-wt_withcd  =  lw_bseg-wt_withcd.
    lw_output1-hkont      =  lw_bseg-hkont.
    lw_output1-qsrec      =  lw_bseg-qsrec.
    lw_output1-ctnumber   =  lw_bseg-ctnumber.
    lw_output1-j_1icertdt =  lw_bseg-j_1icertdt.
    lw_output1-bupla      =  lw_bseg-bupla.
    lw_output1-secco      =  lw_bseg-secco.
    lw_output1-zlspr      =  lw_bseg-zlspr.
*//-- Start of Change INC2613809 D4SK906959
    lw_output1-h_waers    =  lw_bseg-h_waers. "(Doc Currency)
    lw_output1-h_hwaer    =  lw_bseg-h_hwaer. "(Loc Currency)
*//-- Start of Changes INC2718637 D4SK907278
* WT Base Amount (LC)
    lw_output1-wt_qsshh   =  lw_bseg-wt_qsshh.
* WT Base Amount (DC)
    lw_output1-wt_qsshb   =  lw_bseg-wt_qsshb.
* Tax amount (LC)
    lw_output1-wt_qbshh   =  lw_bseg-wt_qbshh.
* Tax amount (DC)
    lw_output1-wt_qbshb   =  lw_bseg-wt_qbshb.

*//-- Local Currency
    READ TABLE gt_tcurx INTO lw_tcurx WITH KEY currkey = lw_output1-h_hwaer.
    IF sy-subrc EQ 0 AND lw_tcurx-currdec EQ 0.
      PERFORM convert_amount_currency USING lw_output1-h_hwaer CHANGING: lw_output1-wt_qsshh,
                                                                         lw_output1-wt_qbshh.
    ENDIF.

*//-- Document Currency
    READ TABLE gt_tcurx INTO lw_tcurx WITH KEY currkey = lw_output1-h_waers.
    IF sy-subrc EQ 0 AND lw_tcurx-currdec EQ 0.
      PERFORM convert_amount_currency USING lw_output1-h_waers CHANGING: lw_output1-wt_qsshb,
                                                                         lw_output1-wt_qbshb.
    ENDIF.
*//-- End of Changes INC2718637 D4SK907278

*Round up tax amount
*    PERFORM data_roundup  CHANGING lw_output1-wt_qbshh . "*//-- INC2613809 D4SK906959 Commented No need to round up

*//-- Start of Changes INC2718637 D4SK907278
*Net amount in LC
    lw_output1-net_amt_lc = ( lw_output1-wt_qsshh - lw_output1-wt_qbshh ) * 1. "*//-- Changes INC2718637 D4SK907278

*Net amount in DC
    lw_output1-net_amt_dc = ( lw_output1-wt_qsshb - lw_output1-wt_qbshb ) * 1. "*//-- Changes INC2718637 D4SK907278
*//-- End of Changes INC2718637 D4SK907278
*//-- End of Change INC2613809 D4SK906959

*//-- Start of Insert INC2732452 D4SK907855
    IF lw_bseg-hkont IS INITIAL.
      CLEAR lw_hkont.
      READ TABLE gt_hkont INTO lw_hkont WITH KEY bukrs = lw_bseg-bukrs
                                                 belnr = lw_bseg-belnr
                                                 gjahr = lw_bseg-gjahr
                                                 ktosl = c_wit.
      IF sy-subrc EQ 0 AND lw_hkont-hkont IS NOT INITIAL.
        lw_output1-hkont = lw_hkont-hkont.
      ELSE.
        READ TABLE gt_hkont INTO lw_hkont WITH KEY bukrs = lw_bseg-bukrs
                                                   belnr = lw_bseg-belnr
                                                   gjahr = lw_bseg-gjahr
                                                   ktosl = ' '.
        IF sy-subrc EQ 0 AND lw_hkont-hkont IS NOT INITIAL.
          lw_output1-hkont = lw_hkont-hkont.
        ENDIF.
      ENDIF.
    ENDIF.
*//-- End of Insert INC2732452 D4SK907855

*Derivation of Surchage rate
    READ TABLE gt_j_liewt_surc1 INTO DATA(lw_j_liewt_surc1) WITH KEY witht = lw_bseg-witht
                                                                     wt_withcd = lw_bseg-wt_withcd BINARY SEARCH.
    IF sy-subrc EQ 0.
      lw_output1-tds_surchg = lw_j_liewt_surc1-j_1isurrat.
    ENDIF.

*Derivation of Educess rate
    READ TABLE gt_j_1iewt_ecess1 INTO DATA(lw_j_1iewt_ecess1) WITH KEY witht = lw_bseg-witht
                                                                       wt_withcd = lw_bseg-wt_withcd BINARY SEARCH.
    IF sy-subrc EQ 0.
      lw_output1-tds_educess = lw_j_1iewt_ecess1-j_1iecessrt.
    ENDIF.

*Derivation of TDS basic
    TRY.
        lw_output1-tds_basic = lw_output1-wt_qbshh /
        ( 1 + lw_output1-tds_surchg / 100 +
        ( ( 1 + lw_output1-tds_surchg / 100 ) *
         lw_output1-tds_educess / 100
        )
        ).
      CATCH cx_sy_zerodivide.
        MESSAGE s029.
    ENDTRY.

*    PERFORM data_roundup  CHANGING lw_output1-tds_basic . "*//-- INC2613809 D4SK906959 Commented No need to round up

*****Derivation of TDS-SURCHG: TDS basic * Surcharge rate / 100.
    lw_output1-tds_surchg = lw_output1-tds_basic * lw_j_liewt_surc1-j_1isurrat / 100.

*    PERFORM data_roundup  CHANGING lw_output1-tds_surchg  . "*//-- INC2613809 D4SK906959 Commented No need to round up

******Derivation of  TDS-EDU-CESS:
*TDS-EDU-CESS = Education cess = Total Tax amount â€“ (TDS basic+TDS Surcharge)
    lw_output1-tds_educess =  lw_output1-wt_qbshh - ( lw_output1-tds_basic + lw_output1-tds_surchg ).
*    PERFORM data_roundup  CHANGING lw_output1-tds_educess.  "*//-- INC2613809 D4SK906959 Commented No need to round up

    IF  lw_output1-tds_educess = 0
             AND lw_bseg-wt_qbshh <> 0
             AND lw_output1-tds_basic <> 0
             AND abs( lw_output1-wt_qbshh ) <> 1
             AND abs( lw_output1-tds_basic ) <> 1
             .

    ENDIF.
    IF abs( lw_output1-wt_qbshh ) = 1 .
      lw_output1-tds_basic = lw_output1-wt_qbshh.
      lw_output1-tds_educess = 0.
      lw_output1-tds_surchg = 0.
    ENDIF.

*Accounting document header data
    READ TABLE gt_bkpf INTO lw_bkpf WITH  KEY bukrs = lw_bseg-bukrs
                                                    belnr = lw_bseg-belnr
                                                    gjahr = lw_bseg-gjahr
                                                    BINARY SEARCH.
    IF sy-subrc = 0.
      lw_output1-monat = lw_bkpf-monat.
      lw_output1-blart = lw_bkpf-blart.
      lw_output1-xblnr = lw_bkpf-xblnr.
      lw_output1-bldat = lw_bkpf-bldat.
      lw_output1-budat = lw_bkpf-budat.
      lw_output1-cpudt = lw_bkpf-cpudt.
      lw_output1-post_date = lw_bkpf-budat.
    ENDIF.

**Language and country key
    READ TABLE gt_t001 INTO DATA(lw_t001) WITH KEY bukrs = lw_bseg-bukrs BINARY SEARCH.
    IF sy-subrc EQ 0.
      lw_output1-langu = lw_t001-spras.
      lw_output1-land1  =  lw_t001-land1.
    ENDIF.

**Vendor details
    READ TABLE gt_lfa1 INTO DATA(lw_lfa1) WITH KEY lifnr = lw_bseg-lifnr
                                    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lw_output1-name1     = lw_lfa1-name1.
      lw_output1-adrnr     = lw_lfa1-adrnr.
      lw_output1-regio     = lw_lfa1-regio.
      lw_output1-ktokk     = lw_lfa1-ktokk.
      lw_output1-j_1ipanno = lw_lfa1-j_1ipanno.
      lw_output1-qland     = lw_lfa1-qland.
      lw_output1-stcd1     = lw_lfa1-stcd1.
      lw_output1-stcd2     = lw_lfa1-stcd2.
      lw_output1-stceg     = lw_lfa1-stceg.
      lw_output1-txjcd     = lw_lfa1-txjcd.

**Tax type and Tax number
      READ TABLE gt_dfkkbptaxnum INTO DATA(lw_dfkkbptaxnum) WITH KEY partner = lw_lfa1-lifnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        lw_output1-taxtype = lw_dfkkbptaxnum-taxtype.
        lw_output1-taxnum = lw_dfkkbptaxnum-taxnum.
      ENDIF.

*Withholding tax code
      READ TABLE gt_t059z INTO DATA(lw_t059z) WITH KEY witht = lw_bseg-witht
                                                     wt_withcd = lw_bseg-wt_withcd BINARY SEARCH.
      IF sy-subrc EQ 0.
        lw_output1-qscod = lw_t059z-qscod.
      ENDIF.

*Address
      READ TABLE gt_adrc INTO DATA(lw_adrc) WITH KEY addrnumber = lw_lfa1-adrnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        lw_output1-city1        =   lw_adrc-city1.
        lw_output1-city2        =   lw_adrc-city2.
        lw_output1-post_code1   =   lw_adrc-post_code1.
        lw_output1-post_code2   =   lw_adrc-post_code2.
        lw_output1-tel_number   =   lw_adrc-tel_number.
        lw_output1-smtp_addr    =   lw_adrc-smtp_addr.
      ENDIF.
    ENDIF.

    APPEND lw_output1 TO gt_output1.
    CLEAR: lw_output1,lw_bseg, lw_bkpf,lw_adrc,lw_t059z,lw_dfkkbptaxnum,
           lw_j_liewt_surc1,lw_j_1iewt_ecess1,lw_t001,lw_lfa1.

  ENDLOOP.

*//-- Start of Insert INC2732452 D4SK907855
*//-- Filter GL Account
  IF s_hkont[] IS NOT INITIAL.
    DELETE gt_output1 WHERE hkont NOT IN s_hkont.
  ENDIF.
*//-- End of Insert INC2732452 D4SK907855

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_ROUNDUP
*&---------------------------------------------------------------------*
*& Round off the value
*&---------------------------------------------------------------------*
FORM data_roundup  CHANGING p_lw_output1 TYPE with_item-wt_qsshb.

  DATA: lv_lw_output1 TYPE i.

*Round up the decimal to be integer.
  lv_lw_output1 =  p_lw_output1.
  p_lw_output1  =  lv_lw_output1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CLEAR_GLOBAL_DATA
*&---------------------------------------------------------------------*
*& Refresh the internal tables
*&---------------------------------------------------------------------*
FORM f_clear_global_data .

  REFRESH: gt_bseg, gt_bkpf, gt_lfa1, gt_t001, gt_dfkkbptaxnum, gt_output1,
           gt_adrc, gt_t059z, gt_output, gt_tcurx. "*//-- Insert INC2613809 D4SK906959.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISP_OUT
*&---------------------------------------------------------------------*
*& Display the result in ALV Report for WHT Exemp Report
*&---------------------------------------------------------------------*
FORM f_disp_out USING pt_table TYPE table.

*To display the ALV for withholding exemption certificate
  CREATE OBJECT go_alv.

  IF pt_table IS NOT INITIAL.
* Call the method to display the results in ALV Report format
    CALL METHOD go_alv->display_alv
      CHANGING
        c_datatab = pt_table.
  ELSE.
    MESSAGE s034 DISPLAY LIKE c_e.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& Authorization check to validate for authorizations
*&---------------------------------------------------------------------*
FORM f_authority_check .

  LOOP AT s_bukrs.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'ACTVT' FIELD '03'
    ID 'BUKRS' FIELD s_bukrs-low.
    IF sy-subrc <> 0.
      MESSAGE e033 WITH s_bukrs-low.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL_ALERT
*&---------------------------------------------------------------------*
*& Send an Email for the WHT Exemption Certificate Report
*&---------------------------------------------------------------------*
FORM f_send_email_alert .
*----------------------------------------------------------------------*
* Declaration for constants
*----------------------------------------------------------------------*
  CONSTANTS :lc_b    TYPE char1       VALUE 'B',
             lc_4103 TYPE abap_encod  VALUE '4103',
             lc_1    TYPE char1       VALUE '1',
             lc_001  TYPE n           VALUE '001',
             lc_csv  TYPE char3       VALUE 'CSV'.
*----------------------------------------------------------------------*
* Declaration for Internal tables
*----------------------------------------------------------------------*
  DATA : lt_attach_attr TYPE TABLE OF zsca_packlist,
         lt_return      TYPE TABLE OF bapiret2.
*----------------------------------------------------------------------*
* Declaration for Work areas
*----------------------------------------------------------------------*
  DATA : lt_attachment   TYPE solix_tab,
         lw_attach_attr  TYPE zsca_packlist,
         lv_sub          TYPE so_obj_des,
         lt_body         TYPE bcsy_text,
         lv_size         TYPE so_obj_len,
         lv_string       TYPE string,
         lv_data_string  TYPE string,
         lv_retcode      TYPE i,
         lv_err_str      TYPE string,
         lt_text_replace TYPE zttca_email_textsymbol_replace,
         lw_text_replace TYPE zsca_email_textsymbol_replace,
         lv_exrate       TYPE char10.


  CREATE OBJECT go_file.

* Assign values to replace in email text
  lw_text_replace-key_type = lc_b.
  lw_text_replace-name = sy-uname.
  lw_text_replace-value = sy-uname.
  APPEND lw_text_replace TO lt_text_replace.
  CLEAR lw_text_replace.

  lw_text_replace-key_type = lc_b.
  lw_text_replace-name = sy-datum.
  lw_text_replace-value = sy-uzeit.
  APPEND lw_text_replace TO lt_text_replace.
  CLEAR lw_text_replace.

* get the subject and body of the email
  CALL METHOD go_file->get_email_content
    EXPORTING
      i_text_name_sub  = gv_subject
      i_text_name_body = gv_body
      i_text_replace   = lt_text_replace
    IMPORTING
      e_subject        = lv_sub
      e_body           = lt_body
      et_return        = lt_return.

  CONCATENATE 'Vendor'(020) 'Cocode'(021) 'WTax Type'(022) 'Subject to w/tax'(023)
               'Rec.Type'(024) 'W/tax ID'(025) 'WTax Code'(026) 'Exem. No.'(027)
               'Exemption Rate'(028) 'Exempt From'(002) 'Exempt To'(003)
               'Exmpt.Resn'(029)
              INTO lv_string
              SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
  CONCATENATE lv_data_string lv_string cl_abap_char_utilities=>cr_lf
              INTO lv_data_string.

  LOOP AT gt_output ASSIGNING FIELD-SYMBOL(<lfs_mail>).
    lv_exrate = <lfs_mail>-wt_exrt.
    CONCATENATE <lfs_mail>-lifnr <lfs_mail>-bukrs <lfs_mail>-witht
                <lfs_mail>-wt_subjct <lfs_mail>-qsrec <lfs_mail>-wt_wtstcd
                <lfs_mail>-wt_withcd <lfs_mail>-wt_exnr lv_exrate
                <lfs_mail>-wt_exdf <lfs_mail>-wt_exdt <lfs_mail>-wt_wtexrs
                INTO lv_string
                SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
    CONCATENATE lv_data_string lv_string cl_abap_char_utilities=>cr_lf
                INTO lv_data_string.

  ENDLOOP.
  TRY.
      cl_bcs_convert=>string_to_solix(
        EXPORTING
          iv_string   = lv_data_string
          iv_codepage = lc_4103       "suitable for MS Excel, leave empty
          iv_add_bom  = abap_true     "for other doc types
        IMPORTING
          et_solix  = lt_attachment
          ev_size   = lv_size ).
    CATCH cx_bcs.
      MESSAGE e445(so).
  ENDTRY.

**--Build attachment attribute
  lw_attach_attr-body_start = lc_1.
  DESCRIBE TABLE lt_attachment LINES lw_attach_attr-body_num.
  lw_attach_attr-doc_type = lc_csv.
  lw_attach_attr-obj_name = 'Email'(005).
  DATA(lv_ob_dec) = 'Withholding Exemption Certificate Report'(006) && ':' && sy-datum && sy-uzeit.
  lw_attach_attr-obj_descr = lv_ob_dec.
  APPEND lw_attach_attr TO lt_attach_attr.
  CLEAR lw_attach_attr.


* Send Mail with attachment
  CALL METHOD go_file->send_mail
    EXPORTING
      i_rec_type             = lc_001
      i_receiver             = gv_mail
      i_subject              = lv_sub
      i_body                 = lt_body
      i_attachment_attribute = lt_attach_attr
      i_attachment           = lt_attachment
      i_immediate            = abap_true
    IMPORTING
      e_retcode              = lv_retcode
      e_err_str              = lv_err_str.

  REFRESH : lt_attach_attr, lt_attachment, lt_body.
  CLEAR: gv_mail, lv_sub, lv_retcode, lv_retcode.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*& Fetch the constants
*&---------------------------------------------------------------------*

FORM f_get_constants  USING   fp_pgmid TYPE char40.

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
        MESSAGE e007 WITH 'TVARVC'(078).      "No data found in & table
      WHEN 2.
        MESSAGE e010 WITH 'TVARVC'(078).      "Atleast one constant entry missing in & table
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

  READ TABLE gt_pgm_const_values INTO  DATA(gs_pgm_const_values) WITH KEY const_name = 'P_ZPTP_SUB_WHT'.
  IF sy-subrc = 0.
    gv_subject = gs_pgm_const_values-low.
  ELSE.
    MESSAGE e037 WITH 'P_ZPTP_SUB_WHT'(013).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO gs_pgm_const_values WITH KEY const_name = 'P_ZPTP_BODY_WHT'.
  IF sy-subrc = 0.
    gv_body = gs_pgm_const_values-low.
  ELSE.
    MESSAGE e037 WITH 'P_ZPTP_BODY_WHT'(014).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO  gs_pgm_const_values WITH KEY const_name = 'P_ZPTP_SUB_WHTPOST'.
  IF sy-subrc = 0.
    gv_subject = gs_pgm_const_values-low.
  ELSE.
    MESSAGE e037 WITH 'P_ZPTP_SUB_WHTPOST'(017).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO gs_pgm_const_values WITH KEY const_name = 'P_ZPTP_BODY_WHTPOST'.
  IF sy-subrc = 0.
    gv_body = gs_pgm_const_values-low.
  ELSE.
    MESSAGE e037 WITH 'P_ZPTP_BODY_WHTPOST'(018).
  ENDIF.


  READ TABLE gt_pgm_const_values INTO gs_pgm_const_values WITH KEY const_name = 'P_ENH001_WHT_EMAIL'.
  IF sy-subrc = 0.
    gv_mail = gs_pgm_const_values-low.
  ELSE.
    MESSAGE e037 WITH 'P_ENH001_WHT_EMAIL'(016).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_VALIDATE_MANDFIELDS
*&---------------------------------------------------------------------*
*& To pass the error message for mandatory fields.
*&---------------------------------------------------------------------*

FORM f_validate_mandfields .
  IF p_rad2 IS NOT INITIAL OR p_rad1 IS NOT INITIAL .
    IF s_bukrs IS INITIAL.
      MESSAGE s038 DISPLAY LIKE c_e .
      STOP.
    ENDIF.
  ENDIF.

  IF p_rad2 IS NOT INITIAL.
    IF s_gjahr IS INITIAL.
      MESSAGE s035 DISPLAY LIKE c_e.
      STOP.
    ENDIF.
  ENDIF.

  IF p_rad2 IS NOT INITIAL.
    IF s_budat IS INITIAL.
      MESSAGE s036 DISPLAY LIKE c_e .
      STOP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_HELP_REQUEST
*&---------------------------------------------------------------------*
*&To provide F1 help for the checkbox
*&---------------------------------------------------------------------*
FORM f_help_request .

  CONSTANTS : lc_u1    TYPE char2 VALUE 'U1',
              lc_title TYPE char10 VALUE 'F1 HELP'.

  REFRESH : gt_text[].
  CLEAR : gv_text.

  gv_text-tdformat = lc_u1.
  gv_text-tdline = TEXT-030.
  APPEND gv_text TO gt_text.
  CLEAR gv_text.

  CALL FUNCTION 'COPO_POPUP_TO_DISPLAY_TEXTLIST'
    EXPORTING
      titel      = lc_title
    TABLES
      text_table = gt_text.
ENDFORM.
*//-- Start of Insert INC2613809 D4SK906959
*&---------------------------------------------------------------------*
*& Form CONVERT_AMOUNT_CURRENCY
*&---------------------------------------------------------------------*
*& Convert Amount to correct Amount Currency
*&---------------------------------------------------------------------*
*& WAERS - Currency
*& AMOUNT - Amount to Convert
*&---------------------------------------------------------------------*
FORM convert_amount_currency  USING    p_waers  TYPE waers
                              CHANGING p_amount TYPE wt_bs.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      currency        = p_waers
      amount_internal = p_amount
    IMPORTING
      amount_external = p_amount.

ENDFORM.
*//-- End of Insert INC2613809 D4SK906959


*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL_ALERT_WHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SEND_EMAIL_ALERT_WHT .
*----------------------------------------------------------------------*
* Declaration for constants
*----------------------------------------------------------------------*
  CONSTANTS :lc_b    TYPE char1       VALUE 'B',
             lc_4103 TYPE abap_encod  VALUE '4103',
             lc_1    TYPE char1       VALUE '1',
             lc_001  TYPE n           VALUE '001',
             lc_csv  TYPE char3       VALUE 'CSV'.
*----------------------------------------------------------------------*
* Declaration for Internal tables
*----------------------------------------------------------------------*
  DATA : lt_attach_attr TYPE TABLE OF zsca_packlist,
         lt_return      TYPE TABLE OF bapiret2.
*----------------------------------------------------------------------*
* Declaration for Work areas
*----------------------------------------------------------------------*
  DATA : lt_attachment   TYPE solix_tab,
         lw_attach_attr  TYPE zsca_packlist,
         lv_sub          TYPE so_obj_des,
         lt_body         TYPE bcsy_text,
         lv_size         TYPE so_obj_len,
         lv_string       TYPE string,
         lv_data_string  TYPE string,
         lv_retcode      TYPE i,
         lv_err_str      TYPE string,
         lt_text_replace TYPE zttca_email_textsymbol_replace,
         lw_text_replace TYPE zsca_email_textsymbol_replace,
         lv_exrate       TYPE char10,
         lv_net_amt_lc   TYPE char10,
         lv_net_amt_dc   TYPE char10,
         lv_wt_qsshh     TYPE char10,
         lv_wt_qsshb     TYPE char10,
         lv_wt_qbshh     TYPE char10,
         lv_wt_qbshb     TYPE  char10,
         lv_tds_basic    TYPE  char10,
         lv_tds_surchg   TYPE char10,
         lv_tds_educess  TYPE char10,
         lv_count        TYPE I.    " for counter to send an email.


  CREATE OBJECT go_file.

* Assign values to replace in email text
  lw_text_replace-key_type = lc_b.
  lw_text_replace-name = sy-uname.
  lw_text_replace-value = sy-uname.
  APPEND lw_text_replace TO lt_text_replace.
  CLEAR lw_text_replace.

  lw_text_replace-key_type = lc_b.
  lw_text_replace-name = sy-datum.
  lw_text_replace-value = sy-uzeit.
  APPEND lw_text_replace TO lt_text_replace.
  CLEAR lw_text_replace.

* get the subject and body of the email
  CALL METHOD go_file->get_email_content
    EXPORTING
      i_text_name_sub  = gv_subject
      i_text_name_body = gv_body
      i_text_replace   = lt_text_replace
    IMPORTING
      e_subject        = lv_sub
      e_body           = lt_body
      et_return        = lt_return.


  CONCATENATE 'Country Key'(031) 'Company code'(032) 'Fiscal year'(033) 'Assesment year'(034)
                'Posting period'(035) 'Vendor'(036) 'Language'(037) 'Special GL indicator'(038)
                'Vendor group'(039) 'Supplier name'(040) 'Addresses'(041)
                'City'(042)'District'(043)'Postal code'(044)'Zipcode'(045)'Region'(046)'PAN number'(047)
                'Phone number'(048)'Email address'(049)'Document Type'(050)'Document number'(051)'Clearing document no'(052)
                'Reference'(053)'Document date'(054)'Posting date'(055)'Entry date'(056)'Clearing date'(057)'Business place'(058)
                'Area code'(059)'Payment block'(060)'Doc Currency'(061)'Local currency'(062)'Treaty county'(063)'Tax type'(064)
                'WHT code'(065)'Tax offical keys'(066)'WHtax GL account'(067)'Type of recipient'(068)'Tax number'(069)'Tax category'(070)
                'Account type'(071)'Cert. No.'(072)
               'Issue date of TDS Certificate'(073)'Tax number 1'(074)'Tax Number 2'(075)'VAT Reg No'(076)'Tax Jurisdiction'(077)
               'Withholding Tax Base Amount (LC)'(079)'Withholding Tax Base Amount (DC)'(080)'Net Amt (LC)'(081)'Net Amt (DC)'(082)
               'Tax Amt ( LC)'(083)'Tax Amt (DC)'(084)'TDS_Basic'(085)'TDS_Surcharge'(086)'TDS_Educess'(087)

               INTO lv_string
               SEPARATED BY cl_abap_char_utilities=>horizontal_tab.

  CONCATENATE  lv_string lv_data_string cl_abap_char_utilities=>cr_lf
  INTO lv_data_string.

  LOOP AT gt_output1 ASSIGNING FIELD-SYMBOL(<lfs_mail>).
*    lv_exrate = <lfs_mail>-wt_exrt.
    lv_exrate     = <lfs_mail>-wt_qsshh.
    lv_net_amt_lc = <lfs_mail>-net_amt_lc.
    lv_net_amt_dc = <lfs_mail>-net_amt_dc.
    lv_wt_qsshh   = <lfs_mail>-wt_qsshh.
    lv_wt_qsshb   = <lfs_mail>-wt_qsshb.
    lv_wt_qbshh   = <lfs_mail>-wt_qbshh.
    lv_wt_qbshb   = <lfs_mail>-wt_qbshb.
    lv_tds_basic  = <lfs_mail>-tds_basic.
    lv_tds_surchg = <lfs_mail>-tds_surchg.
    lv_tds_educess = <lfs_mail>-tds_educess.


* Here the changes required that exrate amount is there , then only the report
* should add the entries and then send an email with an attachment.
*
    IF lv_wt_qbshb <> 0.

      CONCATENATE <lfs_mail>-land1 <lfs_mail>-bukrs <lfs_mail>-gjahr
                  <lfs_mail>-budat <lfs_mail>-monat <lfs_mail>-lifnr
                  <lfs_mail>-langu <lfs_mail>-umskz
                  <lfs_mail>-ktokk  <lfs_mail>-name1 <lfs_mail>-adrnr
                  <lfs_mail>-city1 <lfs_mail>-city2 <lfs_mail>-post_code1
                  <lfs_mail>-post_code2 <lfs_mail>-regio <lfs_mail>-j_1ipanno
                  <lfs_mail>-tel_number <lfs_mail>-smtp_addr <lfs_mail>-blart
                  <lfs_mail>-belnr <lfs_mail>-augbl <lfs_mail>-xblnr <lfs_mail>-bldat
                  <lfs_mail>-post_date <lfs_mail>-cpudt <lfs_mail>-augdt <lfs_mail>-bupla
                  <lfs_mail>-secco  <lfs_mail>-zlspr <lfs_mail>-h_waers
                  <lfs_mail>-h_hwaer <lfs_mail>-qland <lfs_mail>-witht <lfs_mail>-wt_withcd
                  <lfs_mail>-qscod <lfs_mail>-hkont
                  <lfs_mail>-qsrec <lfs_mail>-taxnum <lfs_mail>-taxtype <lfs_mail>-koart
                  <lfs_mail>-ctnumber <lfs_mail>-j_1icertdt <lfs_mail>-stcd1 <lfs_mail>-stcd2
                  <lfs_mail>-stceg <lfs_mail>-txjcd lv_wt_qsshh lv_wt_qsshb lv_net_amt_lc lv_net_amt_dc
                  lv_wt_qbshh lv_wt_qbshb lv_tds_basic lv_tds_surchg lv_tds_educess
                  INTO lv_string
                  SEPARATED BY cl_abap_char_utilities=>horizontal_tab.

      CONCATENATE lv_data_string lv_string cl_abap_char_utilities=>cr_lf
                  INTO lv_data_string.
      lv_count = lv_count + 1.
    ENDIF.


  ENDLOOP.
  IF lv_count <> 0. " dont build the attachment if no entries
    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = lv_data_string
            iv_codepage = lc_4103       "suitable for MS Excel, leave empty
            iv_add_bom  = abap_true     "for other doc types
          IMPORTING
            et_solix  = lt_attachment
            ev_size   = lv_size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.

**--Build attachment attribute
    lw_attach_attr-body_start = lc_1.
    DESCRIBE TABLE lt_attachment LINES lw_attach_attr-body_num.
    lw_attach_attr-doc_type = lc_csv.
    lw_attach_attr-obj_name = 'Email'(005).
    DATA(lv_ob_dec) = 'Withholding Tax Report'(007) && ':' && sy-datum && sy-uzeit.
    lw_attach_attr-obj_descr = lv_ob_dec.
    APPEND lw_attach_attr TO lt_attach_attr.
    CLEAR lw_attach_attr.


* Send Mail with attachment
    CALL METHOD go_file->send_mail
      EXPORTING
        i_rec_type             = lc_001
        i_receiver             = gv_mail
        i_subject              = lv_sub
        i_body                 = lt_body
        i_attachment_attribute = lt_attach_attr
        i_attachment           = lt_attachment
        i_immediate            = abap_true
      IMPORTING
        e_retcode              = lv_retcode
        e_err_str              = lv_err_str.

    REFRESH : lt_attach_attr, lt_attachment, lt_body.
    CLEAR: gv_mail, lv_sub, lv_retcode, lv_retcode.

  ENDIF.


ENDFORM.
