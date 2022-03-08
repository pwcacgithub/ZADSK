**&---------------------------------------------------------------------*
**& Include          ZRUFI_COSTCENTERCREATE_TOP
**&---------------------------------------------------------------------*
*TABLES: csks.
*
**----------------------------------------------------------------------*
** Declaration for Table Types
**----------------------------------------------------------------------*
*TYPES:
*  BEGIN OF ty_data,
*    kostl      TYPE kostl,
*    datab      TYPE char10,
*    datbi      TYPE char10,
*    ktext      TYPE ktext,
*    kltxt      TYPE kltxt,
*    verak_user TYPE verak_user,
*    verak      TYPE verak,
*    abtei      TYPE abtei,
*    kosar      TYPE kosar,
*    khinr      TYPE khinr,
*    bukrs      TYPE bukrs,
*    gsber      TYPE gsber,
*    func_area  TYPE fkber,
*    waers      TYPE waers,
*    prctr      TYPE prctr,
*    mgefl      TYPE mgefl,
*    bkzkp      TYPE bkzkp,
*    pkzkp      TYPE pkzkp,
*    bkzks      TYPE bkzks,
*    pkzks      TYPE pkzks,
*    bkzer      TYPE bkzer,
*    pkzer      TYPE pkzer,
*    bkzob      TYPE bkzob,
*    cpi_templ  TYPE cca_templ_cpi,
*    cpd_templ  TYPE cca_templ_cpd,
*    sci_templ  TYPE cca_templ_sci,
*    scd_templ  TYPE cca_templ_scd,
*    ski_templ  TYPE cca_templ_ski,
*    skd_templ  TYPE cca_templ_skd,
*    kalsm      TYPE aufkalsm,
*    anred      TYPE anred,
*    name1      TYPE name1_gp,
*    name2      TYPE name2_gp,
*    name3      TYPE name3_gp,
*    name4      TYPE name4_gp,
*    stras      TYPE stras_gp,
*    pfach      TYPE pfach,
*    ort01      TYPE ort01_gp,
*    pstlz      TYPE pstlz,
*    ort02      TYPE ort02_gp,
*    pstl2      TYPE pstl2,
*    land1      TYPE land1,
*    regio      TYPE regio,
*    txjcd      TYPE txjcd,
*    spras      TYPE spras,
*    telf1      TYPE telf1,
*    telf2      TYPE telf2,
*    telbx      TYPE telbx,
*    telx1      TYPE telx1,
*    telfx      TYPE telfx,
*    teltx      TYPE teltx,
*    drnam      TYPE kdnam,
*    datlt      TYPE datlt,
*  END OF ty_data,
*
*  BEGIN OF ty_final,
*    kostl   TYPE kostl,
*    ktext   TYPE ktext,
*    type    TYPE bapi_mtype,
*    message TYPE bapi_msg,
*  END OF ty_final.
*
**----------------------------------------------------------------------*
** Declaration for Internal tables
**----------------------------------------------------------------------*
*DATA:
*  gt_data             TYPE TABLE OF ty_data,
*  gt_costcenterlist   TYPE TABLE OF bapi0012_ccinputlist,
*  gt_return           TYPE TABLE OF bapiret2,
*  gt_final            TYPE TABLE OF ty_final,
*  gt_pgm_const_values TYPE TABLE OF zspgm_const_values,
*  gt_error_const      TYPE TABLE OF zserror_const.
*
**----------------------------------------------------------------------*
** Declaration for work areas
**----------------------------------------------------------------------*
*DATA:
*  gw_costcenterlist TYPE bapi0012_ccinputlist,
*  gw_language       TYPE bapi0015_10,
*  gw_final          TYPE ty_final,
*  gw_error_msg      TYPE string.
*
**----------------------------------------------------------------------*
** Declaration for Variables
**----------------------------------------------------------------------*
*DATA:
*  gv_test    TYPE char1,
*  gv_s       TYPE c,
*  gv_file    TYPE string,
*  gv_a       TYPE char1,
*  gv_p       TYPE char1,
*  gv_x       TYPE char1,
*  gv_success TYPE char1,
*  gv_hdr     TYPE abap_encod.
*
**----------------------------------------------------------------------*
** Declaration for Reference Objects
**----------------------------------------------------------------------*
*DATA:
*  go_file TYPE REF TO zcl_ca_utility,
*  go_alv  TYPE REF TO zcl_ca_utility.
