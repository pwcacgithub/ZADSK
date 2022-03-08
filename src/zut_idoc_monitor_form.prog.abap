*&---------------------------------------------------------------------*
*& Include          ZUT_IDOC_MONITOR_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_OBJECTS
*&---------------------------------------------------------------------*
*       Refresh ALL Objects
*----------------------------------------------------------------------*
FORM f_refresh_objects .

  REFRESH : gt_edidc, gt_edids, gt_final, gt_slis_fcat,
            gt_attach_attr.
  CLEAR : gv_exit.
ENDFORM.                    " F_REFRESH_OBJECTS

*&---------------------------------------------------------------------*
*& Fetch the constants for the program
*&---------------------------------------------------------------------*
*& -->  fp_pgmid        Program Name
*&---------------------------------------------------------------------*
FORM f_get_constants USING fp_pgmid TYPE char40.

  REFRESH : gt_pgm_const_values, gt_error_const.
*** Call ZUTIL_PGM_CONSTANTS Utility FM to fetch the constants
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
*        MESSAGE e007 WITH 'TVARVC'(007).    "No data found in TVARVC table
      WHEN 2.
*        MESSAGE e010 WITH 'TVARVC'(007).    "Atleast one constant entry missing in TVARVC table
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_COLLECT_CONSTANTS
*&---------------------------------------------------------------------*
*& Collect the value of the Constants in variables
*&---------------------------------------------------------------------*
FORM f_collect_constants.

  READ TABLE gt_pgm_const_values INTO DATA(lw_pgm_const_values) WITH KEY const_name = 'P_IDOCMONI_MAIL_BODY'.
  IF sy-subrc = 0.
    gv_email_body_text = lw_pgm_const_values-low.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
**** Extract the required data from EDIDC - IDOC Controll Data as per selection
*----------------------------------------------------------------------*
FORM f_get_data .

  TYPES: BEGIN OF ty_date,
           sign TYPE tvarv_sign,
           opti TYPE tvarv_opti,
           low  TYPE rvari_val_255,
           high TYPE rvari_val_255,
         END OF ty_date.

  DATA: lw_date TYPE ty_date,
        lt_date TYPE TABLE OF ty_date.

  lw_date-sign  = 'I'.
  lw_date-opti = 'BT'.
  lw_date-low = '00:00:00'.
  lw_date-high = '23:59:59'.
  APPEND lw_date TO lt_date.

  CLEAR : g_cursor_edidc, g_cursor_edids.
**** Extract the required data from EDIDC - IDOC Control Data as per selection
**** Open Cursor for the Extract
**** Extract the Most recent errors or Recently Processed Error of the IDOC
****  Hence used the Last Updated date / time instead of IDOC creation date/time
  OPEN CURSOR: g_cursor_edidc FOR
       SELECT docnum
              status
              doctyp
              direct
              rcvprt
              rcvprn
              sndprt
              sndprn
              credat
              cretim
              mestyp
              idoctp
              rcvpfc
              sndpfc
              upddat
              updtim
         FROM edidc
         WHERE docnum IN s_docnum
           AND status IN s_status
           AND credat IN s_credat  "Create On Date
           AND cretim IN lt_date
           AND mestyp IN s_mestyp
           AND upddat IN s_upddat  "Updated Date
           AND updtim IN lt_date.

  DO.
***    Fetch the Data based on the Selection based on package size
    FETCH NEXT CURSOR g_cursor_edidc APPENDING TABLE gt_edidc PACKAGE SIZE 500.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
  ENDDO.

  CLOSE CURSOR g_cursor_edidc.

  IF gt_edidc[] IS INITIAL.
    gv_exit = gc_x.
    MESSAGE i368(00) WITH 'No IDOCs Found for the given Selection'(001).
  ELSE.

    SORT gt_edidc BY docnum.
**** Extract the required data from EDIDS - IDOC Status Data as per selection
**** Open Cursor for the Extract
    IF NOT s_credat[] IS INITIAL.
      OPEN CURSOR: g_cursor_edids FOR
       SELECT docnum
              logdat
              logtim
              countr
              status
              statxt
              stapa1
              stapa2
              stapa3
              stapa4
              statyp
              stamid
              stamno
         FROM edids
         FOR ALL ENTRIES IN gt_edidc
         WHERE docnum = gt_edidc-docnum
           AND logdat = gt_edidc-credat "gt_edidc-upddat
           AND logtim = gt_edidc-cretim "gt_edidc-updtim
