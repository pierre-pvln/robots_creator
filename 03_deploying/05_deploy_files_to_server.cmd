:: Name:     05_deploy_files_to_server.cmd
:: Purpose:  FTP file to server
:: Author:   pierre.veelen@pvln.nl
::
::
:: Requires environments vaiables to be set:
::  site_name
::  extension_name
::  deploy_folder
::  secrets_folder
::  extension_folder
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Check if required environment variables are set
IF "%site_name%" == "" (
   SET ERROR_MESSAGE=Environment variable site_name not set.
   GOTO ERROR_EXIT
)
IF "%extension_name%" == "" (
   SET ERROR_MESSAGE=Environment variable extension_name not set.
   GOTO ERROR_EXIT
)
IF "%deploy_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable deploy_folder not set.
   GOTO ERROR_EXIT
)
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable secrets_folder not set.
   GOTO ERROR_EXIT
)
IF "%extension_folder%" == "" (
   SET ERROR_MESSAGE=Environment variable extension_folder not set.
   GOTO ERROR_EXIT
)

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

::call deploy_%extension_name%_%sitename%.cmd
cd %secrets_folder%
IF EXIST deploy_%extension_name%_%site_name%.cmd (
   CALL deploy_%extension_name%_%site_name%.cmd
) ELSE (
   SET ERROR_MESSAGE=File with deployment settings deploy_%extension_name%_%site_name%.cmd for %extension_name% doesn't exist in %secrets_folder%
   GOTO ERROR_EXIT
)

CD "%cmd_dir%" 
IF NOT EXIST "%extension_folder%" (MD "%extension_folder%")
CD "%extension_folder%"

:: move any "old" .htaccess files to history folder 
::
:: check for specific files without producing output 
:: inspiration: https://stackoverflow.com/questions/1262708/suppress-command-line-output
::
dir /b /A:-D ".htaccess_*"
dir ".htaccess_*" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO NO_RELEVANT_FILES
FOR /f %%G in ('dir /b /A:-D ".htaccess_*"') DO (
    IF %ERRORLEVEL% NEQ 0 Echo An error was found
    IF %ERRORLEVEL% EQU 0 Echo No error found
    ECHO =====
	ECHO %%G
	ECHO =====
	MOVE "%%G" ".\_history\"
) 
:NO_RELEVANT_FILES

ECHO TOT HIER WERKT HET GOED
PAUSE


:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

CD "%cmd_dir%" 
CD
ECHO EN TOT HIER ?

:: download current version from website
echo %deploy_user%>%secrets_folder%\_ftp_files.txt
echo %deploy_pw%>>%secrets_folder%\_ftp_files.txt
:: switch to binary mode
echo binary>>%secrets_folder%\_ftp_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>%secrets_folder%\_ftp_files.txt
:: change the local directory so output goes there
echo lcd %extension_folder%	>>%secrets_folder%\_ftp_files.txt
echo cd %deploy_folder%>>%secrets_folder%\_ftp_files.txt
echo get .htaccess>>%secrets_folder%\_ftp_files.txt
echo bye>>%secrets_folder%\_ftp_files.txt

echo %secrets_folder%\_ftp_files.txt
type %secrets_folder%\_ftp_files.txt
echo xxxxxxxxxxxx 3 xx
PAUSE

:: run the actual FTP commandfile
ftp -s:%secrets_folder%\_ftp_files.txt %deploy_server%
del %secrets_folder%\_ftp_files.txt

echo xxxxxxxxxxxx 4 xx
PAUSE


CD "%extension_folder%"
:: Check if .htaccess. was downloaded then rename it
IF EXIST .htaccess. ( rename .htaccess. .htaccess_from_site_%dtStamp%. )

:: get the latest version of the file
CURL http://download.pvln.nl/joomla/baselines/htaccess/pvln/htaccess.txt --output .htaccess.
COPY .htaccess. .htaccess_to_site_%dtStamp%.

echo xxxxxxxxxxxx 5 xx


pause

CD "%cmd_dir%" 
CD
ECHO EN TOT HIER DAN 2?

:: put the new version on the website
echo %deploy_user%>>%secrets_folder%\_ftp_files.txt
echo %deploy_pw%>>%secrets_folder%\_ftp_files.txt
:: switch to binary mode
echo binary>>%secrets_folder%\_ftp_files.txt
:: disable prompt; process the mput or mget without requiring any reply
echo prompt>>%secrets_folder%\_ftp_files.txt
echo lcd %extension_folder%	>>%secrets_folder%\_ftp_files.txt
echo cd %deploy_folder%>>%secrets_folder%\_ftp_files.txt
echo put .htaccess>>%secrets_folder%\_ftp_files.txt
echo bye>>%secrets_folder%\_ftp_files.txt


echo xxxxxxxxxxxx 6 xx


pause


:: run the actual FTP commandfile
ftp -s:%secrets_folder%\_ftp_files.txt %deploy_server%

del %secrets_folder%\_ftp_files.txt

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _ftp_files.txt file
IF EXIST "%secrets_folder%\_ftp_files.txt" (del "%secrets_folder%\_ftp_files.txt")
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT   
timeout /T 10
