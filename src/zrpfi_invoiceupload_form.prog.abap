*&---------------------------------------------------------------------*
*& Include          ZRPFI_INVOICEUPLOAD_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  F4 help to select the file from Presentation server
*&---------------------------------------------------------------------*
*&      <-- P_FPATH  - Selected file path
*&---------------------------------------------------------------------*
FORM f4_filename CHANGING p_fpath.

* Call the method for F4 help
  CALL METHOD zcl_ca_utility=>select_file
    EXPORTING
      i_source   = gv_p
    IMPORTING
      e_filename = p_fpath.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*& Validate the selection screen values
*&---------------------------------------------------------------------*
FORM f_validate_data.

*If file path is blank
  IF p_fpath1 IS INITIAL.
    MESSAGE e003 WITH 'File Path'(003).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_READ_FILE
*&---------------------------------------------------------------------*
*& Read the file from Presentation Server
*&---------------------------------------------------------------------*
FORM f_read_file.

  CREATE OBJECT go_file.

* Read the data from the multiple files uploaded on the selection screen.

  REFRESH: gt_data1, gt_data2, gt_data3, gt_data4, gt_data5.
  IF p_fpath1 IS NOT INITIAL.
    PERFORM read_file USING p_fpath1 CHANGING gt_data1.
    IF NOT gt_data1 IS INITIAL.
      SORT gt_data1 BY bukrs xblnr lifnr.
    ENDIF.
  ENDIF.

  IF p_fpath2 IS NOT INITIAL.
    PERFORM read_file USING p_fpath2 CHANGING gt_data2.
    IF NOT gt_data2 IS INITIAL.
      SORT gt_data2 BY bukrs xblnr lifnr.
    ENDIF.
  ENDIF.

  IF p_fpath3 IS NOT INITIAL.
    PERFORM read_file USING p_fpath3 CHANGING gt_data3.
    IF NOT gt_data3 IS INITIAL.
      SORT gt_data3 BY bukrs xblnr lifnr.
    ENDIF.
  ENDIF.

  IF p_fpath4 IS NOT INITIAL.
    PERFORM read_file USING p_fpath4 CHANGING gt_data4.
    IF NOT gt_data4 IS INITIAL.
      SORT gt_data4 BY bukrs xblnr lifnr.
    ENDIF.
  ENDIF.

  IF p_fpath5 IS NOT INITIAL.
    PERFORM read_file USING p_fpath5 CHANGING gt_data5.
    IF NOT gt_data5 IS INITIAL.
      SORT gt_data5 BY bukrs xblnr lifnr.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_PROCESS_DATA
*&---------------------------------------------------------------------*
*& Process the data read from the file
*&---------------------------------------------------------------------*
FORM f_process_data.

* Validate the data before being sent to Open Text. If any record of a file
* has error, the complete file processing will be skipped and error messages
* will be displayed to the user after execution of the program

* File1 processing
  CLEAR: gv_count, gv_check.
  PERFORM f_check_data USING gt_data1 gv_check gv_count.
  IF gv_count = 1 AND p_atach1 IS INITIAL.
    gv_check = gv_x.
    CLEAR gw_error.
    gw_error-type = gv_e.
    gw_error-message = 'Attachment is missing. Invoice will not be processed'(034).
    APPEND gw_error TO gt_messages.
  ELSEIF gv_count > 1 AND p_atach1 IS NOT INITIAL.
    gw_error-type = gv_i. "'I'.
    gw_error-message = 'Attachment is not processed as file has multiple invoices'(031).
    APPEND gw_error TO gt_messages.
    CLEAR gw_error.
  ENDIF.
  IF gv_check = gv_x.
    CLEAR gw_error.
    gw_error-type = gv_e.
    gw_error-message = 'File1 will not be processed as there are errors'(006).
    APPEND gw_error TO gt_messages.
  ELSE.
    PERFORM f_process_file USING gt_data1 p_fpath1 p_atach1 gv_count.
  ENDIF.

* File2 processing
  IF NOT gt_data2 IS INITIAL.
    CLEAR: gv_count, gv_check.
    PERFORM f_check_data USING gt_data2 gv_check gv_count.
    CLEAR gw_error.
    APPEND gw_error TO gt_messages.
    IF gv_count = 1 AND p_atach2 IS INITIAL.
      gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'Attachment is missing. Invoice will not be processed'(034).
      APPEND gw_error TO gt_messages.
    ELSEIF gv_count > 1 AND p_atach2 IS NOT INITIAL.
      gw_error-type = gv_i. "'I'.
      gw_error-message = 'Attachment is not processed as file has multiple invoices'(031).
      APPEND gw_error TO gt_messages.
      CLEAR gw_error.
    ENDIF.
    IF gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'File2 will not be processed as there are errors'(007).
      APPEND gw_error TO gt_messages.
    ELSE.
      PERFORM f_process_file USING gt_data2 p_fpath2 p_atach2 gv_count.
    ENDIF.
  ENDIF.