*             AND credat = gt_edidc-credat
*             AND cretim = gt_edidc-cretim
           AND status IN s_status.
    ELSEIF NOT s_upddat[] IS INITIAL.
      OPEN CURSOR: g_cursor_edids FOR
       SELECT docnum
              logdat
              logtim
              countr
              status
              statxt
              stapa1
              stapa2
              stapa3
              stapa4
              statyp
              stamid
              stamno
         FROM edids
         FOR ALL ENTRIES IN gt_edidc
         WHERE docnum = gt_edidc-docnum
           AND logdat = gt_edidc-upddat
*           AND logtim = gt_edidc-updtim
*             AND credat = gt_edidc-credat
*             AND cretim = gt_edidc-cretim
           AND status IN s_status.
    ENDIF.
*    OPEN CURSOR: g_cursor_edids FOR
*         SELECT docnum
*                logdat
*                logtim
*                countr
*                status
*                statxt
*                stapa1
*                stapa2
*                stapa3
*                stapa4
*                statyp
*                stamid
*                stamno
*           FROM edids
*           FOR ALL ENTRIES IN gt_edidc
*           WHERE docnum = gt_edidc-docnum
*             AND logdat = gt_edidc-upddat
*             AND logtim = gt_edidc-updtim
**             AND credat = gt_edidc-credat
**             AND cretim = gt_edidc-cretim
*             AND status IN s_status.

    DO.
***    Fetch the Data based on the Selection based on package size
      FETCH NEXT CURSOR g_cursor_edids APPENDING TABLE gt_edids PACKAGE SIZE 500.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDDO.

    CLOSE CURSOR g_cursor_edids.

    IF gt_edids[] IS INITIAL.
      gv_exit = gc_x.
      MESSAGE i368(00) WITH 'No IDOC Status Data Found for the given selection'(002).
    ELSE.
      SORT gt_edids BY docnum.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  f_collect_error_messages
*&---------------------------------------------------------------------*
*    Collect the Data to show in ALV and send Email
*----------------------------------------------------------------------*
FORM f_collect_error_messages .

  LOOP AT gt_edids INTO gw_edids.
*** Get the Header IDOC details***
    CLEAR gw_edidc.
    READ TABLE gt_edidc INTO gw_edidc WITH KEY docnum = gw_edids-docnum BINARY SEARCH.
    IF sy-subrc = 0.
*** Populate final table
      CLEAR : gw_final.
      MOVE-CORRESPONDING gw_edidc TO gw_final.

***    Populate direction
      CASE gw_edidc-direct.
        WHEN '1'.
          gw_final-direct = gc_outbound.
        WHEN '2'.
          gw_final-direct = gc_inbound.
      ENDCASE.

***    Populate Error Text
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = gw_edids-stamid
          lang      = sy-langu
          no        = gw_edids-stamno
          v1        = gw_edids-stapa1
          v2        = gw_edids-stapa2
          v3        = gw_edids-stapa3
          v4        = gw_edids-stapa4
        IMPORTING
          msg       = gw_final-err_message
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2. ##FM_SUBRC_OK
      IF sy-subrc = 0.

      ENDIF.
      APPEND gw_final TO gt_final.
    ENDIF.

  ENDLOOP.
  SORT gt_final BY docnum direct status.
  DELETE gt_final WHERE err_message IS INITIAL.


ENDFORM.                    " F_COLLECT_DATA
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*  Show ALV Output
*----------------------------------------------------------------------*
FORM f_display_output.

  PERFORM f_generate_field_catalog.
  PERFORM f_show_alv TABLES gt_final[].

ENDFORM.                    " F_DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_FIELD_CATALOG
*&---------------------------------------------------------------------*
*  Generate Field Catalog for ALV Output
*----------------------------------------------------------------------*

FORM f_generate_field_catalog.

  REFRESH : gt_slis_fcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_str_name
    CHANGING
      ct_fieldcat            = gt_slis_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3. ##FM_SUBRC_OK
  IF NOT sy-subrc IS INITIAL.

  ENDIF.

ENDFORM.                    " F_GENERATE_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  F_SHOW_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FINAL[]  final Table to show in ALV
*----------------------------------------------------------------------*
FORM f_show_alv TABLES pt_final.

*** Show ALV output
  gs_layout-zebra = gc_x.
  gs_layout-colwidth_optimize = gc_x.

  gv_repid = sy-cprog.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
      it_fieldcat        = gt_slis_fcat[]
      is_layout          = gs_layout
      i_default          = gc_x
      i_save             = gc_a
      is_variant         = gv_variant
    TABLES
      t_outtab           = pt_final[]
    EXCEPTIONS
      OTHERS             = 4. ##FM_SUBRC_OK

