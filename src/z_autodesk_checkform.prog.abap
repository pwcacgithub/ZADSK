*&---------------------------------------------------------------------*
*& Report Z_AUTODESK_CHECKFORM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

************************************************************************
*                                                                      *
*  Check print program RFFOUS_C                                        *
*                                                                      *
************************************************************************
*--------------------------------------------------------------------------------*
* Program includes:                                                              *
*                                                                                *
* RFFORI0M            Definition of macros                                       *
* RFFORI00            international data definitions                             *
* ZINFI_RFFORI01      check                                                      *
* RFFORI06            remittance advice                                          *
* RFFORI07            payment summary list                                       *
* RFFORI99            international subroutines                                  *
*--------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------|
* Change Date |Developer         |RICEFW/Defect#  | Transport#     | Description                                                           |
*------------------------------------------------------------------------------------------------------------------------------------------|
* 02-FEB-2019 |FATHIMA AHMED     |PTP.FRM.002     | D4SK901020     | Check print program for ZF110_CHCK_US and ZF110_CHCK_CA               |
*------------------------------------------------------------------------------------------------------------------------------------------|

*----------------------------------------------------------------------*
* report header                                                        *
*----------------------------------------------------------------------*
*REPORT rffous_c
REPORT Z_AUTODESK_CHECKFORM.
*  LINE-SIZE 132
*  MESSAGE-ID f0
*  NO STANDARD PAGE HEADING.
*
*
*
**----------------------------------------------------------------------*
**  segments and tables for prenumbered checks                          *
**----------------------------------------------------------------------*
*TABLES:
*  reguh,
*  regup.
*
*                                                            "477670
*
*
*DATA: BEGIN OF wa_t012k,
*        bukrs LIKE t012k-bukrs,
*        hbkid LIKE t012k-hbkid,
*        hktid LIKE t012k-hktid,
*        waers LIKE t012k-waers,
*      END OF wa_t012k.
*
*CONSTANTS: c_cad  LIKE t012k-waers VALUE 'CAD',
*           c_3000 LIKE t012k-bukrs VALUE '3000'.
*
**----------------------------------------------------------------------*
**  macro definitions                                                   *
**----------------------------------------------------------------------*
*INCLUDE rffori0m.
*
*INITIALIZATION.
*
**----------------------------------------------------------------------*
**  parameters and select-options                                       *
**----------------------------------------------------------------------*
*  block 1.
*  SELECT-OPTIONS:
*    sel_zawe FOR  reguh-rzawe,              "payment method
*    sel_uzaw FOR  reguh-uzawe,              "payment method supplement
*    sel_gsbr FOR  reguh-srtgb,              "business area
*    sel_hbki FOR  reguh-hbkid NO-EXTENSION NO INTERVALS, "house bank id
*    sel_hkti FOR  reguh-hktid NO-EXTENSION NO INTERVALS. "account id
*  SELECTION-SCREEN:
*    BEGIN OF LINE,
*    COMMENT 01(30) TEXT-106 FOR FIELD par_stap,
*    POSITION POS_LOW.
*  PARAMETERS:
*    par_stap LIKE rfpdo-fordstap.           "check lot number
*  SELECTION-SCREEN:
*    COMMENT 40(30) textinfo FOR FIELD par_stap,
*    END OF LINE.
*  PARAMETERS:
*    par_rchk LIKE rfpdo-fordrchk.           "Restart from
*  SELECT-OPTIONS:
*    sel_waer FOR  reguh-waers,              "currency
*    sel_vbln FOR  reguh-vblnr.              "payment document number
*  SELECTION-SCREEN END OF BLOCK 1.
*
*  block 2.
*  auswahl: zdru z, avis a, begl b.
*  auswahl_alv_list.
*  spool_authority.                     "Spoolberechtigung
*  SELECTION-SCREEN END OF BLOCK 2.
*
*  block 3.
*  PARAMETERS:
*    par_zfor LIKE rfpdo1-fordzfor,          "different form
*    par_fill LIKE rfpdo2-fordfill,          "filler for spell_amount
*    par_anzp LIKE rfpdo-fordanzp,           "number of test prints
*    par_maxp LIKE rfpdo-fordmaxp,           "no of items in summary list
*    par_belp LIKE rfpdo-fordbelp,           "payment doc. validation
*    par_espr LIKE rfpdo-fordespr,           "texts in reciepient's lang.
*    par_isoc LIKE rfpdo-fordisoc,           "currency in ISO code
*    par_nosu LIKE rfpdo2-fordnosu,          "no summary page
*    par_novo LIKE rfpdo2-fordnovo.          "no voiding of checks
*  SELECTION-SCREEN END OF BLOCK 3.
*
*  SELECTION-SCREEN:
*    BEGIN OF BLOCK 4 WITH FRAME TITLE TEXT-100,
*    BEGIN OF LINE.
*  PARAMETERS:
*    par_neud AS CHECKBOX.
*  SELECTION-SCREEN:
*    COMMENT 03(70) TEXT-101 FOR FIELD par_neud,
*    END OF LINE,
*    BEGIN OF LINE,
*    COMMENT 01(31) textchkf FOR FIELD par_chkf,
*    POSITION POS_LOW.
*  PARAMETERS:
*    par_chkf LIKE payr-checf.
*  SELECTION-SCREEN:
*    COMMENT 52(05) textchkt FOR FIELD par_chkt,
*    POSITION POS_HIGH.
*  PARAMETERS:
*    par_chkt LIKE payr-chect.
*  SELECTION-SCREEN:
*    END OF LINE,
*    BEGIN OF LINE,
*    COMMENT 01(30) TEXT-107 FOR FIELD par_void,
*    POSITION POS_LOW.
*  PARAMETERS:
*    par_void LIKE payr-voidr.
*  SELECTION-SCREEN:
*    COMMENT 38(30) textvoid FOR FIELD par_void,
*    END OF LINE,
*    END OF BLOCK 4.
*
*  PARAMETERS:
*    par_xdta     LIKE rfpdo-fordxdta  NO-DISPLAY,
*    par_priw     LIKE rfpdo-fordpriw  NO-DISPLAY,
*    par_sofw     LIKE rfpdo1-fordsofw NO-DISPLAY,
*    par_dtyp     LIKE rfpdo-forddtyp  NO-DISPLAY,
*    par_unix     LIKE rfpdo2-fordnamd NO-DISPLAY,
*    par_nenq(1)  TYPE c           NO-DISPLAY,
*    par_vari(12) TYPE c           NO-DISPLAY,
*    par_sofo(1)  TYPE c           NO-DISPLAY.
*
*
*
**----------------------------------------------------------------------*
**  Default values for parameters and select-options                    *
**----------------------------------------------------------------------*
*  PERFORM init.
*  PERFORM text(sapdbpyf) USING 102 textzdru.
*  PERFORM text(rfchkl00) USING: textchkf 200, textchkt 201.
*  sel_zawe-low    = 'C'.
*  sel_zawe-option = 'EQ'.
*  sel_zawe-sign   = 'I'.
*  APPEND sel_zawe.
*
*  par_belp = space.
*  par_zdru = 'X'.
*  par_xdta = space.
*  par_dtyp = space.
*  par_avis = space.
*  par_begl = 'X'.
*  par_fill = space.
*  par_anzp = 2.
*  par_espr = space.
*  par_isoc = space.
*  par_maxp = 9999.
*
*
*
**----------------------------------------------------------------------*
**  tables / fields / field-groups / at selection-screen                *
**----------------------------------------------------------------------*
*  INCLUDE rffori00.
*
** AT SELECTION-SCREEN.
*
*  PERFORM scheckdaten_eingabe USING par_rchk
*                                    par_stap
*                                    textinfo.
*
** Begin of changes - 477670
** If Company Code is 3000, Account Id Currency is CAD, Check if
** Alternative form is entered. If Alternative form is not entered
** then give error messsage.
** Get the Account Id currency from T012K based on company code
** House bank id, account Id. If Currency is CAD give message to
** enter the Alternative form on the selection screen.
*  READ TABLE zw_zbukr WITH KEY low = '3000'.
*  IF sy-subrc = 0.
*    SELECT SINGLE bukrs
*                  hbkid
*                  hktid
*                  waers
*                  FROM t012k
*                  INTO wa_t012k
*                  WHERE bukrs EQ zw_zbukr-low AND
*                        hbkid = sel_hbki-low  AND
*                        hktid = sel_hkti-low .
** If Data returned from table T012K, then check for Account Id Currency is
** CAD, if yes then if Alternative form is not entered then give error message
*      IF sy-subrc = 0 AND
*         wa_t012k-waers = c_cad.
*        IF par_zfor IS INITIAL.
*          MESSAGE ID 'FS'
*                  TYPE 'E'
*                  NUMBER '899'
*                  WITH 'Enter AlternativeForm for Com.Code-3000 & Curr CAD'(001).
*        ENDIF.
*      ENDIF.
*    ENDIF.
*                                                            "477670
*
*    textvoid = space.
*    IF par_neud EQ 'X'.                    "Neu drucken / reprint
*      IF par_rchk NE space.
*        SET CURSOR FIELD 'PAR_RCHK'.
*        MESSAGE e561(fs).                  "kein Neu drucken bei Restart
*      ENDIF.                               "no reprint in restart mode
*      IF zw_xvorl NE space.
*        SET CURSOR FIELD 'ZW_XVORL'.
*        MESSAGE e561(fs).                  "kein Neu drucken bei Vorschlag
*      ENDIF.                               "no reprint if proposal run
*      IF par_chkf EQ space AND par_chkt NE space.
*        par_chkf = par_chkt.
*      ENDIF.
*      IF par_chkt EQ space.
*        par_chkt = par_chkf.
*      ENDIF.
*      IF par_chkt LT par_chkf.
*        SET CURSOR FIELD 'PAR_CHKF'.
*        MESSAGE e650(db).
*      ENDIF.
*      IF par_chkf NE space OR par_void NE 0.
*        IF par_chkf EQ space.
*          SET CURSOR FIELD 'PAR_CHKF'.
*          MESSAGE e055(00).
*        ENDIF.
*        SELECT * FROM payr UP TO 1 ROWS    "im angegebenen Intervall müssen
*          WHERE zbukr EQ zw_zbukr-low      "Schecks vorhanden sein
*          AND hbkid EQ sel_hbki-low        "check interval is not allowed to
*            AND hktid EQ sel_hkti-low      "be empty
*            AND checf LE par_chkt
*            AND chect GE par_chkf
*            AND ichec EQ space
*            AND voidr EQ 0
*            AND xbanc EQ space.
*        ENDSELECT.
*        IF sy-subrc NE 0.
*          SET CURSOR FIELD 'PAR_CHKF'.
*          MESSAGE e509(fs).
*        ENDIF.
*        SELECT SINGLE * FROM tvoid WHERE voidr EQ par_void.
*          IF sy-subrc NE 0 OR tvoid-xsyse NE space.
*            SET CURSOR FIELD 'PAR_VOID'.
*            MESSAGE e539(fs).
*          ELSE.
*            SELECT SINGLE * FROM tvoit
*              WHERE langu EQ sy-langu AND voidr EQ par_void.
*              textvoid = tvoit-voidt.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          CLEAR:
*            par_chkf,
*            par_chkt,
*            par_void.
*        ENDIF.
*
*        auswahl_alv_list_f4_and_check.
*
*
*AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN.
*    IF screen-group1 EQ 1.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.
*    IF screen-name EQ 'ZW_ZBUKR-HIGH' OR
*       screen-name EQ '%_ZW_ZBUKR_%_APP_%-VALU_PUSH'.
*      screen-active = 0.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_stap.
*  CALL FUNCTION 'F4_CHECK_LOT'
*    EXPORTING
*      i_xdynp      = 'X'
*      i_dynp_progn = 'RFFOUS_C'
*      i_dynp_dynnr = '1000'
*      i_dynp_zbukr = 'ZW_ZBUKR-LOW'
*      i_dynp_hbkid = 'SEL_HBKI-LOW'
*      i_dynp_hktid = 'SEL_HKTI-LOW'
*    IMPORTING
*      e_stapl      = par_stap
*    EXCEPTIONS
*      OTHERS       = 0.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_zfor.
*  PERFORM f4_formular USING par_zfor.
*
*AT SELECTION-SCREEN ON par_zfor.
*  IF par_zfor NE space.
*    SET CURSOR FIELD 'PAR_ZFOR'.
*    CALL FUNCTION 'FORM_CHECK' EXPORTING i_pzfor = par_zfor.
*  ENDIF.
*
*
*
**----------------------------------------------------------------------*
**  batch heading (for the payment summary list)                        *
**----------------------------------------------------------------------*
*TOP-OF-PAGE.
*
*  IF flg_begleitl EQ 1.
*    PERFORM kopf_zeilen.               "RFFORI07
*  ENDIF.
*
*
*
**----------------------------------------------------------------------*
**  preparations                                                        *
**----------------------------------------------------------------------*
*START-OF-SELECTION.
*  hlp_auth  = par_auth.                "spool authority
*  hlp_temse  = '----------'.           "Keine TemSe-Verwendung
*  hlp_filler = par_fill.
*  hlp_ep_element = '525'.    " note 794910
*  PERFORM vorbereitung.
*  PERFORM scheckdaten_pruefen USING par_rchk
*                                    par_stap.
*
*  IF zw_xvorl EQ space AND par_zdru NE space AND par_neud NE space.
*    IF par_chkf NE space.
*      flg_neud = 1.                    "neu drucken durchs Druckprogramm
*      REFRESH tab_check.               "print program reprints checks
*      tab_check-option = 'EQ'.
*      tab_check-sign   = 'I'.
*      tab_check-high   = space.
*      SELECT * FROM payr
*        WHERE zbukr EQ zw_zbukr-low
*          AND hbkid EQ sel_hbki-low
*          AND hktid EQ sel_hkti-low
*          AND checf LE par_chkt
*          AND chect GE par_chkf
*          AND ichec EQ space
*          AND voidr EQ 0
*          AND xbanc EQ space.
*        tab_check-low = payr-checf.
*        APPEND tab_check.
*      ENDSELECT.
*      INSERT *payr INTO daten.
*    ELSE.
*      REFRESH tab_check.
*      flg_neud = 2.
*    ENDIF.
*    SELECT SINGLE * FROM tvoid WHERE voidr EQ par_void.
*    ENDIF.
*
*    IF par_zdru EQ 'X'.
*      IF sy-calld EQ space.              "fremder Enqueue nur wenn
*        par_nenq = space.                "Programm gerufen wurde
*      ENDIF.                             "foreign enqueue only if called
*      IF par_nenq EQ space.
*        PERFORM schecknummern_sperren.   "RFFORI01
*      ELSE.
*        par_anzp = 0.         "sonst funktioniert die Umnumerierung nicht
*      ENDIF.
*    ENDIF.
*
*
*
**----------------------------------------------------------------------*
**  check and extract data                                              *
**----------------------------------------------------------------------*
*GET reguh.
*
*  CHECK sel_zawe.
*  CHECK sel_uzaw.
*  CHECK sel_gsbr.
*  CHECK sel_hbki.
*  CHECK sel_hkti.
*  CHECK sel_waer.
*  CHECK sel_vbln.
*  PERFORM check_reguh_afle_compatible.       " AFLE compatible mode only
*  PERFORM pruefung.
*  PERFORM scheckinfo_pruefen.            "RFFORI01
*  IF reguh-kunnr <> space.
*    TABLES knb1.
*    DATA ls_kna1 LIKE kna1.
*    DATA ld_remit LIKE knb1-remit.
*    SELECT SINGLE remit INTO ld_remit FROM knb1
*         WHERE bukrs = reguh-absbu AND kunnr = reguh-kunnr.
*      IF sy-subrc = 0 AND ld_remit <> space.
*        SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr = ld_remit.
*          IF sy-subrc = 0.
*            reguh-zadnr = ls_kna1-adrnr.
*            reguh-zanre = ls_kna1-anred.
*            reguh-znme1 = ls_kna1-name1.
*            reguh-znme2 = ls_kna1-name2.
*            reguh-znme3 = ls_kna1-name3.
*            reguh-znme4 = ls_kna1-name4.
*            reguh-zpstl = ls_kna1-pstlz.
*            reguh-zort1 = ls_kna1-ort01.
*            reguh-zort2 = ls_kna1-ort02.
*            reguh-zstra = ls_kna1-stras.
*            reguh-zpfac = ls_kna1-pfach.
*            reguh-zpst2 = ls_kna1-pstl2.
*            reguh-zpfor = ls_kna1-pfort.
*            reguh-zland = ls_kna1-land1.
*            reguh-zspra = ls_kna1-spras.
*            reguh-zregi = ls_kna1-regio.
*            reguh-ztlfx = ls_kna1-telfx.
*            reguh-ztelf = ls_kna1-telf1.
*            reguh-ztelx = ls_kna1-telx1.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*      PERFORM extract_vorbereitung.
*
*
*GET regup.
*
*  PERFORM extract.
*  IF reguh-zbukr NE regup-bukrs.
*    tab_uebergreifend-zbukr = reguh-zbukr.
*    tab_uebergreifend-vblnr = reguh-vblnr.
*    COLLECT tab_uebergreifend.
*  ENDIF.
*
*
*
**----------------------------------------------------------------------*
**  print checks, remittance advices and lists                          *
**----------------------------------------------------------------------*
*END-OF-SELECTION.
*
*  IF flg_selektiert NE 0.
*
*    IF par_zdru EQ 'X'.
*      hlp_zforn = par_zfor.
*      hlp_checf_restart = par_rchk.
*      IF par_novo NE space.
*        flg_schecknum = 2.
*      ENDIF.
*      PERFORM scheck.                    "RFFORI01
*      IF par_nenq EQ space.
*        PERFORM schecknummern_entsperren."RFFORI01
*      ENDIF.
*    ENDIF.
*
*    IF par_avis EQ 'X'.
*      flg_schecknum = 1.
*      PERFORM avis.                      "RFFORI06
*    ENDIF.
*
*    IF par_begl EQ 'X' AND par_maxp GT 0.
*      flg_bankinfo = 1.
*      PERFORM begleitliste.              "RFFORI07
*    ENDIF.
*
*  ENDIF.
*
*  PERFORM fehlermeldungen.
*
*  PERFORM information.
*
**----------------------------------------------------------------------*
** Begin of changes by 477670 |PTP.FRM.002 | D4SK901020  |02-FEB-2019   *
**----------------------------------------------------------------------*
**  subroutines for check print and prenumbered checks                  *
**----------------------------------------------------------------------*
*  INCLUDE zinfi_rffori01.
**--------------------------------------------------------------------- *
** End of changes by 477670 |PTP.FRM.002 | D4SK901020 |02-FEB-2019      *
**----------------------------------------------------------------------*
*
**----------------------------------------------------------------------*
**  subroutines for remittance advices                                  *
**----------------------------------------------------------------------*
*  INCLUDE rffori06.
*
**----------------------------------------------------------------------*
**  subroutines for the payment summary list                            *
**----------------------------------------------------------------------*
*  INCLUDE rffori07.
*
**----------------------------------------------------------------------*
**  international subroutines                                           *
**----------------------------------------------------------------------*
*  INCLUDE rffori99.