* File3 processing
  IF NOT gt_data3 IS INITIAL.
    CLEAR: gv_count, gv_check.
    PERFORM f_check_data USING gt_data3 gv_check gv_count.
    CLEAR gw_error.
    APPEND gw_error TO gt_messages.
    IF gv_count = 1 AND p_atach3 IS INITIAL.
      gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'Attachment is missing. Invoice will not be processed'(034).
      APPEND gw_error TO gt_messages.
    ELSEIF gv_count > 1 AND p_atach3 IS NOT INITIAL.
      gw_error-type = gv_i. "'I'.
      gw_error-message = 'Attachment is not processed as file has multiple invoices'(031).
      APPEND gw_error TO gt_messages.
      CLEAR gw_error.
    ENDIF.
    IF gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'File3 will not be processed as there are errors'(008).
      APPEND gw_error TO gt_messages.
    ELSE.
      PERFORM f_process_file USING gt_data3 p_fpath3 p_atach3 gv_count.
    ENDIF.
  ENDIF.

* File4 processing
  IF NOT gt_data4 IS INITIAL.
    CLEAR: gv_count, gv_check.
    PERFORM f_check_data USING gt_data4 gv_check gv_count.
    CLEAR gw_error.
    APPEND gw_error TO gt_messages.
    IF gv_count = 1 AND p_atach4 IS INITIAL.
      gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'Attachment is missing. Invoice will not be processed'(034).
      APPEND gw_error TO gt_messages.
    ELSEIF gv_count > 1 AND p_atach4 IS NOT INITIAL.
      gw_error-type = gv_i. "'I'.
      gw_error-message = 'Attachment is not processed as file has multiple invoices'(031).
      APPEND gw_error TO gt_messages.
      CLEAR gw_error.
    ENDIF.
    IF gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'File4 will not be processed as there are errors'(009).
      APPEND gw_error TO gt_messages.
    ELSE.
      PERFORM f_process_file USING gt_data4 p_fpath4 p_atach4 gv_count.
    ENDIF.
  ENDIF.

* File5 processing
  IF NOT gt_data5 IS INITIAL.
    CLEAR: gv_count, gv_check.
    PERFORM f_check_data USING gt_data5 gv_check gv_count.
    CLEAR gw_error.
    APPEND gw_error TO gt_messages.
    IF gv_count = 1 AND p_atach5 IS INITIAL.
      gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'Attachment is missing. Invoice will not be processed'(034).
      APPEND gw_error TO gt_messages.
    ELSEIF gv_count > 1 AND p_atach5 IS NOT INITIAL.
      gw_error-type = gv_i. "'I'.
      gw_error-message = 'Attachment is not processed as file has multiple invoices'(031).
      APPEND gw_error TO gt_messages.
      CLEAR gw_error.
    ENDIF.
    IF gv_check = gv_x.
      CLEAR gw_error.
      gw_error-type = gv_e.
      gw_error-message = 'File5 will not be processed as there are errors'(010).
      APPEND gw_error TO gt_messages.
    ELSE.
      PERFORM f_process_file USING gt_data5 p_fpath5 p_atach5 gv_count.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_FILE
*&---------------------------------------------------------------------*
*& Read the file from Presentation Server
*&---------------------------------------------------------------------*
*&      <-- P_PATH  - Selected file path
*&      --> PT_DATA  - file data
*&---------------------------------------------------------------------*
FORM read_file USING    p_path TYPE string
               CHANGING pt_data TYPE STANDARD TABLE.

  DATA:
    lv_hdr          TYPE abap_encod,
    lv_path         TYPE rlgrap-filename,
    lv_total_amount TYPE char25,
    lv_totamt       TYPE wrbtr,
    lv_taxamt       TYPE char25,
    lv_taxamount    TYPE wrbtr,
    lv_wrbtramt     TYPE char25,
    lv_wrbtr        TYPE wrbtr,
    lw_data         TYPE ty_data,
    lv_menge_quant  TYPE char10,
    lv_menge        TYPE menge_d,
    lw_main         TYPE ty_data1.

  REFRESH: gt_main.
  CLEAR: lv_path, lv_hdr.
  lv_hdr = gv_x.
  lv_path = p_path.

  CALL METHOD go_file->read_csv_file
    EXPORTING
      i_filename        = lv_path
      i_delimiter       = ','
      i_hdr             = lv_hdr
    CHANGING
      e_datatab         = gt_main
    EXCEPTIONS
      cannot_open_file  = 1
      invalid_delimeter = 2
      error_in_read     = 3
      invalid_source    = 4
      OTHERS            = 5.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1 OR 3 OR 4.
        MESSAGE e013 WITH'check the path or authorization'(004).
      WHEN 2.
        MESSAGE e012 WITH 'valid delimiter'(005).
      WHEN 5.
        MESSAGE e018.  "Error while reading file.
    ENDCASE.
  ENDIF.