ENDFORM.                    " F_SHOW_ALV
*&---------------------------------------------------------------------*
*&      Form  F_SEND_EMAIL_ALERT
*&---------------------------------------------------------------------*
*   Send Email Alert
*----------------------------------------------------------------------*
FORM f_send_email_alert .

  REFRESH : gt_fieldcat.
  PERFORM f_build_fieldcat USING    gc_str_name
                           CHANGING gt_fieldcat.
  PERFORM f_create_header.
  PERFORM f_create_rows.
  PERFORM f_create_solix_data.
  PERFORM f_send_email.

ENDFORM.                    " F_SEND_EMAIL_ALERT
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*   Generate Field Catalog
*----------------------------------------------------------------------*
*       pv_str_name     structure name to generate Field catalog
*      <--PT_FIELDCAT   Field Catalog details
*----------------------------------------------------------------------*
FORM f_build_fieldcat  USING    pv_str_name
                       CHANGING pt_fieldcat TYPE lvc_t_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = pv_str_name
    CHANGING
      ct_fieldcat      = pt_fieldcat.

ENDFORM.                    " F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HEADER
*&---------------------------------------------------------------------*
*       Create Attachment Header
*----------------------------------------------------------------------*
FORM f_create_header .
***Generate Excel sheet header based on the Data element Long text
  CLEAR : gv_string, gv_fcat_tabix, gv_tabix, gv_text , gv_lines, gv_fcat_lines.
  IF gt_fieldcat[] IS NOT INITIAL.

    DESCRIBE TABLE gt_fieldcat[] LINES gv_fcat_lines.

    LOOP AT gt_fieldcat INTO gs_fieldcat.
      CLEAR : gv_fcat_tabix.
      gv_fcat_tabix = sy-tabix.
*** Get All the Fields Data element Long Text and add to string
      CLEAR gv_text.
      MOVE gs_fieldcat-scrtext_l TO gv_text.
      CONDENSE gv_text.

      IF gv_fcat_tabix = gv_fcat_lines.
        CONCATENATE gv_string gv_text INTO gv_string.
      ELSE.
        CONCATENATE gv_string gv_text gc_seperator INTO gv_string.
      ENDIF.
      CONDENSE gv_string.

    ENDLOOP.

    CONCATENATE gv_string gc_cret INTO gv_string.

  ENDIF.

ENDFORM.                    " F_CREATE_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ROWS
*&---------------------------------------------------------------------*
*       Create Excel Rows
*----------------------------------------------------------------------*
FORM f_create_rows .

  CLEAR : gv_lines, gv_tabix.
  DESCRIBE TABLE gt_final LINES gv_lines.

*** Process Final Table records and convert to String to generate Excel sheet Rows
  LOOP AT gt_final ASSIGNING <fs_final>.

*** Store Error Table Current Tabix
    gv_tabix = sy-tabix.
    LOOP AT gt_fieldcat INTO gs_fieldcat.
***      Store Field Catalog Current tabix
      gv_fcat_tabix = sy-tabix.

      CLEAR gv_text.
      ASSIGN COMPONENT gs_fieldcat-fieldname
      OF STRUCTURE <fs_final> TO <fs_value>.
      IF sy-subrc = 0.
        IF gs_fieldcat-inttype = 'N' OR
           gs_fieldcat-inttype = 'D' OR
           gs_fieldcat-inttype = 'C'.
          WRITE <fs_value> TO gv_text.
        ELSE.
          MOVE <fs_value> TO gv_text.
          CONDENSE gv_text.
        ENDIF.
      ENDIF.
***
***      These fields are populated into the gv_string
***IDoc number / Status of IDoc / Direction / Message Type / Basic type / Partner Number of Recipient / Partner Number of Sender
***Error message / Date of Last Change / Time of Last Change
***
      IF gv_fcat_tabix = gv_fcat_lines.
        CONCATENATE gv_string gv_text INTO gv_string.
      ELSE.
        CONCATENATE gv_string gv_text gc_seperator INTO gv_string.
      ENDIF.
      CONDENSE gv_string.

    ENDLOOP.

    IF gv_tabix <> gv_lines.
      CONCATENATE gv_string gc_cret INTO gv_string.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " F_CREATE_ROWS
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SOLIX_DATA
*&---------------------------------------------------------------------*
*       Generate SOLIX data to send as Email attachment
*----------------------------------------------------------------------*
FORM f_create_solix_data .

