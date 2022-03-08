*&--------------------------------------------------------------------------------------------------------------------------------------------*
* This is a copy of the standard SAP Vendor Payment History with OI Sorted List report - RFKOPR00.For a full description of the               |
* report, please see documentation in program RFKOPR00. Set default aging periods to 30, 60, 90 and 120. Addition of two summarization        |
* levels, 5 and 6. Summarization level 5 - Shows the vendor open item aging grouped and summarized by vendor number. Summarization level 6    |
* - Detail list of all open item sorted by company code and vendor number.                                                                    |
*&--------------------------------------------------------------------------------------------------------------------------------------------*

REPORT zrfkopr001 MESSAGE-ID fr LINE-SIZE 201 NO STANDARD PAGE HEADING.

TABLES: b0sg,                                              "#EC NEEDED
        lfa1,                          "Daten auf Mandantenebene
        lfb1,                          "Daten auf Buchungskreisebene
        lfc1,                          "Verkehrszahlen
        lfc3,                          "Sonderumsätze
        bsik,                          "Offend Posten
        bsega.

TABLES: bhdgd,
        t001,
        t074t,
        t074u,
        tbsl,
        tbslt,                                             "#EC NEEDED
        tcurx,
        adrs,
        rfpdo,
        rfpdo1,
        rfsdo,
        faede.

FIELD-SYMBOLS: <f1>.

*Accessibility
DATA: lo_writer TYPE REF TO cl_dopr_writer,
      l_title_1 TYPE string,
      l_title_part2 TYPE string,
      l_hlp_txt TYPE c LENGTH 130,
      l_hlp_txt1 TYPE c LENGTH 15,
      l_hlp_string TYPE string,
      l_raster TYPE AFLEX15D2O21S.    "AFLE enablement original type p,

*Hilfsfelder
*---Prüfung ob mehrere Hauswährungen verarbeitet werden.
DATA:
    cfakt(3)   TYPE p,
    checksaldo TYPE AFLEX15D2O21S, "AFLE enablement original (8)type p,
    checkagobl TYPE AFLEX15D2O21S, "AFLE enablement original (8)type p,
    waers      LIKE t001-waers,
    waers2     LIKE t001-waers,
    wflag2(1)  TYPE p VALUE '0'.

*---Ermittlung aktuelles Geschäftsjahr über Funktionsbaustein.
DATA: curry LIKE bsik-gjahr.

*---Zeilenanzahl fü Adressausgabe -----------------------------------*
DATA: zeilenanzahl LIKE adrs-anzzl VALUE 7.

* Hilfsfelder
* -----------------------------------------------------------
DATA: char1(1)   TYPE c.
DATA: flag1(1)   TYPE c.
DATA: flag2(1)   TYPE c.

*--------------------------------------------------------------------*
*---- 'H' =   Hilfsfelder, die jederzeit fuer Berechnungen ver-  ----*
*---- wendet werden koennen. ----------------------------------------*
*--------------------------------------------------------------------*
DATA: BEGIN OF h,
        stichtag(8),
        offset(2) TYPE p,
        offse1(2) TYPE p,
        soll      LIKE lfc1-um01s,
        haben     LIKE lfc1-um01h,
        saldo     LIKE lfc1-umsav,
        shbkz     LIKE lfc3-shbkz,     "Sonderhauptbuchkennzeichen
        saldv     LIKE lfc3-saldv,     "Sonderhauptbuch-Saldovortrag
        shbls     LIKE lfc3-solll,     "Sonderhauptbuch-Lfd.-Saldo
        shbsl     LIKE lfc3-solll,     "Sonderhauptbuch-Lfd.-SOLL
        shbhb     LIKE lfc3-habnl,     "Sonderhauptbuch-Lfd.-HABEN
        text(15),
        umlow     LIKE bsik-umskz,     "Umsatzkennzeichen
        umhig     LIKE bsik-umskz,     "Umsatzkennzeichen
      END   OF h.
*--------------------------------------------------------------------*
*---- 'C' =   Zwischenergebnisse, die aus Feldern des C-Segmentes ---*
*---- berechnet werden. ---------------------------------------------*
*--------------------------------------------------------------------*
DATA: BEGIN OF c,
        saldo     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz1     LIKE lfc3-shbkz,                          "SHBKZ 1
        sums1     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz2     LIKE lfc3-shbkz,                          "SHBKZ 2
        sums2     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz3     LIKE lfc3-shbkz,                          "SHBKZ 3
        sums3     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz4     LIKE lfc3-shbkz,                          "SHBKZ 4
        sums4     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz5     LIKE lfc3-shbkz,                          "SHBKZ 5
        sums5     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz6     LIKE lfc3-shbkz,                          "SHBKZ 6
        sums6     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz7     LIKE lfc3-shbkz,                          "SHBKZ 7
        sums7     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz8     LIKE lfc3-shbkz,                          "SHBKZ 8
        sums8     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz9     LIKE lfc3-shbkz,                          "SHBKZ 9
        sums9     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz10    LIKE lfc3-shbkz,                          "SHBKZ 10
        sums10    TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        sonob     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        babzg     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        uabzg     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kzins     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kumum     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kumag     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        agobli LIKE lfc1-umsav,        "Gesamt-Obligo (absolut)
      END   OF c.
*--------------------------------------------------------------------*
*---- 'C2'=   Zwischenergebnisse, die aus Feldern des C-Segmentes ---*
*---- berechnet werden. ---------------------------------------------*
*--------------------------------------------------------------------*
DATA: BEGIN OF c2 OCCURS 0,
        bukrs     LIKE lfc1-bukrs,
        saldo     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz1     LIKE lfc3-shbkz,                          "SHBKZ 1
        sums1     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz2     LIKE lfc3-shbkz,                          "SHBKZ 2
        sums2     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz3     LIKE lfc3-shbkz,                          "SHBKZ 3
        sums3     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz4     LIKE lfc3-shbkz,                          "SHBKZ 4
        sums4     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz5     LIKE lfc3-shbkz,                          "SHBKZ 5
        sums5     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz6     LIKE lfc3-shbkz,                          "SHBKZ 6
        sums6     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz7     LIKE lfc3-shbkz,                          "SHBKZ 7
        sums7     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz8     LIKE lfc3-shbkz,                          "SHBKZ 8
        sums8     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz9     LIKE lfc3-shbkz,                          "SHBKZ 9
        sums9     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz10    LIKE lfc3-shbkz,                          "SHBKZ 10
        sums10    TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        sonob     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        babzg     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        uabzg     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kzins     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kumum     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kumag     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        agobli LIKE lfc1-umsav,        "Gesamt-Obligo (absolut)
        lftage(3) TYPE p,              "Langfristige Überzugstage
        mftage(3) TYPE p,              "Mittelfristige Überzugstage
        kftage(3) TYPE p,              "Kurzfristige Überzugstage
        zvtyp(1)    TYPE c,            "Flag Skonto oder Nettozahler
        zvper(6)    TYPE c,            "letze Zahlungsperiode
        zvverzug(8) TYPE p,            "Durchschittliche Verzugst
      END   OF c2.
*--------------------------------------------------------------------*
*---- 'C3'=   Zwischenergebnisse, die aus Feldern des C-Segmentes ---*
*---- berechnet werden. ---------------------------------------------*
*--------------------------------------------------------------------*
DATA: BEGIN OF c3,
        saldo     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz1     LIKE lfc3-shbkz,                          "SHBKZ 1
        sums1     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz2     LIKE lfc3-shbkz,                          "SHBKZ 2
        sums2     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz3     LIKE lfc3-shbkz,                          "SHBKZ 3
        sums3     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz4     LIKE lfc3-shbkz,                          "SHBKZ 4
        sums4     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz5     LIKE lfc3-shbkz,                          "SHBKZ 5
        sums5     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz6     LIKE lfc3-shbkz,                          "SHBKZ 6
        sums6     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz7     LIKE lfc3-shbkz,                          "SHBKZ 7
        sums7     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz8     LIKE lfc3-shbkz,                          "SHBKZ 8
        sums8     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz9     LIKE lfc3-shbkz,                          "SHBKZ 9
        sums9     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        umkz10    LIKE lfc3-shbkz,                          "SHBKZ 10
        sums10    TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        sonob     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        babzg     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        uabzg     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kzins     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kumum     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        kumag     TYPE AFLEX15D2O21S, "AFLE enablement original type p,
        agobli LIKE lfc1-umsav,        "Gesamt-Obligo (absolut)
      END   OF c3.

DATA: shbetrag LIKE bsega-dmshb.       "TYPE P.
*--------------------------------------------------------------------*
*---- 'RTAB' = Rastertabelle fuer offene Posten ---------------------*
*--------------------------------------------------------------------*
DATA: BEGIN OF rtab OCCURS 30,
        sortk(1)   TYPE c,             "0 = Summe Gesber
                                       "1 = Summe aller Gesber
                                       "2 = Umsatzdaten
        bukrs LIKE bsik-bukrs,
        gsber LIKE bsik-gsber,
        waers LIKE bsik-waers,
        raart TYPE c,                  "Rasterart
                                       "1 = Netto-Faelligkeit
                                       "2 = Skonto1-Faelligkeit
                                       "3 = Zahlungseingang
                                       "4 = Ueber-Faelligkeit
        sperr TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        kumum TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        anzah TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        opsum TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast1 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast2 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast3 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast4 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast5 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast6 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
      END   OF rtab.

*--------------------------------------------------------------------*
*---- 'RBUK' = Rastertabelle fuer Summen pro Buchungskreis  ---------*
*--------------------------------------------------------------------*
DATA: BEGIN OF rbuk OCCURS 30,
        sortk(1)   TYPE c,             "0 = Summe Gesber
                                       "1 = Summe aller Gesber
                                       "2 = Umsatzdaten
        bukrs LIKE bsik-bukrs,
        gsber LIKE bsik-gsber,
        waers LIKE bsik-waers,
        raart TYPE c,                  "Rasterart
                                       "1 = Netto-Faelligkeit
                                       "2 = Skonto1-Faelligkeit
                                       "3 = Zahlungseingang
                                       "4 = Ueber-Faelligkeit
        sperr TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        kumum TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        anzah TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        opsum TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast1 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast2 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast3 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast4 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast5 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast6 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
      END   OF rbuk.
*--------------------------------------------------------------------*
*---- 'RSUM' = Rastertabelle pro Währung über alle Buchungskreise ---*
*--------------------------------------------------------------------*
DATA: BEGIN OF rsum OCCURS 30,
        sortk(1)   TYPE c,             "0 = Summe Gesber
                                       "1 = Summe aller Gesber
        waers LIKE bsik-waers,
        raart TYPE c,                  "Rasterart
                                       "1 = Netto-Faelligkeit
                                       "2 = Skonto1-Faelligkeit
                                       "3 = Zahlungseingang
                                       "4 = Ueber-Faelligkeit
        sperr TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        kumum TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        anzah TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        opsum TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast1 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast2 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast3 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast4 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast5 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
        rast6 TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
      END   OF rsum.

*--------------------------------------------------------------------*
*---- interne Tabelle für Periodenabgrenzung-------------------------*
*--------------------------------------------------------------------*
RANGES: bmonat FOR rfpdo-doprbmon.

*--------------------------------------------------------------------*
*---- In die Felder RP01 bis RP05 werden dynamisch die von aussen ---*
*---- eingegebenen Rasterpunkte uebertragen -------------------------*
*--------------------------------------------------------------------*
DATA: rp01(2)   TYPE p,                                     "   0
      rp02(2)   TYPE p,                                     "  20
      rp03(2)   TYPE p,                                     "  40
      rp04(2)   TYPE p,                                     "  80
      rp05(2)   TYPE p,                                     " 100
      RP06(3)   TYPE P,                "   1
      RP07(3)   TYPE P,                "  21
      RP08(3)   TYPE P,                "  41
      RP09(3)   TYPE P,                "  81
      RP10(3)   TYPE P.                " 101
*--------------------------------------------------------------------*
*---- In die Felder RC01 bis RC10 werden die Rasterpunkte in --------*
*---- charakterform abgestellt. (fuer REPLACE-Funktion in Variabler -*
*---- Ueberschrift) -------------------------------------------------*
*--------------------------------------------------------------------*
DATA: rc01(4)   TYPE c,                                     "  0
      rc02(4)   TYPE c,                                     "  20
      rc03(4)   TYPE c,                                     "  40
      rc04(4)   TYPE c,                                     "  80
      rc05(4)   TYPE c,                                     " 100
      rc06(4)   TYPE c,                                     "   1
      rc07(4)   TYPE c,                                     "  21
      rc08(4)   TYPE c,                                     "  41
      rc09(4)   TYPE c,                                     "  81
      rc10(4)   TYPE c.                                     " 101

*--------------------------------------------------------------------*
*---- Felder für Umsatzkennzeichen ----------------------------------*
*---- für Ausweis der Sonderumsätze----------------------------------*
*--------------------------------------------------------------------*
DATA: humkz1    LIKE lfc3-shbkz,
      humkz2    LIKE lfc3-shbkz,
      humkz3    LIKE lfc3-shbkz,
      humkz4    LIKE lfc3-shbkz,
      humkz5    LIKE lfc3-shbkz,
      humkz6    LIKE lfc3-shbkz,
      humkz7    LIKE lfc3-shbkz,
      humkz8    LIKE lfc3-shbkz,
      humkz9    LIKE lfc3-shbkz,
      humkz10   LIKE lfc3-shbkz.

*---- GBZAEHL - In diesem Feld wird vermerkt, fuer wieviele Ge- ------*
*----           schaeftsbereiche ein OP-Raster ausgegeben wird. ------*
*----           Wird das Raster nur fuer einen Geschaeftsbereich ge- -*
*----           druckt, so entfaellt das Summen-Raster. --------------*
DATA: gbzaehl(3) TYPE p.

*---- TOP-FLAG '1' = bei TOP-OF-PAGE Einzelpostenueberschrift ausg. --*
*----          '2' = bei TOP-OF-PAGE Ueberschrift fuer Raster ausgeb. *
*----          '3' = bei TOP-OF-PAGE ULINE ausgeben. -----------------*
*----          '4' = bei TOP-OF-PAGE Stammsatzueberschrift ausgeben --*
DATA: top-flag(1) TYPE c.                                  "#EC *

*---- SEL-STAMM  'J' = Stammsatz wird ausgewertet                     *
*----            'N' = Stammsatz wird nicht ausgewertet               *
*---- SEL-POSTN  'J' = Stammsatz hat Posten gerastert                 *
*----            'N' = Stammsatz hat keine Posten gerastert           *
DATA: BEGIN OF sel,
        stamm(1) TYPE c,
        postn(1) TYPE c,
        post2(1) TYPE c,
      END   OF sel.

*---- SATZART  '1' = Stammdaten --------------------------------------*
*----          '2' = Faelligkeitsraster ------------------------------*
*----          '3' = Einzelposten ------------------------------------*
DATA: satzart(1) TYPE c.

*---- RART  =  Erste ausgewaehlte Rasterart --------------------------*
DATA: rart(1)    TYPE c.
*---- TAGE  =  Tage nach denen die Posten sortiert sind --------------*
DATA: tage(4)    TYPE p,
*---- NTAGE =  Tage fuer Netto-Faelligkeit ---------------------------*
      ntage(4)   TYPE p,
*---- STAGE =  Tage fuer Skonto1-Faelligkeit -------------------------*
      stage(4)   TYPE p,
*---- ATAGE =  Alter der Belege --------------------------------------*
      atage(4)   TYPE p,
*---- UTAGE =  Tage fuer Ueber-Faelligkeit ---------------------------*
      utage(4)   TYPE p.

*---- RASTERUU dient zur Sortierung der Einzelposten. Die Posten -----*
*----          gemaess ihrer Rasterung die Werte '1' bis '6' ---------*
DATA: rasteruu(1) TYPE c.

DATA: BEGIN OF gb,
        gsber  LIKE bsik-gsber,
        waers  LIKE bsik-waers,
      END   OF gb.

*---------------------------------------------------------------------*
*---- Variable Ueberschriften ----------------------------------------*
*---------------------------------------------------------------------*
DATA: BEGIN OF varueb1,
        feld1(45)   TYPE c,
        feld2       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld3       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld4       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld5       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld6       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld7       TYPE AFLEXC14,"AFLE enablement original (14)type C,
      END   OF varueb1.

DATA: BEGIN OF varueb2,
        feld1(45)   TYPE c,
        feld2       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld3       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld4       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld5       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld6       TYPE AFLEXC14,"AFLE enablement original (14)type C,
        feld7       TYPE AFLEXC14,"AFLE enablement original (14)type C,
      END   OF varueb2.

DATA: varueb3(132),
      varueb4(132),
      vartxt1(40),
      VARTXT(40)  TYPE C.

*---------------------------------------------------------------------*
*---- Variable für Ausgabe der Sonderumsätze--------------------------*
*---------------------------------------------------------------------*
DATA: shbbez LIKE t074t-ltext.
DATA: asums  TYPE AFLEX15D2O21S.      "AFLE enablement original type p,

*---------------------------------------------------------------------*
*---- Interne Tabelle für Bezeichnungen der SHBKZ---------------------*
*---------------------------------------------------------------------*
DATA: BEGIN OF bezshb OCCURS 10,
        shbkz LIKE t074t-shbkz,
        ltext LIKE t074t-ltext,
      END OF bezshb.

*---------------------------------------------------------------------*
*---- Interne Tabelle für Zwischenspeicherung ------------------------*
*---------------------------------------------------------------------*
DATA: BEGIN OF blkey,
        bukrs LIKE bsik-bukrs,
        belnr LIKE bsik-belnr,
        gjahr LIKE bsik-gjahr,
        buzei LIKE bsik-buzei,
      END   OF blkey.