*Passing the value of uploaded file to new internal table
  LOOP AT gt_main INTO lw_main.

    lv_total_amount = lw_main-total_amount .
    PERFORM f_char_toamt USING lv_total_amount CHANGING lv_totamt.
    lw_data-total_amount = lv_totamt.

    lv_taxamt = lw_main-tax_amount .
    PERFORM f_char_toamt USING lv_taxamt CHANGING lv_taxamount.
    lw_data-tax_amount = lv_taxamount.

    lv_wrbtramt = lw_main-wrbtr .
    PERFORM f_char_toamt USING lv_wrbtramt CHANGING lv_wrbtr.
    lw_data-wrbtr = lv_wrbtr.

    lv_menge_quant = lw_main-menge.
    PERFORM f_char_toamt USING lv_menge_quant CHANGING lv_menge.
    lw_data-menge = lv_menge.

    lw_data-bukrs         = lw_main-bukrs.
    lw_data-xblnr         = lw_main-xblnr.
    lw_data-lifnr         = lw_main-lifnr.
    lw_data-bldat         = lw_main-bldat.
    lw_data-budat         = lw_main-budat.
    lw_data-waers         = lw_main-waers.
    lw_data-expense_type  = lw_main-expense_type .
    lw_data-approval      = lw_main-approval .
    lw_data-header_txt    = lw_main-header_txt.
    lw_data-sgtxt         = lw_main-sgtxt.
    lw_data-ebeln         = lw_main-ebeln .
    lw_data-ebelp         = lw_main-ebelp.
    lw_data-mwskz         = lw_main-mwskz.
    lw_data-bupla         = lw_main-bupla.
    lw_data-zterm         = lw_main-zterm .
    lw_data-rzawe         = lw_main-rzawe.
    lw_data-hbkid         = lw_main-hbkid .
    lw_data-hktid         = lw_main-hktid .
    lw_data-bvtyp         = lw_main-bvtyp.
    lw_data-hkont         = lw_main-hkont .
    lw_data-kostl         = lw_main-kostl.
    lw_data-anln1         = lw_main-anln1.
    lw_data-ps_posid      = lw_main-ps_posid.
    lw_data-prctr         = lw_main-prctr  .
    lw_data-fkber         = lw_main-fkber .
    lw_data-zuonr         = lw_main-zuonr .
    lw_data-smtp_addr     = lw_main-smtp_addr.
*Start of Change - CATALYST 1239 - 476549 - D4SK907337
    lw_data-gst_part      = lw_main-gst_part.
    lw_data-gst_no        = lw_main-gst_no.            "CATALYST-1239 | D4SK907558
    lw_data-hsn_sac       = lw_main-hsn_sac.
*End of Change - CATALYST 1239 - 476549 - D4SK907337

    APPEND lw_data TO pt_data.
    CLEAR: lw_data, lw_main.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_PROCESS_FILE
*&---------------------------------------------------------------------*
*& Process the data read from the file and send to Open Text
*&---------------------------------------------------------------------*
*&      <-- PT_DATA  - File data
*&      <-- P_PATH  - File path
*&      <-- P_ATTACH  - Attachment file path
*&      <-- P_COUNT  - Total Count
*&---------------------------------------------------------------------*
FORM f_process_file USING pt_data  TYPE STANDARD TABLE
                          p_path   TYPE string
                          p_attach TYPE string
                          p_count  TYPE i.

* Local variable declarations
  TYPES: BEGIN OF ty_t001,
           bukrs TYPE bukrs,
           land1 TYPE land1,
         END OF ty_t001.

  DATA: lt_data       TYPE TABLE OF ty_data,
        lt_t001       TYPE TABLE OF ty_t001,
        lt_vim_archiv TYPE TABLE OF zttfi_vim_archiv.

  DATA: lv_file_ext(4) TYPE c,
        lv_archiv_id   TYPE string,
        lv_path(2)     TYPE c,
        lv_attach(132) TYPE c,
        lv_item        TYPE i,
        lv_blart       TYPE blart,
        lv_arc_doc_id  TYPE saeardoid,
        lv_ar_object   TYPE saeobjart,
        lv_doctype     TYPE /opt/doctype,
        lv_wf_id       TYPE swwwihead-wi_id,
        lv_rc          TYPE sy-subrc,
        lw_doc_status  TYPE /opt/vim_dp_status1,
        lt_return      TYPE STANDARD TABLE OF bapiret2,
* Start of Change - DFT1POST-315 - 476549 - D4SK906744
        lv_amount      TYPE wrbtr,
        lv_currency    TYPE waers.
* End of Change - DFT1POST-315 - 476549 - D4SK906744

  REFRESH: lt_data, lt_t001, lt_vim_archiv.
  lt_data[] = pt_data[].

* Get the country key based on the company code in the file
  SELECT bukrs land1
    FROM t001
    INTO TABLE lt_t001
    FOR ALL ENTRIES IN lt_data
    WHERE bukrs = lt_data-bukrs.
  IF sy-subrc = 0.
    SORT lt_t001 BY bukrs land1.

* Based on the country key, fetch the Archiv ID from ZTTFI_VIM_ARCHIV
    SELECT *
      FROM ztfi_vim_archiv
      INTO TABLE lt_vim_archiv
      FOR ALL ENTRIES IN lt_t001
      WHERE land1 = lt_t001-land1.

  ENDIF.

  CLEAR: lv_blart, gv_amount, lv_item.

  LOOP AT lt_data INTO DATA(lw_data).
    CLEAR gw_item.

