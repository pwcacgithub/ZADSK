*&---------------------------------------------------------------------*
*& Include          ZRPFI_WITHHOLDING_TAX_DMP_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Declaration for Tables
*----------------------------------------------------------------------*
TABLES : lfbw,
         lfa1,                 "Vendor Master (General Section)
         t001,                 "Company Codes
         bkpf,                 "Accounting Document Header
         bseg,                 "Accounting Document Item
         with_item,            "Witholding tax info per W/tax type and FI line item
         t059z,                "Withholding tax code (enhanced functions)
         dfkkbptaxnum,         "Tax Numbers for Business Partner
         adrc,                 "Addresses (Business Address Services)
         adr6.                 "E-Mail Addresses (Business Address Services)

*----------------------------------------------------------------------*
* Declaration for Table Types
*----------------------------------------------------------------------*

TYPES:
  BEGIN OF ty_output,
    lifnr     TYPE lifnr,                   "Vendor
    bukrs     TYPE bukrs,                   "Company code
    witht     TYPE witht,                   "Indicator for Withholding Tax Type
    wt_subjct TYPE wt_subjct,               "Indicator: Subject to Withholding Tax
    qsrec     TYPE qsrec,                   "Type of Recipient
    wt_wtstcd TYPE wt_wtstcd,               "Withholding tax identification number
    wt_withcd TYPE wt_withcd,               "Withholding Tax Code
    wt_exnr   TYPE wt_exnr,                 "Exemption Certificate Number
    wt_exrt   TYPE wt_exrt,                 "Exemption Rate
    wt_exdf   TYPE wt_exdf,                 "Date on Which Exemption Begins
    wt_exdt   TYPE wt_exdt,                 "Date on Which Exemption Ends
    wt_wtexrs TYPE wt_wtexrs,               "Reason for Exemption
  END OF ty_output,

  BEGIN OF ty_bkpf,
    bukrs TYPE bukrs,                       "Company code
    belnr TYPE belnr_d,                     "Accounting document
    gjahr TYPE gjahr,                       "Fiscal year
    blart TYPE bkpf-blart,                  "Document type
    bldat TYPE bkpf-bldat,                  "Document date in document
    budat TYPE bkpf-budat,                  "Posting date in document
    monat TYPE monat,                       "Fiscal Period
    cpudt TYPE bkpf-cpudt,                  "Day Accounting Document Was Entered
    xblnr TYPE bkpf-xblnr,                  "Reference document number
  END OF ty_bkpf,

  BEGIN OF ty_bseg,
    bukrs      TYPE bukrs,                    "Company code
    belnr      TYPE belnr_d,                  "Accounting document
    gjahr      TYPE gjahr,                    "Fiscal year
    buzei      TYPE buzei,                    "Line Item in Accounting document
    augbl      TYPE augbl,                    "Document Number of the Clearing Document
    koart      TYPE koart,                    "Account type
    augdt      TYPE bseg-augdt,               "Clearing Date
    umskz      TYPE bseg-umskz,               "Special G/L Indicator
    lifnr      TYPE bseg-lifnr,               "Vendor
    bupla      TYPE bsak-bupla,               "Business Place
    secco      TYPE bsak-secco,               "Section Code
    zlspr      TYPE bsak-zlspr,               "Payment Block Key
*//-- Start of Insert INC2613809 D4SK906959
    h_waers    TYPE bseg-h_waers,             "Doc Currency
    h_hwaer    TYPE bseg-h_hwaer,             "Local Currency
*//-- End of Insert INC2613809 D4SK906959
    witht      TYPE with_item-witht,          "Indicator for Withholding Tax Type
    wt_withcd  TYPE with_item-wt_withcd,      "Withholding Tax Code
    wt_qsshh   TYPE with_item-wt_qsshh,       "Withholding Tax Base Amount (Local Currency)
    wt_qsshb   TYPE with_item-wt_qsshb,       "Withholding Tax Base Amount in Document Currency
    wt_qbshh   TYPE with_item-wt_qbshh,       "Withholding Tax Amount in Local Currency
    wt_qbshb   TYPE with_item-wt_qbshb,       "Withholding Tax Amount in Document Currency
    hkont      TYPE with_item-hkont,          "General Ledger Account
    qsrec      TYPE with_item-qsrec,          "Type of Recipient
    ctnumber   TYPE with_item-ctnumber,       "Withholding Tax Certificate Number
    j_1icertdt TYPE with_item-j_1icertdt,     "Issue date of TDS Certificate
  END OF ty_bseg,

  BEGIN OF ty_t001,
    bukrs TYPE t001-bukrs,                   "Company code
    land1 TYPE t001-land1,                   "Country Key
    spras TYPE t001-spras,                   "Language
  END OF ty_t001,

  BEGIN OF ty_lfa1,
    lifnr     TYPE  lfa1-lifnr,               "Vendor
    land1     TYPE  lfa1-land1,               "Country Key
    name1     TYPE  lfa1-name1,               "Name1
    adrnr     TYPE  lfa1-adrnr,               "Address
    regio     TYPE  lfa1-regio,               "Region
    ktokk     TYPE  lfa1-ktokk,               "Vendor account group
    j_1ipanno TYPE  lfa1-j_1ipanno,           "PAN number
    stcd1     TYPE  lfa1-stcd1,               "Tax Number 1
    stcd2     TYPE  lfa1-stcd2,               "Tax Number 2
    stceg     TYPE  lfa1-stceg,               "VAT Registration Number
    txjcd     TYPE  lfa1-txjcd,               "Tax Jurisdiction
    qland     TYPE  lfb1-qland,               "Treaty Country
    taxtype   TYPE  dfkkbptaxnum-taxtype,     "Tax type
    taxnum    TYPE  dfkkbptaxnum-taxnum,      "Tax number
  END OF ty_lfa1,