DATA: BEGIN OF rtage,
        ntage LIKE ntage,
        stage LIKE stage,
        atage LIKE atage,
        utage LIKE utage,
     END   OF rtage.

DATA: BEGIN OF hbsik OCCURS 10.
        INCLUDE STRUCTURE bsik.
        INCLUDE STRUCTURE bsega_SFIN.
        INCLUDE STRUCTURE rtage.
DATA: END   OF hbsik.

DATA: BEGIN OF refbl OCCURS 10.
        INCLUDE STRUCTURE blkey.
        INCLUDE STRUCTURE rtage.
DATA: END   OF refbl.

DATA: BEGIN OF hlfb1 OCCURS 10.
        INCLUDE STRUCTURE lfb1.
DATA: END   OF hlfb1.

DATA: BEGIN OF ht001 OCCURS 10.
        INCLUDE STRUCTURE t001.
DATA: END   OF ht001.

*---------------------------------------------------------------------*
*---- Interne Tabelle für Ausgabe der Obligos ------------------------*
*---------------------------------------------------------------------*
DATA: BEGIN OF aobligo OCCURS 12,
        obart TYPE c,             "Flag für Obligoart 1 = Kontokorrent
                                  "                   2 = SHBKZ
                                  "                   3 = sonstige SHB
        shbkz LIKE t074t-shbkz,        "SHB-Kennzeichen
        ltext LIKE t074t-ltext,        "Bezeichnung
        oblig TYPE AFLEX15D2O21S,     "AFLE enablement original type p,
      END OF aobligo.

*---------------------------------------------------------------------*
*---- Declarationen für Accessibility /ALV GRID ----------------------*
*---------------------------------------------------------------------*
* DATA: acc_mode TYPE c.
DATA: uebtext(22) TYPE c.
DATA: uektext(15)  TYPE c.
DATA: tittext(100) TYPE c.
DATA: dattext(10) TYPE c.

DATA: BEGIN OF rtab_alv OCCURS 30,
        bukrs LIKE bsik-bukrs,
        lifnr LIKE lfa1-lifnr,
        busab LIKE lfb1-busab,
        sortl LIKE lfa1-sortl,
        land1 LIKE lfa1-land1,
        gsber LIKE bsik-gsber,
        waers LIKE bsik-waers,
        raart LIKE rf140-raart,        "Rasterart
        kumum LIKE rf140-kumumhw,      "Umsatz
        anzah LIKE rf140-anzbthw,      "Anzahlungen
        opsum LIKE rf140-gsaldd,       "Offene Posten Summe
        rast1 LIKE rf140-rast1,        "Rasterfeld 1
        rast2 LIKE rf140-rast2,        "Rasterfeld 2
        rast3 LIKE rf140-rast3,        "Rasterfeld 3
        rast4 LIKE rf140-rast4,        "Rasterfeld 4
        rast5 LIKE rf140-rast5,        "Rasterfeld 5
        rast6 LIKE rf140-rast6,        "Rasterfeld 6
        adrs1 like adrs-line0,                                 "1253468
        adrs2 like adrs-line0,                                 "1253468
        adrs3 like adrs-line0,                                 "1253468
        adrs4 like adrs-line0,                                 "1253468
      END   OF rtab_alv.

DATA: gd_no_anred type boolean.                                "1320031

*"General Data
TYPE-POOLS: slis.
DATA: g_repid      LIKE sy-repid,
      g_grid_title TYPE  lvc_title.
*"Callback
DATA: g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      g_top_of_page  TYPE slis_formname VALUE 'TOP_OF_PAGE'.   "1613289
*"Variants
DATA: gs_variant LIKE disvariant,
      g_save.
*"ALV HEADER
DATA: gt_listheader  type slis_t_listheader,                   "1613289
      gs_listheader  type slis_listheader.                     "1613289
* Global structure of list
* fieldcatalog
DATA: ls_fieldcat TYPE slis_fieldcat_alv.
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.     "#EC *

DATA: g_tabname   TYPE slis_tabname VALUE 'RTAB_ALV'.

*---------------------------------------------------------------------*
*---- FIELD-GROUPS                            ------------------------*
*---------------------------------------------------------------------*
FIELD-GROUPS:
          header,
          stammdaten,
          op-raster,                                       "#EC *
          einzelposten.

INSERT
  lfb1-bukrs                           " Buchungskreis
  lfa1-lifnr                           " Kontonummer
  lfa1-name1                           " 475950
  lfa1-land1                           " 475950
  satzart                              " Satzart
  rtab-sortk                           " Sortkz fuer Tabelle RTAB
                                       " '0' = normale Eintraege
                                       " '1' = Summeneintraege
  gb                                   " Geschaeftsbereich
                                       " - GB-GSBER
                                       " - GB-WAERS
  rasteruu         " Kennzeichen fuer Detailposten bzw Raster
*---------------- ab hier nur fuer Einzelposten ----------------------*
  tage                                 " Rastertage  fuer Detailposten
  bsik-umskz                           " Umsatzkennzeichen
  bsik-blart                           " Belegart
  bsik-belnr                           " Belegnummer
  bsik-buzei                           " Belegzeile
INTO header.

INSERT
* Addressdaten
  lfa1-lifnr                           " 475950
  lfa1-name1                           " 475950
  lfa1-land1                           " 475950
  adrs-line0                           " 1. Zeile Adressenaufbereitung
  adrs-line1                           " 2. "     "
  adrs-line2                           " 3. "     "
  adrs-line3                           " 4. "     "
  adrs-line4                           " 5. "     "
  adrs-line5                           " 6. "     "
  adrs-line6                           " 7. "     "
* Umsatzdaten
  c-kumum                              " Umsatz
* Obligos
  c-saldo                              " Saldo ohne SHB-Vorgänge
  c-umkz1                                                   "SHBKZ 1
  c-sums1                              "Sonderumsatz 1
  c-umkz2                                                   "SHBKZ 2
  c-sums2                              "Sonderumsatz 2
  c-umkz3                                                   "SHBKZ 3
  c-sums3                              "Sonderumsatz 3
  c-umkz4                                                   "SHBKZ 4
  c-sums4                              "Sonderumsatz 4
  c-umkz5                                                   "SHBKZ 5
  c-sums5                              "Sonderumsatz 5
  c-umkz6                                                   "SHBKZ 6
  c-sums6                              "Sonderumsatz 6
  c-umkz7                                                   "SHBKZ 7
  c-sums7                              "Sonderumsatz 7
  c-umkz8                                                   "SHBKZ 8
  c-sums8                              "Sonderumsatz 8
  c-umkz9                                                   "SHBKZ 9
  c-sums9                              "Sonderumsatz 9
  c-umkz10                                                  "SHBKZ 10
  c-sums10                             "Sonderumsatz 10
  c-sonob                              " Sonst. Obligen
* Limits
  c-agobli                             " Absolutes Gesamtobligo
* Zahlungdaten
  lfb1-zterm                           "Zahlungsbedingung
  lfb1-zahls                           "Sperrschlüssel für Zahlung
  lfb1-zwels                           "Zahlwege
  lfb1-xverr                           "Zahlungsverrechnung
  lfb1-webtr                           "Wechsellimit
  lfb1-busab                           " Sachbearbeiter
  lfa1-sortl
  lfa1-land1
INTO stammdaten.

INSERT
  rtab-raart                           "Rasterart
  rtab-sperr                           "gesperrte Posten
  rtab-kumum                           "Umsatz
  rtab-anzah                           "Anzahlungen
  rtab-opsum                           "Offene Posten Summe
  rtab-rast1                           "Rasterfeld 1
  rtab-rast2                           "Rasterfeld 2
  rtab-rast3                           "Rasterfeld 3
  rtab-rast4                           "Rasterfeld 4
  rtab-rast5                           "Rasterfeld 5
  rtab-rast6                           "Rasterfeld 6
INTO op-raster.

INSERT
  bsik-budat                           " Buchungsdatum
  bsik-bldat                           " Belegdatum
  bsik-cpudt                           " CPU-Datum
  bsik-waers                           " Wahrungsschluessel
  bsega-netdt                          " Nettofaelligkeitsdatum
  bsik-zfbdt                           " Zahlungsfristen-Basisdatum
  bsik-bschl                           " Buchungsschluessel
  bsik-zlsch                           " Zahlungsschluessel
  bsik-xblnr                           " 475950
  bsik-saknr                           " 475950
  bsik-zterm                           " 475950
  shbetrag                             " Hauswaehrungsbetrag
  bsega-dmshb                          " Hauswaehrungsbetrag
  bsega-wrshb                          " Fremwaehrungsbetrag
INTO einzelposten.

BEGIN_OF_BLOCK 1.
PARAMETERS:     monat    LIKE rfpdo-doprbmon.
SELECT-OPTIONS: kksaldo2 FOR rfsdo-koprsal2,    "Saldovortrag
                agoblig2 FOR rfsdo-koprago2.    "Absolutes Obligo
SELECT-OPTIONS: akonts   FOR lfb1-akont,
                akontp   FOR bsik-hkont.
SELECT-OPTIONS: budat    FOR bsik-budat,
                bldat    FOR bsik-bldat,
                netdt    FOR bsega-netdt.
PARAMETERS:     n_belege LIKE rfpdo-bpetnbel DEFAULT 'X',
                stat_blg LIKE rfpdo-bpetsbel.  "Statistische Belege
END_OF_BLOCK 1.

BEGIN_OF_BLOCK 2.
PARAMETERS: sortart  LIKE rfpdo1-koprsoar DEFAULT '1',
            verdicht LIKE rfpdo1-koprverd DEFAULT '1',
            rastverd LIKE rfpdo1-koprrast DEFAULT '0',
            konzvers LIKE rfpdo-dopokonz,   "Konzernversion
            xbukrdat LIKE rfpdo3-allgbukd DEFAULT 0, "Bukr.daten
            kausgabe as checkbox.           " 475950
PARAMETERS: rart-net LIKE rfpdo-doprrnet DEFAULT 'X'.      "#EC *
PARAMETERS: rart-skt LIKE rfpdo-doprrskt DEFAULT 'X'.      "#EC *
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rart-alt LIKE rfpdo1-koprralt DEFAULT 'X'.     "#EC *
SELECTION-SCREEN COMMENT 03(28) text-031 for field rart-alt.
SELECTION-SCREEN POSITION pos_high.
PARAMETERS  rbldat   LIKE rfpdo2-kord10bd.
SELECTION-SCREEN COMMENT 61(12) text-032 for field rbldat.
SELECTION-SCREEN END OF LINE.
PARAMETERS: rart-ueb LIKE rfpdo-doprrueb DEFAULT 'X'.      "#EC *
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) text-026 for field rastbis1.
PARAMETERS: rastbis1 LIKE rfpdo1-allgrogr DEFAULT '000'.
PARAMETERS: rastbis2 LIKE rfpdo1-allgrogr DEFAULT '030'. " 475950
PARAMETERS: rastbis3 LIKE rfpdo1-allgrogr DEFAULT '060'. " 475950
PARAMETERS: rastbis4 LIKE rfpdo1-allgrogr DEFAULT '090'. " 475950
PARAMETERS: rastbis5 LIKE rfpdo1-allgrogr DEFAULT '120'. " 475950
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) text-029 for field faktor.
PARAMETERS: faktor   LIKE rfpdo-doprfakt DEFAULT '0'.
SELECTION-SCREEN COMMENT 35(1) text-028 for field stellen.
PARAMETERS: stellen  LIKE rfpdo-doprfakt DEFAULT '0'.
SELECTION-SCREEN END OF LINE.
PARAMETERS: pzuor    LIKE rfpdo2-doprzuor.
PARAMETERS: umsatzkz LIKE rfpdo1-doprshbo.
PARAMETERS: title    LIKE rfpdo1-allgline,
            listsep  LIKE rfpdo-allglsep,
            mikfiche LIKE rfpdo-allgmikf.
" PARAMETERS: p_acc    like rfpdo1-doprxalv USER-COMMAND ACC.    "2366028
" PARAMETERS: p_lvar   LIKE gs_variant-variant DEFAULT space MODIF ID 508.
END_OF_BLOCK 2.

AT SELECTION-SCREEN ON akonts.
  LOOP AT akonts.
    PERFORM alphaformat(sapfs000)
      USING akonts-low akonts-low.
    PERFORM alphaformat(sapfs000)
      USING akonts-high akonts-high.
    MODIFY akonts.
  ENDLOOP.

AT SELECTION-SCREEN ON akontp.
  LOOP AT akontp.
    PERFORM alphaformat(sapfs000)
      USING akontp-low akontp-low.
    PERFORM alphaformat(sapfs000)
      USING akontp-high akontp-high.
    MODIFY akontp.
  ENDLOOP.