* Populate the item table based on the data in the file
    IF lw_data-ebeln IS INITIAL.
      lv_blart = gv_blart_kr.
      gw_item-ebeln    = '0000000000'.
    ELSE.
      lv_blart = gv_blart_re.
      gw_item-ebeln    = lw_data-ebeln.
    ENDIF.

    lv_item = lv_item + 1.
    gw_item-itemid   = lv_item.
    gw_item-sgtxt    = lw_data-sgtxt.
    gw_item-ebeln    = lw_data-ebeln.
    gw_item-ebelp    = lw_data-ebelp.
    gw_item-menge    = lw_data-menge.



* Amount conversion when the currency has zero decimals
* Start of Change - DFT1POST-315 - 476549 - D4SK906744
    CLEAR: lv_amount, lv_currency.
    lv_amount = lw_data-wrbtr.
    lv_currency = lw_data-waers.

    PERFORM f_zero_decimal_check USING    lv_amount
                                          lv_currency
                                 CHANGING lw_data-wrbtr.
* End of Change - DFT1POST-315 - 476549 - D4SK906744

* Start of Change - DFT1PSOST-67 - Richa - D4SK906575
    IF lw_data-wrbtr < 0.
      gw_item-wrbtr = lw_data-wrbtr * -1.
      gw_item-shkzg = 'H'.
    ELSE.
      gw_item-wrbtr = lw_data-wrbtr.
      gw_item-shkzg = 'S'.
    ENDIF.
* End of Change - DFT1PSOST-67 - Richa - D4SK906575

    gw_item-tax_code1    = lw_data-mwskz.  "Insert D4SK907469
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lw_data-hkont
      IMPORTING
        output = gw_item-hkont.
    gw_item-kostl    = lw_data-kostl.
    gw_item-anln1    = lw_data-anln1.
    gw_item-ps_posid = lw_data-ps_posid.
    gw_item-prctr    = lw_data-prctr.
    gw_item-fkber    = lw_data-fkber.
    gw_item-zuonr    = lw_data-zuonr.
    gw_item-hsn_sac  = lw_data-hsn_sac.       "CATALYST-1239  | D4SK907337

* If total amount is missing in the file, sum the line item
* amount to get the total amount
    gv_amount = gv_amount + lw_data-wrbtr.
    IF lw_data-total_amount IS INITIAL.
      lw_data-total_amount = gv_amount.
    ELSE.
* Amount conversion when currency has zero decimals
* Start of Change - DFT1POST-315 - 476549 - D4SK906744
      CLEAR: lv_amount, lv_currency.
      lv_amount = lw_data-total_amount.
      lv_currency = lw_data-waers.

      PERFORM f_zero_decimal_check USING    lv_amount
                                            lv_currency
                                   CHANGING lw_data-total_amount.
* End of Change - DFT1POST-315 - 476549 - D4SK906744
    ENDIF.

* Assign the Open Text Document Type based on the condition
* if PO Number is there in the file or not
    IF lw_data-ebeln IS INITIAL.
      gw_header-doctype = gv_doctype_nonpo.
      gw_header-ebeln   = '0000000000'.
    ELSE.
      gw_header-doctype = gv_doctype_po.
      gw_header-ebeln   = lw_data-ebeln.
    ENDIF.

    APPEND gw_item TO gt_item.

* Populate the header structure
    gw_header-blart          = lv_blart.
    gw_header-bukrs          = lw_data-bukrs.
    gw_header-xblnr          = lw_data-xblnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lw_data-lifnr
      IMPORTING
        output = gw_header-lifnr.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = lw_data-bldat
      IMPORTING
        date_internal            = gw_header-bldat
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    gw_header-bukrs        = lw_data-bukrs.
    gw_header-waers        = lw_data-waers.
    gw_header-expense_type = lw_data-expense_type.
    gw_header-bktxt        = lw_data-header_txt.
    gw_header-bupla        = lw_data-bupla.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lw_data-zterm
      IMPORTING
        output = gw_header-pymnt_terms.
    gw_header-payment_method = lw_data-rzawe.
    gw_header-gross_amount   = lw_data-total_amount.

    IF lw_data-tax_amount IS NOT INITIAL.
* Start of Change - DFT1POST-315 - 476549 - D4SK906744
      CLEAR: lv_amount, lv_currency.
      lv_amount = lw_data-tax_amount.
      lv_currency = lw_data-waers.

      PERFORM f_zero_decimal_check USING    lv_amount
                                            lv_currency
                                   CHANGING lw_data-total_amount.
    ENDIF.
* End of Change - DFT1POST-315 - 476549 - D4SK906744

    gw_header-hbkid          = lw_data-hbkid.
    gw_header-hktid          = lw_data-hktid.
    gw_header-bvtyp          = lw_data-bvtyp.
    gw_header-email_id       = lw_data-smtp_addr.
    gw_header-channel_id     = gv_channel.
    gw_header-gst_part       = lw_data-gst_part.    "CATALYST-1239  | D4SK907337
    gw_header-gst_reg_num    = lw_data-gst_no.      "CATALYST-1239  | D4SK907558

