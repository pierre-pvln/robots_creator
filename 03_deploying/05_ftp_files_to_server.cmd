:: Name:     05_ftp_file_to_server.cmd
:: Purpose:  FTP file to server
:: Author:   pierre.veelen@pvln.nl
::





:: https://stackoverflow.com/questions/10084941/how-can-i-upload-an-entire-folder-that-contains-other-folders-using-sftp-on-li
:: scp -r foo your_username@remotehost.edu:/some/remote/directory/bar





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

::IF EXIST 00_name.cmd (
::   CALL 00_name.cmd
::) ELSE (
::   SET ERROR_MESSAGE=File with baseline name settings doesn't exist
::   GOTO ERROR_EXIT
::)

IF EXIST 04_folders.cmd (
   CALL 04_folders.cmd
) ELSE (
   SET ERROR_MESSAGE=File with folder settings doesn't exist
   GOTO ERROR_EXIT
)

::call ftp_%extension%_settings.cmd
cd ..\..\..\_secrets
IF EXIST ftp_htaccess_settings.cmd (
   CALL ftp_htaccess_settings.cmd
) ELSE (
   SET ERROR_MESSAGE=File with ftp settings for this extension doesn't exist
   GOTO ERROR_EXIT
)

cd "%cmd_dir%"
:: DOWNLOAD SERVER
:: =============
::
:: remove any existing ..\04_settings\_ftp_files.txt file
IF EXIST "..\04_settings\_ftp_files.txt" (del "..\04_settings\_ftp_files.txt")
::
:: Create ..\04_settings\_ftp_files.txt
echo %ftp_user_downloadserver%>>..\04_settings\_ftp_files.txt
echo %ftp_pw_downloadserver%>>..\04_settings\_ftp_files.txt
:: switch to binary mode
echo binary>>..\04_settings\_ftp_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>..\04_settings\_ftp_files.txt
echo cd %ftp_download_folder%>>..\04_settings\_ftp_files.txt
echo mput %output_dir%\*>>..\04_settings\_ftp_files.txt
echo bye>>..\04_settings\_ftp_files.txt

:: run the actual FTP commandfile
ftp -s:..\04_settings\_ftp_files.txt %ftp_downloadserver%

del ..\04_settings\_ftp_files.txt

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _ftp_files.txt file
IF EXIST "..\04_settings\_ftp_files.txt" (del "..\04_settings\_ftp_files.txt")
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************

   
:CLEAN_EXIT   
timeout /T 10
