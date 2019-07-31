:: Name:     stage_pscp_put.cmd
:: Purpose:  Transfer files to staging/downloadserver using pscp
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: - staging_command			  command incl path that is used transfer files to staging/download server
:: - staging_user_downloadserver  the username on the download server
:: - staging_pw_downloadserver    the password for that user
:: - output_dir                   the folder with files that are transfered (on local machine)
:: - staging_downloadserver       the name or ip-address of the staging/download server 
:: - staging_folder               the folder where the files are stored in on the staging/download server
::
:: Remarks
:: ==============================
:: %~n0 = the name of this script
::
@ECHO off
::
:: Check if required environment variables are set. If not exit script.
::
IF "%staging_command%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] staging_command not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_user_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] staging_user_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_pw_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] staging_pw_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%output_dir%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] output_dir not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_downloadserver%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] staging_downloadserver not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
IF "%staging_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] staging_folder not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
:: Run the script
"%staging_command%" -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% -r %output_dir%\* %staging_downloadserver%:%staging_folder%
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO %ERROR_MESSAGE%
::timeout /T 5
EXIT /B 1

:CLEAN_EXIT_SUBSCRIPT   
::timeout /T 5
EXIT /B 0