* Begin of changes CATALYST-1239 - 477670 - D4SK907687
* Populating Tax Amount field
    CLEAR: lv_amount, lv_currency.
    lv_amount   = lw_data-tax_amount.
    lv_currency = lw_data-waers.

    PERFORM f_zero_decimal_check USING    lv_amount
                                          lv_currency
                                 CHANGING lw_data-tax_amount.

    gw_header-vat_amount = lw_data-tax_amount.
* End of changes CATALYST-1239 - 477670 - D4SK907687

    IF lw_data-budat IS INITIAL.
      gw_header-budat = sy-datum.
    ELSE.
      gw_header-budat = lw_data-budat.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external            = lw_data-budat
        IMPORTING
          date_internal            = gw_header-budat
        EXCEPTIONS
          date_external_is_invalid = 1
          OTHERS                   = 2.
    ENDIF.

* At the end of Vendor Number in the file,
* process the record to be sent to Open Text
    AT END OF lifnr.

      DELETE ADJACENT DUPLICATES FROM gt_item COMPARING ALL FIELDS.

      READ TABLE lt_t001 INTO DATA(lw_t001) WITH KEY bukrs = gw_header-bukrs.
      IF sy-subrc = 0.
        READ TABLE lt_vim_archiv INTO DATA(lw_vim_archiv) WITH KEY land1 = lw_t001-land1.
        IF sy-subrc = 0.
          lv_ar_object = lw_vim_archiv-ar_object.
        ENDIF.
      ENDIF.

      CASE sy-sysid.
        WHEN 'D4S'(025).
          lv_path = gv_d1. "'D1'.
        WHEN 'S4Q'(026).
          lv_path = gv_q1. "'Q1'.
        WHEN OTHERS.
          lv_path = gv_p1. "'P1'.
      ENDCASE.

      CLEAR: lv_file_ext, lv_attach.
      lv_file_ext = gv_attach_ext.
      lv_attach = p_attach.
* If the number of records to be processed in the file is 1
* archieve the attachment, else do not process the attachment
      IF p_count = 1.
        IF NOT p_attach IS INITIAL.
          CALL FUNCTION 'SCMS_AO_FILE_CREATE_PATH'
            EXPORTING
              arc_id            = lv_path
              path              = lv_attach
              doc_type          = lv_file_ext
              no_delete         = gv_x
            IMPORTING
              doc_id            = lv_arc_doc_id
            EXCEPTIONS
              error_http        = 1
              error_archiv      = 2
              error_kernel      = 3
              error_config      = 4
              blocked_by_policy = 5
              OTHERS            = 6.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
      ELSE.

      ENDIF.

* Call the FM to send the data to Open Text and create a DP document
      CALL FUNCTION '/OPT/VIM_START_DOC_PROCESS_EXT'
        EXPORTING
          doctype      = gw_header-doctype
          archiv_id    = lv_path
          arc_doc_id   = lv_arc_doc_id
          ar_object    = lv_ar_object
          channel_id   = gv_channel
          i_doc_header = gw_header
        IMPORTING
          rc           = lv_rc
          e_wf_id      = lv_wf_id
          doc_status   = lw_doc_status
        TABLES
          i_doc_items  = gt_item
          return       = lt_return.

* Populate the output table with the required fields to be displayed to the user.
      READ TABLE lt_return INTO DATA(lw_return) INDEX 1.
      IF lv_wf_id IS INITIAL.
        gw_error-bukrs = gw_header-bukrs.
        gw_error-xblnr = gw_header-xblnr.
        gw_error-lifnr = gw_header-lifnr.
        gw_error-doctype = gw_header-doctype.
        gw_error-type = gv_w.
        gw_error-message = lw_return-message.
        APPEND gw_error TO gt_messages.
        CLEAR gw_error.
      ELSE.
        gw_error-bukrs = gw_header-bukrs.
        gw_error-xblnr = gw_header-xblnr.
        gw_error-lifnr = gw_header-lifnr.
        gw_error-doctype = gw_header-doctype.
        gw_error-index = lw_doc_status-docid.
        gw_error-type = gv_s. "'S'.
        CONCATENATE 'Workitem Created'(011) lv_wf_id lw_return-message
           INTO gw_error-message SEPARATED BY space.
        APPEND gw_error TO gt_messages.
        CLEAR gw_error.
      ENDIF.
      CLEAR: gw_item, lv_item,  gw_header, lv_rc, lv_wf_id, lw_doc_status, gv_amount.
      REFRESH: gt_item.
    ENDAT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CHECK_DATA
*&---------------------------------------------------------------------*
*& Validate the data read from the file
*&---------------------------------------------------------------------*
*&      <-- PT_DATA  - File data
*&      <-- P_CHECK  - Check if the file has valid data or not
*&      <-- P_COUNT  - Total Count
*&---------------------------------------------------------------------*
FORM f_check_data USING pt_data TYPE STANDARD TABLE
                        p_check TYPE char1
                        p_count TYPE i.