*//-- Start of Insert INC2732452 D4SK907855
  BEGIN OF ty_hkont,
    bukrs TYPE bseg-bukrs,                "Company Code
    belnr TYPE bseg-belnr,                "Doc Number
    gjahr TYPE bseg-gjahr,                "Fiscal Year
    hkont TYPE bseg-hkont,                "GL Account
    ktosl type bseg-ktosl,                "Transaction Key
  END OF ty_hkont,
*//-- End of Insert INC2732452 D4SK907855

  BEGIN OF ty_t059z,
    witht     TYPE t059z-witht,                "Tax type
    wt_withcd TYPE t059z-wt_withcd,            "WHT Code
    qscod     TYPE t059z-qscod,                "Tax Official Keys
  END OF ty_t059z,

  BEGIN OF ty_adrc,
    addrnumber TYPE adrc-addrnumber,            "Address
    city1      TYPE adrc-city1,                 "City
    city2      TYPE adrc-city2,                 "District
    post_code1 TYPE adrc-post_code1,            "Postal Code
    post_code2 TYPE adrc-post_code2,            "Zip code
    tel_number TYPE adrc-tel_number,            "Telephone number
    smtp_addr  TYPE adr6-smtp_addr,             "Email address
  END OF ty_adrc,

  BEGIN OF ty_dfkkbptaxnum,
    partner TYPE bu_partner,                     "Vendor
    taxtype TYPE bptaxtype,                      "Tax type
    taxnum  TYPE bptaxnum,                       "Tax num
  END OF ty_dfkkbptaxnum,

  BEGIN OF ty_j_1iewt_surc1,
    bukrs      TYPE    bukrs,
    witht      TYPE witht,
    wt_withcd  TYPE wt_withcd,
    qsrec      TYPE wt_qsrec,
    j_1isurrat TYPE j_1isurrat,
  END OF ty_j_1iewt_surc1,

  BEGIN OF ty_j_1iewt_ecess1,
    bukrs       TYPE bukrs,
    witht       TYPE witht,
    wt_withcd   TYPE wt_withcd,
    qsrec       TYPE wt_qsrec,
    j_1iecessrt TYPE j_1iecessrt,
  END OF ty_j_1iewt_ecess1,

  BEGIN OF ty_output1,
    land1       TYPE t001-land1,                  "Country Key
    bukrs       TYPE t001-bukrs,                  "Company code
    gjahr       TYPE bseg-gjahr,                  "Fiscal year
    budat       TYPE bkpf-budat,                  "Assesment year
    monat       TYPE monat,                       "Posting period
    lifnr       TYPE lfb1-lifnr,                  "Vendor
    langu       TYPE sy-langu,                    "Language
    umskz       TYPE bseg-umskz,                  "Special GL indicator
    ktokk       TYPE lfa1-ktokk,                  "Vendor group
    name1       TYPE lfa1-name1,                  "Supplier name
    adrnr       TYPE lfa1-adrnr,                  "Addresses
    city1       TYPE adrc-city1,                  "City
    city2       TYPE adrc-city2,                  "District
    post_code1  TYPE adrc-post_code1,             "Postal code
    post_code2  TYPE adrc-post_code2,             "Zipcode
    regio       TYPE lfa1-regio,                  "Region
    j_1ipanno   TYPE lfa1-j_1ipanno,              "PAN number
    tel_number  TYPE adrc-tel_number,             "Phone number
    smtp_addr   TYPE adr6-smtp_addr,              "Email address
    blart       TYPE bkpf-blart,                  "Document type
    belnr       TYPE bkpf-belnr,                  "Document number
    augbl       TYPE bseg-augbl,                  "Clearing document no
    xblnr       TYPE bkpf-xblnr,                  "Reference
    bldat       TYPE bkpf-bldat,                  "Document date
    post_date   TYPE bkpf-budat,                  "Posting date
    cpudt       TYPE bkpf-cpudt,                  "Entry date
    augdt       TYPE bseg-augdt,                  "Clearing date
    bupla       TYPE bseg-bupla,                  "Business place
    secco       TYPE bseg-secco,                  "Area code
    zlspr       TYPE bseg-zlspr,                  "Payment block
