:: Name:     _create_build_scripts.cmd
:: Purpose:  Create all the required build scripts from folder structure
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
::

@ECHO OFF
CD ..\00_dev_code

ECHO :: >..\01_building\build_all_batch.cmd
ECHO @ECHO off >>..\01_building\build_all_batch.cmd

FOR /f %%G in ('dir /b /A:D') DO (
    ECHO [INFO ] Creating ..\01_building\build_%%G.cmd ...
    ECHO :: >..\01_building\build_%%G.cmd
    ECHO @ECHO off >>..\01_building\build_%%G.cmd
    ECHO CALL 05_build_file.cmd %%G >>..\01_building\build_%%G.cmd
    ECHO. >>..\01_building\build_%%G.cmd
    ECHO PAUSE >>..\01_building\build_%%G.cmd

    ECHO CLS >>..\01_building\build_all_batch.cmd
    ECHO CALL 05_build_file.cmd %%G >>..\01_building\build_all_batch.cmd
    ECHO. >>..\01_building\build_all_batch.cmd
)

:CLEAN_EXIT
timeout /T 5