* Local variable declaration
  DATA: lt_data     TYPE TABLE OF ty_data,
        lt_item     TYPE TABLE OF bapiacgl09,
        lt_vendor   TYPE TABLE OF bapiacap09,
        lt_currency TYPE TABLE OF bapiaccr09,
        lt_return   TYPE STANDARD TABLE OF bapiret2.

  DATA: lw_header   TYPE bapiache09,
        lw_item     TYPE bapiacgl09,
        lw_vendor   TYPE bapiacap09,
        lw_currency TYPE bapiaccr09.

  DATA: lv_blart        TYPE blart,
        lv_count        TYPE i,
        lv_item         TYPE posnr,
***********************************************
        lv_total_amount TYPE rl03t-pickm.

  REFRESH lt_data.
  lt_data[] = pt_data[].

  CLEAR: lv_blart, lw_item, gv_amount, lw_vendor, lw_currency, lv_item, lv_count.
  REFRESH: lt_item, lt_vendor, lt_currency.

* Begin of changes CATALYST-1239 - 477670 - D4SK907558
*Validation for HSN number
  SELECT steuc FROM  t604f
               INTO TABLE @DATA(lt_t604f)
               FOR ALL ENTRIES IN @lt_data
               WHERE land1 EQ @gv_ind
               AND   steuc EQ @lt_data-hsn_sac.

  IF sy-subrc EQ 0.
    SORT lt_t604f BY steuc.
  ENDIF.
* End of changes CATALYST-1239 - 477670 - D4SK907558

  LOOP AT lt_data INTO DATA(lw_data).
    IF lw_data-ebeln IS INITIAL.
      lv_blart = gv_blart_kr.
    ELSE.
      lv_blart = gv_blart_re.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lw_data-hkont
      IMPORTING
        output = lw_data-hkont.

* Populate the item table
    CLEAR: lw_item, lw_currency.
    READ TABLE lt_item INTO DATA(lw_itm) WITH KEY gl_account = lw_data-hkont.
    IF sy-subrc <> 0.
      lw_item-gl_account  = lw_data-hkont.
      IF lw_data-hkont IS INITIAL.
        lw_item-acct_type = gv_koart_k.
      ENDIF.
      lv_item = lv_item + 10.
      lw_item-itemno_acc  = lv_item.
      lw_item-item_text   = lw_data-sgtxt.
      lw_item-comp_code   = lw_data-bukrs.
      lw_item-func_area   = lw_data-fkber.
      lw_item-alloc_nmbr  = lw_data-zuonr.
      lw_item-tax_code    = lw_data-mwskz.
      lw_item-costcenter  = lw_data-kostl.
      lw_item-profit_ctr  = lw_data-prctr.
      lw_item-wbs_element = lw_data-ps_posid.
      lw_item-asset_no    = lw_data-anln1.
      lw_item-quantity    = lw_data-menge.
      IF lw_data-menge IS NOT INITIAL.
        lw_item-base_uom = 'EA'(012).
      ENDIF.
      lw_item-po_number   = lw_data-ebeln.
      lw_item-po_item     = lw_data-ebelp.
      lw_item-expense_type = lw_data-expense_type.
      APPEND lw_item TO lt_item.

      lw_currency-itemno_acc  = lv_item.
      lw_currency-currency = lw_data-waers.
      lw_currency-amt_doccur = lw_data-total_amount.
      IF lw_data-total_amount IS INITIAL.
        lw_currency-amt_doccur = lw_data-wrbtr.
        IF lw_data-total_amount IS INITIAL.
          lw_currency-amt_doccur = 1000.
        ENDIF.
      ENDIF.

      APPEND lw_currency TO lt_currency.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lw_data-lifnr
      IMPORTING
        output = lw_data-lifnr.

    CLEAR: lw_vendor, lw_currency.
    READ TABLE lt_vendor INTO DATA(lw_lifnr) WITH KEY vendor_no = lw_data-lifnr.
    IF sy-subrc <> 0.
      lv_item = lv_item + 10.
      lw_vendor-itemno_acc  = lv_item.
      lw_vendor-vendor_no       = lw_data-lifnr.
      lw_vendor-comp_code       = lw_data-bukrs.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lw_data-zterm
        IMPORTING
          output = lw_vendor-pmnttrms.
      lw_vendor-pymt_meth       = lw_data-rzawe.
      lw_vendor-businessplace   = lw_data-bupla.
      lw_vendor-partner_bk      = lw_data-bvtyp.
      lw_vendor-bank_id         = lw_data-hbkid.
      lw_vendor-housebankacctid = lw_data-hktid.

      APPEND lw_vendor TO lt_vendor.

      lw_currency-itemno_acc  = lv_item.
      lw_currency-currency = lw_data-waers.
      lw_currency-amt_doccur = lw_data-total_amount * -1.
      IF lw_data-total_amount IS INITIAL.
        lw_currency-amt_doccur = lw_data-wrbtr * -1.
        IF lw_data-total_amount IS INITIAL.
          lw_currency-amt_doccur = 1000 * -1.
        ENDIF.
      ENDIF.
      APPEND lw_currency TO lt_currency.
    ENDIF.

    lw_header-header_txt = lw_data-header_txt.
    lw_header-comp_code  = lw_data-bukrs.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = lw_data-bldat
      IMPORTING
        date_internal            = lw_header-doc_date
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.