*//-- Start of Insert INC2613809 D4SK906959
    h_waers     TYPE bseg-h_waers,                "Doc Currency
    h_hwaer     TYPE bseg-h_hwaer,                "Local Currency
*//-- End of Insert INC2613809 D4SK906959
    qland       TYPE lfb1-qland,                  "Treaty country
    witht       TYPE with_item-witht,             "Tax type
    wt_withcd   TYPE with_item-wt_withcd,         "WHT code
    qscod       TYPE t059z-qscod,                 "Tax official keys
    hkont       TYPE with_item-hkont,             "WH tax GL account
    qsrec       TYPE with_item-qsrec,             "Type of recipient
    taxnum      TYPE dfkkbptaxnum-taxnum,         "Tax number
    taxtype     TYPE dfkkbptaxnum-taxtype,        "Tax category
    koart       TYPE koart,                       "Account type (K,S)
    ctnumber    TYPE with_item-ctnumber,          "Cert. No.
    j_1icertdt  TYPE with_item-j_1icertdt,        "Issue date of TDS Certificate
    stcd1       TYPE lfa1-stcd1,                  "Tax Number 1
    stcd2       TYPE lfa1-stcd2,                  "Tax Number 2
    stceg       TYPE lfa1-stceg,                  "VAT Reg No
    txjcd       TYPE lfa1-txjcd,                  "Tax Jurisdiction
*//-- Start of Changes INC2718637 D4SK907278
    wt_qsshh    TYPE zwt_bs,                      "Withholding Tax Base Amount (LC)
    wt_qsshb    TYPE zwt_bs1,                     "Withholding Tax Base Amount (DC)
    net_amt_lc  TYPE znetamount_lc,               "Net Amt (LC)
    net_amt_dc  TYPE znetamount_dc,               "Net Amt (DC)
    wt_qbshh    TYPE zwt_wt,                      "Tax Amt (LC)
    wt_qbshb    TYPE zwt_wt1,                     "Tax Amt (DC)
*//-- End of Changes INC2718637 D4SK907278
    tds_basic   TYPE ztdsbasic,          "TDS_BASIC ZTDSSURCHG with_item-wt_qbshh
    tds_surchg  TYPE ztdssurchg,          "TDS_SURCHG ZTDSSURCHG
    tds_educess TYPE ztdseducess,          "TDS_EDUCESS ZTDSEDUCESS
  END OF ty_output1.

*----------------------------------------------------------------------*
* Declaration for constants
*----------------------------------------------------------------------*
CONSTANTS :c_e TYPE char1       VALUE 'E',
*//-- Start of Insert INC2732452 D4SK907855
           c_s TYPE koart       VALUE 'S',
           c_x TYPE xbilk       VALUE 'X',
           c_wit type ktosl     value 'WIT'.
*//-- End of Insert INC2732452 D4SK907855
*----------------------------------------------------------------------*
* Declaration for Internal tables
*----------------------------------------------------------------------*

DATA :
  gt_output           TYPE STANDARD TABLE OF ty_output,
  gt_bseg             TYPE TABLE OF ty_bseg,
  gt_lfa1             TYPE TABLE OF ty_lfa1,
  gt_adrc             TYPE TABLE OF ty_adrc,
  gt_t059z            TYPE TABLE OF ty_t059z,
  gt_output1          TYPE TABLE OF ty_output1,
  gt_t001             TYPE TABLE OF ty_t001,
  gt_dfkkbptaxnum     TYPE TABLE OF ty_dfkkbptaxnum,
  gt_j_1iewt_ecess1   TYPE TABLE OF ty_j_1iewt_ecess1,
  gt_j_liewt_surc1    TYPE TABLE OF ty_j_1iewt_surc1,
  gt_bkpf             TYPE STANDARD TABLE OF ty_bkpf,
  gt_pgm_const_values TYPE TABLE OF zspgm_const_values,
  gt_error_const      TYPE TABLE OF zserror_const,
  gt_text             TYPE TABLE OF tline INITIAL SIZE 1,
  gt_tcurx            TYPE TABLE OF tcurx, "*//-- Insert INC2613809 D4SK906959
  gt_hkont            TYPE TABLE OF ty_hkont. "*//-- Insert INC2732452 D4SK907855

*----------------------------------------------------------------------*
* Declaration for Reference Objects
*----------------------------------------------------------------------*
DATA:
  go_alv  TYPE REF TO zcl_ca_utility,
  go_alv1 TYPE REF TO zcl_ca_utility,
  go_file TYPE REF TO zcl_ca_utility.

*----------------------------------------------------------------------*
* Declaration for Variables
*----------------------------------------------------------------------*
DATA :
  gv_body    TYPE thead-tdname,
  gv_subject TYPE thead-tdname,
  gv_mail    TYPE string,
  gv_text    TYPE tline.
