*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 29.11.2019 at 02:21:14
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTUTILITY_CONST.................................*
DATA:  BEGIN OF STATUS_ZTUTILITY_CONST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTUTILITY_CONST               .
CONTROLS: TCTRL_ZTUTILITY_CONST
            TYPE TABLEVIEW USING SCREEN '0901'.
*.........table declarations:.................................*
TABLES: *ZTUTILITY_CONST               .
TABLES: ZTUTILITY_CONST                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