* Populate the header structure
    lw_header-doc_type   = lv_blart.
    lw_header-ref_doc_no = lw_data-xblnr.
    lw_header-username   = sy-uname.
    IF lw_data-budat IS INITIAL.
      lw_header-pstng_date = sy-datum.
    ELSE.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external            = lw_data-budat
        IMPORTING
          date_internal            = lw_header-pstng_date
        EXCEPTIONS
          date_external_is_invalid = 1
          OTHERS                   = 2.
    ENDIF.

    IF lw_data-wrbtr IS INITIAL.
      p_check = gv_x.

      gw_error-bukrs = lw_header-comp_code.
      gw_error-xblnr = lw_header-ref_doc_no.
      gw_error-lifnr = lw_vendor-vendor_no.
      gw_error-type = gv_e.
      gw_error-message = 'Line Item Amount is missing'(033).
      APPEND gw_error TO gt_messages.

    ENDIF.

*Start of Change - CATALYST 1239 - 476549 - D4SK907337
*If business place and hsn number are missing in the input file
*the record should not be processed and error should be displayed

*If business place is entered in the input file,
*validate it with the values entered in the TVARVC variable
    IF lw_data-bukrs = gv_bukrs.
      IF lw_data-bupla IS INITIAL.
        p_check = gv_x.

        gw_error-bukrs = lw_header-comp_code.
        gw_error-xblnr = lw_header-ref_doc_no.
        gw_error-lifnr = lw_vendor-vendor_no.
        gw_error-type = gv_e.
        gw_error-message = 'Business Place is missing'(035).
        APPEND gw_error TO gt_messages.
      ELSE.
        IF lw_data-bupla IN gt_val.
        ELSE.
          p_check = gv_x.

          gw_error-bukrs = lw_header-comp_code.
          gw_error-xblnr = lw_header-ref_doc_no.
          gw_error-lifnr = lw_vendor-vendor_no.
          gw_error-type = gv_e.
          gw_error-message = 'Invalid Business Place Value'(038).
          APPEND gw_error TO gt_messages.
        ENDIF.
      ENDIF.

* Begin of changes CATALYST-1239 - 477670 - D4SK907558
*Validating HSN number
      IF lw_data-hsn_sac IS NOT INITIAL.

        READ TABLE lt_t604f INTO DATA(lw_t604f) WITH KEY steuc = lw_data-hsn_sac.
        IF sy-subrc NE 0.
          p_check = gv_x.
          gw_error-bukrs = lw_header-comp_code.
          gw_error-xblnr = lw_header-ref_doc_no.
          gw_error-lifnr = lw_vendor-vendor_no.
          gw_error-type = gv_e.
          gw_error-message = 'HSN code is not defined for country IN'(040).
          APPEND gw_error TO gt_messages.
        ENDIF.
* End of changes CATALYST-1239 - 477670 - D4SK907558
      ELSE.
        p_check = gv_x.

        gw_error-bukrs = lw_header-comp_code.
        gw_error-xblnr = lw_header-ref_doc_no.
        gw_error-lifnr = lw_vendor-vendor_no.
        gw_error-type = gv_e.
        gw_error-message = 'HSN Code is missing'(036).
        APPEND gw_error TO gt_messages.
      ENDIF.
    ENDIF.
*End of Change - CATALYST 1239 - 476549 - D4SK907337

    AT END OF lifnr.

      lv_count = lv_count + 1.

      CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
        EXPORTING
          documentheader = lw_header
        TABLES
          accountgl      = lt_item
          accountpayable = lt_vendor
          currencyamount = lt_currency
          return         = lt_return.

      DELETE: lt_return WHERE type = gv_e AND id = 'RW' AND number = 609,
              lt_return WHERE type = gv_e AND id = 'FF' AND number = 818.

      LOOP AT lt_return INTO DATA(lw_return) WHERE type = gv_e.
        p_check = gv_x.
        gw_error-bukrs = lw_header-comp_code.
        gw_error-xblnr = lw_header-ref_doc_no.
        gw_error-lifnr = lw_vendor-vendor_no.
        gw_error-type = gv_e.
        gw_error-message = lw_return-message.
        APPEND gw_error TO gt_messages.
        CLEAR gw_error.
      ENDLOOP.

      REFRESH: lt_item, lt_vendor, lt_currency, lt_return.
      CLEAR: lw_header, lv_item.
    ENDAT.
  ENDLOOP.

* Hold the count of the number of invoice data in a particular file
  p_count = lv_count.