AT SELECTION-SCREEN.
  IF NOT rastbis5 IS INITIAL.
    IF  rastbis5 GT rastbis4
    AND rastbis4 GT rastbis3
    AND rastbis3 GT rastbis2
    AND rastbis2 GT rastbis1.
    ELSE.
      MESSAGE e379.
    ENDIF.
  ELSE.
    IF NOT rastbis4 IS INITIAL.
      IF  rastbis4 GT rastbis3
      AND rastbis3 GT rastbis2
      AND rastbis2 GT rastbis1.
      ELSE.
        MESSAGE e379.
      ENDIF.
    ELSE.
      IF NOT rastbis3 IS INITIAL.
        IF  rastbis3 GT rastbis2
        AND rastbis2 GT rastbis1.
        ELSE.
          MESSAGE e379.
        ENDIF.
      ELSE.
        IF NOT rastbis2 IS INITIAL.
          IF  rastbis2 GT rastbis1.
          ELSE.
            MESSAGE e379.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR bezshb.
  REFRESH bezshb.
  CONDENSE umsatzkz NO-GAPS.
  IF NOT umsatzkz(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+1(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+1(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+2(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+2(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+3(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+3(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+4(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+4(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+5(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+5(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+6(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+6(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+7(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+7(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+8(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+8(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.
  IF NOT umsatzkz+9(1) IS INITIAL.
    CLEAR char1.
    MOVE umsatzkz+9(1) TO char1.
    PERFORM shbkz_pruefen.
  ENDIF.

INITIALIZATION.
  get_frame_title: 1, 2.
  monat = '16'.

START-OF-SELECTION.
* AFLE - If active, the classic list cannot be used.
  DATA: lv_mode type FLE_MODE.                                    "AFLE
  CLEAR lv_mode.                                                  "AFLE

  cl_abap_list_layout=>suppress_implicit_page_breaks( abap_true ).

  COMMIT WORK.
  copy: akonts to kd_akont, akontp to kd_hkont.

  SELECT * FROM t001 APPENDING TABLE ht001
    WHERE bukrs IN kd_bukrs.

*- Standardseitenkopf fuellen ---------------------------------------*
  MOVE '0'      TO bhdgd-inifl.
  MOVE sy-linsz TO bhdgd-lines.
  MOVE sy-uname TO bhdgd-uname.
  MOVE sy-repid TO bhdgd-repid.
  MOVE sy-title TO bhdgd-line1.
  MOVE title    TO bhdgd-line2.
  MOVE '    '   TO bhdgd-bukrs.
  MOVE mikfiche TO bhdgd-miffl.
  MOVE listsep  TO bhdgd-separ.
  MOVE 'BUKRS'  TO bhdgd-domai.
*- OP-Raster und Ueberschriften aufbereiten -------------------------*
  PERFORM raster_aufbau.
  PERFORM shb_kennzeichen.

  IF n_belege <> space.
    n_belege = 'X'.
    b0sg-xstan = 'X'.
  ELSE.
    b0sg-xstan = ' '.
  ENDIF.

  IF stat_blg <> space.
    stat_blg = 'X'.
    b0sg-xstas = 'X'.
  ENDIF.

  IF monat IS INITIAL
  OR monat GT '16'.
    monat = '16'.
  ENDIF.
  bmonat-low    = '1'.
  bmonat-high   = monat.
  bmonat-option = 'BT'.
  bmonat-sign   = 'I'.
  APPEND bmonat.

GET lfa1.
  CLEAR adrs.
  MOVE-CORRESPONDING lfa1 TO adrs.                         "#EC ENHOK
  MOVE zeilenanzahl TO adrs-anzzl.
  CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
    EXPORTING
      adrswa_in  = adrs
    IMPORTING
      adrswa_out = adrs.

  IF NOT konzvers IS INITIAL.
    CLEAR checksaldo.
    CLEAR checkagobl.
    CLEAR waers2.
    CLEAR wflag2.
    CLEAR   hbsik.
    REFRESH hbsik.
    CLEAR   refbl.
    REFRESH refbl.
    sel-stamm  = 'N'.
    sel-postn  = 'N'.
    sel-post2  = 'N'.
    CLEAR   rtab.
    REFRESH rtab.
    CLEAR   hlfb1.
    REFRESH hlfb1.
    CLEAR   c2.
    REFRESH c2.
    CLEAR   c3.
  ENDIF.

GET lfb1.
  CHECK akonts.
  IF konzvers IS INITIAL.
    CLEAR checksaldo.
    CLEAR checkagobl.
    CLEAR   hbsik.
    REFRESH hbsik.
    CLEAR   refbl.
    REFRESH refbl.
    sel-stamm = 'N'.
    sel-postn = 'N'.
    CLEAR   rtab.
    REFRESH rtab.
  ENDIF.
  CLEAR c.
  CLEAR h-saldo.
  CLEAR: gb,
         rasteruu,
         tage.
* Lfd. Geschaeftsjahr gemaess Stichtag besorgen ---------------------*
* laufendes Geschäftsjahr ermitteln
* ---------------------------------
  CALL FUNCTION 'GET_CURRENT_YEAR'
    EXPORTING
      bukrs = lfb1-bukrs
      date  = kd_stida
    IMPORTING
      curry = curry.
  READ TABLE ht001 WITH KEY bukrs = lfb1-bukrs.
  t001 = ht001.
  IF  NOT waers2 IS INITIAL
  AND waers2 NE t001-waers.
    wflag2 = '1'.
  ENDIF.
  waers2 = t001-waers.

GET lfc1.
  CHECK: lfc1-gjahr = curry.
* aktuellen Saldo ermitteln (fuer CHECK auf Saldo) ------------------*
  PERFORM saldo_aktuell.
  PERFORM kum_werte.
  sel-stamm = 'J'.

GET lfc3.
  CHECK lfc3-gjahr = curry.
*  Errechnen Sonderumsatz-Salden, Gesamtsaldo ------------------------*
*  Trend, Umsatz pro Gesch.Bereich -----------------------------------*
  PERFORM sonder_umsaetze.
  sel-stamm = 'J'.

GET bsik.
  IF konzvers IS INITIAL.
    CHECK checksaldo IN kksaldo2.
    CHECK checkagobl IN agoblig2.
  ENDIF.
  CHECK akontp.
  CASE bsik-bstat.
    WHEN ' '.
      CHECK n_belege EQ 'X'.
    WHEN 'S'.
      CHECK stat_blg EQ 'X'.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

* Einzelposten werden nur dann weiterverarbeitet, wenn ueberhaupt ---*
* ein OP-Raster gewuenscht wird. ------------------------------------*
  CHECK rastverd < '2'.

* Bei SORTART = '2' werden nur Belege verarbeitet, welche in Fremd- -*
* waehrung gebucht sind ---------------------------------------------*
  IF sortart  = '2'.
    CHECK bsik-waers NE t001-waers.
  ENDIF.

  CHECK bsik-budat LE kd_stida.

  CLEAR faede.
  MOVE-CORRESPONDING bsik TO faede.                        "#EC ENHOK
  faede-koart = 'K'.

  CALL FUNCTION 'DETERMINE_DUE_DATE'                       "#EC *
    EXPORTING
      i_faede = faede
    IMPORTING
      e_faede = faede
    EXCEPTIONS
      OTHERS  = 1.

  bsega-netdt = faede-netdt.

* TAGE gemaess Rasterart ermitteln -----------------------------------*
* Netto-Faelligkeit --------------------------------------------------*
  ntage = faede-netdt - kd_stida.
* Ueber-Faelligkeit --------------------------------------------------*
  utage = kd_stida - faede-netdt.
* Skonto1-Faelligkeit ------------------------------------------------*
  stage = faede-sk1dt - kd_stida.
* Alter der Belege ---------------------------------------------------*
  IF rbldat IS INITIAL.
    atage = kd_stida - bsik-budat.
  ELSE.
    atage = kd_stida - bsik-bldat.
  ENDIF.
  IF NOT pzuor    IS INITIAL
  OR NOT konzvers IS INITIAL.
    PERFORM einzelposten_save.
  ELSE.
* die Einzelposten werden nach den Tagen der ersten Rasterart --------*
* sortiert -----------------------------------------------------------*
    IF rart-net = 'X'.
      tage = ntage.
    ELSE.
      IF rart-skt = 'X'.
        tage = stage.
      ELSE.
        IF rart-alt = 'X'.
          tage = atage.
        ELSE.
          IF rart-ueb = 'X'.
            tage = utage.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    CASE bsik-umsks.
*--------------- Anzahlungen sammeln ---------------------------------*
*--------------- auch wenn nicht von aussen abgegrenzt ---------------*
      WHEN 'A'.
        CLEAR rtab.
        IF bsik-bstat NE 'S'.
          MOVE: bsik-bukrs TO rtab-bukrs,
                '0'      TO rtab-sortk,
                bsik-gsber TO rtab-gsber,
                rart     TO rtab-raart.
          IF sortart = '2'.
            MOVE bsik-waers TO rtab-waers.
            MOVE bsega-wrshb TO rtab-anzah.
          ELSE.                                             "748519
"            IF NOT konzvers IS INITIAL.      " 475950
"              MOVE t001-waers TO rtab-waers. " 475950
              MOVE bsega-dmshb TO rtab-anzah. " 475950
"            ELSE.
"              MOVE bsega-dmshb TO rtab-anzah.
"            ENDIF.
          ENDIF.
          COLLECT rtab.
*--------------- Summieren ueber alle Geschaeftsbereiche -------------*
          MOVE: '1'      TO rtab-sortk,
                '**'     TO rtab-gsber.
          COLLECT rtab.
        ENDIF.
    ENDCASE.

    CHECK: budat,
           bldat,
           netdt.
    sel-postn = 'J'.

    IF sortart = '1'.
****Commenting the code same as in ECC.
"      IF konzvers IS INITIAL .              " 475950
        PERFORM posten_rastern USING space.
        MOVE space    TO gb-waers.
"      ELSE.                                 " 475950
"        PERFORM posten_rastern USING t001-waers. " 475950
"        MOVE t001-waers TO gb-waers.             " 475950
"      ENDIF.
    ELSE.
      PERFORM posten_rastern USING bsik-waers.
      MOVE bsik-waers TO gb-waers.
    ENDIF.
*---- nur bei Verdichtungsstufe '0' werden EINZELPOSTEN extrahiert --*
    IF verdicht = '0' or verdicht = '6'. " 475950
      MOVE   '3'    TO satzart.
      MOVE bsik-gsber TO gb-gsber.
      MOVE bsega-dmshb TO shbetrag.
*------Der Fremdwährungsbetrag soll nur Übernommen werden, wenn sich
*      sich der Währung von der Hauswährung unterscheidet.
      IF bsik-waers EQ t001-waers.
        MOVE space TO bsega-wrshb.
      ENDIF.
      EXTRACT einzelposten.
    ENDIF.
  ENDIF.

GET lfb1 LATE.
  IF konzvers IS INITIAL.
    CHECK checksaldo IN kksaldo2.
    CHECK checkagobl IN agoblig2.

    IF NOT pzuor IS INITIAL.
      PERFORM einzelposten_link.
      PERFORM einzelposten_proc.
    ENDIF.

* Bei SORTART = '2' werden nur dann Stammsatzdaten ausgegeben, wenn -*
* auch Einzelposten gerastert wurden. -------------------------------*
    IF rastverd < '3'.
      IF sortart = '2'.
        CHECK sel-postn = 'J'.
      ENDIF.
      IF NOT kausgabe IS INITIAL.
        CHECK sel-postn = 'J'.
      ENDIF.
    ENDIF.

    CLEAR: gb,
           rasteruu,
           tage.
    MOVE '1' TO satzart.
* Stammdaten extrahieren ---------------------------------------------*
    CHECK: checkagobl IN agoblig2.
    EXTRACT stammdaten.
* OP-Raster extrahieren ----------------------------------------------*
    SORT rtab ASCENDING.

    LOOP AT rtab.
      MOVE:     '2'    TO satzart,
            rtab-gsber TO gb-gsber,
            rtab-waers TO gb-waers,
            rtab-raart TO rasteruu.
      EXTRACT op-raster.
    ENDLOOP.
  ELSE.
    hlfb1 = lfb1.
    APPEND hlfb1.
    MOVE-CORRESPONDING c TO c2.
    c2-bukrs = lfb1-bukrs.
    APPEND c2.
  ENDIF.

GET lfa1 LATE.
  IF NOT konzvers IS INITIAL.
    IF wflag2 IS INITIAL.
      CHECK checksaldo IN kksaldo2.
      CHECK: checkagobl IN agoblig2.
    ENDIF.

    IF NOT pzuor IS INITIAL.
      PERFORM einzelposten_link.
    ENDIF.

    CLEAR sel-post2.
    LOOP AT hlfb1.
      lfb1 = hlfb1.
      LOOP AT c2
        WHERE bukrs = lfb1-bukrs.
        CLEAR c.
        MOVE-CORRESPONDING c2 TO c.
        EXIT.
      ENDLOOP.
      PERFORM summ_c3.
      CLEAR sel-postn.
      PERFORM einzelposten_proc.

* Bei SORTART = '2' werden nur dann Stammsatzdaten ausgegeben, wenn -*
* auch Einzelposten gerastert wurden. -------------------------------*
      IF rastverd < '3'.
        IF sortart = '2'.
          CHECK sel-postn = 'J'.
        ENDIF.
        IF NOT kausgabe IS INITIAL.
          CHECK sel-postn = 'J'.
        ENDIF.
      ENDIF.

      sel-post2 = 'J'.
      CLEAR: gb,
             rasteruu,
             tage.
      MOVE '1' TO satzart.
* Stammdaten extrahieren ---------------------------------------------*
      CLEAR bsik.
      EXTRACT stammdaten.
* OP-Raster extrahieren ----------------------------------------------*
      SORT rtab ASCENDING.

      LOOP AT rtab
        WHERE bukrs = lfb1-bukrs.
        MOVE:     '2'    TO satzart,
              rtab-gsber TO gb-gsber,
              rtab-waers TO gb-waers,
              rtab-raart TO rasteruu.
        EXTRACT op-raster.
        CLEAR rtab-bukrs.
        COLLECT rtab.
      ENDLOOP.
    ENDLOOP.

    CLEAR lfb1.
* Bei SORTART = '2' werden nur dann Stammsatzdaten ausgegeben, wenn -*
* auch Einzelposten gerastert wurden. -------------------------------*
    CLEAR c.
    IF wflag2 IS INITIAL.
      MOVE-CORRESPONDING c3 TO c.
    ENDIF.
    IF rastverd < '3'.
      IF sortart = '2'.
        CHECK sel-post2 = 'J'.
      ENDIF.
      IF NOT kausgabe IS INITIAL.
        CHECK sel-post2 = 'J'.
      ENDIF.
    ENDIF.

    CLEAR: gb,
           rasteruu,
           tage.
    MOVE '1' TO satzart.
* Stammdaten extrahieren ---------------------------------------------*
    CLEAR bsik.
    EXTRACT stammdaten.
* OP-Raster extrahieren ----------------------------------------------*
    SORT rtab ASCENDING.

    LOOP AT rtab
      WHERE bukrs = lfb1-bukrs.
      MOVE:     '2'    TO satzart,
            rtab-gsber TO gb-gsber,
            rtab-waers TO gb-waers,
            rtab-raart TO rasteruu.
      EXTRACT op-raster.
    ENDLOOP.
  ENDIF.
  CLEAR adrs.
END-OF-SELECTION.


*---------------------------------------------------------------------*
*        Aufbereitung                                                 *
*---------------------------------------------------------------------*
  CREATE OBJECT lo_writer.

  CLEAR   rtab.
  REFRESH rtab.
  IF konzvers = space.
*****Code for summerization level 6 on selection screen
   if verdicht = '6'.          "  475950
          sort by lfb1-bukrs   "  475950
              satzart          "  475950
                 rtab-sortk    "  475950
               gb              " 475950
               rasteruu        " 475950
               lfa1-lifnr      " 475950
               tage            " 475950
               bsik-umskz      " 475950
               bsik-blart      " 475950
               bsik-belnr      " 475950
               bsik-buzei.     " 475950
    else.                      " 475950
    SORT BY  lfb1-bukrs
             lfa1-lifnr
             satzart
             rtab-sortk
             gb
             rasteruu
             tage
             bsik-umskz
             bsik-blart
             bsik-belnr
             bsik-buzei.
   endif.                     "475950
  ELSE.
    SORT BY  lfa1-lifnr
             lfb1-bukrs
             satzart
             rtab-sortk
             gb
             rasteruu
             tage
             bsik-umskz
             bsik-blart
             bsik-belnr
             bsik-buzei.
  ENDIF.

  LOOP.
    AT FIRST.
      IF konzvers = 'X'.
        MOVE '0000' TO bhdgd-werte.
        PERFORM new-section(rsbtchh0).
      ENDIF.
    ENDAT.

    IF konzvers IS INITIAL.
      AT NEW lfb1-bukrs.
        MOVE lfb1-bukrs    TO bhdgd-grpin(4).     "<= Micro-Fiche Info
        MOVE lfb1-bukrs    TO bhdgd-bukrs.
        MOVE bhdgd-bukrs TO bhdgd-werte.
* For summarization level 5, new section heading not needed.
        IF VERDICHT NE '5'.                " 475950
          PERFORM NEW-SECTION(RSBTCHH0).
        ELSE.                              " 475950
          SKIP.                            " 475950
        ENDIF.                             " 475950
"        PERFORM new-section(rsbtchh0).
        CLEAR   rbuk.
        REFRESH rbuk.
        SELECT SINGLE * FROM t001 WHERE bukrs EQ lfb1-bukrs.
        IF waers EQ space.
          MOVE t001-waers TO waers.
        ENDIF.

*-  Betraege in    gemaess Skalierung aufbereiten --------------------*
        CLEAR h-text.
        IF faktor(1) GT '0'.
          MOVE '1' TO h-text.
          WHILE sy-index LT 10 AND sy-index LE faktor(1).

      DATA :  LV_TEXT(15).                       " 475950
              LV_TEXT = H-TEXT+SY-INDEX .        " 475950
              ASSIGN LV_TEXT TO <F1>.            " 475950
"            ASSIGN h-text+sy-index(1) TO <f1>.  " 475950
            MOVE '0' TO <f1>.
          ENDWHILE.
        ENDIF.

        MOVE t001-waers TO h-text+10.
        CONDENSE h-text.
"        l_hlp_txt = h-text.               " 475950

        DO 15 TIMES.
          h-offset = 15 - sy-index.
          ASSIGN h-text+h-offset(1) TO <f1>.
          IF <f1> = space.
            MOVE  '-' TO <f1>.
          ELSE.
            ASSIGN <f1>+1 TO <f1>.
            MOVE space TO <f1>.
            EXIT.
          ENDIF.
        ENDDO.

*******Below changes / comments are from ECC custom code
        IF sortart = '1'.
"          MOVE text-607 TO l_title_part2.
"          REPLACE '$SKAL'  WITH l_hlp_txt   INTO l_title_part2.
        ELSE.
          IF rastverd < '2'.
"            MOVE text-665 TO l_title_part2.
          ELSE.
"            MOVE text-607 TO l_title_part2.                             " 475950
"            REPLACE '$SKAL'  WITH l_hlp_txt   INTO l_title_part2.       " 475950
          ENDIF.
        ENDIF.
        WRITE kd_stida TO h-stichtag DD/MM/YY.

 "       REPLACE '$STIDA' WITH h-stichtag INTO l_title_part2.
"  Start of changes by Bharani
        IF VERDICHT = '5'.                   "DVAK941167 - summ 5
* Write out header for option 5 summarization
          FORMAT RESET.
          WRITE: /01 SY-VLINE, 02 SY-ULINE(197),
                 199 SY-VLINE.
          WRITE: /01 SY-VLINE,
                03(04) TEXT-060 COLOR COL_HEADING INTENSIFIED ON,
                08(08) TEXT-061 COLOR COL_HEADING INTENSIFIED ON,
                17(17) TEXT-062 COLOR COL_HEADING INTENSIFIED ON,
                35(05) TEXT-063 COLOR COL_HEADING INTENSIFIED ON,
                41(15) TEXT-077 COLOR COL_HEADING INTENSIFIED ON,
                57(15) TEXT-078 COLOR COL_HEADING INTENSIFIED ON,
                73(13) TEXT-079 COLOR COL_HEADING INTENSIFIED ON,
                87(15) TEXT-080 COLOR COL_HEADING INTENSIFIED ON,
                103(15) TEXT-081 COLOR COL_HEADING INTENSIFIED ON,
                119(15) TEXT-082 COLOR COL_HEADING INTENSIFIED ON,
                135(15) TEXT-083 COLOR COL_HEADING INTENSIFIED ON,
                151(15) TEXT-084 COLOR COL_HEADING INTENSIFIED ON,
                167(15) TEXT-085 COLOR COL_HEADING INTENSIFIED ON,
                183(15) TEXT-086 COLOR COL_HEADING INTENSIFIED ON,
                199(01) SY-VLINE.
          WRITE: /01 SY-VLINE, 02 SY-ULINE(197),
                 199 SY-VLINE.
        ENDIF.
" End of changes by Bharani
      ENDAT.


      AT NEW lfa1-lifnr.
        MOVE lfa1-lifnr  TO bhdgd-grpin+6(10).  "<= Micro-Fiche Info
        CLEAR gbzaehl.
*-- Nur bei Verdichtungsstufe < 2 erfolgt Seitenvorschub pro Konto ---*
        IF verdicht < '2'.
"          IF p_acc IS INITIAL.     " 475950
            NEW-PAGE.
"          ENDIF.                   " 475950
*---- Es bleibt Platz fuer ein Raster --------------------------------*
          RESERVE 5 LINES.
        ENDIF.
        top-flag = '0'.

*-- Bei Verdichtungsstufe '2' und Ausgabe von OP-Rastern muss Platz --*
*-- fuer Stamminfo inclusive Ueberschrift bleiben, weil kein Seiten- -*
*-- vorschub bei neuem Konto erfolgt. --------------------------------*
        IF verdicht = '2' AND rastverd < '2'.
          RESERVE 10 LINES.
        ENDIF.

*-- Bei Verdichtungsstufe '2'  o h n e  Ausgabe von OP-Rastern muss --*
*-- Platz fuer Stamminfo ohne Ueberschrift bleiben, weil kein Seiten- *
*-- vorschub bei neuem Konto erfolgt. --------------------------------*
*-- Die Ueberschrift wird einmal bei TOP-OF-PAGE ausgegeben. ---------*
*-- TOP-FLAG = '4' ---------------------------------------------------*
        IF verdicht = '2' AND rastverd = '2'.
          RESERVE  7 LINES.
        ENDIF.
      ENDAT.
    ELSE.
      AT NEW lfa1-lifnr.
        MOVE lfa1-lifnr  TO bhdgd-grpin(10).  "<= Micro-Fiche Info
        IF sortart = '1'.
"          MOVE text-670 TO l_title_part2.    " 475950
        ELSE.
          IF rastverd < '2'.
"            MOVE text-665 TO l_title_part2.  " 475950
          ELSE.
"            MOVE text-670 TO l_title_part2.  " 475950
          ENDIF.
        ENDIF.
        WRITE kd_stida TO h-stichtag DD/MM/YY.
"        REPLACE '$STIDA' WITH h-stichtag INTO l_title_part2.  "475950
      ENDAT.

      AT NEW lfb1-bukrs.
        CLEAR   rbuk.
        REFRESH rbuk.
        CLEAR gbzaehl.
        MOVE lfb1-bukrs    TO bhdgd-grpin+10(4).  "<= Micro-Fiche Info

        IF NOT lfb1-bukrs IS INITIAL.
          READ TABLE ht001 WITH KEY bukrs = lfb1-bukrs.
          t001 = ht001.
          IF waers EQ space.
            MOVE t001-waers TO waers.
          ENDIF.
        ENDIF.
" Begin of changes by Bharani
        IF VERDICHT = '5'.                   "DVAK941167 - summ 5
* Write out header for option 5 summarization
          WRITE: /01 SY-VLINE, 02 SY-ULINE(197),
                 199 SY-VLINE.
          WRITE: /01 SY-VLINE,
                03(04) TEXT-060 COLOR COL_HEADING INTENSIFIED ON,
                08(08) TEXT-061 COLOR COL_HEADING INTENSIFIED ON,
                17(17) TEXT-062 COLOR COL_HEADING INTENSIFIED ON,
                35(05) TEXT-063 COLOR COL_HEADING INTENSIFIED ON,
                41(15) TEXT-077 COLOR COL_HEADING INTENSIFIED ON,
                57(15) TEXT-078 COLOR COL_HEADING INTENSIFIED ON,
                73(13) TEXT-079 COLOR COL_HEADING INTENSIFIED ON,
                87(15) TEXT-080 COLOR COL_HEADING INTENSIFIED ON,
                103(15) TEXT-081 COLOR COL_HEADING INTENSIFIED ON,
                119(15) TEXT-082 COLOR COL_HEADING INTENSIFIED ON,
                135(15) TEXT-083 COLOR COL_HEADING INTENSIFIED ON,
                151(15) TEXT-084 COLOR COL_HEADING INTENSIFIED ON,
                167(15) TEXT-085 COLOR COL_HEADING INTENSIFIED ON,
                183(15) TEXT-086 COLOR COL_HEADING INTENSIFIED ON,
                199(01) SY-VLINE.
          WRITE: /01 SY-VLINE, 02 SY-ULINE(197),
                 199 SY-VLINE.
        ENDIF.
" End of changes by Bharani
      ENDAT.

    ENDIF.

    AT NEW satzart.
      CASE satzart.
        WHEN '2'.                           "Raster
"          IF p_acc IS INITIAL.
            IF rastverd < '2'.
              IF verdicht < '3'.
                IF  NOT konzvers IS INITIAL
                AND NOT lfb1-bukrs IS INITIAL.
                  CHECK xbukrdat NE '2'.
                ENDIF.

*-------- Wenn ein neues Raster beginnt, muessen mindestens noch -----*
*-------- 9 Zeilen Platz haben. --------------------------------------*
                top-flag = '3'.
                RESERVE 9 LINES.
              IF SORTART = '1'.
                WRITE: /01 SY-VLINE,
                        02 VARUEB1-FELD1,
                        48 SY-VLINE,
                        49 VARUEB1-FELD2,
                        62 SY-VLINE,
                        63 VARUEB1-FELD3,
                        76 SY-VLINE,
                        77 VARUEB1-FELD4,
                        90 SY-VLINE,
                        91 VARUEB1-FELD5,
                       104 SY-VLINE,
                       105 VARUEB1-FELD6,
                       118 SY-VLINE,
                       119 VARUEB1-FELD7,
                       132 SY-VLINE.
                WRITE: /01 SY-VLINE,
                        02 VARUEB2-FELD1,
                        48 SY-VLINE,
                        49 VARUEB2-FELD2,
                        62 SY-VLINE,
                        63 VARUEB2-FELD3,
                        76 SY-VLINE,
                        77 VARUEB2-FELD4,
                        90 SY-VLINE,
                        91 VARUEB2-FELD5,
                       104 SY-VLINE,
                       105 VARUEB2-FELD6,
                       118 SY-VLINE,
                       119 VARUEB2-FELD7,
                       132 SY-VLINE.
              ELSE.
                WRITE: /01 SY-VLINE,   "Anordnung Raster
                        02 VARUEB1-FELD1,             " wie bei Dopr00
                        42 SY-VLINE,
                        43 VARUEB1-FELD2,
                        57 SY-VLINE,
                        58 VARUEB1-FELD3,
                        72 SY-VLINE,
                        73 VARUEB1-FELD4,
                        87 SY-VLINE,
                        88 VARUEB1-FELD5,
                       102 SY-VLINE,
                       103 VARUEB1-FELD6,
                       117 SY-VLINE,
                       118 VARUEB1-FELD7,
                       132 SY-VLINE.
                WRITE: /01 SY-VLINE,
                        02 VARUEB2-FELD1,
                        42 SY-VLINE,
                        43 VARUEB2-FELD2,
                        57 SY-VLINE,
                        58 VARUEB2-FELD3,
                        72 SY-VLINE,
                        73 VARUEB2-FELD4,
                        87 SY-VLINE,
                        88 VARUEB2-FELD5,
                       102 SY-VLINE,
                       103 VARUEB2-FELD6,
                       117 SY-VLINE,
                       118 VARUEB2-FELD7,
                       132 SY-VLINE.
                ENDIF.
              ENDIF.
            ENDIF.
"          ENDIF.

        WHEN '3'.                      "Einzelposten
" Start of changes by Bharani
          FORMAT COLOR COL_HEADING INTENSIFIED OFF.
          IF VERDICHT = '0'.                " summ 6
*       SUMMARY.
            WRITE:  /01 SY-VLINE, 02 TEXT-108, 132 SY-VLINE.
*              / TEXT-109.
*       DETAIL.
            WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
          ELSE.                        " summ 6
* Write out header for option 6 summarization.
            FORMAT RESET.
            WRITE: /01 SY-VLINE, 02 SY-ULINE(181), 182 SY-VLINE.
            WRITE: /01 SY-VLINE,
                  03(04) TEXT-060 COLOR COL_HEADING INTENSIFIED ON,
                  08(08) TEXT-061 COLOR COL_HEADING INTENSIFIED ON,
                  17(17) TEXT-062 COLOR COL_HEADING INTENSIFIED ON,
                  35(05) TEXT-063 COLOR COL_HEADING INTENSIFIED ON,
                  41(10) TEXT-064 COLOR COL_HEADING INTENSIFIED ON,
                  52(02) TEXT-065 COLOR COL_HEADING INTENSIFIED ON,
                  55(10) TEXT-066 COLOR COL_HEADING INTENSIFIED ON,
                  66(10) TEXT-067 COLOR COL_HEADING INTENSIFIED ON,
                  77(10) TEXT-068 COLOR COL_HEADING INTENSIFIED ON,
                  88(05) TEXT-069 COLOR COL_HEADING INTENSIFIED ON,
                  94(13)  TEXT-070 COLOR COL_HEADING INTENSIFIED ON,
                  108(13) TEXT-071 COLOR COL_HEADING INTENSIFIED ON,
                  122(13) TEXT-072 COLOR COL_HEADING INTENSIFIED ON,
                  136(15) TEXT-073 COLOR COL_HEADING INTENSIFIED ON,
                  152(06) TEXT-074 COLOR COL_HEADING INTENSIFIED ON,
                  159(15) TEXT-075 COLOR COL_HEADING INTENSIFIED ON,
                  175(06) TEXT-076 COLOR COL_HEADING INTENSIFIED ON,
                  182 SY-VLINE.
            WRITE: /01 SY-VLINE, 02 SY-ULINE(181), 182 SY-VLINE.
          ENDIF.
" End of changes by Bharani
          top-flag = '1'.
      ENDCASE.
    ENDAT.

    AT stammdaten.                     "Satzart '1'
"      IF p_acc IS INITIAL.    " 475950
        IF verdicht < '3'.
          DETAIL.

          IF  NOT konzvers IS INITIAL
          AND NOT lfb1-bukrs IS INITIAL.
            IF  xbukrdat = '2'
            AND verdicht > '0'.
              CHECK 1 = 2.
            ENDIF.
          ENDIF.
" Start of changes by Bharani
        IF  NOT KONZVERS   IS INITIAL
        AND NOT LFB1-BUKRS IS INITIAL
        AND XBUKRDAT = '2'.
        ELSE.
          FORMAT COLOR COL_HEADING INVERSE.
          WRITE: 01 SY-VLINE, 02 VARUEB4(130), 132 SY-VLINE.
          FORMAT COLOR COL_HEADING INVERSE OFF.
        ENDIF.
*       FORMAT COLOR COL_GROUP INTENSIFIED.
        FORMAT COLOR COL_HEADING INTENSIFIED.
        IF KONZVERS IS INITIAL.
          WRITE: /01 SY-VLINE,
                  TEXT-110,
                  LFB1-BUKRS,
                  TEXT-111,
                  LFB1-BUSAB,
                  TEXT-112,
                  LFA1-LIFNR,
                  132 SY-VLINE.
        ELSE.
          IF LFB1-BUKRS IS INITIAL.
            WRITE: /01 SY-VLINE,
                    TEXT-112,
                    LFA1-LIFNR,
                    132 SY-VLINE.
" End of changes by Bharani
          ELSE.
" Start of changes by Bharani
            WRITE: /01 SY-VLINE,
                    TEXT-112,
                    LFA1-LIFNR,
                    TEXT-110,
                    LFB1-BUKRS,
                    TEXT-111,
                    LFB1-BUSAB,
                    132 SY-VLINE.
" End of changes by bharani
          ENDIF.

" Start of changes by Bharani
          IF  NOT konzvers   IS INITIAL
          AND NOT lfb1-bukrs IS INITIAL
          AND xbukrdat = '2'.
          ELSE.
"            CONCATENATE l_title_1 ',' l_title_part2 INTO l_title_1 SEPARATED BY space.
            write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline. " 475950
          ENDIF.
          top-flag = '4'.
          PERFORM anschrift.
"          intens = 'X'.  " 475950
        ENDIF.
" End of changes by Bharani

      ENDIF.
    ENDAT.

    AT op-raster.                      "Satzart '2'
      IF verdicht < '3' or verdicht = '5'.   " 475950
"        IF p_acc IS INITIAL.
       if verdicht ne '5'.        " 475950
          NEW-LINE.
        ENDIF.
        PERFORM raster_ausgabe.
      ENDIF.
*-- Summen fuer hoehere Gruppenstufen bilden --------------------------*
"      IF p_acc IS INITIAL.  "  475950
        PERFORM sum_bukrs_total.
"      ENDIF.                "  475950
    ENDAT.

    AT einzelposten.                   "Satzart '3'
      RESERVE 2 LINES.
      NEW-LINE.
      PERFORM einzelposten_ausgabe.
    ENDAT.

    AT END OF rasteruu.
      IF satzart = '3'.
" Start of changes by Bharani
        format color col_total intensified off.
          if verdicht = '6'.
            write: /01 sy-vline, 02 sy-uline(180), 182 sy-vline.
          else.
            write: /01 sy-vline, 02 sy-uline(131), 132 sy-vline.
          endif.
" End of changes by Bharani
        CASE rasteruu.
          WHEN '1'.
            MOVE text-052 TO vartxt1.
            REPLACE '$BIS' WITH rc01 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
            IF VERDICHT = '6'.            " summ 6
              WRITE: /01 SY-VLINE,
                      120 VARTXT1,
                      159(15) SUM(SHBETRAG)
                              CURRENCY T001-WAERS,
                      175(1)  '*',
                      182(1) SY-VLINE.
            ELSE.                         " summ 6
              WRITE: /01 SY-VLINE,
                      40 VARTXT1,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                  ROUND FAKTOR DECIMALS STELLEN,
*                             '*'  UNDER BSIk-WAERS.
                                  '*'  UNDER BSIK-WAERS,
                     132(1)  SY-VLINE.
            ENDIF.
" ENd of changes by Bharani
          WHEN '2'.
            IF NOT rc02 IS INITIAL.
              MOVE text-053 TO vartxt1.
              REPLACE '$VON' WITH rc06 INTO vartxt1.
              REPLACE '$BIS' WITH rc02 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              IF VERDICHT < '5'.            " summ 6
                WRITE: /01 SY-VLINE,
                        40 VARTXT1,
                        87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
*                               '*'  UNDER BSIk-WAERS.
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 132 SY-VLINE.
              ELSE.                         " summ 6
                WRITE: /01 SY-VLINE,
                        120 VARTXT1,
                        159(15) SUM(SHBETRAG) CURRENCY T001-WAERS,
                        175(1)  '*'.
                WRITE: 182(1) SY-VLINE.
              ENDIF.                        " summ 6
" ENd of changes by Bharani

            ELSE.
              MOVE text-054 TO vartxt1.
              REPLACE '$VON' WITH rc06 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              WRITE: /01 SY-VLINE,
                      40 VARTXT1,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
*                               '*'  UNDER BSIK-WAERS.
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 132 SY-VLINE.
" End of changes by Bharani
            ENDIF.

          WHEN '3'.
            IF NOT rc03 IS INITIAL.
              MOVE text-053 TO vartxt1.
              REPLACE '$VON' WITH rc07 INTO vartxt1.
              REPLACE '$BIS' WITH rc03 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              IF VERDICHT < '5'.             " summ 6
                WRITE: /01 SY-VLINE,
                        40 VARTXT1,
                        87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 132 SY-VLINE.
              ELSE.                          " summ 6
                WRITE: /01 SY-VLINE,
                        120 VARTXT1,
                        159(15) SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                        round faktor decimals stellen,
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 182 SY-VLINE.
              ENDIF.                         " summ 6
" End of changes by Bharani
            ELSE.
              MOVE text-054 TO vartxt1.
              REPLACE '$VON' WITH rc07 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              WRITE: /01 SY-VLINE,
                      40 VARTXT1,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
*                               '*'  UNDER BSIK-WAERS.
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 132 SY-VLINE.
" End of changes by Bharani
            ENDIF.

          WHEN '4'.
            IF NOT rc04 IS INITIAL.
              MOVE text-053 TO vartxt1.
              REPLACE '$VON' WITH rc08 INTO vartxt1.
              REPLACE '$BIS' WITH rc04 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              IF VERDICHT < '5'.             " summ 6
                WRITE: /01 SY-VLINE,
                        40 VARTXT1,
                        87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 132 SY-VLINE.
              ELSE.                        " summ 6
                WRITE: /01 SY-VLINE,
                        120 VARTXT1,
                        159(15) SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                     round faktor decimals stellen,
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 182 SY-VLINE.
              ENDIF.                       " summ 6
" End of changes by Bharani
            ELSE.
              MOVE text-054 TO vartxt1.
              REPLACE '$VON' WITH rc08 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              WRITE: /01 SY-VLINE,
                      40 VARTXT1,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
*                               '*'  UNDER BSIK-WAERS.
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 132 SY-VLINE.
" End of change by Bharani
            ENDIF.

          WHEN '5'.
            IF NOT rc05 IS INITIAL.
              MOVE text-053 TO vartxt1.
              REPLACE '$VON' WITH rc09 INTO vartxt1.
              REPLACE '$BIS' WITH rc05 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              IF VERDICHT < '5'.           " summ 6
                WRITE: /01 SY-VLINE,
                        40 VARTXT1,
                        87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 132 SY-VLINE.
              ELSE.                        " summ 6
                WRITE: /01 SY-VLINE,
                        120 VARTXT1,
                        159(15) SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                     round faktor decimals stellen,
                                    '*'  UNDER BSIK-WAERS.
                WRITE: 182 SY-VLINE.
              ENDIF.                        " summ 6
" ENd of change by bharani
            ELSE.
              MOVE text-054 TO vartxt1.
              REPLACE '$VON' WITH rc09 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
              WRITE: /01 SY-VLINE,
                      40 VARTXT1,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                    ROUND FAKTOR DECIMALS STELLEN,
*                               '*'  UNDER BSIK-WAERS.
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 132 SY-VLINE.
" End of change by Bharani
            ENDIF.

          WHEN '6'.
            MOVE text-054 TO vartxt1.
            REPLACE '$VON' WITH rc10 INTO vartxt1.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
            IF VERDICHT < '5'.             " summ 6
              WRITE: /01 SY-VLINE,
                      40 VARTXT1,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                  ROUND FAKTOR DECIMALS STELLEN,
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 132 SY-VLINE.
            ELSE.                          " summ 6
              WRITE: /01 SY-VLINE,
                      120 VARTXT1,
                      159(15) SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                      round faktor decimals stellen,
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 182 SY-VLINE.
            ENDIF.                        " summ 6
" End of change by Bharani
          WHEN OTHERS.
" Start of changes by Bharani. Change the code
" to display the report output by write statements
            IF VERDICHT < '5'.            " summ 6
              WRITE: /01 SY-VLINE,
                      87 SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                  ROUND FAKTOR DECIMALS STELLEN,
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 132 SY-VLINE.
            ELSE.                         " summ 6
              WRITE: /01 SY-VLINE,
                      159(15) SUM(SHBETRAG) CURRENCY T001-WAERS,
*                                   round faktor decimals stellen,
                                  '*'  UNDER BSIK-WAERS.
              WRITE: 182 SY-VLINE.
            ENDIF.                        " summ 6
" End of change by Bharani
        ENDCASE.
" Start of change by Bharani
        IF VERDICHT = '6'.                " summ 6
          WRITE: /01 SY-VLINE, 02 SY-ULINE(181), 182 SY-VLINE.
        ELSE.                             " summ 6
          WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
        ENDIF.                            " summ 6
" End of change by Bharani
      ENDIF.
    ENDAT.

    AT END OF satzart.
      IF satzart = '2'.
        IF rastverd < '2'.
          IF verdicht < '3'.
" Start of change by Bharani
            IF VERDICHT NE '6' AND             " summ 6
               VERDICHT NE '5'.                " summ 5
              WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
            ELSE.
              WRITE: /01 SY-VLINE, 02 SY-ULINE(180), 182 SY-VLINE.
            ENDIF.
" End of change by Bharani
            ENDIF.
          ENDIF.
        ENDIF.
"      ENDIF.
    ENDAT.


"    IF p_acc IS INITIAL.
      IF konzvers IS INITIAL.
        AT END OF lfb1-bukrs.
          MOVE space     TO bhdgd-grpin+4. "<= Micro-Fiche Info
          IF verdicht < '4' or verdicht = '5'. " 475950
             if verdicht NE '5'.
            NEW-PAGE.
              endif.
            MOVE text-050 TO varueb3.
            REPLACE '$BUK' WITH lfb1-bukrs    INTO varueb3.
            top-flag = '2'.
            PERFORM raster_ausgabe_bukrb.
          ENDIF.
        ENDAT.
        AT END OF lfb1-bukrs.
          MOVE space     TO bhdgd-grpin+14. "<= Micro-Fiche Info
        ENDAT.

        AT END OF lfa1-lifnr.
          MOVE space       TO bhdgd-grpin+10.      "<= Micro-Fiche Info
        ENDAT.
      ELSE.
      ENDIF.
"    ENDIF.

    AT LAST.
" Start of changes by Bharani
      IF VERDICHT < '5'.                      " summ 5
        MOVE SPACE       TO BHDGD-GRPIN. "<= Micro-Fiche Info
        MOVE '    '      TO BHDGD-BUKRS.
        MOVE BHDGD-BUKRS TO BHDGD-WERTE.
        IF VERDICHT NE '5'.                   " summ 5
          PERFORM NEW-SECTION(RSBTCHH0).
        ENDIF.                                " summ 5
        MOVE TEXT-055 TO VARUEB3.
        TOP-FLAG = '2'.
        IF SORTART = '1'.
          MOVE TEXT-109 TO VARUEB4.
        ELSE.
          MOVE TEXT-165 TO VARUEB4.
        ENDIF.
*     WRITE kD_STIDA TO H-STICHTAG DD/MM/YY.
        REPLACE '$STIDA' WITH H-STICHTAG INTO VARUEB4.
        FLAG2 = 'X'.
        PERFORM RASTER_AUSGABE_TOTAL.
        CLEAR FLAG2.
      ENDIF.                                  " summ 5
" ENd of changes by Bharani
    ENDAT.
  ENDLOOP.


TOP-OF-PAGE.
*- Standard-Seitenkopf drucken --------------------------------------*
  PERFORM batch-heading(rsbtchh0).

*-- ab der zweiten Seite pro Konto Ueberschrift fuer Einzelposten ---*
  DETAIL.
  CASE top-flag.

    WHEN '1'.
" Start of changes by Bharani
        write: / sy-vline, 2 sy-uline(130), 132 sy-vline.
*     summary.
      format color col_heading intensified off.
      write: / sy-vline, 2 text-108, 132 sy-vline.
*            text-109.
      write: / sy-vline, 2 sy-uline(130), 132 sy-vline.
" End of changes by Bharani
*     detail.
*-- Ueberschriften fuer Listenteil 2 ausgeben -----------------------*
    WHEN '2'.
" Start of changes by Bharani
*     SUMMARY.
      FORMAT COLOR COL_HEADING INVERSE.
"      WRITE: /01 SY-VLINE, 02 VARUEB4(130), 132 SY-VLINE.
      FORMAT COLOR COL_HEADING INVERSE OFF.
*     FORMAT COLOR COL_GROUP INTENSIFIED.
      FORMAT COLOR COL_HEADING INTENSIFIED.
"      WRITE: /01 SY-VLINE, 02 VARUEB3(130), 132 SY-VLINE.
      WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
      FORMAT COLOR COL_HEADING INTENSIFIED OFF.
      IF SORTART = '1'.
        IF FLAG2 IS INITIAL.
          WRITE: /01 SY-VLINE,
                  02 VARUEB1-FELD1,
                  48 SY-VLINE,
                  49 VARUEB1-FELD2,
                  62 SY-VLINE,
                  63 VARUEB1-FELD3,
                  76 SY-VLINE,
                  77 VARUEB1-FELD4,
                  90 SY-VLINE,
                  91 VARUEB1-FELD5,
                 104 SY-VLINE,
                 105 VARUEB1-FELD6,
                 118 SY-VLINE,
                 119 VARUEB1-FELD7,
                 132 SY-VLINE.
          WRITE: /01 SY-VLINE,
                  02 VARUEB2-FELD1,
                  48 SY-VLINE,
                  49 VARUEB2-FELD2,
                  62 SY-VLINE,
                  63 VARUEB2-FELD3,
                  76 SY-VLINE,
                  77 VARUEB2-FELD4,
                  90 SY-VLINE,
                  91 VARUEB2-FELD5,
                 104 SY-VLINE,
                 105 VARUEB2-FELD6,
                 118 SY-VLINE,
                 119 VARUEB2-FELD7,
                 132 SY-VLINE.
        ELSE.
          WRITE: /01 SY-VLINE,         "Anordnung Raster
                  02 VARUEB1-FELD1,    " wie bei Dopr00
                  42 SY-VLINE,
                  43 VARUEB1-FELD2,
                  57 SY-VLINE,
                  58 VARUEB1-FELD3,
                  72 SY-VLINE,
                  73 VARUEB1-FELD4,
                  87 SY-VLINE,
                  88 VARUEB1-FELD5,
                 102 SY-VLINE,
                 103 VARUEB1-FELD6,
                 117 SY-VLINE,
                 118 VARUEB1-FELD7,
                 132 SY-VLINE.
          WRITE: /01 SY-VLINE,
                  02 VARUEB2-FELD1,
                  42 SY-VLINE,
                  43 VARUEB2-FELD2,
                  57 SY-VLINE,
                  58 VARUEB2-FELD3,
                  72 SY-VLINE,
                  73 VARUEB2-FELD4,
                  87 SY-VLINE,
                  88 VARUEB2-FELD5,
                 102 SY-VLINE,
                 103 VARUEB2-FELD6,
                 117 SY-VLINE,
                 118 VARUEB2-FELD7,
                 132 SY-VLINE.
        ENDIF.
      ELSE.
        WRITE: /01 SY-VLINE,           "Anordnung Raster
                02 VARUEB1-FELD1,      " wie bei Dopr00
                42 SY-VLINE,
                43 VARUEB1-FELD2,
                57 SY-VLINE,
                58 VARUEB1-FELD3,
                72 SY-VLINE,
                73 VARUEB1-FELD4,
                87 SY-VLINE,
                88 VARUEB1-FELD5,
               102 SY-VLINE,
               103 VARUEB1-FELD6,
               117 SY-VLINE,
               118 VARUEB1-FELD7,
               132 SY-VLINE.
        WRITE: /01 SY-VLINE,
                02 VARUEB2-FELD1,
                42 SY-VLINE,
                43 VARUEB2-FELD2,
                57 SY-VLINE,
                58 VARUEB2-FELD3,
                72 SY-VLINE,
                73 VARUEB2-FELD4,
                87 SY-VLINE,
                88 VARUEB2-FELD5,
               102 SY-VLINE,
               103 VARUEB2-FELD6,
               117 SY-VLINE,
               118 VARUEB2-FELD7,
               132 SY-VLINE.
      ENDIF.
      WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
*     DETAIL.
" End of changes by Bharani
    WHEN '3'.
*     SUMMARY.
*      uline.                                " summ 6
      WRITE: /01 SY-VLINE,                   " summ 6
              02 SY-ULINE(130),              " summ 6
              132 SY-VLINE.                  " summ 6
*     DETAIL.

*-- Ueberschrift fuer Stammsatzinformationen ------------------------*
    WHEN '4'.

      DETAIL.
      FORMAT COLOR COL_HEADING INVERSE.
"      WRITE: 01 SY-VLINE, 02 VARUEB4(130), 132 SY-VLINE.
      FORMAT COLOR COL_HEADING INVERSE OFF.
*     FORMAT COLOR COL_GROUP INTENSIFIED.
      FORMAT COLOR COL_HEADING INTENSIFIED.
      WRITE: /01 SY-VLINE,
              TEXT-110,
              LFB1-BUKRS,
              TEXT-111,
              LFB1-BUSAB,
              TEXT-112,
              LFA1-LIFNR,
              132 SY-VLINE.
      DETAIL.
      WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.

  ENDCASE.


*---------------------------------------------------------------------*
*       FORM CFAKTOR                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM cfaktor.
  IF t001-waers NE tcurx-currkey.
    SELECT SINGLE * FROM tcurx WHERE currkey = t001-waers.
    IF sy-subrc NE 0.
      tcurx-currkey = t001-waers.
      cfakt = 100.
    ELSE.
      cfakt = 1.
      DO tcurx-currdec TIMES.
        cfakt = cfakt * 10.
      ENDDO.
    ENDIF.
  ENDIF.
ENDFORM.                    "CFAKTOR

*---------------------------------------------------------------------*
*       FORM RASTER_AUFBAU                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM raster_aufbau.
* Erste ausgewaehlte Rasterarte sichern ------------------------------*
  IF rart-net = 'X'.
    rart = '1'.
  ELSE.
    IF rart-skt = 'X'.
      rart = '2'.
    ELSE.
      IF rart-alt = 'X'.
        rart = '3'.
      ELSE.
        IF rart-ueb = 'X'.
          rart = '4'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* Obergrenze Intervall -----------------------------------------------*
  rp01 = rastbis1.
  rp02 = rastbis2.
  rp03 = rastbis3.
  rp04 = rastbis4.
  rp05 = rastbis5.

* Untergrenze Intervall -----------------------------------------------*

  rp06 = rp01 + 1.
  IF NOT rp02 IS INITIAL.
    rp07 = rp02 + 1.
  ENDIF.
  IF NOT rp03 IS INITIAL.
    rp08 = rp03 + 1.
  ENDIF.
  IF NOT rp04 IS INITIAL.
    rp09 = rp04 + 1.
  ENDIF.
  IF NOT rp05 IS INITIAL.
    rp10 = rp05 + 1.
  ENDIF.

* Rasterpunkte in Charakterform für REPLACE.
  WRITE: rp01 TO rc01.
  IF NOT rp02 IS INITIAL.
    WRITE: rp02 TO rc02.
    MOVE text-202 TO varueb2-feld3.
  ENDIF.
  IF NOT rp03 IS INITIAL.
    WRITE: rp03 TO rc03.
    MOVE text-203 TO varueb2-feld4.
  ENDIF.
  IF NOT rp04 IS INITIAL.
    WRITE: rp04 TO rc04.
    MOVE text-204 TO varueb2-feld5.
  ENDIF.
  IF NOT rp05 IS INITIAL.
    WRITE: rp05 TO rc05.
    MOVE text-205 TO varueb2-feld6.
  ENDIF.
  IF NOT rp06 IS INITIAL.
    WRITE: rp06 TO rc06.
    MOVE text-206 TO varueb1-feld3.
  ENDIF.
  IF NOT rp07 IS INITIAL.
    WRITE: rp07 TO rc07.
    MOVE text-207 TO varueb1-feld4.
  ENDIF.
  IF NOT rp08 IS INITIAL.
    WRITE: rp08 TO rc08.
    MOVE text-208 TO varueb1-feld5.
  ENDIF.
  IF NOT rp09 IS INITIAL.
    WRITE: rp09 TO rc09.
    MOVE text-209 TO varueb1-feld6.
  ENDIF.
  IF NOT rp10 IS INITIAL.
    WRITE: rp10 TO rc10.
    MOVE text-210 TO varueb1-feld7.
  ENDIF.

* Variable ersetzen --------------------------------------------------*
  IF sortart = '1'.
    MOVE text-103 TO varueb1-feld1.
    MOVE text-163 TO varueb2-feld1.
    MOVE text-201 TO varueb2-feld2.
  ELSE.
    MOVE text-102 TO varueb1-feld1.
    MOVE text-106 TO varueb2-feld1.
    MOVE text-201 TO varueb2-feld2.
  ENDIF.

  REPLACE 'RP01' WITH rc01 INTO varueb2.                    "bis   0
  REPLACE 'RP02' WITH rc02 INTO varueb2.                    "bis  20
  REPLACE 'RP03' WITH rc03 INTO varueb2.                    "bis  40
  REPLACE 'RP04' WITH rc04 INTO varueb2.                    "bis  80
  REPLACE 'RP05' WITH rc05 INTO varueb2.                    "bis 100
  REPLACE 'RP06' WITH rc06 INTO varueb1.                    "von   1
  REPLACE 'RP07' WITH rc07 INTO varueb1.                    "von  21
  REPLACE 'RP08' WITH rc08 INTO varueb1.                    "von  41
  REPLACE 'RP09' WITH rc09 INTO varueb1.                    "von  81
  REPLACE 'RP10' WITH rc10 INTO varueb1.                    "von 101
ENDFORM.                    "RASTER_AUFBAU

*---------------------------------------------------------------------*
*       FORM SALDO_AKTUELL                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM saldo_aktuell.
  ADD lfc1-um01s THEN lfc1-um02s UNTIL lfc1-um16s GIVING h-soll
      ACCORDING TO bmonat.
  ADD lfc1-um01h THEN lfc1-um02h UNTIL lfc1-um16h GIVING h-haben
      ACCORDING TO bmonat.
  h-saldo  = h-soll - h-haben + lfc1-umsav.
* aktueller Saldo = Teil des Gesamtobligos --------------------------*
  PERFORM cfaktor.
  c-agobli = h-saldo.
  IF cfakt NE 0.
    checksaldo = checksaldo + h-saldo / cfakt.
    checkagobl = checkagobl + c-agobli / cfakt.
  ELSE.
    checksaldo = checksaldo + h-saldo.
    checkagobl = checkagobl + c-agobli.
  ENDIF.
  c-saldo  = h-saldo.
ENDFORM.                    "SALDO_AKTUELL

*---------------------------------------------------------------------*
*       FORM KUM_WERTE                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM kum_werte.
* Jahresumsatz -------------------------------------------------------*
  ADD lfc1-um01u THEN lfc1-um02u UNTIL lfc1-um16u GIVING c-kumum
      ACCORDING TO bmonat.
  IF sortart = '1' . "Ausgabe kum Kum.Umsatz wenn Hauswährung gewünscht.
* Kum. Umsatz---------------------------------------------------------*
    CLEAR rtab.
    MOVE: lfc1-bukrs TO rtab-bukrs.
* Satz für Ausgabe des kummulierten Umsatzes auf Summenebene.
* (Summe pro Sachbearbeiter und Buchungskreis)
    MOVE: '2' TO rtab-sortk,
    '** '   TO rtab-gsber,
    c-kumum TO rtab-kumum.
    COLLECT rtab.
  ENDIF.
ENDFORM.                    "KUM_WERTE

*---------------------------------------------------------------------*
*       FORM SONDER_UMSAETZE                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM sonder_umsaetze.
* Errechnen Sonderumsatz-Salden, Gesamtsaldo ------------------------*
*---------- Trend, Umsatz pro Gesch.Bereich -------------------------*
  h-shbls = lfc3-solll - lfc3-habnl.
*-- Gesamt-Obligo ----------------------------------------------------*
  c-agobli = lfc3-saldv + h-shbls.
  PERFORM cfaktor.
  IF cfakt NE 0.
    checkagobl = checkagobl + c-agobli / cfakt.
  ELSE.
    checkagobl = checkagobl + c-agobli.
  ENDIF.
*-- Sonderumsatz-Salden ----------------------------------------------*
  CASE lfc3-shbkz.
    WHEN humkz1.
      c-umkz1 = lfc3-shbkz.
      c-sums1 = c-sums1 + lfc3-saldv + h-shbls.
    WHEN humkz2.
      c-umkz2 = lfc3-shbkz.
      c-sums2 = c-sums2 + lfc3-saldv + h-shbls.
    WHEN humkz3.
      c-umkz3 = lfc3-shbkz.
      c-sums3 = c-sums3 + lfc3-saldv + h-shbls.
    WHEN humkz4.
      c-umkz4 = lfc3-shbkz.
      c-sums4 = c-sums4 + lfc3-saldv + h-shbls.
    WHEN humkz5.
      c-umkz5 = lfc3-shbkz.
      c-sums5 = c-sums5 + lfc3-saldv + h-shbls.
    WHEN humkz6.
      c-umkz6 = lfc3-shbkz.
      c-sums6 = c-sums6 + lfc3-saldv + h-shbls.
    WHEN humkz7.
      c-umkz7 = lfc3-shbkz.
      c-sums7 = c-sums7 + lfc3-saldv + h-shbls.
    WHEN humkz8.
      c-umkz8 = lfc3-shbkz.
      c-sums8 = c-sums8 + lfc3-saldv + h-shbls.
    WHEN humkz9.
      c-umkz9 = lfc3-shbkz.
      c-sums9 = c-sums9 + lfc3-saldv + h-shbls.
    WHEN humkz10.
      c-umkz10 = lfc3-shbkz.
      c-sums10 = c-sums10 + lfc3-saldv + h-shbls.
    WHEN OTHERS.
      c-sonob = c-sonob + lfc3-saldv + h-shbls.
  ENDCASE.

ENDFORM.                    "SONDER_UMSAETZE

*---------------------------------------------------------------------*
*       FORM POSTEN_RASTERN                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM posten_rastern USING  posten_waers.
  IF rart-net = 'X'.
    IF sortart = '1'.
      PERFORM r USING ntage '1' bsega-dmshb     posten_waers.
    ELSE.
      PERFORM r USING ntage '1' bsega-wrshb     posten_waers.
    ENDIF.
  ENDIF.

  IF rart-skt = 'X'.
    IF sortart = '1'.
      PERFORM r USING stage '2' bsega-dmshb     posten_waers.
    ELSE.
      PERFORM r USING stage '2' bsega-wrshb     posten_waers.
    ENDIF.
  ENDIF.
  IF rart-alt = 'X'.
    IF sortart = '1'.
      PERFORM r USING atage '3' bsega-dmshb     posten_waers.
    ELSE.
      PERFORM r USING atage '3' bsega-wrshb     posten_waers.
    ENDIF.
  ENDIF.
  IF rart-ueb = 'X'.
    IF sortart = '1'.
      PERFORM r USING utage '4' bsega-dmshb     posten_waers.
    ELSE.
      PERFORM r USING utage '4' bsega-wrshb     posten_waers.
    ENDIF.
  ENDIF.
ENDFORM.                    "POSTEN_RASTERN

*---------------------------------------------------------------------*
*       FORM R                                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM r USING r_tage r_art r_betrag r_waers.
  CLEAR rtab.
  MOVE: bsik-bukrs TO rtab-bukrs,
        '0'      TO rtab-sortk,
        bsik-gsber TO rtab-gsber,
        r_waers  TO rtab-waers,
        r_art    TO rtab-raart,
        r_betrag TO rtab-opsum.

*-- gesperrte Posten -------------------------------------------------*
  IF bsik-zlspr NE space.
    IF bsik-zlspr NE '*'.
      MOVE r_betrag TO rtab-sperr.
    ENDIF.
  ENDIF.

  IF r_tage <= rp01.
    MOVE: r_betrag TO rtab-rast1.
    IF r_art = rart.
      MOVE  '1'    TO rasteruu.
    ENDIF.
  ELSE.
    IF r_tage <= rp02
    OR rp07 IS INITIAL.
      MOVE: r_betrag TO rtab-rast2.
      IF r_art = rart.
        MOVE  '2'    TO rasteruu.
      ENDIF.
    ELSE.
      IF r_tage <= rp03
      OR rp08 IS INITIAL.
        MOVE: r_betrag TO rtab-rast3.
        IF r_art = rart.
          MOVE  '3'    TO rasteruu.
        ENDIF.
      ELSE.
        IF r_tage <= rp04
        OR rp09 IS INITIAL.
          MOVE: r_betrag TO rtab-rast4.
          IF r_art = rart.
            MOVE  '4'    TO rasteruu.
          ENDIF.
        ELSE.
          IF r_tage <= rp05
          OR rp10 IS INITIAL.
            MOVE: r_betrag TO rtab-rast5.
            IF r_art = rart.
              MOVE  '5'    TO rasteruu.
            ENDIF.
          ELSE.
            MOVE: r_betrag TO rtab-rast6.
            IF r_art = rart.
              MOVE  '6'    TO rasteruu.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  COLLECT rtab.
* Summieren ueber alle Geschaeftsbereiche ---------------------------*
* aber nur wenn SORTART = '1' ----------------------------------------*
  MOVE: '1'      TO rtab-sortk,
        '**'     TO rtab-gsber.
  COLLECT rtab.
ENDFORM.                    "R

*---------------------------------------------------------------------*
*       FORM ANSCHRIFT                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM anschrift.

****Start of changes by Bharani. This form has been copied from the
****ECC program.
  IF NOT lfb1-bukrs IS INITIAL.
    IF NOT konzvers IS INITIAL.
      CHECK xbukrdat = 0.
    ENDIF.
  ENDIF.
  PERFORM obligos.

  IF KONZVERS IS INITIAL.
* Ausgabe der Debitoreninformationen pro Buchungskreis
* <<<<<<<<<<<< Block 1>>>>>>>>>>>>>>>
*------------  Zeile 1 --------------
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE: /01 SY-VLINE,                 "Anschrift
       02  TEXT-113 INTENSIFIED,         "Anschrift
       39  SY-VLINE,
       40  TEXT-116 INTENSIFIED,         "Obligo
       90  SY-VLINE,
       91  TEXT-115 INTENSIFIED,         "Umsatzdaten
       132 SY-VLINE.
    WRITE: /01 SY-VLINE, 02 SY-ULINE(37), 39 SY-VLINE,
            40 SY-ULINE(50), 90 SY-VLINE, 91 SY-ULINE(41), 132 SY-VLINE.
*   99  TEXT-127 INTENSIFIED.                    "Zahlungsdaten
*------------  ZEILE 2 --------------
    FORMAT COLOR COL_BACKGROUND INTENSIFIED OFF.
    DETAIL.
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '1'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    WRITE:
       /01 SY-VLINE,
        02 ADRS-LINE0(35),               "Adressausgabe
        39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."1. Obligo
    IF NOT SHBBEZ IS INITIAL.
      WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
    ENDIF.
    WRITE:
    70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                    ROUND FAKTOR DECIMALS STELLEN.
    WRITE: 90 SY-VLINE,
        91 TEXT-122  COLOR COL_HEADING INVERSE,            "Jahresumsatz
    110    C-KUMUM  CURRENCY T001-WAERS NO-ZERO
                    ROUND FAKTOR DECIMALS STELLEN.
    WRITE: 132 SY-VLINE.
*------------  Zeile 3 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '2'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE1 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE1(35),             "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."2. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE:  90 SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 4 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '3'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE2 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE2(35),             "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."3. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 5 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '4'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE3 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE3(35),             "Adressausgabe
          39 SY-VLINE,                   "Adressausgabe
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."4. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 6 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '5'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE4 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE4(35),             "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."5. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 7 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '6'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE5 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE5(35),             "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."6. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 8 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '7'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE6 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE6(35),             "Adressausgabe
          39 SY-VLINE,                   "Adressausgabe
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."7. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 9 --------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '8'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE7 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE7(35),             "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."8. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 10 -------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '9'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE8 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE8(35),             "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."9. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 11 -------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '10'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
    ENDIF.
    IF NOT ADRS-LINE9 IS INITIAL
    OR NOT ASUMS      IS INITIAL.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE9(35),             "Adressausgabe
          39 SY-VLINE,
             SHBBEZ   UNDER TEXT-116.                       "10. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 12 -------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '11'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
      WRITE:
         /01 SY-VLINE,
          39 SY-VLINE,
          SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."11. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*------------  Zeile 13 -------------
    CLEAR SHBBEZ.
    CLEAR ASUMS.
    READ TABLE AOBLIGO INDEX '12'.
    IF SY-SUBRC = 0.
      SHBBEZ = AOBLIGO-LTEXT.
      ASUMS  = AOBLIGO-OBLIG.
      WRITE:
         /01 SY-VLINE,
          39 SY-VLINE,
             SHBBEZ   UNDER TEXT-116.                       "12. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90  SY-VLINE.
      WRITE: 132 SY-VLINE.
    ENDIF.
*SKIP.
*
*              Block 2
*
*------------  Zeile 1 --------------            "躡erschriften
*WRITE: / TEXT-129 INTENSIFIED.                    "Mahndaten
*
*------------  Zeile 2 --------------            "躡erschriften
*        DETAIL.
*WRITE: / TEXT-136   UNDER TEXT-129.               "Mahnbereich
*WRITE: 17     TXT_1.     CLEAR TXT_1.
*------------  Zeile 3 --------------            "躡erschriften
*WRITE: / TEXT-137   UNDER TEXT-136.               "Mahnverfahren
*WRITE: TXT_2      UNDER TXT_1. CLEAR TXT_2.
*------------  Zeile 4 --------------            "躡erschriften
*WRITE: / TEXT-138   UNDER TEXT-137.              "Kontonr Mahnempf鋘ger
*WRITE: TXT_3      UNDER TXT_2. CLEAR TXT_3.
*--------- Zeile 5 ------------------------
*WRITE: / TEXT-139    UNDER TEXT-138.              "Letzte Mahnung
*WRITE: TXT_4       UNDER TXT_3. CLEAR TXT_4.
*--------- Zeile 6 ------------------------
*WRITE: / TEXT-140   UNDER TEXT-139.               "Mahnstufe
*WRITE: TXT_5 UNDER TXT_4. CLEAR TXT_5.
*--------- Zeile 7 ------------------------
*WRITE: / TEXT-141   UNDER TEXT-140.               "Sachbearb. Mahnen
*WRITE: TXT_6 UNDER TXT_5. CLEAR TXT_6.
*--------- Zeile 8 ------------------------
*WRITE: / TEXT-142 UNDER TEXT-141.               "Mahnsperre
*WRITE: TXT_7      UNDER TXT_6. CLEAR TXT_7.
*--------- Zeile 9 ------------------------
*WRITE: / TEXT-143 UNDER TEXT-142.               "Dat.gerichtliche Mahn
*WRITE: TXT_8      UNDER TXT_7. CLEAR TXT_8.
  ELSE.
    IF LFB1-BUKRS IS INITIAL.
* Ausgabe der Debitoreninformationen pro Buchungskreis
* <<<<<<<<<<<< Block 1>>>>>>>>>>>>>>>
*------------  Zeile 1 --------------
      FORMAT COLOR COL_HEADING INTENSIFIED OFF.
      WRITE: /01 SY-VLINE,                 "Anschrift
         02  TEXT-113 INTENSIFIED,         "Anschrift
         39  SY-VLINE,
         40  TEXT-116 INTENSIFIED,         "Obligo
         90  SY-VLINE,
         91  TEXT-115 INTENSIFIED,         "Umsatzdaten
         132 SY-VLINE.
      WRITE: /01 SY-VLINE, 02 SY-ULINE(37), 39 SY-VLINE,
            40 SY-ULINE(50), 90 SY-VLINE, 91 SY-ULINE(41), 132 SY-VLINE.
*   99  TEXT-127 INTENSIFIED.                    "Zahlungsdaten
*------------  ZEILE 2 --------------
      FORMAT COLOR COL_BACKGROUND INTENSIFIED OFF.
      DETAIL.
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '1'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      WRITE:
         /01 SY-VLINE,
          02 ADRS-LINE0(35),               "Adressausgabe
          39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."1. Obligo
      IF NOT SHBBEZ IS INITIAL.
        WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
      ENDIF.
      WRITE:
      70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 90 SY-VLINE,
        91 TEXT-122  COLOR COL_HEADING INVERSE,            "Jahresumsatz
      110    C-KUMUM  CURRENCY T001-WAERS NO-ZERO
                      ROUND FAKTOR DECIMALS STELLEN.
      WRITE: 132 SY-VLINE.
*------------  Zeile 3 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '2'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE1 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE1(35),             "Adressausgabe
            39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."2. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE:  90 SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 4 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '3'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE2 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE2(35),             "Adressausgabe
            39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."3. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 5 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '4'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE3 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE3(35),             "Adressausgabe
            39 SY-VLINE,                   "Adressausgabe
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."4. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 6 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '5'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE4 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE4(35),             "Adressausgabe
            39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."5. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 7 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '6'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE5 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE5(35),             "Adressausgabe
            39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."6. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 8 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '7'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE6 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE6(35),             "Adressausgabe
            39 SY-VLINE,                   "Adressausgabe
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."7. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 9 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '8'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE7 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE7(35),             "Adressausgabe
            39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."8. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 10 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '9'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE8 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE8(35),             "Adressausgabe
            39 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."9. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 11 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '10'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ADRS-LINE9 IS INITIAL
      OR NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
            02 ADRS-LINE9(35),             "Adressausgabe
            39 SY-VLINE,
               SHBBEZ   UNDER TEXT-116.                     "10. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 12 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '11'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
        WRITE:
           /01 SY-VLINE,
            39 SY-VLINE,
          SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."11. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 13 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '12'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
        WRITE:
           /01 SY-VLINE,
            39 SY-VLINE,
               SHBBEZ   UNDER TEXT-116.                     "12. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 68     TEXT-161.
        ENDIF.
        WRITE:
        70     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 90  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
    ELSE.
* Buchungskreisdaten bei Konzernversion
* <<<<<<<<<<<< Block 1>>>>>>>>>>>>>>>
*------------  Zeile 1 --------------
      FORMAT COLOR COL_HEADING INTENSIFIED OFF.
      WRITE: /01 SY-VLINE,                 "Anschrift
         02  TEXT-116 INTENSIFIED,         "Obligo
         51  SY-VLINE,
         52  TEXT-115 INTENSIFIED,         "Umsatzdaten
         132 SY-VLINE.
      WRITE: /01 SY-VLINE, 02 SY-ULINE(50), 51 SY-VLINE,
              52 SY-ULINE(80), 132 SY-VLINE.
*   99  TEXT-127 INTENSIFIED.                    "Zahlungsdaten
*------------  ZEILE 2 --------------
      FORMAT COLOR COL_BACKGROUND INTENSIFIED OFF.
      DETAIL.
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '1'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL
      OR NOT C-KUMUM    IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."1. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51 SY-VLINE,
        52 TEXT-122  COLOR COL_HEADING INVERSE,            "Jahresumsatz
         72    C-KUMUM  CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 3 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '2'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."2. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE:  51 SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 4 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '3'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."3. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 5 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '4'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."4. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 6 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '5'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."5. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 7 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '6'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."6. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 8 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '7'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."7. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 9 --------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '8'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."8. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 10 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '9'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
           SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."9. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51 SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 11 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '10'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
      ENDIF.
      IF NOT ASUMS      IS INITIAL.
        WRITE:
           /01 SY-VLINE,
               SHBBEZ   UNDER TEXT-116.                     "10. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 12 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '11'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
        WRITE:
           /01 SY-VLINE,
          SHBBEZ   UNDER TEXT-116 COLOR COL_HEADING INVERSE."11. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161 COLOR COL_HEADING INVERSE.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
*------------  Zeile 13 -------------
      CLEAR SHBBEZ.
      CLEAR ASUMS.
      READ TABLE AOBLIGO INDEX '12'.
      IF SY-SUBRC = 0.
        SHBBEZ = AOBLIGO-LTEXT.
        ASUMS  = AOBLIGO-OBLIG.
        WRITE:
           /01 SY-VLINE,
               SHBBEZ   UNDER TEXT-116.                     "12. Obligo
        IF NOT SHBBEZ IS INITIAL.
          WRITE: 31     TEXT-161.
        ENDIF.
        WRITE:
        33     ASUMS    CURRENCY T001-WAERS NO-ZERO
                        ROUND FAKTOR DECIMALS STELLEN.
        WRITE: 51  SY-VLINE.
        WRITE: 132 SY-VLINE.
      ENDIF.
    ENDIF.
  ENDIF.

*    SKIP.
  WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
  IF RASTVERD = '2'.
    SKIP 1.
  ENDIF.
* ULINE.
* NEW-PAGE.


ENDFORM.                    "ANSCHRIFT

*---------------------------------------------------------------------*
*       FORM RASTER_AUSGABE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM raster_ausgabe.
****Start of changes by Bharani. This form has been changed by the same
**** code as in ECC

* Bei Verdichtung der Geschaeftsbereiche nur das Summenraster ausgeben*
  IF RASTVERD = '1'.                   " AND VERDICHT > 0.
    CHECK RTAB-SORTK = '1'.
  ENDIF.

* Das Summen-Raster wird nur ausgegeben, wenn mehr als ein Geschaefts-*
* bereich vorhanden ist. ---------------------------------------------*
  IF RTAB-SORTK = '1' AND RASTVERD NE '1'.
    CHECK GBZAEHL > 1.
  ENDIF.

  IF  NOT KONZVERS IS INITIAL
  AND NOT LFB1-BUKRS IS INITIAL.
    CHECK XBUKRDAT NE '2'.
  ENDIF.

  IF RTAB-SORTK NE '2'.
* Bei der ersten Rasterart       , Anzahlungen usw. ausgeben ---------*
    IF RASTERUU = RART.
      IF GB-GSBER NE '**'.
*   OR GB-GSBER NE '***'.
        GBZAEHL = GBZAEHL + 1.
      ENDIF.
      IF VERDICHT NE '5'.                       "DVAK941167 - summ 5
        WRITE: SY-ULINE(132).                   "DVAK941167 - summ 6
      ENDIF.                                    "DVAK941167 - summ 5
      RESERVE 5 LINES.

      IF GB-GSBER NE '**'.
        FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR COL_TOTAL INTENSIFIED.
      ENDIF.
      IF VERDICHT NE '5'.                       "DVAK941167 - summ 5
        TOP-FLAG = '2'.
        IF SORTART = '1'.
          WRITE:
              01 SY-VLINE,
              02(04) GB-GSBER,           " Geschaeftsbereich
              08(11) RTAB-SPERR CURRENCY T001-WAERS  " gesperrte Posten
                                ROUND FAKTOR DECIMALS STELLEN NO-ZERO,
              20(11) RTAB-ANZAH CURRENCY T001-WAERS  " Anzahlungen
                                ROUND FAKTOR DECIMALS STELLEN,
              32(12) RTAB-OPSUM CURRENCY T001-WAERS  " Offene Posten
                                ROUND FAKTOR DECIMALS STELLEN.
        ELSE.
          WRITE:
            01 SY-VLINE,
            02(04) GB-GSBER,             " Geschaeftsbereich
            08(05) GB-WAERS,             " Waehrung
            14(11) RTAB-ANZAH CURRENCY GB-WAERS    " Anzahlungen
                              ROUND FAKTOR DECIMALS STELLEN,
            26(12) RTAB-OPSUM CURRENCY GB-WAERS    " Offene Posten Summe
                              ROUND FAKTOR  DECIMALS STELLEN.
        ENDIF.
      ELSE.                              "DVAK941167 - summ 5
        WRITE:                           " Betraege in FW ausgeben
              03(04)  LFB1-BUKRS,
              08(08)  LFA1-LIFNR,
              17(17)  LFA1-NAME1,
              35(05)  LFA1-LAND1,
              41(15)  C-KUMUM  CURRENCY T001-WAERS NO-ZERO
                                        ROUND FAKTOR
                                        DECIMALS STELLEN,
              57(15)  RTAB-SPERR CURRENCY T001-WAERS
                                 ROUND FAKTOR DECIMALS STELLEN NO-ZERO,
              73(13)  RTAB-ANZAH CURRENCY T001-WAERS
                                 ROUND FAKTOR DECIMALS STELLEN NO-ZERO,
              87(15)  RTAB-OPSUM CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              103(15) RTAB-RAST1 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              119(15) RTAB-RAST2 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              135(15) RTAB-RAST3 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR DECIMALS STELLEN,
              151(15) RTAB-RAST4 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR DECIMALS STELLEN,
              167(15) RTAB-RAST5 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              183(15) RTAB-RAST6 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN.
      ENDIF.                                  " summ 5
    ELSE.
      WRITE: 01 SY-VLINE.
    ENDIF.

    IF VERDICHT NE '5'.                       " summ 5
      IF SORTART = '1'.
        CASE RASTERUU.
      WHEN '1'. WRITE: 45(3) TEXT-019, 48 SY-VLINE.             " Net-Fa
      WHEN '2'. WRITE: 45(3) TEXT-020, 48 SY-VLINE.             " Skt-Fa
      WHEN '3'. WRITE: 45(3) TEXT-021, 48 SY-VLINE.             " Zhl-Ei
      WHEN '4'. WRITE: 45(3) TEXT-022, 48 SY-VLINE.             " Ueb-Fa
        ENDCASE.
      ELSE.
        CASE RASTERUU.
      WHEN '1'. WRITE: 39(3) TEXT-019, 42 SY-VLINE.             " Net-Fa
      WHEN '2'. WRITE: 39(3) TEXT-020, 42 SY-VLINE.             " Skt-Fa
      WHEN '3'. WRITE: 39(3) TEXT-021, 42 SY-VLINE.             " Zhl-Ei
      WHEN '4'. WRITE: 39(3) TEXT-022, 42 SY-VLINE.             " Ueb-Fa
        ENDCASE.
      ENDIF.
      IF SORTART = '1'.

        WRITE:                           " Betraege in HW ausgeben
              (11) RTAB-RAST1 CURRENCY T001-WAERS NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 62  SY-VLINE,
              (11) RTAB-RAST2 CURRENCY T001-WAERS NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 76  SY-VLINE,
              (11) RTAB-RAST3 CURRENCY T001-WAERS NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 90  SY-VLINE,
              (11) RTAB-RAST4 CURRENCY T001-WAERS NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 104 SY-VLINE,
              (11) RTAB-RAST5 CURRENCY T001-WAERS NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 118 SY-VLINE,
              (11) RTAB-RAST6 CURRENCY T001-WAERS NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 132 SY-VLINE.
      ELSE.
        WRITE:                           " Betraege in FW ausgeben
              (12) RTAB-RAST1 CURRENCY GB-WAERS   NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 57  SY-VLINE,
              (12) RTAB-RAST2 CURRENCY GB-WAERS   NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 72  SY-VLINE,
              (12) RTAB-RAST3 CURRENCY GB-WAERS   NO-ZERO
                         ROUND FAKTOR DECIMALS STELLEN,  87  SY-VLINE,
              (12) RTAB-RAST4 CURRENCY GB-WAERS   NO-ZERO
                         ROUND FAKTOR DECIMALS STELLEN,  102 SY-VLINE,
              (12) RTAB-RAST5 CURRENCY GB-WAERS   NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 117 SY-VLINE,
              (12) RTAB-RAST6 CURRENCY GB-WAERS   NO-ZERO
                         ROUND FAKTOR  DECIMALS STELLEN, 132 SY-VLINE.
      ENDIF.
    ELSE.
      IF VERDICHT = '5'.                      "  summ 5
        WRITE:
            103(15) RTAB-RAST1 CURRENCY T001-WAERS NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            119(15) RTAB-RAST2 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            135(15) RTAB-RAST3 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR DECIMALS STELLEN,
            151(15) RTAB-RAST4 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR DECIMALS STELLEN,
            167(15) RTAB-RAST5 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            183(15) RTAB-RAST6 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            199(1) SY-VLINE.
      ENDIF.                                   " summ 5
    ENDIF.
  ENDIF.
ENDFORM.                    "RASTER_AUSGABE

*---------------------------------------------------------------------*
*       FORM SUM_BUKRS_TOTAL                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM sum_bukrs_total.
  IF rtab-sortk = '0'.
    IF       konzvers   IS INITIAL
    OR ( NOT konzvers   IS INITIAL
    AND  NOT rtab-bukrs IS INITIAL ) .
*-- Summen pro Buchungskreis -----------------------------------------*
      MOVE-CORRESPONDING rtab TO rbuk.
      MOVE: lfb1-bukrs TO  rbuk-bukrs,
            gb-gsber   TO  rbuk-gsber,
            gb-waers   TO  rbuk-waers.
      COLLECT rbuk.
*-- Gesamtsumme ueber alle Geschaeftsbereiche und Sachbearb. ---------*
*-- ermitteln, aber nur bei SORTART = '1' ----------------------------*
      MOVE: lfb1-bukrs TO  rbuk-bukrs,
            '**'       TO  rbuk-gsber,
            '1'        TO  rbuk-sortk.
      COLLECT rbuk.
    ENDIF.

*-- Summen fuer Listenteil 2 ermitteln -------------------------------*
    MOVE: lfb1-bukrs TO  rtab-bukrs,
          gb-gsber TO  rtab-gsber,
          gb-waers TO  rtab-waers.
    COLLECT rtab.

    IF       konzvers   IS INITIAL
    OR ( NOT konzvers   IS INITIAL
    AND      rtab-bukrs IS INITIAL ) .
      MOVE-CORRESPONDING rtab TO rsum.
      IF sortart = '1' AND konzvers IS INITIAL.
        MOVE: t001-waers TO  rsum-waers.
      ENDIF.
      MOVE: '1'        TO  rsum-sortk.
      COLLECT rsum.
    ENDIF.
  ENDIF.

  IF  rtab-sortk = '2'.
    IF sortart = '1'.
      MOVE-CORRESPONDING rtab TO rbuk.
      MOVE: lfb1-bukrs TO  rbuk-bukrs,
            gb-gsber   TO  rbuk-gsber,
            gb-waers   TO  rbuk-waers,
            '2'        TO  rbuk-sortk.
      COLLECT rbuk.
    ENDIF.
  ENDIF.

ENDFORM.                    "SUM_BUKRS_TOTAL

*---------------------------------------------------------------------*
*       FORM EINZELPOSTEN_AUSGABE                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM einzelposten_ausgabe.

* DETAIL.
  IF VERDICHT = '0'.
    WRITE: 01 SY-VLINE,
          02 LFB1-BUKRS,                 " Buchungskreis
             GB-GSBER,                   " Geschaeftsbereich
             TAGE,                       " Ueberzugstage
          21 BSIK-UMSKZ,                 " Umsatzkennzeichen
          23 BSIK-BLART,                 " Belegart
*       24 BSIK-ZUONR,                           " Zuordnungsnummer
          26 BSIK-BELNR,                 " Belegnummer
             BSIK-BUZEI,                 " Belegzeile
         (8) BSEGA-NETDT,                " Netto-Faelligkeit
*      (8) FAEDE-NETDT,                          " Netto-Faelligkeit
         (8) BSIK-ZFBDT,                 " Zahlungsfristenbasis
         (8) BSIK-BUDAT,                 " Buchungsdatum
         (8) BSIK-BLDAT,                 " Belegdatum
*      (8) BSIK-CPUDT,                           " CPU-Datum
             BSIK-BSCHL,                 " Buchungsschluessel
             BSIK-ZLSCH,                 " Zahlungsschluessel
*      120 BKPF-USNAM.                           " Benutzer
*       82 BSIK-MANST NO-ZERO,
          86 BSEGA-DMSHB CURRENCY T001-WAERS,      "Hauswaehrungsbetrag
*          ROUND FAKTOR DECIMALS STELLEN,
             BSIK-WAERS,                 "Waehrung
            BSEGA-WRSHB CURRENCY BSIK-WAERS NO-ZERO, "Fremdwaehrungsbtr.
*          ROUND FAKTOR DECIMALS STELLEN.
*     SUMMARY.
         132 SY-VLINE.
  ELSE.                                        "DVAK941167 - summ 6
* Write out option 6 summarization detail
    WRITE: 01 SY-VLINE,
           03(04) LFB1-BUKRS,
           08(08) LFA1-LIFNR,
           17(17) LFA1-NAME1,
           35(05) LFA1-LAND1,
           41(10) TAGE,
           52(02) BSIK-BLART,
           55(10) BSIK-BELNR,
           66(10) BSIK-XBLNR,
           77(10) BSIK-SAKNR,
           88(05) BSIK-ZTERM,
           94(13) BSEGA-NETDT,
           108(13) BSIK-BUDAT,
           122(13) BSIK-ZFBDT,
           136(15) BSEGA-WRSHB CURRENCY BSIK-WAERS NO-ZERO,
           152(06) BSIK-WAERS,
           159(15) BSEGA-DMSHB CURRENCY T001-WAERS,
           175(06) T001-WAERS,
           182 SY-VLINE.
  ENDIF.                                       " summ 6

ENDFORM.                    "EINZELPOSTEN_AUSGABE

*---------------------------------------------------------------------*
*       FORM RASTER_AUSGABE_BUKRB                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM raster_ausgabe_bukrb.
   IF RASTVERD < '2'.
    DETAIL.
    SORT RBUK.
    CLEAR GBZAEHL.
    LOOP AT RBUK.
      IF VERDICHT NE '5'.                       " summ 5
        NEW-LINE.
      ELSE.                                     " summ 5
        IF RBUK-RAART = '1'.                    " summ 5
          WRITE: /01 SY-VLINE, 02 SY-ULINE(197),
                 199 SY-VLINE.
        ENDIF.
      ENDIF.                                    " summ 5
* Bei Verdichtung der Geschaeftsbereiche nur das Summenraster ausgeben*
      IF RASTVERD = '1'.               " AND VERDICHT > 0.
        CHECK RBUK-SORTK NE '0' .
      ENDIF.

* Das Summen-Raster wird nur ausgegeben, wenn mehr als ein Geschaefts-*
* bereich vorhanden ist. ---------------------------------------------*
      IF RBUK-SORTK = '1' AND RASTVERD NE '1'.
        CHECK GBZAEHL GT 1.
      ENDIF.

      IF RBUK-GSBER NE '**'.
        FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR COL_TOTAL INTENSIFIED.
      ENDIF.

      IF RBUK-SORTK NE '2'.
* Bei der ersten Rasterart         Anzahlungen usw. ausgeben ---------*
        IF RBUK-RAART = RART.
          IF RBUK-GSBER NE '**'.
            GBZAEHL = GBZAEHL + 1.
          ENDIF.
          RESERVE 5 LINES.

          IF VERDICHT NE '5'.                   " summ 5
            IF SORTART = '1'.
              WRITE: /01 SY-VLINE,
                02(04) RBUK-GSBER,       " Geschaeftsbereich
                8(11) RBUK-SPERR CURRENCY T001-WAERS  " gesperrte Posten
                                  ROUND FAKTOR DECIMALS STELLEN NO-ZERO,
                20(11) RBUK-ANZAH CURRENCY T001-WAERS  " Anzahlungen
                                  ROUND FAKTOR DECIMALS STELLEN,
            32(12) RBUK-OPSUM CURRENCY T001-WAERS  " Offene Posten Summe
                                  ROUND FAKTOR DECIMALS STELLEN.
            ELSE.
              WRITE: /01 SY-VLINE,
                02(04) RBUK-GSBER,       " Geschaeftsbereich
                08(05) RBUK-WAERS,       " Waehrung
                14(11) RBUK-ANZAH CURRENCY RBUK-WAERS  " Anzahlungen
                                  ROUND FAKTOR DECIMALS STELLEN,
            26(12) RBUK-OPSUM CURRENCY RBUK-WAERS  " Offene Posten Summe
                                  ROUND FAKTOR DECIMALS STELLEN.
            ENDIF.
          ELSE.
            IF RBUK-RAART = '1'.             " summ 5
* Write out summarization 5 detail
              FORMAT COLOR COL_TOTAL INTENSIFIED. " summ 5
              WRITE: 17   'Total:'.          " summ 5
            ENDIF.                           " summ 5
              FORMAT COLOR COL_TOTAL INTENSIFIED. " summ 5
            WRITE:                           " Betraege in FW ausgeben
              01      SY-VLINE,
              87(15)  RBUK-OPSUM CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              103(15) RBUK-RAST1 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              119(15) RBUK-RAST2 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              135(15) RBUK-RAST3 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR DECIMALS STELLEN,
              151(15) RBUK-RAST4 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR DECIMALS STELLEN,
              167(15) RBUK-RAST5 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              183(15) RBUK-RAST6 CURRENCY T001-WAERS NO-ZERO
                             ROUND FAKTOR  DECIMALS STELLEN,
              199(1) SY-VLINE.
          ENDIF.                                 " summ 5
        ELSE.
          IF VERDICHT NE '5'.                    " summ 5
            WRITE: /01 SY-VLINE.
          ENDIF.                                 " summ 5
        ENDIF.

        IF VERDICHT NE '5'.                      " summ 5
          IF SORTART = '1'.
            CASE RBUK-RAART.
      WHEN '1'. WRITE: 45(3) TEXT-019, 48 SY-VLINE.             " Net-Fa
      WHEN '2'. WRITE: 45(3) TEXT-020, 48 SY-VLINE.             " Skt-Fa
      WHEN '3'. WRITE: 45(3) TEXT-021, 48 SY-VLINE.             " Zhl-Ei
      WHEN '4'. WRITE: 45(3) TEXT-022, 48 SY-VLINE.             " Ueb-Fa
            ENDCASE.
          ELSE.
            CASE RBUK-RAART.
      WHEN '1'. WRITE: 39(3) TEXT-019, 42 SY-VLINE.             " Net-Fa
      WHEN '2'. WRITE: 39(3) TEXT-020, 42 SY-VLINE.             " Skt-Fa
      WHEN '3'. WRITE: 39(3) TEXT-021, 42 SY-VLINE.             " Zhl-Ei
      WHEN '4'. WRITE: 39(3) TEXT-022, 42 SY-VLINE.             " Ueb-Fa
            ENDCASE.
          ENDIF.

          IF SORTART = '1'.
            WRITE:                       " Ausgabe in HW
                  (11) RBUK-RAST1 CURRENCY T001-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 62  SY-VLINE,
                  (11) RBUK-RAST2 CURRENCY T001-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 76  SY-VLINE,
                  (11) RBUK-RAST3 CURRENCY T001-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 90  SY-VLINE,
                  (11) RBUK-RAST4 CURRENCY T001-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 104 SY-VLINE,
                  (11) RBUK-RAST5 CURRENCY T001-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 118 SY-VLINE,
                  (11) RBUK-RAST6 CURRENCY T001-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 132 SY-VLINE.
          ELSE.
            WRITE:                       " Ausgabe in FW
                  (12) RBUK-RAST1 CURRENCY RBUK-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 57  SY-VLINE,
                  (12) RBUK-RAST2 CURRENCY RBUK-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 72  SY-VLINE,
                  (12) RBUK-RAST3 CURRENCY RBUK-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 87  SY-VLINE,
                  (12) RBUK-RAST4 CURRENCY RBUK-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 102 SY-VLINE,
                  (12) RBUK-RAST5 CURRENCY RBUK-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 117 SY-VLINE,
                  (12) RBUK-RAST6 CURRENCY RBUK-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 132 SY-VLINE.
          ENDIF.
        ELSE.                                 " summ 5
             FORMAT COLOR COL_TOTAL INTENSIFIED.
          WRITE:
            103(15) RBUK-RAST1 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            119(15) RBUK-RAST2 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            135(15) RBUK-RAST3 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR DECIMALS STELLEN,
            151(15) RBUK-RAST4 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR DECIMALS STELLEN,
            167(15) RBUK-RAST5 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            183(15) RBUK-RAST6 CURRENCY T001-WAERS   NO-ZERO
                           ROUND FAKTOR  DECIMALS STELLEN,
            199(1) SY-VLINE.
        ENDIF.                                " summ 5
      ELSE.
* Ausgabe des Jahresumsatzes -----------------------------------------*
        IF VERDICHT NE '5'.                    " summ 5
          WRITE:  01 SY-VLINE.
          WRITE: 02    RBUK-GSBER(4),
                 7     TEXT-166,
                 87    RBUK-KUMUM CURRENCY T001-WAERS.
          WRITE: 132 SY-VLINE.
        ENDIF.                                 " summ 5
      ENDIF.

      AT END OF WAERS.
*        uline.                                " summ 5
        IF VERDICHT NE '5'.                    " summ 5
          WRITE: /01 SY-VLINE,                 " summ 6
                  02 SY-ULINE(130),            " summ 6
                  132 SY-VLINE.                " summ 6
        ENDIF.                                 " summ 5
      ENDAT.

    ENDLOOP.
  ENDIF.

ENDFORM.                    "RASTER_AUSGABE_BUKRB

*---------------------------------------------------------------------*
*       FORM RASTER_AUSGABE_TOTAL                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM raster_ausgabe_total.
  IF RASTVERD < '2'.
    DETAIL.
    MOVE TEXT-102 TO VARUEB1-FELD1.
    MOVE TEXT-106 TO VARUEB2-FELD1.
    REPLACE 'RP01' WITH RC01 INTO VARUEB2.                  "bis   0
    REPLACE 'RP02' WITH RC02 INTO VARUEB2.                  "bis  20
    REPLACE 'RP03' WITH RC03 INTO VARUEB2.                  "bis  40
    REPLACE 'RP04' WITH RC04 INTO VARUEB2.                  "bis  80
    REPLACE 'RP05' WITH RC05 INTO VARUEB2.                  "bis 100
    REPLACE 'RP06' WITH RC06 INTO VARUEB1.                  "von   1
    REPLACE 'RP07' WITH RC07 INTO VARUEB1.                  "von  21
    REPLACE 'RP08' WITH RC08 INTO VARUEB1.                  "von  41
    REPLACE 'RP09' WITH RC09 INTO VARUEB1.                  "von  81
    REPLACE 'RP10' WITH RC10 INTO VARUEB1.                  "von 101
    SORT RSUM.
    LOOP AT RSUM.
      NEW-LINE.

* Bei Verdichtung der Geschaeftsbereiche nur das Summenraster ausgeben*
      IF RASTVERD = '1' AND VERDICHT > 0.
        CHECK RSUM-SORTK = '1'.
      ENDIF.

      FORMAT COLOR COL_TOTAL INTENSIFIED.

* Bei der ersten Rasterart Umsatz, Anzahlungen usw. ausgeben ---------*
      IF RSUM-RAART = RART.
        RESERVE 5 LINES.
        WRITE: 01 SY-VLINE,
               02(02) '**',                                 "
                8(05) RSUM-WAERS,      " Waehrung
               14(11) RSUM-ANZAH CURRENCY RSUM-WAERS  " Anzahlungen
                                 ROUND FAKTOR DECIMALS STELLEN,
             26(12) RSUM-OPSUM CURRENCY RSUM-WAERS " Offene Posten Summe
                                 ROUND FAKTOR DECIMALS STELLEN.
*   ENDIF.
      ELSE.
        WRITE: /01 SY-VLINE.
      ENDIF.

      CASE RSUM-RAART.
     WHEN '1'. WRITE: 39(3) TEXT-019, 42 SY-VLINE.             " Net-Fae
     WHEN '2'. WRITE: 39(3) TEXT-020, 42 SY-VLINE.             " Skt-Fae
     WHEN '3'. WRITE: 39(3) TEXT-021, 42 SY-VLINE.             " Zhl-Ein
     WHEN '4'. WRITE: 39(3) TEXT-022, 42 SY-VLINE.             " Ueb-Fae
      ENDCASE.

      WRITE:
            (12) RSUM-RAST1 CURRENCY RSUM-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 57  SY-VLINE,
            (12) RSUM-RAST2 CURRENCY RSUM-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 72  SY-VLINE,
            (12) RSUM-RAST3 CURRENCY RSUM-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 87  SY-VLINE,
            (12) RSUM-RAST4 CURRENCY RSUM-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 102 SY-VLINE,
            (12) RSUM-RAST5 CURRENCY RSUM-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 117 SY-VLINE,
            (12) RSUM-RAST6 CURRENCY RSUM-WAERS NO-ZERO
                            ROUND FAKTOR DECIMALS STELLEN, 132 SY-VLINE.
* ENDIF.

      AT END OF WAERS.
*        uline.
        WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.

      ENDAT.

    ENDLOOP.
  ENDIF.

ENDFORM.                    "RASTER_AUSGABE_TOTAL

*---------------------------------------------------------------------*
*       FORM SHB_KENNZEICHEN                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM shb_kennzeichen.
  CLEAR humkz1.
  CLEAR humkz2.
  CLEAR humkz3.
  CLEAR humkz4.
  CLEAR humkz5.
  CLEAR humkz6.
  CLEAR humkz7.
  CLEAR humkz8.
  CLEAR humkz9.
  CLEAR humkz10.

  IF NOT umsatzkz(1) IS INITIAL.
    humkz1 = umsatzkz(1).
  ENDIF.
  IF NOT umsatzkz+1(1) IS INITIAL.
    humkz2 = umsatzkz+1(1).
  ENDIF.
  IF NOT umsatzkz+2(1) IS INITIAL.
    humkz3 = umsatzkz+2(1).
  ENDIF.
  IF NOT umsatzkz+3(1) IS INITIAL.
    humkz4 = umsatzkz+3(1).
  ENDIF.
  IF NOT umsatzkz+4(1) IS INITIAL.
    humkz5 = umsatzkz+4(1).
  ENDIF.
  IF NOT umsatzkz+5(1) IS INITIAL.
    humkz6 = umsatzkz+5(1).
  ENDIF.
  IF NOT umsatzkz+6(1) IS INITIAL.
    humkz7 = umsatzkz+6(1).
  ENDIF.
  IF NOT umsatzkz+7(1) IS INITIAL.
    humkz8 = umsatzkz+7(1).
  ENDIF.
  IF NOT umsatzkz+8(1) IS INITIAL.
    humkz9 = umsatzkz+8(1).
  ENDIF.
  IF NOT umsatzkz+9(1) IS INITIAL.
    humkz10 = umsatzkz+9(1).
  ENDIF.

ENDFORM.                    "SHB_KENNZEICHEN

*---------------------------------------------------------------------*
*       FORM SHBKZ_PRUEFEN                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM shbkz_pruefen.
  CLEAR flag1.
  SELECT * FROM tbsl
    WHERE koart = 'K'.
    IF NOT tbsl-xsonu IS INITIAL.
      SELECT * FROM tbslt
        WHERE bschl = tbsl-bschl
        AND   umskz = char1.

        flag1 = 'X'.
      ENDSELECT.
    ENDIF.
  ENDSELECT.
  IF NOT flag1 IS INITIAL.
    SELECT SINGLE * FROM t074u
      WHERE koart = 'K'
      AND   umskz = char1.
    IF NOT t074u-merkp IS INITIAL.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'UMSATZKZ'.
      ENDIF.
      MESSAGE w376 WITH char1 'K'.
    ENDIF.

    SELECT SINGLE * FROM t074t
      WHERE spras = sy-langu
      AND   koart = 'K'
      AND   shbkz = char1.
    IF sy-subrc = 0.
      bezshb-shbkz = t074t-shbkz.
      bezshb-ltext = t074t-ltext.
      APPEND bezshb.
    ELSE.
      CLEAR flag1.
    ENDIF.
  ENDIF.
  IF flag1 IS INITIAL.
    IF sy-batch IS INITIAL.
      SET CURSOR FIELD umsatzkz.
    ENDIF.
    MESSAGE e375 WITH char1 'K'.
  ENDIF.
ENDFORM.                    "SHBKZ_PRUEFEN

*---------------------------------------------------------------------*
*       FORM OBLIGOS                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM obligos.
  CLEAR aobligo.
  REFRESH aobligo.
  IF NOT c-saldo IS INITIAL.
    CLEAR aobligo.
    MOVE '1' TO aobligo-obart.
    MOVE c-saldo TO aobligo-oblig.
    WRITE text-117 TO aobligo-ltext.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums1 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz1 TO aobligo-shbkz.
    MOVE c-sums1 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz1.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums2 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz2 TO aobligo-shbkz.
    MOVE c-sums2 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz2.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums3 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz3 TO aobligo-shbkz.
    MOVE c-sums3 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz3.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums4 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz4 TO aobligo-shbkz.
    MOVE c-sums4 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz4.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums5 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz5 TO aobligo-shbkz.
    MOVE c-sums5 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz5.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums6 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz6 TO aobligo-shbkz.
    MOVE c-sums6 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz6.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums7 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz7 TO aobligo-shbkz.
    MOVE c-sums7 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz7.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums8 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz8 TO aobligo-shbkz.
    MOVE c-sums8 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz8.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums9 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz9 TO aobligo-shbkz.
    MOVE c-sums9 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz9.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sums10 IS INITIAL.
    CLEAR aobligo.
    MOVE '2' TO aobligo-obart.
    MOVE c-umkz10 TO aobligo-shbkz.
    MOVE c-sums10 TO aobligo-oblig.
    LOOP AT bezshb
      WHERE shbkz = c-umkz10.
      MOVE bezshb-ltext TO aobligo-ltext.
    ENDLOOP.
    APPEND aobligo.
  ENDIF.
  IF NOT c-sonob IS INITIAL.
    CLEAR aobligo.
    MOVE '3' TO aobligo-obart.
    MOVE c-sonob TO aobligo-oblig.
    WRITE text-152 TO aobligo-ltext.
    APPEND aobligo.
  ENDIF.
  SORT aobligo.

ENDFORM.                    "OBLIGOS

*---------------------------------------------------------------------*
*       FORM EINZELPOSTEN_SAVE                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM einzelposten_save.
  CLEAR hbsik.
  CLEAR refbl.
  MOVE-CORRESPONDING bsik  TO hbsik.
  MOVE-CORRESPONDING bsega TO hbsik.                       "#EC ENHOK
  MOVE ntage TO hbsik-ntage.
  MOVE stage TO hbsik-stage.
  MOVE atage TO hbsik-atage.
  MOVE utage TO hbsik-utage.
  APPEND hbsik.
  MOVE-CORRESPONDING bsik  TO refbl.                       "#EC ENHOK
  MOVE ntage TO refbl-ntage.
  MOVE stage TO refbl-stage.
  MOVE atage TO refbl-atage.
  MOVE utage TO refbl-utage.
  APPEND refbl.
ENDFORM.                    "EINZELPOSTEN_SAVE

*---------------------------------------------------------------------*
*       FORM EINZELPOSTEN_LINK                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM einzelposten_link.
  SORT refbl BY bukrs belnr gjahr buzei.                       "1579685
  LOOP AT hbsik
    WHERE rebzg NE space.
    READ TABLE refbl WITH KEY bukrs = hbsik-bukrs              "1579685
                              belnr = hbsik-rebzg              "1579685
                              gjahr = hbsik-rebzj              "1579685
                              buzei = hbsik-rebzz              "1579685
                              BINARY SEARCH.                   "1579685
    IF sy-subrc = 0.                                           "1579685
      hbsik-ntage = refbl-ntage.
      hbsik-stage = refbl-stage.
      hbsik-atage = refbl-atage.
      hbsik-utage = refbl-utage.
      MODIFY hbsik.
    ENDIF.                                                     "1579685
  ENDLOOP.
ENDFORM.                    "EINZELPOSTEN_LINK

*---------------------------------------------------------------------*
*       FORM EINZELPOSTEN_PROC                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM einzelposten_proc.
  LOOP AT hbsik
    WHERE bukrs = lfb1-bukrs.
*    IF t001-bukrs NE lfb1-bukrs.
*      READ TABLE ht001 WITH KEY bukrs = lfb1-bukrs.
*      t001 = ht001.
*    ENDIF.
    CLEAR bsik.
    CLEAR bsega.
    MOVE-CORRESPONDING hbsik TO bsik.
    MOVE-CORRESPONDING hbsik TO bsega.                     "#EC ENHOK
    ntage =  hbsik-ntage.
    stage =  hbsik-stage.
    atage =  hbsik-atage.
    utage =  hbsik-utage.

* die Einzelposten werden nach den Tagen der ersten Rasterart --------*
* sortiert -----------------------------------------------------------*
    IF rart-net = 'X'.
      tage = ntage.
    ELSE.
      IF rart-skt = 'X'.
        tage = stage.
      ELSE.
        IF rart-alt = 'X'.
          tage = atage.
        ELSE.
          IF rart-ueb = 'X'.
            tage = utage.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    CASE bsik-umsks.
*--------------- Anzahlungen sammeln ---------------------------------*
*--------------- auch wenn nicht von aussen abgegrenzt ---------------*
      WHEN 'A'.
        CLEAR rtab.
        IF bsik-bstat NE 'S'.
          MOVE: bsik-bukrs TO rtab-bukrs,
                '0'      TO rtab-sortk,
                bsik-gsber TO rtab-gsber,
                rart     TO rtab-raart.
          IF sortart = '2'.
            MOVE bsik-waers TO rtab-waers.
            MOVE bsega-wrshb TO rtab-anzah.
          ELSE.
" Start of changes by Bharani
*            IF NOT konzvers IS INITIAL.
*              MOVE t001-waers TO rtab-waers.
              MOVE bsega-dmshb TO rtab-anzah.
*            ELSE.
*              MOVE bsega-dmshb TO rtab-anzah.
*            ENDIF.
" End of hcanges by Bharani
          ENDIF.
          COLLECT rtab.
*--------------- Summieren ueber alle Geschaeftsbereiche -------------*
          MOVE: '1'      TO rtab-sortk,
                '**'     TO rtab-gsber.
          COLLECT rtab.
        ENDIF.
    ENDCASE.

    CHECK: budat,
           bldat,
           netdt.
    sel-postn = 'J'.

    IF sortart = '1'.
" Start of hcanges by Bharani
"      IF konzvers IS INITIAL.
        PERFORM posten_rastern USING space.
        MOVE space    TO gb-waers.
*      ELSE.
*        PERFORM posten_rastern USING t001-waers.
*        MOVE t001-waers TO gb-waers.
*      ENDIF.
" End of changes by Bharani
    ELSE.
      PERFORM posten_rastern USING bsik-waers.
      MOVE bsik-waers TO gb-waers.
    ENDIF.
*---- nur bei Verdichtungsstufe '0' werden EINZELPOSTEN extrahiert --*
    IF verdicht = '0'.
      MOVE   '3'    TO satzart.
      MOVE bsik-gsber TO gb-gsber.
      MOVE bsega-dmshb TO shbetrag.
*------Der Fremdwährungsbetrag soll nur Übernommen werden, wenn sich
*      sich der Währung von der Hauswährung unterscheidet.
      IF bsik-waers EQ t001-waers.
        MOVE space TO bsega-wrshb.
      ENDIF.
      EXTRACT einzelposten.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "EINZELPOSTEN_PROC

*---------------------------------------------------------------------*
*       FORM SUMM_C3                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM summ_c3.
  c3-saldo     = c3-saldo + c-saldo.
  c3-umkz1     = c-umkz1.
  c3-sums1     = c3-sums1 + c-sums1.
  c3-umkz2     = c-umkz2.
  c3-sums2     = c3-sums2 + c-sums2.
  c3-umkz3     = c-umkz3.
  c3-sums3     = c3-sums3 + c-sums3.
  c3-umkz4     = c-umkz4.
  c3-sums4     = c3-sums4 + c-sums4.
  c3-umkz5     = c-umkz5.
  c3-sums5     = c3-sums5 + c-sums5.
  c3-umkz6     = c-umkz6.
  c3-sums6     = c3-sums6 + c-sums6.
  c3-umkz7     = c-umkz7.
  c3-sums7     = c3-sums7 + c-sums7.
  c3-umkz8     = c-umkz8.
  c3-sums8     = c3-sums8 + c-sums8.
  c3-umkz9     = c-umkz9.
  c3-sums9     = c3-sums9 + c-sums9.
  c3-umkz10    = c-umkz10.
  c3-sums10    = c3-sums10 + c-sums10.
  c3-sonob     = c3-sonob  + c-sonob.
  c3-babzg     = c3-babzg  + c-babzg.
  c3-uabzg     = c3-uabzg  + c-uabzg.
  c3-kzins     = c3-kzins  + c-kzins.
  c3-kumum     = c3-kumum  + c-kumum.
  c3-kumag     = c3-kumag  + c-kumag.
  c3-agobli    = c3-agobli + c-agobli.
ENDFORM.                                                    "SUMM_C3

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_s_lvar
*&---------------------------------------------------------------------*
*       ........
*----------------------------------------------------------------------*
FORM f4_for_s_lvar CHANGING  i_variant LIKE disvariant.
  DATA: exit.
  DATA: e_variant LIKE disvariant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = i_variant
      i_save        = 'A'
    IMPORTING
      e_exit        = exit
      es_variant    = e_variant
    EXCEPTIONS
      program_error = 3
      OTHERS        = 3.
  IF sy-subrc = 0 AND exit = space.
    i_variant-variant = e_variant-variant.
  ENDIF.

ENDFORM.                               " F4_FOR_s_lvar

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Possible header for ALV Grid                           "1613289
*----------------------------------------------------------------------*
FORM top_of_page.                                          "#EC CALLED

   CLEAR gs_listheader.
   REFRESH gt_listheader.
   gs_listheader-typ = 'H'.
   gs_listheader-info = title.
   INSERT gs_listheader INTO TABLE gt_listheader.
   CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
     EXPORTING
       it_list_commentary = gt_listheader.
ENDFORM.                               " TOP_OF_PAGE