*       Generate SOLIX data to send as Email attachment
  REFRESH : gt_solix.
  CLEAR   : gv_size.

  TRY.
      cl_bcs_convert=>string_to_solix(
      EXPORTING
        iv_string     = gv_string
        iv_codepage   = gc_codepage
        iv_add_bom    = gc_addbom
      IMPORTING
        et_solix      = gt_solix
        ev_size       = gv_size ).

    CATCH cx_bcs.

  ENDTRY.

ENDFORM.                    " F_CREATE_SOLIX_DATA
*&---------------------------------------------------------------------*
*&      Form  F_SEND_EMAIL
*&---------------------------------------------------------------------*
* Send email
*----------------------------------------------------------------------*
FORM f_send_email .

*  DATA(go_file) = NEW zcl_ca_utility_adsk( ).
  DATA(go_file) = NEW zsdci_cl_xa_utility( ).
  CLEAR : gv_subject,
          gv_sys_client.

**** Get email body from standard text
  PERFORM f_get_email_body_text.

***   Email Subject
  CONCATENATE sy-sysid sy-mandt INTO gv_sys_client.
  CONCATENATE gv_sys_client '-IDOC Error Monitoring'(003) INTO gv_subject.

**--Build attachment attribute
  gw_attach_attr-body_start = 1.
  DESCRIBE TABLE gt_solix LINES gw_attach_attr-body_num.
  gw_attach_attr-doc_type = 'XLS'(004).
  gw_attach_attr-obj_name = 'Email'(005).
  CONCATENATE gv_sys_client'-IDOC Error Monitoring'(003) sy-datum sy-timlo INTO DATA(gv_ob_dec)
                        SEPARATED BY space.
  gw_attach_attr-obj_descr = gv_ob_dec.
  APPEND gw_attach_attr TO gt_attach_attr.
  CLEAR gw_attach_attr.

***   Email Subject
  CONCATENATE gv_sys_client'-IDOC Error Monitoring'(003) INTO gv_subject.

**  " Create mail document
  CREATE OBJECT g_document_bcs.

  TRY.
      LOOP AT s_email.
        CLEAR : g_recipient, gv_email.
        IF sy-tabix EQ 1.
          gv_email = s_email-low.
        ELSE.
          CONCATENATE gv_email s_email-low INTO gv_email SEPARATED BY ';'(008).
        ENDIF.
      ENDLOOP.

      CALL METHOD go_file->send_mail
        EXPORTING
          i_rec_type             = '001'
          i_receiver             = gv_email
          i_subject              = gv_subject
          i_body                 = gt_mail_body
          i_attachment_attribute = gt_attach_attr
          i_attachment           = gt_solix
          i_immediate            = abap_true
        IMPORTING
          e_retcode              = gv_retcode
          e_err_str              = gv_err_str.

    CATCH cx_document_bcs INTO g_excep_bcs.
  ENDTRY.

  COMMIT WORK.

ENDFORM.                    " F_SEND_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMAIL_BODY_TEXT
*&---------------------------------------------------------------------*
*  Read Text
*----------------------------------------------------------------------*
FORM f_get_email_body_text .
*** Read the Standard Text
  REFRESH : gt_line, gt_mail_body.
  CLEAR : gv_langu.
  gv_langu = sy-langu.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = gc_st
      language                = gv_langu
      name                    = gv_email_body_text
      object                  = gc_object
    TABLES
      lines                   = gt_line
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.     "##FM_SUBRC_OK.
  IF sy-subrc <> 0.

  ENDIF.

  LOOP AT gt_line INTO gs_line.
    CLEAR : gs_mail_body.
    gs_mail_body = gs_line-tdline.
    APPEND gs_mail_body TO gt_mail_body.
  ENDLOOP.

ENDFORM.                    " F_GET_EMAIL_BODY_TEXT
*&---------------------------------------------------------------------*
*& Form F_VALIDATE_DATE
*&---------------------------------------------------------------------*
*       Validate Update Date
*&---------------------------------------------------------------------*
FORM f_validate_date .

  IF s_credat[] IS INITIAL AND s_upddat[] IS INITIAL.
    gv_exit = gc_x.
    MESSAGE i368(00) WITH 'Enter either Create On/Changed On Date.'(010).
  ENDIF.

  IF NOT s_credat[] IS INITIAL AND NOT s_upddat[] IS INITIAL.
    gv_exit = gc_x.
    MESSAGE i368(00) WITH 'Enter either Create On/Changed On Date.'(010).
  ENDIF.

*  IF s_upddat[] IS INITIAL.
*    gv_exit = gc_x.
*    MESSAGE i368(00) WITH 'Please enter Last Changed Date.'(010).
*  ENDIF.

ENDFORM.