ENDFORM.
*&---------------------------------------------------------------------*
*& Display the data in ALV Report
*&---------------------------------------------------------------------*
*&      --> pt_table  table
*&---------------------------------------------------------------------*
FORM f_display_data.

  DELETE ADJACENT DUPLICATES FROM gt_messages COMPARING ALL FIELDS.

  CREATE OBJECT go_alv.

  CALL METHOD go_alv->display_alv
    CHANGING
      c_datatab = gt_messages.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*& Fetch the constants for the program
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& -->  fp_pgmid        Program Name
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
        MESSAGE e007 WITH 'TVARVC'(013).      "No data found in & table
      WHEN 2.
        MESSAGE e010 WITH 'TVARVC'(013).      "Atleast one constant entry missing in & table
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

  READ TABLE gt_pgm_const_values INTO DATA(lw_pgm_const_values) WITH KEY const_name = 'P_P'.
  IF sy-subrc = 0.
    gv_p = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_P'(014).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_X'.
  IF sy-subrc = 0.
    gv_x = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_X'(015).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_E'.
  IF sy-subrc = 0.
    gv_e = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_E'(016).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_BLART_KR'.
  IF sy-subrc = 0.
    gv_blart_kr = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_BLART_KR'(017).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_BLART_RE'.
  IF sy-subrc = 0.
    gv_blart_re = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_BLART_RE'(018).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_DOCTYPE_NONPO'.
  IF sy-subrc = 0.
    gv_doctype_nonpo = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_DOCTYPE_NONPO'(019).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_DOCTYPE_PO'.
  IF sy-subrc = 0.
    gv_doctype_po = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_DOCTYPE_PO'(020).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_W'.
  IF sy-subrc = 0.
    gv_w = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_W'(021).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_S'.
  IF sy-subrc = 0.
    gv_s = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_S'(022).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_KOART_K'.
  IF sy-subrc = 0.
    gv_koart_k = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_KOART_K'(023).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_CHANNEL'.
  IF sy-subrc = 0.
    gv_channel = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_CHANNEL'(024).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_ARCHIV_ID_D1'.
  IF sy-subrc = 0.
    gv_d1 = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_ARCHIV_ID_D1'(027).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_ARCHIV_ID_Q1'.
  IF sy-subrc = 0.
    gv_q1 = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_ARCHIV_ID_Q1'(028).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_ARCHIV_ID_P1'.
  IF sy-subrc = 0.
    gv_p1 = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_ARCHIV_ID_P1'(029).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_ATTACH_EXT'.
  IF sy-subrc = 0.
    gv_attach_ext = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_ATTACH_EXT'(030).
  ENDIF.

  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_I'.
  IF sy-subrc = 0.
    gv_i = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_I'(032).
  ENDIF.

*Start of Change - CATALYST 1239 - 476549 - D4SK907337
  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_BUKRS_1700'.
  IF sy-subrc = 0.
    gv_bukrs = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_BUKRS_1700'(037).
  ENDIF.

  LOOP AT gt_pgm_const_values INTO lw_pgm_const_values WHERE const_name = 'ZGST_REGIO'.
    gw_val-sign = 'I'.
    gw_val-option = 'EQ'.
    gw_val-low = lw_pgm_const_values-low.
    APPEND gw_val TO gt_val.
  ENDLOOP.

*End of Change - CATALYST 1239 - 476549 - D4SK907337

* Begin of changes CATALYST-1239 - 477670 - D4SK907615
  READ TABLE gt_pgm_const_values INTO lw_pgm_const_values WITH KEY const_name = 'P_LAND1_IN'.
  IF sy-subrc = 0.
    gv_ind = lw_pgm_const_values-low.
  ELSE.
    MESSAGE e025 WITH 'P_LAND1_IN'(039).
  ENDIF.

* End of changes CATALYST-1239 - 477670 - D4SK907615

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CHAR_TOAMT
*&---------------------------------------------------------------------*
*& Changing the character to amount type
*&---------------------------------------------------------------------*
*&      --> LV_TOTAL_AMOUNT
*&---------------------------------------------------------------------*
FORM f_char_toamt  USING  p_charamnt CHANGING p_numamount.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = p_charamnt
    IMPORTING
      num             = p_numamount
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
* Start of Change - DFT1POST-315 - 476549 - D4SK906744
*&---------------------------------------------------------------------*
*& Form F_ZERO_DECIMAL_CHECK
*&---------------------------------------------------------------------*
*& Check if currency and zero decimal, if so, change the amount
*&---------------------------------------------------------------------*
*&      --> P_AMOUNT
*&      --> P_CURR
*&      --> P_WRBTR
*&---------------------------------------------------------------------*
FORM f_zero_decimal_check USING    p_amount
                                   p_curr
                          CHANGING p_wrbtr.

  SELECT SINGLE currdec
    FROM tcurx
    INTO @DATA(lv_currdec)
    WHERE currkey = @p_curr.

  IF sy-subrc = 0.
    IF lv_currdec = 0.
      p_wrbtr = p_amount / 100.
    ENDIF.
  ENDIF.

ENDFORM.
* End of Change - DFT1POST-315 - 476549 - D4SK906744
