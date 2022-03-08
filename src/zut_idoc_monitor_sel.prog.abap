*&---------------------------------------------------------------------*
*& Include          ZUT_IDOC_MONITOR_SEL
*&---------------------------------------------------------------------*
SELECT-OPTIONS : s_docnum for edidc-docnum,
                 s_mestyp FOR edidc-mestyp NO INTERVALS VISIBLE LENGTH 100 OBLIGATORY,
                 s_status FOR edidc-status,
                 s_credat FOR edidc-credat,
                 s_upddat FOR edidc-upddat. " OBLIGATORY.

SELECTION-SCREEN skip 1.

SELECT-OPTIONS : s_email FOR adr6-smtp_addr NO INTERVALS MODIF ID id1 VISIBLE LENGTH 100.
