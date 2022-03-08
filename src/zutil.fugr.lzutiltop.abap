FUNCTION-POOL ZUTIL.                        "MESSAGE-ID ..

* INCLUDE LZUTILD...                         " Local class definition

*** Data Declaration
DATA : gv_msg TYPE char50.

*** Work Area Declaration
DATA : gw_pgm_const_values TYPE zspgm_const_values,
       gw_error_const      TYPE zserror_const.

*** Constants
CONSTANTS : gc_comma TYPE char1 VALUE ','.
