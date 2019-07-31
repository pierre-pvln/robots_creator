:: Name:     stage_psftp_put.cmd
:: Purpose:  Transfer files to staging/downloadserver using psftp
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: - staging_command			  command incl path that is used transfer files to staging/download server
:: - staging_user_downloadserver  the username on the download server
:: - staging_pw_downloadserver    the password for that user
:: - output_dir                   the folder with files that are transfered (on local machine)
:: - temporary_folder             the folder where temporary files are stored (on local machine)
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
IF "%temporary_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] temporary_folder not set ...
   GOTO ERROR_EXIT_SUBSCRIPT
)
::
:: Remove any existing %temporary_folder%\_ftp_files.txt file
::
IF EXIST "%temporary_folder%\_staging_files.txt" (del "%temporary_folder%\_staging_files.txt")
::
:: Create %temporary_folder%\_staging_files.txt
::
ECHO cd %staging_folder%>>%temporary_folder%\_staging_files.txt
ECHO lcd %output_dir%>>%temporary_folder%\_staging_files.txt
FOR /f %%G in ('dir /b /A:D "%output_dir%"') DO (
	ECHO mkdir %%G>>%temporary_folder%\_staging_files.txt
	ECHO cd %%G>>%temporary_folder%\_staging_files.txt
	ECHO lcd %%G>>%temporary_folder%\_staging_files.txt
    FOR /f %%H in ('dir /b /A:-D "%output_dir%\%%G"') DO (
   	    ECHO put %%H>>%temporary_folder%\_staging_files.txt
    )
	ECHO cd ..>>%temporary_folder%\_staging_files.txt
	ECHO lcd ..>>%temporary_folder%\_staging_files.txt
)	
ECHO bye>>%temporary_folder%\_staging_files.txt

:: Run the script
"%staging_command%" -b %temporary_folder%\_staging_files.txt -be -l %staging_user_downloadserver% -pw %staging_pw_downloadserver% %staging_downloadserver%
del %temporary_folder%\_staging_files.txt
GOTO CLEAN_EXIT_SUBSCRIPT

:ERROR_EXIT_SUBSCRIPT
ECHO %ERROR_MESSAGE%
::timeout /T 5
EXIT /B 1

:CLEAN_EXIT_SUBSCRIPT   
::timeout /T 5
EXIT /B 0
