***************************************************************************
**************************************************************************
***                                                                      *
*** Include RFFORI01, used in the payment print programs RFFOxxxz        *
*** with subroutines for printing checks                                 *
*** and subroutines for prenumbered checks (see below)                   *
***                                                                      *
**************************************************************************
**
**TYPES : BEGIN OF ty_bank,
**          banks TYPE banks,
**          banka TYPE banka,
**          provz TYPE regio,
**          stras TYPE stras_gp,
**          ort01 TYPE ort01_gp,
**          pskto TYPE pskto_ch,
**        END OF ty_bank.
**
**DATA : gt_bank TYPE STANDARD TABLE OF ty_bank,
**       gw_bank TYPE ty_bank.
**
**DATA: gv_banka TYPE banka,
**      gv_stras TYPE stras_gp,
**      gv_ort01 TYPE ort01_gp,
**      gv_pskto TYPE pskto_ch,
**      gv_bezei TYPE bezei20.
**
***----------------------------------------------------------------------*
*** Declaration for work areas
***----------------------------------------------------------------------*
**DATA: gw_thead LIKE thead,
**      gt_tline LIKE tline OCCURS 0 WITH HEADER LINE.
***----------------------------------------------------------------------*
*** Declaration for Variables
***----------------------------------------------------------------------*
**
**DATA: gv_flag            TYPE c,        "Flag for signature lines       +477670|D4SK903597
**      gv_string(3)       TYPE c,
**      gv_balance_forward TYPE c,        " Flag for balance forward
**      gv_total_flag      TYPE c,        " Flag for balance forward
**      gv_count           LIKE sy-tabix, " Loop count
**      gv_page_count      LIKE gv_count,  " page no. for text
**      gv_swnet_temp(15)  TYPE c,        " Temp carried fwd amount net
**      gv_swskt_temp(13)  TYPE c,        " Temp carried forward disc. amt
**      gv_swrbt_temp(15)  TYPE c,        " Temp carried forward tot.amount
**      gv_swnet_tot(17)   TYPE c,        " Tot.amount with $ and ** Script
**      gv_check_num(13)   TYPE c.
**
**DATA : gv_wabzg      LIKE regud-wabzg,  "Total of Discount Coloumn.
**       gv_carryfwd   LIKE regud-wabzg, "Balance Carryforward.
**       gv_carryfwd1  LIKE regud-wabzg,gv_carryfwd2 LIKE regud-wabzg,
**       gv_carryfwd3  LIKE regud-wabzg,gv_carryfwd4 LIKE regud-wabzg,
**       gv_carryfwd5  LIKE regud-wabzg,gv_carryfwd6 LIKE regud-wabzg,
**       gv_carryfwd7  LIKE regud-wabzg,gv_carryfwd8 LIKE regud-wabzg,
**       gv_carryfwd9  LIKE regud-wabzg,gv_carryfwd10 LIKE regud-wabzg,
**       gv_carryfwd11 LIKE regud-wabzg,gv_carryfwd12 LIKE regud-wabzg,
**       gv_carryfwd13 LIKE regud-wabzg,gv_carryfwd14 LIKE regud-wabzg,
**       gv_carryfwd15 LIKE regud-wabzg,gv_carryfwd16 LIKE regud-wabzg,
**       gv_carryfwd17 LIKE regud-wabzg,gv_carryfwd18 LIKE regud-wabzg,
**       gv_carryfwd19 LIKE regud-wabzg,gv_carryfwd20 LIKE regud-wabzg,
**       gv_carryfwd21 LIKE regud-wabzg,gv_carryfwd22 LIKE regud-wabzg,
**       gv_carryfwd23 LIKE regud-wabzg,gv_carryfwd24 LIKE regud-wabzg,
**       gv_carryfwd25 LIKE regud-wabzg,gv_carryfwd26 LIKE regud-wabzg,
**       gv_carryfwd27 LIKE regud-wabzg,gv_carryfwd28 LIKE regud-wabzg,
**       gv_carryfwd29 LIKE regud-wabzg,
**       gv_pcount.                     "Current Page Count.
**
**
***--------Begin of changes by 477670 | DFT1POST-239 | D4SK906650--------*
*** Declaration for Constants
***----------------------------------------------------------------------*
**DATA : gc_3000(4) TYPE c VALUE '3000',
**       gc_cad(3)  TYPE c VALUE 'CAD'.
***----------End of changes by 477670 | DFT1POST-239 | D4SK906650--------*
**
***----------------------------------------------------------------------*
*** FORM SCHECK                                                          *
***----------------------------------------------------------------------*
*** Druck des Avises mit Allongeteil                                     *
*** (Beispiel Scheck)                                                    *
*** Gerufen von END-OF-SELECTION (RFFOxxxz)                              *
***----------------------------------------------------------------------*
*** prints a remittance advice with a check                              *
*** called by END-OF-SELECTION (RFFOxxxz)                                *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM scheck.
**
***----------------------------------------------------------------------*
*** Declaration for Constants
***----------------------------------------------------------------------*
**
**  CONSTANTS : lc_tdobject(4) TYPE c       VALUE 'TEXT',
**              lc_tdname(15)  TYPE c       VALUE 'ZCHECK_PRINT',
**              lc_tdid(2)     TYPE c       VALUE 'ST',
**              lc_tdspras     TYPE c       VALUE 'E',
**              lc_10k         TYPE wnetv   VALUE '10000.00'.        " Changes D4SK907604
***----------------------------------------------------------------------*
**
*** Tabellen für den Angabeteil von Auslandsschecks in Österreich
*** Austria only
**  DATA:
**    BEGIN OF up_oenb_angaben OCCURS 5, "Angaben zur OeNB-Meldung
**      diekz    LIKE regup-diekz,       "Anmerkung: die betragshöchste
**      lzbkz    LIKE regup-lzbkz,       "Angabe wird auf den Angabenteil
**      summe(7) TYPE p,                 "übernommen
**    END OF up_oenb_angaben,
**    BEGIN OF up_oenb_kontowae OCCURS 5,"Kontowährung der Hausbankkonten
**      ubhkt LIKE reguh-ubhkt,       "für die OeNB-Meldung
**      uwaer LIKE t012k-waers,
**    END OF up_oenb_kontowae.
**
***----------------------------------------------------------------------*
*** Abarbeiten der extrahierten Daten                                    *
*** loop at extracted data                                               *
***----------------------------------------------------------------------*
**  IF flg_sort NE 2.
**    SORT BY avis.
**    flg_sort = 2.
**  ENDIF.
**
**
*** Initalise the text name where the data for the ZMain window,
*** the "main" window on the check part of the output, are temporary
*** stored
**  gw_thead-tdid     = lc_tdid.
**  gw_thead-tdspras  = lc_tdspras.
**  gw_thead-tdname   = lc_tdname.
**  gw_thead-tdobject = lc_tdobject.
**
**  CLEAR gv_total_flag.
**  CLEAR gv_count.
**  gv_page_count = 1.                    " First page
**  hlp_ep_element = '525'.
**
**  CLEAR : gv_wabzg,
**          gv_carryfwd,gv_carryfwd1,gv_carryfwd2,gv_carryfwd3,gv_carryfwd4,
**          gv_carryfwd5,gv_carryfwd6,gv_carryfwd7,gv_carryfwd8,gv_carryfwd9,
**       gv_carryfwd10,gv_carryfwd11,gv_carryfwd12,gv_carryfwd13,gv_carryfwd14,
**       gv_carryfwd15,gv_carryfwd16,gv_carryfwd17,gv_carryfwd18,gv_carryfwd19,
**       gv_carryfwd20,gv_carryfwd21,gv_carryfwd22,gv_carryfwd23,gv_carryfwd24,
**       gv_carryfwd25,gv_carryfwd26,gv_carryfwd27,gv_carryfwd28,gv_carryfwd29,
**          gv_pcount.
**
**  LOOP.
**
**
***-- Neuer zahlender Buchungskreis --------------------------------------
***-- new paying company code --------------------------------------------
**    AT NEW reguh-zbukr.
**
**      PERFORM buchungskreis_daten_lesen.
**
**    ENDAT.
**
**
***-- Neuer Zahlweg ------------------------------------------------------
***-- new payment method -------------------------------------------------
**    AT NEW reguh-rzawe.
**
**      flg_probedruck = 0.              "für diesen Zahlweg wurde noch
**      "kein Probedruck durchgeführt
**      "test print for this payment
**      "method not yet done
**      PERFORM zahlweg_daten_lesen.
**
***     Spoolparameter zur Ausgabe des Schecks angeben
***     specify spool parameters for check print
**      PERFORM fill_itcpo USING par_priz
**                               t042z-zlstn
**                               space   "par_sofz via tab_ausgabe!
**                               hlp_auth.
**
**      IF flg_schecknum EQ 1.
**        itcpo-tddelete  = 'X'.         "delete after print
**      ENDIF.
**      EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.
**
***     Scheckformular öffnen
***     open check form
**      CALL FUNCTION 'OPEN_FORM'
**        EXPORTING
**          form     = t042e-zforn
**          device   = 'PRINTER'
**          language = t001-spras
**          options  = itcpo
**          dialog   = space
**        EXCEPTIONS
**          form     = 1.
**      IF sy-subrc EQ 1.                "abend:
**        IF sy-batch EQ space.          "form is not active
**          MESSAGE a069 WITH t042e-zforn.
**        ELSE.
**          MESSAGE s069 WITH t042e-zforn.
**          MESSAGE s094.
**          STOP.
**        ENDIF.
**      ENDIF.
**
***     Formular auf Segmenttext (Global &REGUP-SGTXT) untersuchen
***     examine whether segment text is to be printed
**      IF t042e-xavis NE space AND t042e-anzpo NE 99.
**        flg_sgtxt = 0.
**        CALL FUNCTION 'READ_FORM_LINES'
**          EXPORTING
**            element = hlp_ep_element
**          TABLES
**            lines   = tab_element
**          EXCEPTIONS
**            element = 1.
**        IF sy-subrc EQ 0.
**          LOOP AT tab_element.
**            IF    tab_element-tdline   CS 'REGUP-SGTXT'
**              AND tab_element-tdformat NE '/*'.
**              flg_sgtxt = 1.           "Global für Segmenttext existiert
**              EXIT.                    "global for segment text exists
**            ENDIF.
**          ENDLOOP.
**        ENDIF.
**      ENDIF.
**
***     Scheck auf Währungsschlüssel (Global &REGUD-WAERS&) und Maximal-
***     betrag für die Umsetzung der Ziffern in Worten untersuchen
***     currency code &REGUD-WAERS& has to exist in window CHECK for
***     foreign currency checks, compute maximal amount 'in words'
**      flg_fw_scheck = 0.
**      IF t042z-xeinz EQ space.
**        hlp_element = '545'.
**      ELSE.
**        hlp_element = '546'.
**      ENDIF.
**      CALL FUNCTION 'READ_FORM_LINES'
**        EXPORTING
**          window  = 'CHECK'
**          element = hlp_element
**        TABLES
**          lines   = tab_element
**        EXCEPTIONS
**          element = 2.
**      CALL FUNCTION 'READ_FORM_LINES'
**        EXPORTING
**          window  = 'CHECKSPL'
**          element = hlp_element
**        TABLES
**          lines   = tab_element2
**        EXCEPTIONS
**          element = 2.
**      APPEND LINES OF tab_element2 TO tab_element.
**
**      hlp_maxstellen = 0.              "der Maximalbetrag wird nur
**      hlp_maxbetrag  = 10000000000000. "berechnet, wenn die Globals
**      "SPELL-DIGnn verwendet wurden
**      IF sy-tabix NE 0.                "max. amount only computed if
**        LOOP AT tab_element.           "globals SPELL-DIGnn are used
**          IF tab_element-tdformat NE '/*'.
***           Währungsschlüssel
***           currency code
**            IF tab_element-tdline CP '*REGU+-WAERS*'.
**              flg_fw_scheck = 1.
**            ENDIF.
***           Maximal umsetzbare Stellen ermitteln
***           find out maximal number of places which can be transformed
**            WHILE tab_element-tdline CS '&SPELL-DIG'.
**              SHIFT tab_element-tdline BY sy-fdpos PLACES.
**              SHIFT tab_element-tdline BY 10 PLACES.
**              IF tab_element-tdline(2) CO '0123456789'.
**                IF hlp_maxstellen LT tab_element-tdline(2).
**                  hlp_maxstellen = tab_element-tdline(2).
**                ENDIF.
**              ENDIF.
**            ENDWHILE.
**          ENDIF.
**        ENDLOOP.
***       Maximalbetrag ermitteln
***       compute maximal amount for transformation 'in words'
**        IF hlp_maxstellen NE 0.
**          hlp_maxbetrag = 1.
**          DO hlp_maxstellen TIMES.
**            hlp_maxbetrag = hlp_maxbetrag * 10.
**          ENDDO.
**        ENDIF.
**      ENDIF.
**      CALL FUNCTION 'CLOSE_FORM'.
**
**    ENDAT.
**
**
***-- Neue Hausbank ------------------------------------------------------
***-- new house bank -----------------------------------------------------
**    AT NEW reguh-ubnkl.
**
**      PERFORM hausbank_daten_lesen.
**
***     Felder für Formularabschluß initialisieren
***     initialize fields for summary
**      cnt_formulare = 0.
**      cnt_hinweise  = 0.
**      sum_abschluss = 0.
**
***     Vornumerierte Schecks: erste Schecknummer ermitteln
***     prenumbered checks: find out first check number
**      IF flg_schecknum EQ 1.
**        PERFORM schecknummer_ermitteln USING 1.
**      ENDIF.
**
**    ENDAT.
**
**
***-- Neue Kontonummer bei der Hausbank ----------------------------------
***-- new account number with house bank ---------------------------------
**    AT NEW reguh-ubknt.
**
***     Kontonummer ohne Aufbereitungszeichen für OCRA-Zeile speichern
***     store numerical account number for code line
**      regud-obknt = reguh-ubknt.
**
**    ENDAT.
**
**
***-- Neue Empfängerbank -------------------------------------------------
***-- new bank of payee --------------------------------------------------
**    AT NEW reguh-zbnkl.
**
**      PERFORM empfbank_daten_lesen.
**
**    ENDAT.
**
**
***-- Neue Zahlungsbelegnummer -------------------------------------------
***-- new payment document number ----------------------------------------
**    AT NEW reguh-vblnr.
**
***     Angabentabelle und Kontowährung für die OeNB-Meldung (Österreich)
***     Austria only
**      IF t042e-xausl EQ 'X' AND        "nur Auslandsscheck
**        hlp_laufk NE 'P'.              "kein HR
**        REFRESH up_oenb_angaben.
**        CLEAR up_oenb_kontowae.
**        READ TABLE up_oenb_kontowae WITH KEY reguh-ubhkt.
**        IF sy-subrc NE 0.
**          PERFORM hausbank_konto_lesen.
**          up_oenb_kontowae-ubhkt = reguh-ubhkt.
**          PERFORM isocode_umsetzen
**            USING t012k-waers up_oenb_kontowae-uwaer.
**          APPEND up_oenb_kontowae.
**        ENDIF.
**      ENDIF.
**
***     Lesen der Referenzangaben (Schweiz)
***     Switzerland only
**      PERFORM hausbank_konto_lesen.
**
***     Kein Druck falls Fremdwährung, aber kein Fremdwährungsscheck
***     no print if foreign currency, but global &REGUD-WAERS& is missing
**      flg_kein_druck = 0.
**
**      IF flg_kein_druck EQ 0.
**
**        PERFORM zahlungs_daten_lesen.
**
***       Tag der Zahlung in Worten (Spanien)
***       day of payment in words (Spain)
**        CLEAR t015z.
**        SELECT SINGLE * FROM t015z
**          WHERE spras EQ hlp_sprache
**            AND einh  EQ reguh-zaldt+6(1)
**            AND ziff  EQ reguh-zaldt+7(1).
**        IF sy-subrc EQ 0.
**          regud-text2 = t015z-wort.
**          TRANSLATE regud-text2 TO LOWER CASE.           "#EC TRANSLANG
**          TRANSLATE regud-text2 USING '; '.
**        ELSE.
**          CLEAR err_t015z.
**          err_t015z-spras = hlp_sprache.
**          err_t015z-einh  = reguh-zaldt+6(1).
**          err_t015z-ziff  = reguh-zaldt+7(1).
**          COLLECT err_t015z.
**        ENDIF.
**
***       Elementname für die Einzelposteninformation ermitteln
***       determine element name for item list
**        IF hlp_laufk EQ 'P' OR
**           hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN'.
**          hlp_ep_element = '525-HR'.
**        ELSE.
**          hlp_ep_element = '525'.
**        ENDIF.
**
***       Name des Fensters mit dem Anschreiben zusammensetzen
***       specify name of the window with the check text
**        hlp_element   = '510-'.
**        hlp_element+4 = reguh-rzawe.
**        hlp_eletext   = text_510.
**        REPLACE '&ZAHLWEG' WITH reguh-rzawe INTO hlp_eletext.
**
***       Druckvorgaben modifizieren lassen
***       modification of print parameters
**        IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
**        PERFORM modify_itcpo.
**
***       Scheckformular öffnen
***       open check form
**        IF cnt_formulare EQ 0.
**          itcpo-tdnewid = 'X'.
**        ELSE.
**          itcpo-tdnewid = space.
**        ENDIF.
**        IF par_priz EQ space.
**          flg_dialog = 'X'.
**        ELSE.
**          flg_dialog = space.
**        ENDIF.
**        CALL FUNCTION 'OPEN_FORM'
**          EXPORTING
**            archive_index  = toa_dara
**            archive_params = arc_params
**            form           = t042e-zforn
**            device         = 'PRINTER'
**            language       = t001-spras
**            options        = itcpo
**            dialog         = flg_dialog
**          IMPORTING
**            result         = itcpp
**          EXCEPTIONS
**            form           = 1.
**        IF sy-subrc EQ 1.              "abend:
**          IF sy-batch EQ space.        "form is not active
**            MESSAGE a069 WITH t042e-zforn.
**          ELSE.
**            MESSAGE s069 WITH t042e-zforn.
**            MESSAGE s094.
**            STOP.
**          ENDIF.
**        ENDIF.
**
**
***--------------------------------------------------------|
*** Begin of changes by 477670  |PTP.FRM.002 |13-AUG-2019  |
***--------------------------------------------------------|
**
*** Get Bank Address
**        SELECT a~banks
**               a~banka
**               a~provz
**               a~stras
**               a~ort01
**               a~pskto
**          FROM bnka AS a INNER JOIN t012 AS b
**            ON a~bankl = b~bankl
**           AND a~banks = b~banks
**          INTO CORRESPONDING FIELDS OF TABLE gt_bank
**         WHERE b~bukrs = reguh-zbukr
**           AND b~hbkid = reguh-hbkid.
**        IF sy-subrc EQ 0.
**          READ TABLE gt_bank INTO gw_bank INDEX 1.
**          IF sy-subrc EQ 0.
**            CLEAR : gv_banka,
**                    gv_stras,
**                    gv_ort01,
**                    gv_pskto,
**                    gv_bezei.
**
**            gv_banka = gw_bank-banka.
**            gv_stras = gw_bank-stras.
**            gv_ort01 = gw_bank-ort01.
**            gv_pskto = gw_bank-pskto.
**
**            IF gw_bank-provz IS NOT INITIAL AND gw_bank-banks IS NOT INITIAL.
**
**              SELECT SINGLE bezei
**                FROM t005u
**                INTO gv_bezei
**               WHERE spras = sy-langu
**                 AND land1 = gw_bank-banks
**                 AND bland = gw_bank-provz.
**            ENDIF.
**          ENDIF.
**        ENDIF.
***------------------------------------------------------|
*** End of changes by 477670  |PTP.FRM.002 | 13-AUG-2019 |
***------------------------------------------------------|
**
**
**        IF par_priz EQ space.
**          par_priz = itcpp-tddest.
**          PERFORM fill_itcpo_from_itcpp.
**          EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.
**        ENDIF.
**
***       Probedruck
***       test print
**        IF flg_probedruck EQ 0.        "Probedruck noch nicht erledigt
**          PERFORM daten_sichern.       "test print not yet done
**          cnt_seiten = 0.
**          DO par_anzp TIMES.
***           Vornumerierte Schecks: Schecknummer hochzählen ab 2.Seite
***           prenumbered checks: add 1 to check number
**            IF flg_schecknum EQ 1 AND sy-index GT 1.
**              hlp_page = sy-index.
**              PERFORM schecknummer_addieren.
**            ENDIF.
***           Probedruck-Formular starten
***           start test print form
**            CALL FUNCTION 'START_FORM'
**              EXPORTING
**                language = hlp_sprache.
***           Fenster mit Probedruck schreiben
***           write windows with test print
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                window   = 'INFO'
**                element  = '505'
**                function = 'APPEND'
**              EXCEPTIONS
**                window   = 1
**                element  = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                window  = 'CHECK'
**                element = '540'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element = hlp_element
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**            IF sy-subrc NE 0.
**              CALL FUNCTION 'WRITE_FORM'
**                EXPORTING
**                  element = '510'
**                EXCEPTIONS
**                  window  = 1
**                  element = 2.
**            ENDIF.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element = '514'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element = '515'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element  = hlp_ep_element
**                function = 'APPEND'
**              EXCEPTIONS
**                window   = 1
**                element  = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element  = '530'
**                function = 'APPEND'
**              EXCEPTIONS
**                window   = 1
**                element  = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                window  = 'TOTAL'
**                element = '530'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                window   = 'INFO'
**                element  = '505'
**                function = 'DELETE'
**              EXCEPTIONS
**                window   = 1
**                element  = 2.
***           Probedruck-Formular beenden
***           end test print
**            CALL FUNCTION 'END_FORM'
**              IMPORTING
**                result = itcpp.
**            IF itcpp-tdpages EQ 0.     "Print via RDI
**              itcpp-tdpages = 1.
**            ENDIF.
**            ADD itcpp-tdpages TO cnt_seiten.
**          ENDDO.
**          IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
**            PERFORM scheckinfo_speichern USING 1.
**          ENDIF.
**          PERFORM daten_zurueck.
**          flg_probedruck = 1.          "Probedruck erledigt
**        ENDIF.                         "test print done
**
**        PERFORM summenfelder_initialisieren.
**
***       Prüfe, ob HR-Formular zu verwenden ist
***       Check if HR-form is to be used
**        IF ( hlp_laufk EQ 'P' OR
**             hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' )
**         AND hrxblnr-xhrfo NE space.
**          hlp_xhrfo = 'X'.
**        ELSE.
**          hlp_xhrfo = space.
**        ENDIF.
**
***       Formular starten
***       start check form
**        CALL FUNCTION 'START_FORM'
**          EXPORTING
**            archive_index = toa_dara
**            language      = hlp_sprache.
**
***       Vornumerierte Schecks: nächste Schecknummer ermitteln
***       prenumbered checks: compute next check number
**        IF flg_schecknum EQ 1.
**          PERFORM schecknummer_ermitteln USING 2.
**        ENDIF.
**
***       Fenster Check, Element Entwerteter Scheck
***       window check, element voided check
**        CALL FUNCTION 'WRITE_FORM'
**          EXPORTING
**            window  = 'CHECK'
**            element = '540'
**          EXCEPTIONS
**            window  = 1
**            element = 2.
**        IF sy-subrc EQ 2.
**          err_element-fname = t042e-zforn.
**          err_element-fenst = 'CHECK'.
**          err_element-elemt = '540'.
**          err_element-text  = text_540.
**          COLLECT err_element.
**        ENDIF.
**
**        IF hlp_xhrfo EQ space.
**
***         Fenster Info, Element Unsere Nummer (falls diese gefüllt ist)
***         window info, element our number (if filled)
**          IF reguh-eikto NE space.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                window   = 'INFO'
**                element  = '505'
**                function = 'APPEND'
**              EXCEPTIONS
**                window   = 1
**                element  = 2.
**            IF sy-subrc EQ 2.
**              err_element-fname = t042e-zforn.
**              err_element-fenst = 'INFO'.
**              err_element-elemt = '505'.
**              err_element-text  = text_505.
**              COLLECT err_element.
**            ENDIF.
**          ENDIF.
**
***         Fenster Carry Forward, Element Übertrag (außer letzte Seite)
***         window carryfwd, element carry forward below (not last page)
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'CARRYFWD'
**              element = '535'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'CARRYFWD'.
**            err_element-elemt = '535'.
**            err_element-text  = text_535.
**            COLLECT err_element.
**          ENDIF.
**
***         Hauptfenster, Element Anschreiben (nur auf der ersten Seite)
***         main window, element check text (only on first page)
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element = hlp_element
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element = '510'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'MAIN'.
**            err_element-elemt = hlp_element.
**            err_element-text  = hlp_eletext.
**            COLLECT err_element.
**          ENDIF.
**
***         Hauptfenster, Element Zahlung erfolgt im Auftrag von
***         main window, element payment by order of
**          IF reguh-absbu NE reguh-zbukr.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element = '513'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**
**            IF sy-subrc EQ 2.
**              err_element-fname = t042e-zforn.
**              err_element-fenst = 'MAIN'.
**              err_element-elemt = '513'.
**              err_element-text  = text_513.
**              COLLECT err_element.
**            ENDIF.
**          ENDIF.
**
***         Hauptfenster, Element Abweichender Zahlungsemfänger
***         main window, element different payee
**          IF regud-xabwz EQ 'X'.
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                element = '512'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**
**            IF sy-subrc EQ 2.
**              err_element-fname = t042e-zforn.
**              err_element-fenst = 'MAIN'.
**              err_element-elemt = '512'.
**              err_element-text  = text_512.
**              COLLECT err_element.
**            ENDIF.
**          ENDIF.
**
***         Hauptfenster, Element Gruß und Unterschrift
***         main window, element regards and signature
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element = '514'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**
***         Hauptfenster, Element Überschrift (nur auf der ersten Seite)
***         main window, element title (only on first page)
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element = '515'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'MAIN'.
**            err_element-elemt = '515'.
**            err_element-text  = text_515.
**            COLLECT err_element.
**          ENDIF.
**
***         Hauptfenster, Element Überschrift (ab der zweiten Seite oben)
***         main window, element title (2nd and following pages)
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element = '515'
**              type    = 'TOP'
**            EXCEPTIONS
**              window  = 1        "Fehler bereits oben gemerkt
**              element = 2.       "error already noted
**
***         Hauptfenster, Element Übertrag (ab der zweiten Seite oben)
***         main window, element carry forward above (2nd and following p)
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element  = '520'
**              type     = 'TOP'
**              function = 'APPEND'
**            EXCEPTIONS
**              window   = 1
**              element  = 2.
**          IF sy-subrc EQ 0.
*** Sets the  gv_balance_forward flag if the balance should be printed
*** when it is more than one page. The flag is used to put the
*** balance out in the Temporary text.
**            WRITE 'X' TO gv_balance_forward.
**          ELSEIF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'MAIN'.
**            err_element-elemt = '520'.
**            err_element-text  = text_520.
**            COLLECT err_element.
**          ENDIF.
**
**        ELSE.
**
**          PERFORM hr_formular_lesen.
**
**        ENDIF.
**
***       Prüfung, ob Avishinweis erforderlich
***       check if advice note is necessary
**        cnt_zeilen = 0.
**        IF t042e-xavis NE space AND t042e-anzpo NE 99.
**          IF hlp_xhrfo EQ space.
**            IF flg_sgtxt = 1.
**              cnt_zeilen = reguh-rpost + reguh-rtext.
**            ELSE.
**              cnt_zeilen = reguh-rpost.
**            ENDIF.
**          ELSE.
**            DESCRIBE TABLE pform LINES cnt_zeilen.
**          ENDIF.
**          IF cnt_zeilen GT t042e-anzpo.
**            IF hlp_xhrfo EQ space.
**              CALL FUNCTION 'WRITE_FORM'
**                EXPORTING
**                  element  = '526'
**                  function = 'APPEND'
**                EXCEPTIONS
**                  window   = 1
**                  element  = 2.
**              IF sy-subrc EQ 2.
**                err_element-fname = t042e-zforn.
**                err_element-fenst = 'MAIN'.
**                err_element-elemt = '526'.
**                err_element-text  = text_526.
**                COLLECT err_element.
**              ENDIF.
**            ENDIF.
**            ADD 1 TO cnt_hinweise.
**          ENDIF.
**        ENDIF.
**
***       HR-Formular ausgeben
***       write HR form
**        IF hlp_xhrfo NE space.
**          LOOP AT pform.
**            IF cnt_zeilen GT t042e-anzpo AND sy-tabix GT t042e-anzpo.
**              EXIT.
**            ENDIF.
**            regud-txthr = pform-linda.
**            PERFORM scheckavis_zeile.
**          ENDLOOP.
**        ENDIF.
**        flg_diff_bukrs = 0.
**
**      ENDIF.
**
**    ENDAT.
**
***-- Neuer Rechnungsbuchungskreis ---------------------------------------
***-- New invoice company code -------------------------------------------
**    AT NEW regup-bukrs.
**      IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
**        IF ( regup-bukrs NE reguh-zbukr OR flg_diff_bukrs EQ 1 ) AND
**           ( reguh-absbu EQ space OR reguh-absbu EQ reguh-zbukr ).
**          flg_diff_bukrs = 1.
**          SELECT SINGLE * FROM t001 INTO *t001
**            WHERE bukrs EQ regup-bukrs.
**          regud-abstx = *t001-butxt.
**          regud-absor = *t001-ort01.
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element = '513'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'MAIN'.
**            err_element-elemt = '513'.
**            err_element-text  = text_513.
**            COLLECT err_element.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**    ENDAT.
**
**
***-- Verarbeitung der Einzelposten-Informationen ------------------------
***-- single item information --------------------------------------------
**    AT daten.
**      IF flg_kein_druck EQ 0.
**
**        PERFORM einzelpostenfelder_fuellen.
**
**** included to cumulate discount and withholding tax for each lineitem.
**        DATA : l_tabix LIKE sy-tabix.
**        l_tabix = sy-tabix.
**        IF regud-xabwz = 'X'.      " if alternate payee only
**          l_tabix = l_tabix + 6.
**        ENDIF.
**        IF l_tabix <= 12.
**          gv_pcount = 1.
**        ELSEIF l_tabix > 12 AND l_tabix <= 24.
**          gv_pcount = 2.
**        ELSEIF l_tabix > 24 AND l_tabix <= 36.
**          gv_pcount = 3.
**        ELSEIF l_tabix > 36 AND l_tabix <= 48.
**          gv_pcount = 4.
**        ELSEIF l_tabix > 48 AND l_tabix <= 60.
**          gv_pcount = 5.
**        ELSEIF l_tabix > 60 AND l_tabix <= 72.
**          gv_pcount = 6.
**        ELSEIF l_tabix > 72 AND l_tabix <= 84.
**          gv_pcount = 7.
**        ELSEIF l_tabix > 84 AND l_tabix <= 96.
**          gv_pcount = 8.
**        ELSEIF l_tabix > 96 AND l_tabix <= 108.
**          gv_pcount = 9.
**        ELSEIF l_tabix > 108 AND l_tabix <= 120.
**          gv_pcount = 10.
****
**        ELSEIF l_tabix > 120 AND l_tabix <= 132.
**          gv_pcount = 11.
**        ELSEIF l_tabix > 132 AND l_tabix <= 144.
**          gv_pcount = 12.
**        ELSEIF l_tabix > 144 AND l_tabix <= 156.
**          gv_pcount = 13.
**        ELSEIF l_tabix > 156 AND l_tabix <= 168.
**          gv_pcount = 14.
**        ELSEIF l_tabix > 168 AND l_tabix <= 180.
**          gv_pcount = 15.
**        ELSEIF l_tabix > 180 AND l_tabix <= 192.
**          gv_pcount = 16.
**        ELSEIF l_tabix > 192 AND l_tabix <= 204.
**          gv_pcount = 17.
**        ELSEIF l_tabix > 204 AND l_tabix <= 216.
**          gv_pcount = 18.
**        ELSEIF l_tabix > 216 AND l_tabix <= 228.
**          gv_pcount = 19.
**        ELSEIF l_tabix > 228 AND l_tabix <= 240.
**          gv_pcount = 20.
**        ELSEIF l_tabix > 240 AND l_tabix <= 252.
**          gv_pcount = 21.
**        ELSEIF l_tabix > 252 AND l_tabix <= 264.
**          gv_pcount = 22.
**        ELSEIF l_tabix > 264 AND l_tabix <= 276.
**          gv_pcount = 22.
**        ELSEIF l_tabix > 276 AND l_tabix <= 288.
**          gv_pcount = 23.
**        ELSEIF l_tabix > 288 AND l_tabix <= 300.
**          gv_pcount = 24.
**        ELSEIF l_tabix > 300 AND l_tabix <= 312.
**          gv_pcount = 25.
**        ELSEIF l_tabix > 312 AND l_tabix <= 324.
**          gv_pcount = 26.
**        ELSEIF l_tabix > 324 AND l_tabix <= 336.
**          gv_pcount = 27.
**        ELSEIF l_tabix > 336 AND l_tabix <= 348.
**          gv_pcount = 28.
**        ELSEIF l_tabix > 348 AND l_tabix <= 360.
**          gv_pcount = 29.
****
**        ENDIF.
**
**        CASE gv_pcount.
**          WHEN '1'.
**            gv_carryfwd = gv_carryfwd + regud-wabzg.
**          WHEN  '2'.
**            IF l_tabix = 13.
**              gv_carryfwd1 = gv_carryfwd + regud-wabzg.
**            ELSE.
**              gv_carryfwd1 = gv_carryfwd1 + regud-wabzg.
**            ENDIF.
**          WHEN  '3'.
**            IF l_tabix = 25.
**              gv_carryfwd2 = gv_carryfwd1 + regud-wabzg.
**            ELSE.
**              gv_carryfwd2 = gv_carryfwd2 + regud-wabzg.
**            ENDIF.
**          WHEN  '4'.
**            IF l_tabix = 37.
**              gv_carryfwd3 = gv_carryfwd2 + regud-wabzg.
**            ELSE.
**              gv_carryfwd3 = gv_carryfwd3 + regud-wabzg.
**            ENDIF.
**          WHEN  '5'.
**            IF l_tabix = 49.
**              gv_carryfwd4 = gv_carryfwd3 + regud-wabzg.
**            ELSE.
**              gv_carryfwd4 = gv_carryfwd4 + regud-wabzg.
**            ENDIF.
**          WHEN  '6'.
**            IF l_tabix = 61.
**              gv_carryfwd5 = gv_carryfwd4 + regud-wabzg.
**            ELSE.
**              gv_carryfwd5 = gv_carryfwd5 + regud-wabzg.
**            ENDIF.
**          WHEN  '7'.
**            IF l_tabix = 73.
**              gv_carryfwd6 = gv_carryfwd5 + regud-wabzg.
**            ELSE.
**              gv_carryfwd6 = gv_carryfwd6 + regud-wabzg.
**            ENDIF.
**          WHEN  '8'.
**            IF l_tabix = 85.
**              gv_carryfwd7 = gv_carryfwd6 + regud-wabzg.
**            ELSE.
**              gv_carryfwd7 = gv_carryfwd7 + regud-wabzg.
**            ENDIF.
**          WHEN  '9'.
**            IF l_tabix = 97.
**              gv_carryfwd8 = gv_carryfwd7 + regud-wabzg.
**            ELSE.
**              gv_carryfwd8 = gv_carryfwd8 + regud-wabzg.
**            ENDIF.
**          WHEN  '10'.
**            IF l_tabix = 109.
**              gv_carryfwd9 = gv_carryfwd8 + regud-wabzg.
**            ELSE.
**              gv_carryfwd9 = gv_carryfwd9 + regud-wabzg.
**            ENDIF.
****
**          WHEN  '11'.
**            IF l_tabix = 121.
**              gv_carryfwd10 = gv_carryfwd9 + regud-wabzg.
**            ELSE.
**              gv_carryfwd10 = gv_carryfwd10 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '12'.
**            IF l_tabix = 133.
**              gv_carryfwd11 = gv_carryfwd10 + regud-wabzg.
**            ELSE.
**              gv_carryfwd11 = gv_carryfwd11 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '13'.
**            IF l_tabix = 145.
**              gv_carryfwd12 = gv_carryfwd11 + regud-wabzg.
**            ELSE.
**              gv_carryfwd12 = gv_carryfwd12 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '14'.
**            IF l_tabix = 157.
**              gv_carryfwd13 = gv_carryfwd12 + regud-wabzg.
**            ELSE.
**              gv_carryfwd13 = gv_carryfwd13 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '15'.
**            IF l_tabix = 169.
**              gv_carryfwd14 = gv_carryfwd13 + regud-wabzg.
**            ELSE.
**              gv_carryfwd14 = gv_carryfwd14 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '16'.
**            IF l_tabix = 181.
**              gv_carryfwd15 = gv_carryfwd14 + regud-wabzg.
**            ELSE.
**              gv_carryfwd15 = gv_carryfwd15 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '17'.
**            IF l_tabix = 193.
**              gv_carryfwd16 = gv_carryfwd15 + regud-wabzg.
**            ELSE.
**              gv_carryfwd16 = gv_carryfwd16 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '18'.
**            IF l_tabix = 205.
**              gv_carryfwd17 = gv_carryfwd16 + regud-wabzg.
**            ELSE.
**              gv_carryfwd17 = gv_carryfwd17 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '19'.
**            IF l_tabix = 217.
**              gv_carryfwd18 = gv_carryfwd17 + regud-wabzg.
**            ELSE.
**              gv_carryfwd18 = gv_carryfwd18 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '20'.
**            IF l_tabix = 229.
**              gv_carryfwd19 = gv_carryfwd18 + regud-wabzg.
**            ELSE.
**              gv_carryfwd19 = gv_carryfwd19 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '21'.
**            IF l_tabix = 241.
**              gv_carryfwd20 = gv_carryfwd19 + regud-wabzg.
**            ELSE.
**              gv_carryfwd20 = gv_carryfwd20 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '22'.
**            IF l_tabix = 253.
**              gv_carryfwd21 = gv_carryfwd20 + regud-wabzg.
**            ELSE.
**              gv_carryfwd21 = gv_carryfwd21 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '23'.
**            IF l_tabix = 265.
**              gv_carryfwd22 = gv_carryfwd21 + regud-wabzg.
**            ELSE.
**              gv_carryfwd22 = gv_carryfwd22 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '24'.
**            IF l_tabix = 277.
**              gv_carryfwd23 = gv_carryfwd22 + regud-wabzg.
**            ELSE.
**              gv_carryfwd23 = gv_carryfwd23 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '25'.
**            IF l_tabix = 289.
**              gv_carryfwd24 = gv_carryfwd23 + regud-wabzg.
**            ELSE.
**              gv_carryfwd24 = gv_carryfwd24 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '26'.
**            IF l_tabix = 301.
**              gv_carryfwd25 = gv_carryfwd24 + regud-wabzg.
**            ELSE.
**              gv_carryfwd25 = gv_carryfwd25 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '27'.
**            IF l_tabix = 313.
**              gv_carryfwd26 = gv_carryfwd25 + regud-wabzg.
**            ELSE.
**              gv_carryfwd26 = gv_carryfwd26 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '28'.
**            IF l_tabix = 325.
**              gv_carryfwd27 = gv_carryfwd26 + regud-wabzg.
**            ELSE.
**              gv_carryfwd27 = gv_carryfwd27 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '29'.
**            IF l_tabix = 337.
**              gv_carryfwd28 = gv_carryfwd27 + regud-wabzg.
**            ELSE.
**              gv_carryfwd28 = gv_carryfwd28 + regud-wabzg.
**            ENDIF.
**
**          WHEN  '30'.
**            IF l_tabix = 349.
**              gv_carryfwd29 = gv_carryfwd28 + regud-wabzg.
**            ELSE.
**              gv_carryfwd29 = gv_carryfwd29 + regud-wabzg.
**            ENDIF.
****
**        ENDCASE.
**
**        gv_wabzg = gv_wabzg + regud-wabzg.
**
***       Ausgabe der Einzelposten, falls kein Avishinweis erforderl. war
***       single item information if no advice note
**        IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
**          regud-txthr = regup-sgtxt.
*** Counting the numbers of lines going out in the main window.
*** This must be counted so we have available space for the same
*** lines in the the ZMAIN window. THIS MUST ONLY BE CHANGES IF THE MAIN
*** WINDOW IN THE SCRIPT IS RESIZED
**          gv_count = gv_count + 1.
**          IF gv_count LE 13.
**            PERFORM scheckavis_zeile.
**          ELSE.
**
**            CLEAR gv_count.
*** Creates one temporary page for each MAIN page
**            WRITE gv_page_count TO gv_string.
**            CONCATENATE gw_thead-tdname(17) gv_string INTO gw_thead-tdname.
**            CONDENSE gw_thead-tdname NO-GAPS.
**
*** Saves the temporary page
**            CALL FUNCTION 'SAVE_TEXT'
**              EXPORTING
**                header = gw_thead
**              TABLES
**                lines  = gt_tline.
**
**            CLEAR gt_tline.
**            REFRESH gt_tline.
***----------------------------------------------------------------------|
*** Begin of changes by 477670  |PTP.FRM.002 | D4SK905470   |20-AUG-2019 |
***----------------------------------------------------------------------|
**
**            CALL FUNCTION 'WRITE_FORM'
**              EXPORTING
**                window  = 'ZMAIN'
**                element = '1'
**              EXCEPTIONS
**                window  = 1
**                element = 2.
**
***----------------------------------------------------------------------|
*** End of changes by 477670  |PTP.FRM.002 | D4SK905470   |20-AUG-2019   |
***----------------------------------------------------------------------|
**            gv_page_count = gv_page_count + 1.
*** IF gv_balance_forward FLAG are set write out the balances on the top
*** of the next page
**            IF gv_balance_forward EQ 'X'.
**
**              WRITE regud-swnet TO gv_swnet_temp.
**              WRITE regud-swrbt TO gv_swrbt_temp.
**              WRITE gv_carryfwd TO gv_swskt_temp.
**              WRITE 'T1' TO gt_tline-tdformat.
**              CONCATENATE ',,<B>Balances carried forward</>.........'
**                          ',,,,,,<M>' gv_swrbt_temp '</>' ',,<M>'
**                          gv_swskt_temp '</>' ',,<m>'
**                           gv_swnet_temp '</>' INTO gt_tline-tdline.
**              APPEND gt_tline.
**              CLEAR gt_tline.
**              gv_count = gv_count + 1.
**            ENDIF.
**            PERFORM scheckavis_zeile.
**            gv_count = gv_count + 1.
**          ENDIF.
**          IF hlp_page = 2.
**            IF l_tabix EQ 24.
**              gv_carryfwd = gv_carryfwd1.
**            ENDIF.
**          ELSEIF hlp_page = 3.
**            IF l_tabix EQ 36.
**              gv_carryfwd = gv_carryfwd2.
**            ENDIF.
**          ELSEIF hlp_page = 4.
**            IF l_tabix EQ 48.
**              gv_carryfwd = gv_carryfwd3.
**            ENDIF.
**          ELSEIF hlp_page = 5.
**            IF l_tabix EQ 60.
**              gv_carryfwd = gv_carryfwd4.
**            ENDIF.
**          ELSEIF hlp_page = 6.
**            IF l_tabix EQ 72.
**              gv_carryfwd = gv_carryfwd5.
**            ENDIF.
**          ELSEIF hlp_page = 7.
**            IF l_tabix EQ 84.
**              gv_carryfwd = gv_carryfwd6.
**            ENDIF.
**          ELSEIF hlp_page = 8.
**            IF l_tabix EQ 96.
**              gv_carryfwd = gv_carryfwd7.
**            ENDIF.
**          ELSEIF hlp_page = 9.
**            IF l_tabix EQ 108.
**              gv_carryfwd = gv_carryfwd8.
**            ENDIF.
**          ELSEIF hlp_page = 10.
**            IF l_tabix EQ 120.
**              gv_carryfwd = gv_carryfwd9.
**            ENDIF.
**
**          ELSEIF hlp_page = 11.
**            IF l_tabix EQ 132.
**              gv_carryfwd = gv_carryfwd10.
**            ENDIF.
**
**          ELSEIF hlp_page = 12.
**            IF l_tabix EQ 144.
**              gv_carryfwd = gv_carryfwd11.
**            ENDIF.
**
**          ELSEIF hlp_page = 13.
**            IF l_tabix EQ 156.
**              gv_carryfwd = gv_carryfwd12.
**            ENDIF.
**
**          ELSEIF hlp_page = 14.
**            IF l_tabix EQ 168.
**              gv_carryfwd = gv_carryfwd13.
**            ENDIF.
**
**          ELSEIF hlp_page = 15.
**            IF l_tabix EQ 180.
**              gv_carryfwd = gv_carryfwd14.
**            ENDIF.
**
**          ELSEIF hlp_page = 16.
**            IF l_tabix EQ 192.
**              gv_carryfwd = gv_carryfwd15.
**            ENDIF.
**
**          ELSEIF hlp_page = 17.
**            IF l_tabix EQ 204.
**              gv_carryfwd = gv_carryfwd16.
**            ENDIF.
**
**          ELSEIF hlp_page = 18.
**            IF l_tabix EQ 216.
**              gv_carryfwd = gv_carryfwd17.
**            ENDIF.
**
**          ELSEIF hlp_page = 19.
**            IF l_tabix EQ 228.
**              gv_carryfwd = gv_carryfwd18.
**            ENDIF.
**
**          ELSEIF hlp_page = 20.
**            IF l_tabix EQ 240.
**              gv_carryfwd = gv_carryfwd19.
**            ENDIF.
**
**          ELSEIF hlp_page = 21.
**            IF l_tabix EQ 252.
**              gv_carryfwd = gv_carryfwd20.
**            ENDIF.
**
**          ELSEIF hlp_page = 22.
**            IF l_tabix EQ 264.
**              gv_carryfwd = gv_carryfwd21.
**            ENDIF.
**
**          ELSEIF hlp_page = 23.
**            IF l_tabix EQ 276.
**              gv_carryfwd = gv_carryfwd22.
**            ENDIF.
**
**          ELSEIF hlp_page = 24.
**            IF l_tabix EQ 288.
**              gv_carryfwd = gv_carryfwd23.
**            ENDIF.
**
**          ELSEIF hlp_page = 25.
**            IF l_tabix EQ 300.
**              gv_carryfwd = gv_carryfwd24.
**            ENDIF.
**
**          ELSEIF hlp_page = 26.
**            IF l_tabix EQ 312.
**              gv_carryfwd = gv_carryfwd25.
**            ENDIF.
**
**          ELSEIF hlp_page = 27.
**            IF l_tabix EQ 324.
**              gv_carryfwd = gv_carryfwd26.
**            ENDIF.
**
**          ELSEIF hlp_page = 28.
**            IF l_tabix EQ 336.
**              gv_carryfwd = gv_carryfwd27.
**            ENDIF.
**
**          ELSEIF hlp_page = 29.
**            IF l_tabix EQ 348.
**              gv_carryfwd = gv_carryfwd28.
**            ENDIF.
**
**          ELSEIF hlp_page = 30.
**            IF l_tabix EQ 360.
**              gv_carryfwd = gv_carryfwd29.
**            ENDIF.
****
**          ENDIF.
**        ENDIF.
**        PERFORM summenfelder_fuellen.
**
**        IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element  = '525-TX'
**              function = 'APPEND'
**            EXCEPTIONS
**              window   = 1
**              element  = 2.
**        ENDIF.
**      ENDIF.
**
***     Angabentabelle für die OeNB-Meldung (Österreich)
**      IF t042e-xausl = 'X'.            "nur Auslandsscheck
**        CLEAR up_oenb_angaben.
**        up_oenb_angaben-diekz = regup-diekz.
**        up_oenb_angaben-lzbkz = regup-lzbkz.
**        up_oenb_angaben-summe = regud-netto.
**        COLLECT up_oenb_angaben.
**      ENDIF.
**    ENDAT.
**
***-- Ende der Zahlungsbelegnummer ---------------------------------------
***-- end of payment document number -------------------------------------
**    AT END OF reguh-vblnr.
**      .
**
**      IF flg_kein_druck EQ 0.
**
***       Zahlbetrag ohne Aufbereitungszeichen für Codierzeile speichern
***       store numerical payment amount for code line
**        IF reguh-waers EQ t001-waers.
**          regud-socra = regud-swnes.
**        ELSE.
**          regud-socra = 0.
**          PERFORM laender_lesen USING t001-land1.
**          IF t005-intca EQ 'DE'.
**            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
**            IF hlp_waers EQ 'DEM' OR hlp_waers EQ 'EUR'.
**              regud-socra = regud-swnes.
**            ENDIF.
**          ENDIF.
**          IF t005-intca EQ 'AT'.
**            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
**            IF hlp_waers EQ 'ATS' OR hlp_waers EQ 'EUR'.
**              regud-socra = regud-swnes.
**            ENDIF.
**          ENDIF.
**        ENDIF.
**        IF reguh-waers EQ t012k-waers.
**          regud-socrb = regud-swnes.
**        ELSE.
**          regud-socrb = 0.
**        ENDIF.
**
**        PERFORM ziffern_in_worten.
**
***       Summenfelder hochzählen und aufbereiten
***       add up total amount fields
**        ADD 1            TO cnt_formulare.
**        ADD reguh-rbetr  TO sum_abschluss.
**        WRITE:
**          cnt_hinweise   TO regud-avish,
**          cnt_formulare  TO regud-zahlt,
**          sum_abschluss  TO regud-summe CURRENCY t001-waers.
**        TRANSLATE:
**          regud-avish USING ' *',
**          regud-zahlt USING ' *',
**          regud-summe USING ' *'.
**
**        IF hlp_xhrfo EQ space.
**
*** Nur für Brasilien (Check auf Land liegt in Funktionsbaustein)
*** Only Brazil (Check on country within the function module)
**
**          CALL FUNCTION 'BOLETO_DATA'
**            EXPORTING
**              line_reguh = reguh
**            TABLES
**              itab_regup = tab_regup
**            CHANGING
**              line_regud = regud.
**
**          CALL FUNCTION 'KOREA_DATA'
**            EXPORTING
**              line_reguh = reguh
**            TABLES
**              itab_regup = tab_regup
**            CHANGING
**              line_regud = regud.
**
**
***         Hauptfenster, Element Gesamtsumme (nur auf der letzten Seite)
***         main window, element total (only last page)
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'CARRYFWD'
**              element = '530'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
***----------------------------------------------------------------------|
*** Begin of changes by 477670  |PTP.FRM.002 | D4SK903597   |09-JUL-2019 |
***----------------------------------------------------------------------|
***for checking if amount is greater than $10K, then only two signature
***      lines should be printed in the form
**          CLEAR gv_flag.              "Changes D4SK907604
**          IF regud-swnet GE lc_10k .
**            gv_flag =  'X'.
**          ENDIF.
***----------------------------------------------------------------------|
*** End of changes by 477670  |PTP.FRM.002 | D4SK903597   |09-JUL-2019   |
***----------------------------------------------------------------------|
****for check number
**          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**            EXPORTING
**              input  = regud-chect
**            IMPORTING
**              output = gv_check_num.
**
**          "payer name
**          regud-abstx = t001-butxt.
**
**          IF sy-subrc EQ 0.
**            WRITE 'X' TO gv_total_flag.
**
**            WRITE regud-swnet TO gv_swnet_tot.
**
*** For Company Code 3000 and Currency CAD $ should not be
*** printed in the check
**            IF reguh-zbukr =  gc_3000 AND         "DFT1POST-239 | D4SK906650
**               regud-waers EQ gc_cad.
**              CONDENSE gv_swnet_tot NO-GAPS.
**              SHIFT gv_swnet_tot RIGHT DELETING TRAILING space.
**              TRANSLATE gv_swnet_tot USING ' *'.
**            ELSE.
**              CONCATENATE '$' gv_swnet_tot INTO gv_swnet_tot.
**              CONDENSE gv_swnet_tot NO-GAPS.
**              SHIFT gv_swnet_tot RIGHT DELETING TRAILING space.
**              TRANSLATE gv_swnet_tot USING ' *'.
**            ENDIF.
**
**          ELSEIF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'MAIN'.
**            err_element-elemt = '530'.
**            err_element-text  = text_530.
**            COLLECT err_element.
**          ENDIF.
**
***         Vornumerierte Schecks: Schecknummer hochzählen ab 2.Seite
***         prenumbered checks: add 1 to check number
**          IF flg_schecknum EQ 1.
**            CALL FUNCTION 'GET_TEXTSYMBOL'
**              EXPORTING
**                line         = '&PAGE&'
**                start_offset = 0
**              IMPORTING
**                value        = hlp_page.
**            IF hlp_page NE hlp_seite.
**              hlp_seite = hlp_page.
**              PERFORM schecknummer_addieren.
**            ENDIF.
**          ENDIF.
**
***         Alternativ: Fenster Total, Element Gesamtsumme
***         alternatively: window total, element total
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'TOTAL'
**              element = '530'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2 AND
**            (  err_element-fname NE t042e-zforn
**            OR err_element-fenst NE 'MAIN'
**            OR err_element-elemt NE '530' ).
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'TOTAL'.
**            err_element-elemt = '530'.
**            err_element-text  = text_530.
**            COLLECT err_element.
**          ENDIF.
**
***         Fenster Carry Forward, Element Übertrag löschen
***         window carryfwd, delete element carry forward below
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window   = 'CARRYFWD'
**              element  = '535'
**              function = 'DELETE'
**            EXCEPTIONS
**              window   = 1       "Fehler bereits oben gemerkt
**              element  = 2.      "error already noted
**
***         Hauptfenster, Element Überschrift löschen
***         main window, delete element title
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element  = '515'
**              type     = 'TOP'
**              function = 'DELETE'
**            EXCEPTIONS
**              window   = 1       "Fehler bereits oben gemerkt
**              element  = 2.      "error already noted
**
***         Hauptfenster, Element Übertrag löschen
***         main window, delete element carry forward above
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              element  = '520'
**              type     = 'TOP'
**              function = 'DELETE'
**            EXCEPTIONS
**              window   = 1       "Fehler bereits oben gemerkt
**              element  = 2.      "error already noted
**
**        ENDIF.
**
***       Fenster Check, Element Entwerteter Scheck löschen
***       window check, delete element voided check
**        CALL FUNCTION 'WRITE_FORM'
**          EXPORTING
**            window   = 'CHECK'
**            element  = '540'
**            function = 'DELETE'
**          EXCEPTIONS
**            window   = 1         "Fehler bereits oben gemerkt
**            element  = 2.        "error already noted
**
**        CALL FUNCTION 'WRITE_FORM'
**          EXPORTING
**            window   = 'ZMAIN'
**            element  = '1'
**            function = 'DELETE'
**          EXCEPTIONS
**            window   = 1
**            element  = 2.
**
**        PERFORM check_foreign_currency.
**
***       Fenster Check, Element Echter Scheck (nur auf letzte Seite)
***       window check, element genuine check (only last page)
**        IF t042z-xeinz EQ space.
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'CHECKSPL'
**              element = '545'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**
**
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'CHECK'
**              element = '545'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'CHECK'.
**            err_element-elemt = '545'.
**            err_element-text  = text_545.
**            COLLECT err_element.
**          ENDIF.
**        ELSE.                          "debitorische Wechsel Frankreich
**          CALL FUNCTION 'WRITE_FORM'   "bills of exchange to debitors
**            EXPORTING               "(France)
**              window  = 'CHECKSPL'
**              element = '546'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'CHECK'
**              element = '546'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**          IF sy-subrc EQ 2.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'CHECK'.
**            err_element-elemt = '546'.
**            err_element-text  = text_546.
**            COLLECT err_element.
**          ENDIF.
**        ENDIF.
**
***       Angabenteil für die OeNB-Meldung (Österreich)
***       Austria only
**        IF t042e-xausl NE space        "Auslandsscheck, nicht Pfändung
**        AND NOT ( hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' ).
**          CLEAR:
**            regud-x08, regud-x10, regud-x11, regud-x12, regud-x13,
**            regud-text1, regud-zwck1, regud-zwck2.
**          IF up_oenb_kontowae-uwaer EQ 'ATS'.
**            regud-x08   = 'X'.
**          ELSE.
**            regud-text1 = up_oenb_kontowae-uwaer.
**          ENDIF.
**          SORT up_oenb_angaben BY summe DESCENDING.
**          READ TABLE up_oenb_angaben INDEX 1.
**          CASE up_oenb_angaben-diekz.
**            WHEN space.
**              regud-x10 = 'X'.
**            WHEN 'I'.
**              regud-x10 = 'X'.
**            WHEN 'R'.
**              regud-x11 = 'X'.
**            WHEN 'K'.
**              regud-x12 = 'X'.
**            WHEN OTHERS.
**              regud-x13 = 'X'.
**              PERFORM read_scb_indicator USING up_oenb_angaben-lzbkz.
**              regud-zwck1 = t015l-zwck1.
**              regud-zwck2 = t015l-zwck2.
**          ENDCASE.
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'ORDERS'
**              element = '550'
**            EXCEPTIONS
**              window  = 1
**              element = 2.
**        ENDIF.
**        CLEAR gv_count.
**
**        WRITE gv_page_count TO gv_string.
**        CONCATENATE gw_thead-tdname(17) gv_string INTO gw_thead-tdname.
**        CONDENSE gw_thead-tdname NO-GAPS.
**
**        CALL FUNCTION 'SAVE_TEXT'
**          EXPORTING
**            header = gw_thead
**          TABLES
**            lines  = gt_tline.
**        CLEAR gt_tline.
**        REFRESH gt_tline.
**
**        CALL FUNCTION 'WRITE_FORM'
**          EXPORTING
**            window  = 'ZMAIN'
**            element = '1'
**          EXCEPTIONS
**            window  = 1
**            element = 2.
*** When we print out more than one check, do we have to store the item
*** lines with a new name in the text memory.
**        gv_page_count = gv_page_count + 1.
**
***       Formular beenden
***       end check form
**        CALL FUNCTION 'END_FORM'
**          IMPORTING
**            result = itcpp.
**        IF itcpp-tdpages EQ 0.         "Print via RDI
**          itcpp-tdpages = 1.
**        ENDIF.
**        cnt_seiten = itcpp-tdpages.    "für vornumerierte Schecks
**        "for prenumbered checks
**        IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
**          PERFORM scheckinfo_speichern USING 2.
**        ENDIF.
***         Delete the texts before we write them to the text file
**        CALL FUNCTION 'DELETE_TEXT'
**          EXPORTING
**            id              = 'ST'
**            language        = 'E'
**            name            = 'ZCHECK_PRINT*'
**            object          = 'TEXT'
**            savemode_direct = ' '
**            textmemory_only = ' '
**          EXCEPTIONS
**            not_found       = 1
**            OTHERS          = 2.
**
**        CLEAR gv_total_flag.
**        CALL FUNCTION 'CLOSE_FORM'
**          IMPORTING
**            result = itcpp.
**
**        IF itcpp-tdspoolid NE 0.
**          CLEAR tab_ausgabe.
**          tab_ausgabe-name    = t042z-text1.
**          tab_ausgabe-dataset = itcpp-tddataset.
**          tab_ausgabe-spoolnr = itcpp-tdspoolid.
**          tab_ausgabe-immed   = par_sofz.
**          COLLECT tab_ausgabe.
**        ENDIF.
**      ENDIF.
**
**      CLEAR: gv_wabzg,gv_carryfwd.
**
**    ENDAT.
**
***-- Ende der Hausbank --------------------------------------------------
***-- end of house bank --------------------------------------------------
**    AT END OF reguh-ubnkl.
**
**      IF cnt_formulare NE 0.           "Formularabschluß erforderlich
**        "summary necessary
**        IF hlp_laufk NE '*'            "kein Onlinedruck
**                                       "no online check print
**          AND par_nosu EQ space.       "Formularabschluß gewünscht
**          "summary requested
***         Formular für den Abschluß starten
***         start form for summary
**          SET COUNTRY space.
**          IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
**          itcpo-tdnewid = space.
**          CALL FUNCTION 'OPEN_FORM'
**            EXPORTING
**              form     = t042e-zforn
**              device   = 'PRINTER'
**              language = t001-spras
**              options  = itcpo
**              dialog   = space.
**          CALL FUNCTION 'START_FORM'
**            EXPORTING
**              startpage = 'LAST'
**              language  = t001-spras.
**
***         Vornumerierte Schecks: letzte Schecknummer ermitteln
***         prenumbered checks: compute last check number
**          IF flg_schecknum EQ 1.
**            PERFORM schecknummer_ermitteln USING 3.
**          ENDIF.
**
***         Ausgabe des Formularabschlusses
***         print summary
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window = 'SUMMARY'
**            EXCEPTIONS
**              window = 1.
**          IF sy-subrc EQ 1.
**            err_element-fname = t042e-zforn.
**            err_element-fenst = 'SUMMARY'.
**            err_element-elemt = space.
**            err_element-text  = space.
**            COLLECT err_element.
**          ENDIF.
**
***         Fenster Scheck, Element Entwertet
***         window check, element voided check
**          CALL FUNCTION 'WRITE_FORM'
**            EXPORTING
**              window  = 'CHECK'
**              element = '540'
**            EXCEPTIONS
**              window  = 1        "Fehler bereits oben gemerkt
**              element = 2.       "error already noted
**
***         Formular für den Abschluß beenden
***         end form for summary
**          CALL FUNCTION 'END_FORM'
**            IMPORTING
**              result = itcpp.
**          IF itcpp-tdpages EQ 0.       "Print via RDI
**            itcpp-tdpages = 1.
**          ENDIF.
**          cnt_seiten = itcpp-tdpages.  "für vornumerierte Schecks
**          "for prenumbered checks
**          IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
**            PERFORM scheckinfo_speichern USING 3.
**          ENDIF.
**
***         Abschluß des Formulars
***         close form
**          CALL FUNCTION 'CLOSE_FORM'
**            IMPORTING
**              result = itcpp.
**
**          IF itcpp-tdspoolid NE 0.
**            CLEAR tab_ausgabe.
**            tab_ausgabe-name    = t042z-text1.
**            tab_ausgabe-dataset = itcpp-tddataset.
**            tab_ausgabe-spoolnr = itcpp-tdspoolid.
**            tab_ausgabe-immed   = par_sofz.
**            COLLECT tab_ausgabe.
**          ENDIF.
**
**        ENDIF.
**
**      ENDIF.
**
**    ENDAT.
**
**  ENDLOOP.
**
**  hlp_ep_element = '525'.
**
**ENDFORM.                               "Scheck
**
**
**
**************************************************************************
***                                                                      *
***  subroutines for prenumbered checks                                  *
***                                                                      *
***  subroutine                                called by / in subroutine *
***  ------------------------------------------------------------------- *
***  SCHECKDATEN_EINGABE (check data input on screen)   SELECTION-SCREEN *
***  SCHECKDATEN_PRUEFEN (check data before start)    START-OF-SELECTION *
***  SCHECKINFO_PRUEFEN (test of check information)            GET REGUH *
***  SCHECKNUMMERN_SPERREN (enqueue check numbers)      END-OF-SELECTION *
***  SCHECKNUMMER_ERMITTELN (find out check number)               SCHECK *
***  SCHECKAVIS_ZEILE (one line on the check advice)              SCHECK *
***  SCHECKS_ADDIEREN (add 1 to check number)    SCHECKAVIS_ZEILE,SCHECK *
***  SCHECKS_UMNUMERIEREN (renumber checks)       SCHECKNUMMER_ERMITTELN *
***  SCHECKINFO_SPEICHERN (store check information)               SCHECK *
***  SCHECK_ENTWERTEN (void check in restart mode)  SCHECKINFO_SPEICHERN *
***  SCHECKNUMMERN_ENTSPERREN (dequeue check numbers)   END-OF-SELECTION *
***  SCHECKDRUCK_MAIL (send mail) SCHECKNUMMERN_SPERREN,SELECTION-SCREEN *
***                                                                      *
**************************************************************************
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKDATEN_EINGABE                                             *
***----------------------------------------------------------------------*
*** Prüfen der Eingabedaten auf dem Selektionsbild                       *
*** Check the input data on the selection screen                         *
***----------------------------------------------------------------------*
*** P_RCHK  Restart-Schecknummer                                         *
*** P_STAP  Stapel                                                       *
*** P_INFO  Info zum Stapel                                              *
***----------------------------------------------------------------------*
**FORM scheckdaten_eingabe USING p_rchk LIKE pcec-checl
**                               p_stap LIKE pcec-stapl
**                               p_info TYPE c.
**
**  DESCRIBE TABLE zw_zbukr LINES hlp_zeilen.
**  IF hlp_zeilen NE 1.                  "genau ein Buchungskreis
**    SET CURSOR FIELD 'ZW_ZBUKR-LOW'.   "exactly one company code
**    MESSAGE e543(fs).
**  ELSE.
**    READ TABLE zw_zbukr INDEX 1.
**    IF zw_zbukr-option NE 'EQ' OR zw_zbukr-sign NE 'I'.
**      SET CURSOR FIELD 'ZW_ZBUKR-LOW'.
**      MESSAGE e543(fs).
**    ENDIF.
**  ENDIF.
**  "genau eine Hausbank
**  READ TABLE sel_hbki INDEX 1.         "exactly one house bank
**  IF sy-subrc NE 0 OR sel_hbki-option NE 'EQ' OR sel_hbki-sign NE 'I'.
**    SET CURSOR FIELD 'SEL_HBKI-LOW'.
**    MESSAGE e544(fs).
**  ENDIF.
**  "genau eine Kontenverbindung
**  READ TABLE sel_hkti INDEX 1.         "exactly one bank account
**  IF sy-subrc NE 0 OR sel_hkti-option NE 'EQ' OR sel_hkti-sign NE 'I'.
**    SET CURSOR FIELD 'SEL_HKTI-LOW'.
**    MESSAGE e545(fs).
**  ENDIF.
**
**  IF zw_xvorl EQ space.                "Echtlauf
**    "production run
**    IF p_rchk NE space.                "Restartfall
**      p_stap = 0.                      "restart mode
**      p_info = space.
**      SELECT * FROM payr               "Restartnummer muß vorhanden sein
**        WHERE zbukr EQ zw_zbukr-low    "und zum angegebenen Zahllauf
**          AND hbkid EQ sel_hbki-low    "gehören
**          AND hktid EQ sel_hkti-low    "restart number has to exist in
**          AND rzawe IN sel_zawe        "PAYR and has to belong to this
**          AND chect GE p_rchk          "payment run
**          AND checf EQ p_rchk.                            "#EC PORTABLE
**      ENDSELECT.
**      IF sy-subrc NE 0.
**        SET CURSOR FIELD 'PAR_RCHK'.
**        MESSAGE e562(fs).
**      ENDIF.
**      IF ( zw_laufd NE payr-laufd OR zw_laufi NE payr-laufi )
**        AND zw_laufi+5(1) NE '*'.
**        SET CURSOR FIELD 'PAR_RCHK'.
**        MESSAGE e563(fs).
**      ENDIF.
**      IF payr-checv NE space.          "gab es beim Restartscheck einen
**        SELECT SINGLE * FROM payr      "Seitenüberlauf?
**          WHERE zbukr EQ payr-zbukr    "was there an overflow with the
**            AND hbkid EQ payr-hbkid    "first restart check?
**            AND hktid EQ payr-hktid
**            AND rzawe EQ payr-rzawe
**            AND chect EQ payr-checv.
**        IF payr-voidr EQ 2.
**          p_rchk = payr-checf.         "Parameter korrigieren
**        ENDIF.                         "correct parameter
**      ENDIF.
**      IF payr-voidr EQ 3.              "Formularabschluß, also nichts
**        SET CURSOR FIELD 'PAR_RCHK'.   "summary => nothing to be printed
**        MESSAGE e571(fs).
**      ENDIF.
**    ELSE.                              "neue Schecks
**      IF par_zdru NE space.            "new checks
**        IF p_stap IS INITIAL.
**          p_info = space.
**          SET CURSOR FIELD 'PAR_STAP'.
**          IF zw_laufi+5(1) EQ '*'.
**            PERFORM scheckdruck_mail.
**            MESSAGE a577(fs) WITH '546' space.
**          ELSE.
**            MESSAGE e546(fs).
**          ENDIF.                       "Stapelnummer muß angegeben
**        ELSE.                          "werden, vorhanden sein und eine
**          CALL FUNCTION 'LOT_CHECK'    "gültige letzte vergebene Nummer
**            EXPORTING                  "haben (ggf. in Folgestapel)
**              i_zbukr = zw_zbukr-low   "lot number has to be filled, has
**              i_hbkid = sel_hbki-low   "to exist and must have a valid
**              i_hktid = sel_hkti-low   "last number, perhaps in next lot
**              i_stapl = p_stap
**            IMPORTING
**              e_stapl = p_stap
**              e_stapi = pcec-stapi
**              e_zwels = pcec-zwels
**            EXCEPTIONS
**              OTHERS  = 4.
**          p_info = pcec-stapi.
**          IF sy-subrc NE 0.
**            p_info = space.
**            SET CURSOR FIELD 'PAR_STAP'.
**            IF zw_laufi+5(1) EQ '*'.
**              PERFORM scheckdruck_mail.
**              fimsg-msgno = sy-msgno.
**              fimsg-msgv1 = sy-msgv1.
**              MESSAGE a577(fs) WITH fimsg-msgno fimsg-msgv1.
**            ELSE.
**              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1.
**            ENDIF.
**          ELSE.
**            IF pcec-zwels NE space.
**              SELECT SINGLE * FROM t001 WHERE bukrs EQ zw_zbukr-low.
**              SELECT * FROM t042z WHERE land1 EQ t001-land1
**                                  AND   zlsch IN sel_zawe
**                                  AND   progn EQ sy-repid.
**                IF pcec-zwels NA t042z-zlsch.
**                  MESSAGE e665(fs) WITH t042z-zlsch p_stap pcec-zwels.
**                ENDIF.
**              ENDSELECT.
**            ENDIF.
**            p_info = pcec-stapi.
**          ENDIF.
**        ENDIF.
**      ELSE.
**        p_stap = 0.
**        p_info = space.
**      ENDIF.
**    ENDIF.
**
**  ELSE.                                "Vorschlagslauf
**    "proposal run
**    IF p_rchk NE space.
**      SET CURSOR FIELD 'ZW_XVORL'.
**      MESSAGE e561(fs).                "kein Restart bei Vorschlagslauf
**    ENDIF.                             "no restart mode if proposal run
**    p_stap = 0.
**    p_info = space.
**
**  ENDIF.
**
**ENDFORM.                               "Scheckdaten Eingabe
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKDATEN_PRUEFEN                                             *
***----------------------------------------------------------------------*
*** Prüfen der Eingabedaten vor der Datenselektion                       *
*** Check the input data before the selection of data                    *
***----------------------------------------------------------------------*
*** P_RCHK  Restart-Schecknummer                                         *
*** P_STAP  Stapel                                                       *
***----------------------------------------------------------------------*
**FORM scheckdaten_pruefen USING p_rchk LIKE pcec-checl
**                               p_stap LIKE pcec-stapl.
**
**  REFRESH tab_check.
**  flg_schecknum = 1.
**  flg_pruefung  = 1.                   "Scheckinfo i.a. prüfen
**  "check check info (in general)
**  IF zw_xvorl EQ space AND par_zdru NE space. "Scheckdruck für Echtlauf
**    "check print for a productive run
**    IF p_rchk NE space.                "Restartfall
**      flg_restart = 1.                 "restart mode
**      SELECT * FROM payr
**        WHERE zbukr EQ zw_zbukr-low
**          AND hbkid EQ sel_hbki-low
**          AND hktid EQ sel_hkti-low
**          AND rzawe IN sel_zawe
**          AND chect GE p_rchk
**          AND checf EQ p_rchk.                            "#EC PORTABLE
**      ENDSELECT.
**      CASE payr-voidr.
**        WHEN 0.
**          hlp_checf_restart = p_rchk.
**        WHEN 1.                        "vollständiger Restart
**          flg_restart = 2.             "complete restart
**          CALL FUNCTION 'COMPARE_CHECK_NUMBERS'
**            EXPORTING
**              i_check1   = payr-checf
**              i_check2   = payr-chect
**            IMPORTING
**              e_distance = par_anzp.
**          ADD 1 TO par_anzp.
**        WHEN 2.
**          hlp_checf_restart = payr-checv.
**      ENDCASE.
**      tab_check-sign   = 'I'.
**      tab_check-option = 'BT'.
**      CALL FUNCTION 'GET_CHECK_INTERVAL'
**        EXPORTING
**          i_zbukr = zw_zbukr-low
**          i_hbkid = sel_hbki-low
**          i_hktid = sel_hkti-low
**          i_check = p_rchk
**        IMPORTING
**          e_pcec  = pcec
**        EXCEPTIONS
**          OTHERS  = 4.
**      pcec-checf = p_rchk.
**      IF sy-subrc NE 0.
**        CLEAR pcec-fstap.
**        IF '9' GT 'Z'.                                    "#EC PORTABLE
**          pcec-chect = '9999999999999'.
**        ELSE.
**          pcec-chect = 'ZZZZZZZZZZZZZ'.
**        ENDIF.
**      ENDIF.
**      DO.
**        tab_check-low  = pcec-checf.
**        tab_check-high = pcec-chect.
**        APPEND tab_check.
**        IF pcec-fstap IS INITIAL.
**          EXIT.
**        ENDIF.
**        SELECT SINGLE * FROM pcec
**          WHERE zbukr EQ pcec-zbukr
**            AND hbkid EQ pcec-hbkid
**            AND hktid EQ pcec-hktid
**            AND stapl EQ pcec-fstap.
**        IF sy-subrc NE 0.
**          EXIT.
**        ENDIF.
**      ENDDO.
**    ELSE.                              "neue Schecks
**      IF sy-batch NE space.            "new checks
**        CALL FUNCTION 'LOT_CHECK'
**          EXPORTING
**            i_zbukr = zw_zbukr-low
**            i_hbkid = sel_hbki-low
**            i_hktid = sel_hkti-low
**            i_stapl = p_stap
**          IMPORTING
**            e_stapl = p_stap
**          EXCEPTIONS
**            OTHERS  = 4.
**        IF sy-subrc NE 0.
**          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1.
**          STOP.
**        ENDIF.
**      ENDIF.
**      SELECT SINGLE * FROM pcec
**        WHERE zbukr EQ zw_zbukr-low
**          AND hbkid EQ sel_hbki-low
**          AND hktid EQ sel_hkti-low
**          AND stapl EQ p_stap.
**    ENDIF.
**    IMPORT flg_local FROM MEMORY ID 'MFCHKFN0'.
**    IF sy-subrc EQ 0.                  "bei Transaktion 'Scheck neu
**      flg_pruefung = 0.                "drucken' Pruefung ausschalten
**    ENDIF.                             "no check when 'reprint check'
**
**  ELSE.                                "Vorschlagslauf oder nur Avise
**    "proposal run or only advices
**    pcec-mandt = sy-mandt.             "Testdaten erhalten Dummy-Scheck-
**    pcec-zbukr = zw_zbukr-low.         "nummern, die nicht in PAYR abge-
**    pcec-hbkid = sel_hbki-low.         "speichert werden
**    pcec-hktid = sel_hkti-low.         "test checks get dummy check
**    pcec-stapl = 1.                    "numbers, not stored in PAYR
**    pcec-checf = 'TEST000000001'.
**    pcec-chect = 'TEST999999999'.
**    pcec-fstap = 0.
**    pcec-checl = space.
**
**  ENDIF.
**
**ENDFORM.                               "Scheckdaten prüfen
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKINFO_PRUEFEN                                              *
***----------------------------------------------------------------------*
*** Prüfen, ob die Belegnummer bereits in PAYR gespeichert ist           *
*** test that payment document number is already stored in PAYR          *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM scheckinfo_pruefen.
**
**  IF t042z-xnopo NE space.             "keine Zahlungsaufträge erlaubt
**    IF sy-batch EQ space.              "im Scheckmanagement
**      MESSAGE a071(f3).                "payment orders are not allowed
**    ELSE.                              "in the check management
**      MESSAGE s071(f3).
**      MESSAGE s549(fs).
**      flg_selektiert = 0.
**      STOP.
**    ENDIF.
**  ENDIF.
**
**  CLEAR payr.
**  CHECK:
**    par_zdru NE space,                 "nur bei Scheckdruck
**                                       "only if checks are to be printed
**    zw_xvorl EQ space,                 "nur bei Echtlauf
**                                       "only after production run
**    flg_pruefung EQ 1.                 "nicht beim 'Schecks neu drucken'
**  "not in transaction reprint check
**  IF hlp_laufk NE 'P'.                 "FI-Beleg vorhanden?
**    SELECT * FROM payr
**      WHERE zbukr EQ reguh-zbukr
**      AND   vblnr EQ reguh-vblnr
**      AND   gjahr EQ regud-gjahr
**      AND   voidr EQ 0.
**    ENDSELECT.
**    sy-msgv1 = reguh-zbukr.
**    sy-msgv2 = regud-gjahr.
**    sy-msgv3 = reguh-vblnr.
**  ELSE.                                "HR-Abrechnung vorhanden?
**    SELECT * FROM payr
**      WHERE pernr EQ reguh-pernr
**      AND   seqnr EQ reguh-seqnr
**      AND   btznr EQ reguh-btznr
**      AND   voidr EQ 0.
**    ENDSELECT.
**    sy-msgv1 = reguh-pernr.
**    sy-msgv2 = reguh-seqnr.
**    sy-msgv3 = reguh-btznr.
**  ENDIF.
**
**  IF flg_restart NE 0.
**    IF NOT payr-chect IN tab_check.
**      REJECT.
**    ENDIF.
**    IF sy-subrc NE 0.                  "Scheck nicht vorhanden
**      IF sy-batch EQ space.            "check does not exist
**        MESSAGE a564(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
**      ELSE.
**        MESSAGE s564(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
**        MESSAGE s549(fs).
**        flg_selektiert = 0.
**        STOP.
**      ENDIF.
**    ENDIF.
**  ELSEIF flg_neud EQ 1.                "soll Scheck neu gedruckt werden?
**    IF NOT payr-chect IN tab_check.    "is this check to be reprinted?
**      REJECT.
**    ELSE.
**      *payr = payr.
**    ENDIF.
**  ELSE.
**    IF sy-subrc EQ 0.                  "Scheck bereits vorhanden
**      IF sy-batch EQ space.            "check does exist
**        MESSAGE a551(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
**      ELSE.
**        MESSAGE s551(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
**        MESSAGE s549(fs).
**        flg_selektiert = 0.
**        STOP.
**      ENDIF.
**    ENDIF.
**  ENDIF.
**
**ENDFORM.                               "Scheckinfo prüfen
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKNUMMERN_SPERREN                                           *
***----------------------------------------------------------------------*
*** Sperren des zu druckenden Schecknummernbereichs                      *
*** enqueue check numbers                                                *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM schecknummern_sperren.
**
**  DATA:
**    up_answer(1) TYPE c,
**    up_subrc     LIKE sy-subrc.
**
**  CHECK:
**    zw_xvorl EQ space,                 "nur bei Echtlauf ohne Restart
**    flg_restart EQ 0.                  "only after production run
**  "without restart mode
**  DO.
**    CALL FUNCTION 'ENQUEUE_EFPCEC'
**      EXPORTING
**        zbukr        = pcec-zbukr
**        hbkid        = pcec-hbkid
**        hktid        = pcec-hktid
***       X_STAPL      = 'X'
**        _wait        = 'X'
**      EXCEPTIONS
**        foreign_lock = 8.
**    up_subrc = sy-subrc.
**    IF up_subrc EQ 0 OR sy-batch NE space.
**      EXIT.
**    ENDIF.
**    SET EXTENDED CHECK OFF.
**    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
**      EXPORTING
**        diagnosetext1 = TEXT-900
**        diagnosetext2 = sy-msgv1
**        diagnosetext3 = TEXT-901
**        textline1     = TEXT-902
**        textline2     = TEXT-903
**        titel         = TEXT-904
**      IMPORTING
**        answer        = up_answer.
**    IF up_answer NE 'J'.
**      EXIT.
**    ENDIF.
**    SET EXTENDED CHECK ON.
**  ENDDO.
**  IF up_subrc NE 0.                    "Nummern sind durch anderen
**    IF sy-batch EQ space.              "Benutzer gesperrt
**      PERFORM scheckdruck_mail.        "numbers are locked by another
**      MESSAGE a536(fs) WITH sy-msgv1.  "user
**    ELSE.
**      MESSAGE s536(fs) WITH sy-msgv1.
**      MESSAGE s549(fs).
**      STOP.
**    ENDIF.
**  ELSE.
**    CALL FUNCTION 'LOT_CHECK'
**      EXPORTING
**        i_zbukr = pcec-zbukr
**        i_hbkid = pcec-hbkid
**        i_hktid = pcec-hktid
**        i_stapl = pcec-stapl
**      IMPORTING
**        e_stapl = pcec-stapl
**      EXCEPTIONS
**        OTHERS  = 4.
**    IF sy-subrc NE 0.
**      IF zw_laufi+5(1) EQ '*'.
**        PERFORM scheckdruck_mail.
**        fimsg-msgno = sy-msgno.
**        fimsg-msgv1 = sy-msgv1.
**        MESSAGE a577(fs) WITH fimsg-msgno fimsg-msgv1.
**      ELSE.
**        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1.
**      ENDIF.
**    ENDIF.
**    SELECT SINGLE * FROM pcec
**      WHERE zbukr = pcec-zbukr
**      AND   hbkid = pcec-hbkid
**      AND   hktid = pcec-hktid
**      AND   stapl = pcec-stapl.
**  ENDIF.
**  IF flg_restart NE 0 OR
**   flg_neud    NE 0.
**    DO.
**      CALL FUNCTION 'ENQUEUE_EFPAYR'
**        EXPORTING
**          zbukr        = pcec-zbukr
**          hbkid        = pcec-hbkid
**          hktid        = pcec-hktid
**          _wait        = 'X'
**        EXCEPTIONS
**          foreign_lock = 8.
**      up_subrc = sy-subrc.
**      IF up_subrc EQ 0 OR sy-batch NE space.
**        EXIT.
**      ENDIF.
**      SET EXTENDED CHECK OFF.
**      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
**        EXPORTING
**          diagnosetext1 = TEXT-900
**          diagnosetext2 = sy-msgv1
**          diagnosetext3 = TEXT-901
**          textline1     = TEXT-902
**          textline2     = TEXT-903
**          titel         = TEXT-904
**        IMPORTING
**          answer        = up_answer.
**      IF up_answer NE 'J'.
**        EXIT.
**      ENDIF.
**      SET EXTENDED CHECK ON.
**    ENDDO.
**    IF up_subrc NE 0.                    "Zahlungsträgerdatei ist durch
**      IF sy-batch EQ space.              "anderen Benutzer gesperrt
**        PERFORM scheckdruck_mail.        "payment register is locked by
**        MESSAGE a556(fs) WITH sy-msgv1.  "another user
**      ELSE.
**        MESSAGE s556(fs) WITH sy-msgv1.
**        MESSAGE s549(fs).
**        STOP.
**      ENDIF.
**    ENDIF.
**  ENDIF.
**  IF sy-batch NE space.
**    MESSAGE s550(fs) WITH pcec-checl.  "Ausgabe des Nummernstandes
**  ENDIF.                               "print last check number assigned
**
**ENDFORM.                               "Schecknummern sperren
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKNUMMER_ERMITTELN                                          *
***----------------------------------------------------------------------*
*** Erste, nächste bzw. letzte Schecknummer ermitteln                    *
*** find out first, next or last check number                            *
***----------------------------------------------------------------------*
*** TYP = 1   erster benutzter Scheck                                    *
***           first used check                                           *
***       2   Scheck (bei Seitenüberlauf nur die erste Seite)            *
***           check (only first page when overflow)                      *
***       3   Formularabschluß                                           *
***           summary                                                    *
***----------------------------------------------------------------------*
**FORM schecknummer_ermitteln USING typ.
**
**  IF flg_restart EQ 0.                 "kein Restart
**    "no restart
**    IF pcec-checl IS INITIAL.
**      regud-checf = pcec-checf.        "Start mit neuem Stapel
**      regud-stapf = pcec-stapl.        "start with a new lot
**      regud-chect = pcec-checf.
**      regud-stapt = pcec-stapl.
**      *pcec = pcec.
**    ELSE.
**      CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**        EXPORTING
**          i_pcec = pcec
**          i_n    = 1
**        IMPORTING
**          e_pcec = *pcec.
**      IF typ EQ 1.
**        regud-checf = *pcec-checl.     "erste Schecknummer
**        regud-stapf = *pcec-stapl.     "first check number
**        regud-chect = *pcec-checl.
**        regud-stapt = *pcec-stapl.
**      ELSE.
**        regud-chect = *pcec-checl.     "nächste/letzte Schecknummer
**        regud-stapt = *pcec-stapl.     "next/last check number
**      ENDIF.
**    ENDIF.
**    IF *pcec-zwels NE space AND *pcec-zwels NA reguh-rzawe.
**      IF sy-batch EQ space.
**        MESSAGE a665(fs) WITH reguh-rzawe *pcec-stapl *pcec-zwels.
**      ELSE.
**        MESSAGE s665(fs) WITH reguh-rzawe *pcec-stapl *pcec-zwels.
**        MESSAGE s549(fs).
**        STOP.
**      ENDIF.
**    ENDIF.
**
**  ELSE.                                "Restart
**
**    IF typ EQ 1.
**      CALL FUNCTION 'GET_CHECK_INTERVAL'
**        EXPORTING
**          i_zbukr = zw_zbukr-low
**          i_hbkid = sel_hbki-low
**          i_hktid = sel_hkti-low
**          i_check = hlp_checf_restart
**        IMPORTING
**          e_pcec  = pcec.
**      pcec-checl  = hlp_checf_restart.
**      regud-checf = pcec-checl.        "erste Schecknummer
**      regud-stapf = pcec-stapl.        "first check number
**      regud-chect = pcec-checl.
**      regud-stapt = pcec-stapl.
**    ELSE.
**      SELECT * FROM payr               "Scheck zum Zahlungsbeleg
**        WHERE zbukr EQ reguh-zbukr     "payment document's check
**        AND   vblnr EQ reguh-vblnr
**        AND   gjahr EQ regud-gjahr
**        AND   voidr EQ 0.
**      ENDSELECT.
**      IF typ EQ 2 AND payr-checv NE space AND payr-checv NE '*'.
**        SELECT * FROM payr
**          WHERE zbukr EQ payr-zbukr
**          AND   hbkid EQ payr-hbkiv
**          AND   hktid EQ payr-hktiv
**          AND   rzawe EQ payr-rzawe
**          AND   chect EQ payr-checv
**          AND   voidr EQ 2.
**          EXIT.
**        ENDSELECT.
**      ENDIF.
**      CALL FUNCTION 'GET_CHECK_INTERVAL'
**        EXPORTING                   "zugehöriger Stapel
**          i_zbukr = zw_zbukr-low "accompanying lot
**          i_hbkid = sel_hbki-low
**          i_hktid = sel_hkti-low
**          i_check = payr-checf
**        IMPORTING
**          e_pcec  = pcec.
**      pcec-checl = payr-checf.
**      IF typ EQ 2 AND flg_restart NE 2.
**        CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**          EXPORTING
**            i_pcec = pcec
**            i_n    = par_anzp
**          IMPORTING
**            e_pcec = pcec.
**      ENDIF.
**      IF typ EQ 3.
**        CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**          EXPORTING                 "nächster Scheck=Formularabschluß
**            i_pcec = pcec        "next check=summary
**            i_n    = 1
**          IMPORTING
**            e_pcec = pcec.
**        IF flg_restart NE 2 AND par_anzp NE 0.
**          PERFORM schecks_umnumerieren.
**        ENDIF.
**      ENDIF.
**      regud-chect = pcec-checl.        "nächste/letzte Schecknummer
**      regud-stapt = pcec-stapl.        "next/last check number
**    ENDIF.
**
**  ENDIF.
**
**  IF typ NE 1 AND par_avis NE space.   "Schecknummer merken für das Avis
**    tab_schecks-zbukr = reguh-zbukr.   "store check number for advice
**    tab_schecks-vblnr = reguh-vblnr.
**    tab_schecks-chect = regud-chect.
**    APPEND tab_schecks.
**  ENDIF.
**  hlp_seite = '1'.
**
**ENDFORM.                               "Schecknummer ermitteln
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKAVIS_ZEILE                                                *
***----------------------------------------------------------------------*
*** Schreiben einer Zeile des Avis zum Scheck                            *
*** Write one line of the remittance advice of the check                 *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM scheckavis_zeile.
**
**  DATA: lv_bldat_temp(10) TYPE c,     " temp date field
**        lv_wrbtr_temp(13) TYPE c,     " temp gross amount char
**        lv_wabzg_temp(12) TYPE c,     " temp discount field char
**        lv_wnett_temp(13) TYPE c.     " remp nett amount char
**
**  CALL FUNCTION 'WRITE_FORM'
**    EXPORTING
**      element  = hlp_ep_element
**      function = 'APPEND'
**    EXCEPTIONS
**      window   = 1
**      element  = 2.
**
**  IF sy-subrc EQ 0.
**    WRITE: regup-bldat TO lv_bldat_temp MM/DD/YYYY,
**           regud-wrbtr TO lv_wrbtr_temp NO-GAP,
**           regud-wabzg TO lv_wabzg_temp,
**           regud-wnett TO lv_wnett_temp.
**
**    gt_tline-tdformat = 'T1'.
**    CONCATENATE ''
**          regup-belnr regup-xblnr lv_bldat_temp  lv_wrbtr_temp
**          lv_wabzg_temp lv_wnett_temp INTO
**          gt_tline-tdline SEPARATED BY ',,'.
**    APPEND gt_tline.
**    CLEAR  gt_tline.
**
**  ELSEIF sy-subrc EQ 2.
**    err_element-fname = t042e-zforn.
**    err_element-fenst = 'MAIN'.
**    err_element-elemt = hlp_ep_element.
**    err_element-text  = text_525.
**    COLLECT err_element.
**  ENDIF.
**
*** Vornumerierte Schecks: Schecknummer hochzählen ab 2.Seite
*** prenumbered checks: add 1 to check number
**  IF flg_schecknum EQ 1.
**    CALL FUNCTION 'GET_TEXTSYMBOL'
**      EXPORTING
**        line         = '&PAGE&'
**        start_offset = 0
**      IMPORTING
**        value        = hlp_page.
**    IF hlp_page NE hlp_seite.
**      hlp_seite = hlp_page.
**      PERFORM schecknummer_addieren.
**    ENDIF.
**  ENDIF.
**
**ENDFORM.                               "Scheckavis Zeile
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKNUMMER_ADDIEREN                                           *
***----------------------------------------------------------------------*
*** Werden zu einem Scheck mehrere Seiten gedruckt (Probedruck oder      *
*** Seitenüberlauf), so wird ab Seite 2 mit dieser Routine hochgezählt   *
*** If one check has more than 1 page (test or overflow), this routine   *
*** computes the current check number                                    *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM schecknummer_addieren.
**
**  *pcec = pcec.
**  IF pcec-checl EQ space.              "neuer Stapel / new lot
**    *pcec-checl = *pcec-checf.
**    hlp_page    = hlp_page - 1.
**  ELSEIF flg_restart NE 0.             "Restart
**    hlp_page    = hlp_page - 1.
**  ENDIF.
**  CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**    EXPORTING
**      i_pcec = *pcec
**      i_n    = hlp_page
**    IMPORTING
**      e_pcec = *pcec.
**  regud-chect = *pcec-checl.           "nächste Schecknummer
**  regud-stapt = *pcec-stapl.           "next check number
**
**ENDFORM.                               "Schecknummer addieren
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKS_UMNUMERIEREN                                            *
***----------------------------------------------------------------------*
*** Umnumerieren, wenn beim Restart, der nicht alle Schecks neu druckt,  *
*** Probedrucke angegeben worden sind                                    *
*** renumber, if in restart mode test prints are wished and not all      *
*** checks are to be reprinted                                           *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM schecks_umnumerieren.
**
**  DATA up_bdc LIKE bdcdata OCCURS 9 WITH HEADER LINE.
**
**  CLEAR up_bdc.
**  up_bdc-program  = 'SAPMFCHK'.
**  up_bdc-dynpro   = '400'.
**  up_bdc-dynbegin = 'X'.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PAYR-ZBUKR'.
**  up_bdc-fval     = zw_zbukr-low.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PAYR-HBKID'.
**  up_bdc-fval     = sel_hbki-low.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PAYR-HKTID'.
**  up_bdc-fval     = sel_hkti-low.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PAYR-CHECF'.
**  up_bdc-fval     = hlp_checf_restart.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PAYR-CHECT'.
**  up_bdc-fval     = pcec-checl.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PAYR-VOIDR'.
**  up_bdc-fval     = '01'.
**  APPEND up_bdc.
**  CALL FUNCTION 'GET_CHECK_INTERVAL'
**    EXPORTING
**      i_zbukr = zw_zbukr-low
**      i_hbkid = sel_hbki-low
**      i_hktid = sel_hkti-low
**      i_check = hlp_checf_restart
**    IMPORTING
**      e_pcec  = *pcec.
**  *pcec-checl   = hlp_checf_restart.
**  CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**    EXPORTING
**      i_pcec = *pcec
**      i_n    = par_anzp
**    IMPORTING
**      e_pcec = *pcec.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'PCEC-CHECF'.
**  up_bdc-fval     = *pcec-checl.
**  APPEND up_bdc.
**  CLEAR up_bdc.
**  up_bdc-fnam     = 'BDC_OKCODE'.
**  up_bdc-fval     = '/18'.
**  APPEND up_bdc.
**
**  CALL TRANSACTION 'FCH4' USING up_bdc MODE 'N'.
**  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
**    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**  pcec-checl = sy-msgv4.
**
**ENDFORM.                               "Schecks umnumerieren
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKINFO_SPEICHERN                                            *
***----------------------------------------------------------------------*
*** Speichern der Scheckinformationen in PAYR und                        *
*** aktualisieren des Schecknummernstandes in PCEC                       *
*** store check information in PAYR and update the                       *
*** last used number in PCEC                                             *
***----------------------------------------------------------------------*
*** TYP = 1   Probedrucke                                                *
***           test print                                                 *
***       2   Schecks, evtl. mit Überlauf                                *
***           checks, perhaps with overflow                              *
***       3   Formularabschluß                                           *
***           summary                                                    *
***----------------------------------------------------------------------*
**FORM scheckinfo_speichern USING typ.
**  CHECK flg_restart EQ 0.              "nicht im Restartfall
**  "not in restart mode
**  DATA:
**    up_checf LIKE payr-checf,          "Nummern der bedruckten Schecks
**    up_chect LIKE payr-chect,          "numbers of printed checks
**    up_checv LIKE payr-checv.
**
*** Nummern der bedruckten Schecks berechnen
*** compute numbers of printed checks
**  IF pcec-checl IS INITIAL.            "Start mit neuem Stapel
**    pcec-checl = pcec-checf.           "start with a new lot
**  ELSE.
**    CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**      EXPORTING
**        i_pcec = pcec
**        i_n    = 1
**      IMPORTING
**        e_pcec = pcec.
**  ENDIF.
**  up_checf = pcec-checl.
**  IF cnt_seiten GT 1.
**    cnt_seiten = cnt_seiten - 1.
**    CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**      EXPORTING
**        i_pcec = pcec
**        i_n    = cnt_seiten
**      IMPORTING
**        e_pcec = pcec.
**    cnt_seiten = cnt_seiten + 1.
**  ENDIF.
**  up_chect = pcec-checl.
**
**  IF zw_xvorl EQ space.                "Echtlauf (PAYR und PCEC updaten)
**    "production run
**
***   Prüfen, ob Eintrag bereits in PAYR vorhanden ist
***   test that entry does not already exist in PAYR
**    SELECT * FROM payr
**      WHERE ichec EQ space
**        AND zbukr EQ pcec-zbukr
**        AND hbkid EQ pcec-hbkid
**        AND hktid EQ pcec-hktid
**        AND chect EQ up_chect.
**    ENDSELECT.
**    IF sy-subrc EQ 0.                  "Schecknummer bereits vorhanden
**      IF sy-batch EQ space.            "check number already exists
**        MESSAGE a552(fs)
**          WITH pcec-zbukr pcec-hbkid pcec-hktid up_chect.
**      ELSE.
**        ROLLBACK WORK.
**        MESSAGE s552(fs)
**          WITH pcec-zbukr pcec-hbkid pcec-hktid up_chect.
**        MESSAGE s549(fs).
**        STOP.
**      ENDIF.
**    ENDIF.
**
***   PAYR füllen und Scheckinfo abspeichern
***   fill PAYR and store check information
**    CLEAR payr.
**    payr-mandt = sy-mandt.
**    payr-zbukr = pcec-zbukr.
**    payr-hbkid = pcec-hbkid.
**    payr-hktid = pcec-hktid.
**    payr-rzawe = reguh-rzawe.
**    payr-laufd = zw_laufd.
**    payr-laufi = zw_laufi.
**    payr-pridt = sy-datlo.
**    payr-priti = sy-timlo.
**    payr-prius = sy-uname.
**    CASE typ.
**
***     Probedrucke
***     test prints
**      WHEN 1.
**        payr-checf = up_checf.
**        payr-chect = up_chect.
**        payr-voidr = 1.
**        payr-voidd = sy-datlo.
**        payr-voidu = sy-uname.
**        CALL FUNCTION 'VOID_CHECKS'
**          EXPORTING
**            i_payr = payr.
**
***     Schecks, evtl. mit Überlauf
***     checks, perhaps with overflow
**      WHEN 2.
**        IF cnt_seiten GT 1.            "Überlauf
**          payr-checv = pcec-checl.     "overflow
**          payr-hbkiv = pcec-hbkid.
**          payr-hktiv = pcec-hktid.
**          CALL FUNCTION 'SUBTRACT_N_FROM_CHECK_NUMBER'
**            EXPORTING
**              i_pcec = pcec
**              i_n    = 1
**            IMPORTING
**              e_pcec = pcec.
**          payr-checf = up_checf.
**          payr-chect = pcec-checl.
**          payr-voidr = 2.
**          payr-voidd = sy-datlo.
**          payr-voidu = sy-uname.
**          CALL FUNCTION 'VOID_CHECKS'
**            EXPORTING
**              i_payr  = payr
**            IMPORTING
**              e_checv = up_checv.
**          CLEAR payr.                  "Vorbereitung für echten Scheck
**          payr-checv = up_checv.       "mit Rückverweis zum entwerteten
**          payr-hbkiv = pcec-hbkid.     "Scheck
**          payr-hktiv = pcec-hktid.     "prepare genuine check
**          CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
**            EXPORTING
**              i_pcec = pcec
**              i_n    = 1
**            IMPORTING
**              e_pcec = pcec.
**        ENDIF.
**        MOVE-CORRESPONDING reguh TO payr.
**        IF hlp_laufk EQ 'P'.
**          payr-vblnr = space.
**          payr-kunnr = space.
**          payr-lifnr = space.
**        ENDIF.
**        payr-strgb = reguh-srtgb.
**        payr-gjahr = regud-gjahr.
**        payr-rwbtr = - payr-rwbtr.
**        payr-rwskt = - payr-rwskt.
**        payr-checf = up_chect.
**        payr-chect = up_chect.
**        payr-pridt = sy-datlo.
**        payr-priti = sy-timlo.
**        payr-prius = sy-uname.
**        tab_uebergreifend-zbukr = reguh-zbukr.
**        tab_uebergreifend-vblnr = reguh-vblnr.
**        READ TABLE tab_uebergreifend.
**        IF sy-subrc EQ 0.
**          payr-xbukr = 'X'.
**        ELSE.
**          payr-xbukr = space.
**        ENDIF.
**        IF flg_neud EQ 1.
**          IF payr-checv NE space OR *payr-checv NE space.
**            payr-checv = '*'.
**          ENDIF.
**        ENDIF.
**        INSERT payr.
**        UPDATE pcec.
**
**        CASE flg_neud.
**
***         Beim Neudruck alten Scheck entwerten
***         void old check in reprint mode
**          WHEN 1.
**            PERFORM scheck_entwerten.
**            IF payr-checv EQ space.
**              payr-hbkiv = *payr-hbkid.
**              payr-hktiv = *payr-hktid.
**              payr-checv = *payr-chect.
**            ENDIF.
**            UPDATE payr.
**
***         Beim Neudruck ohne Angabe von Schecks alle Kandidaten
***         entwerten (sofern nicht bereits geschehen) und verweisen
***         void all relevant checks if no check numbers were specified
***         on the selection screen and set pointer to new check
**          WHEN 2.
**            IF hlp_laufk NE 'P'.
**              SELECT * FROM payr INTO *payr
**                WHERE zbukr EQ payr-zbukr
**                AND   vblnr EQ payr-vblnr
**                AND   gjahr EQ payr-gjahr
**                AND ( hbkid NE payr-hbkid
**                   OR hktid NE payr-hktid
**                   OR chect NE payr-chect ).
**                PERFORM scheck_entwerten.
**              ENDSELECT.
**            ELSE.
**              SELECT * FROM payr INTO *payr
**                WHERE pernr EQ reguh-pernr
**                AND   seqnr EQ reguh-seqnr
**                AND   btznr EQ reguh-btznr
**                AND ( zbukr NE payr-zbukr
**                   OR hbkid NE payr-hbkid
**                   OR hktid NE payr-hktid
**                   OR chect NE payr-chect ).
**                PERFORM scheck_entwerten.
**              ENDSELECT.
**            ENDIF.
**            IF sy-dbcnt NE 0.
**              IF sy-dbcnt EQ 1 AND payr-checv EQ space.
**                payr-hbkiv = *payr-hbkid.
**                payr-hktiv = *payr-hktid.
**                payr-checv = *payr-chect.
**              ELSE.
**                payr-checv = '*'.
**              ENDIF.
**              UPDATE payr.
**            ENDIF.
**        ENDCASE.
**
***     Formularabschluß
***     summary
**      WHEN 3.
**        payr-checf = up_checf.
**        payr-chect = up_chect.
**        payr-voidr = 3.
**        payr-voidd = sy-datlo.
**        payr-voidu = sy-uname.
**        CALL FUNCTION 'VOID_CHECKS'
**          EXPORTING
**            i_payr = payr.
**    ENDCASE.
**
**    CALL FUNCTION 'DB_COMMIT'.
**
**  ENDIF.
**
**ENDFORM.                               "Scheckinfo speichern
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECK_ENTWERTEN                                                *
***----------------------------------------------------------------------*
*** Entwerten der alten Schecks bei Neudruck und Verweis zum neuen Scheck*
*** Void old checks in reprint mode and set pointer to new check         +
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM scheck_entwerten.
**
**  IF *payr-checv NE space.
**    IF *payr-checv NE '*'.
**      UPDATE payr SET hbkiv = payr-hbkid
**                      hktiv = payr-hktid
**                      checv = payr-chect
**                WHERE zbukr EQ *payr-zbukr
**                  AND hbkid EQ *payr-hbkiv
**                  AND hktid EQ *payr-hktiv
**                  AND rzawe EQ *payr-rzawe
**                  AND chect EQ *payr-checv.
**    ELSE.
**      UPDATE payr SET hbkiv = payr-hbkid
**                      hktiv = payr-hktid
**                      checv = payr-chect
**                WHERE zbukr EQ *payr-zbukr
**                  AND hbkid EQ *payr-hbkid
**                  AND hktid EQ *payr-hktid
**                  AND rzawe EQ *payr-rzawe
**                  AND checv EQ *payr-chect.
**    ENDIF.
**    payr-checv = '*'.
**  ENDIF.
**  *payr-hbkiv   = payr-hbkid.
**  *payr-hktiv   = payr-hktid.
**  *payr-checv   = payr-chect.
**  IF *payr-voidr EQ 0.
**    *payr-voidr = tvoid-voidr.
**  ENDIF.
**  *payr-voidd   = sy-datlo.
**  *payr-voidu   = sy-uname.
**  UPDATE *payr.
**
**ENDFORM.                               "Scheck entwerten
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKNUMMERN_ENTSPERREN                                        *
***----------------------------------------------------------------------*
*** Entsperren des gedruckten Schecknummernbereichs                      *
*** dequeue check numbers                                                +
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM schecknummern_entsperren.
**
**  CHECK:
**    zw_xvorl EQ space,                 "nur bei Echtlauf ohne Restart
**    flg_restart EQ 0.                  "only after production run
**  "without restart
**  CALL FUNCTION 'DEQUEUE_EFPCEC'
**    EXPORTING
**      zbukr = pcec-zbukr
**      hbkid = pcec-hbkid
**      hktid = pcec-hktid.
***           X_STAPL = 'X'.
**  CALL FUNCTION 'DEQUEUE_EFPAYR'
**    EXPORTING
**      zbukr = pcec-zbukr
**      hbkid = pcec-hbkid
**      hktid = pcec-hktid.
**
**ENDFORM.                               "Schecknummern entsperren
**
**
**
***----------------------------------------------------------------------*
*** FORM SCHECKDRUCK_MAIL                                                *
***----------------------------------------------------------------------*
*** Im Online-Scheckdruck wird ein Mail versendet, wenn der Druck        *
*** nicht erfolgreich war                                                *
*** Using post + print the user will get a mail if the print was not     *
*** successfull                                                          *
***----------------------------------------------------------------------*
*** keine USING-Parameter                                                *
*** no USING-parameters                                                  *
***----------------------------------------------------------------------*
**FORM scheckdruck_mail.
**
**  CHECK sy-tcode EQ 'FBZ4'.
**
**  DATA BEGIN OF up_object_hd_change.
**  INCLUDE STRUCTURE sood1.
**  DATA END OF up_object_hd_change.
**  DATA BEGIN OF up_user.
**  INCLUDE STRUCTURE soud3.
**  DATA END OF up_user.
**  DATA BEGIN OF up_objcont OCCURS 10.
**  INCLUDE STRUCTURE soli.
**  DATA END OF up_objcont.
**  DATA BEGIN OF up_objhead OCCURS 1.
**  INCLUDE STRUCTURE soli.
**  DATA END OF up_objhead.
**  DATA BEGIN OF up_objpara OCCURS 10.
**  INCLUDE STRUCTURE selc.
**  DATA END OF up_objpara.
**  DATA BEGIN OF up_objparb OCCURS 1.
**  INCLUDE STRUCTURE soop1.
**  DATA END OF up_objparb.
**  DATA BEGIN OF up_receivers OCCURS 1.
**  INCLUDE STRUCTURE soos1.
**  DATA END OF up_receivers.
**
**  CLEAR:
**    up_object_hd_change,
**    up_user,
**    up_objcont,
**    up_objhead,
**    up_objpara,
**    up_objparb,
**    up_receivers.
**  REFRESH:
**    up_objcont,
**    up_objhead,
**    up_objpara,
**    up_objparb,
**    up_receivers.
**
**  SET EXTENDED CHECK OFF.
**  up_object_hd_change-objla  = sy-langu.
**  up_object_hd_change-objnam = TEXT-910.
**  up_object_hd_change-objdes = TEXT-911.
**  up_object_hd_change-objsns = 'F'.
**  up_object_hd_change-vmtyp  = 'T'.
**  up_object_hd_change-acnam  = 'FBZ5'.
**  up_user-sapnam             = sy-uname.
**  CALL FUNCTION 'SO_NAME_CONVERT'
**    EXPORTING
**      name_in  = up_user
**    IMPORTING
**      name_out = up_user
**    EXCEPTIONS
**      OTHERS   = 8.
**  IF sy-subrc NE 0.
**    up_user-usrnam           = sy-uname.
**  ENDIF.
**  up_objcont-line            = space.          APPEND up_objcont.
**  up_objcont-line            = TEXT-912.       APPEND up_objcont.
**  up_objcont-line            = TEXT-913.       APPEND up_objcont.
**  up_objcont-line            = space.          APPEND up_objcont.
**  up_objcont-line            = TEXT-914.
**  GET PARAMETER ID 'BUK' FIELD reguh-zbukr.
**  GET PARAMETER ID 'BLN' FIELD reguh-vblnr.
**  IF regud-gjahr EQ 0.
**    GET PARAMETER ID 'GJR' FIELD regud-gjahr.
**  ENDIF.
**  REPLACE '&' WITH:
**    reguh-vblnr INTO up_object_hd_change-objdes,
**    reguh-zbukr INTO up_objcont-line,
**    reguh-vblnr INTO up_objcont-line,
**    regud-gjahr INTO up_objcont-line.
**  APPEND up_objcont.
**  up_objcont-line            = space.          APPEND up_objcont.
**  up_objcont-line            = TEXT-915.       APPEND up_objcont.
**  up_objcont-line            = TEXT-916.       APPEND up_objcont.
**  up_objpara-name            = 'GJR'.
**  up_objpara-low             = regud-gjahr.    APPEND up_objpara.
**  up_objpara-name            = 'BLN'.
**  up_objpara-low             = reguh-vblnr.    APPEND up_objpara.
**  up_receivers-recnam        = up_user-usrnam.
**  up_receivers-acall         = 'X'.
**  up_receivers-sndex         = 'X'.            APPEND up_receivers.
**  SET EXTENDED CHECK ON.
**
**  CALL FUNCTION 'SO_OBJECT_SEND'
**    EXPORTING
**      object_hd_change = up_object_hd_change
**      object_type      = 'RAW'
**      owner            = up_user-usrnam
**    TABLES
**      objcont          = up_objcont
**      objhead          = up_objhead
**      objpara          = up_objpara
**      objparb          = up_objparb
**      receivers        = up_receivers
**    EXCEPTIONS
**      OTHERS           = 4.
**  COMMIT WORK.
**
**ENDFORM.                               "Scheckdruck Mail
**
***----------------------------------------------------------------------*
*** FORM CHECK_FOREIGN_CURRENCY
***----------------------------------------------------------------------*
**FORM check_foreign_currency.
**  IF reguh-zbukr    = c_3000 AND
**           wa_t012k-waers = c_cad.
**    CLEAR regud-waers.
**  ENDIF.
**ENDFORM.                    "CHECK_FOREIGN_CURRENCY
