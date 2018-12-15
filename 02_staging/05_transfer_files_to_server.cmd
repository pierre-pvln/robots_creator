:: Name:     05_transfer_files_to_server.cmd
:: Purpose:  Transfer files to downloadserver
:: Author:   pierre.veelen@pvln.nl
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: BASIC SETTINGS
:: ==============
:: Setting the name of the script
SET me=%~n0
:: Setting the name of the directory with this script
SET parent=%~p0
:: Setting the drive of this commandfile
SET drive=%~d0
:: Setting the directory and drive of this commandfile
SET cmd_dir=%~dp0

:: STATIC VARIABLES
:: ================
CD ..\04_settings\

IF EXIST 04_folders.cmd (
   CALL 04_folders.cmd
) ELSE (
   SET ERROR_MESSAGE=File with folder settings doesn't exist
   GOTO ERROR_EXIT
)

:: call staging_robots.cmd
:: returns:
:: - staging_downloadserver
:: - staging_user_downloadserver
:: - staging_pw_downloadserver
::
cd ..\..\..\_secrets
IF EXIST staging_robots.cmd (
   CALL staging_robots.cmd
) ELSE (
   SET ERROR_MESSAGE=File with staging settings for robots.txt building blocks doesn't exist
   GOTO ERROR_EXIT
)

cd "%cmd_dir%"
:: Put it on download server
:: =========================
::
:: remove any existing ..\09_temporary\_ftp_files.txt file
IF EXIST "..\09_temporary\_staging_files.txt" (del "..\09_temporary\_staging_files.txt")
::
:: Create ..\09_temporary\_staging_files.txt
echo %staging_user_downloadserver%>>..\09_temporary\_staging_files.txt
echo %staging_pw_downloadserver%>>..\09_temporary\_staging_files.txt
:: switch to binary mode
echo binary>>..\09_temporary\_staging_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>..\09_temporary\_staging_files.txt
:: copy files from top level folder
echo cd %ftp_download_folder%>>..\09_temporary\_staging_files.txt
echo mput %output_dir%\*>>..\09_temporary\_staging_files.txt
:: copy files from all sub folders
FOR /f %%G in ('dir /b /A:D "%output_dir%"') DO (
	echo mkdir %%G>>..\09_temporary\_staging_files.txt
    echo cd %%G>>..\09_temporary\_staging_files.txt
	echo mput %output_dir%\%%G\*>>..\09_temporary\_staging_files.txt
	echo put %output_dir%\index.html>>..\09_temporary\_staging_files.txt
	echo cd ..>>..\09_temporary\_staging_files.txt
    )
echo bye>>..\09_temporary\_staging_files.txt

:: run the actual FTP commandfile
ftp -s:..\09_temporary\_staging_files.txt %staging_downloadserver%
del ..\09_temporary\_staging_files.txt

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _staging_files.txt file
IF EXIST "..\09_temporary\_staging_files.txt" (del "..\09_temporary\_staging_files.txt")
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT   
timeout /T 10
