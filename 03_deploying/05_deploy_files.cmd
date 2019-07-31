:: Name:     05_deploy_files.cmd
:: Purpose:  Deploy files to server
:: Author:   pierre@pvln.nl
::
:: Required environment variables
:: ==============================
:: site_name                      the name of the site
:: extension_name                 the name of the extension
:: deploy_folder
:: secrets_folder                 the folder where the secrets are stored
:: extension_folder               the folder where the old and the newly deployed files are stored
:: CHECK_TRANSFER_LIST            list off commands which could be used to transfer the files
::
@ECHO off
::
:: inspiration: http://batcheero.blogspot.com/2007/06/how-to-enabledelayedexpansion.html
:: using ENABLEDELAYEDEXPANSION and !env-var! ensures correct operation of script 
::
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
::
:: Check if required environment variables are set. If not exit script ...
::
IF "%extension_name%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] extension_name not set ...
   GOTO ERROR_EXIT
)
IF "%deploy_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] deploy_folder not set ...
   GOTO ERROR_EXIT
)
IF "%secrets_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] secrets_folder not set ...
   GOTO ERROR_EXIT
)
IF "%extension_folder%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] extension_folder not set ...
   GOTO ERROR_EXIT
)
IF "%site_name%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] site_name not set ...
   GOTO ERROR_EXIT
)
IF "%CHECK_TRANSFER_LIST%" == "" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] CHECK_TRANSFER_LIST not set ...
   GOTO ERROR_EXIT
)
::
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

::
:: Reset environment variables
::
SET TRANSFER_COMMAND=
SET deploy_command=
::
:: Now check if transfer executable is available. Assumes that get and put can both be performed with transfer executable
:: Then if security settings are available
:: And finally if transfer scripts are available
::
FOR %%x IN (%CHECK_TRANSFER_LIST%) DO (
    SET ERROR_MESSAGE=
	ECHO [INFO ] Checking for %%x ...
    where /Q %%x
    IF !ERRORLEVEL!==0 ( 
       FOR /F "tokens=*" %%G IN ( 'WHERE %%x' ) DO ( SET deploy_command=%%G )
       SET TRANSFER_COMMAND=%%x
	   ECHO [INFO ] Checking requirements for !TRANSFER_COMMAND!
	   CD "%secrets_folder%"
       IF NOT EXIST deploy_%extension_name%_!TRANSFER_COMMAND!.cmd (
	       SET ERROR_MESSAGE=[ERROR] [%~n0 ] File with deployment settings deploy_%extension_name%_%TRANSFER_COMMAND%.cmd for %extension_name% doesn't exist in %secrets_folder%
	       ECHO !ERROR_MESSAGE!
       )
       CD "%cmd_dir%"
	   IF NOT EXIST deploy_!TRANSFER_COMMAND!_get.cmd (
           SET ERROR_MESSAGE=[ERROR] [%~n0 ] File deploy_!TRANSFER_COMMAND!_get.cmd script doesn't exist
    	   ECHO !ERROR_MESSAGE!
       )
	   IF NOT EXIST deploy_!TRANSFER_COMMAND!_put.cmd (
           SET ERROR_MESSAGE=[ERROR] [%~n0 ] File deploy_!TRANSFER_COMMAND!_put.cmd script doesn't exist
    	   ECHO !ERROR_MESSAGE!
       )
	   IF "!ERROR_MESSAGE!" == "" GOTO TRANSFER_COMMAND_FOUND
    ) ELSE (
        ECHO [INFO ] %%x not possible ...		
    )
)
:TRANSFER_COMMAND_NOT_FOUND
SET ERROR_MESSAGE=[ERROR] [%~n0 ] A deploy command from %CHECK_TRANSFER_LIST% could not be set ...
GOTO ERROR_EXIT

:TRANSFER_COMMAND_FOUND
ECHO [INFO ] Transfer using %TRANSFER_COMMAND% ...
::
CD "%cmd_dir%"
:: call deploy_%extension_name%_%TRANSFER_COMMAND%.cmd
:: returns:
:: - deploy_downloadserver
:: - deploy_user_downloadserver
:: - deploy_pw_downloadserver
::
CD %secrets_folder%
CALL deploy_%extension_name%_%TRANSFER_COMMAND%.cmd

CD "%cmd_dir%" 
IF NOT EXIST "%extension_folder%" (MD "%extension_folder%")
CD "%extension_folder%"

ECHO [INFO ] Check if any robots files exists and if so move it to history folder ... 
::
:: check for specific files without producing output 
:: inspiration: https://stackoverflow.com/questions/1262708/suppress-command-line-output
::
:: For the previous versionsrobots
dir "robots_*" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO NO_RELEVANT_OLD_TYPE_FILES
FOR /f %%G in ('dir /b /A:-D "robots_*"') DO (
    ECHO [INFO ] Moving %%G to history folder ...
    MOVE "%%G" ".\_history\"
)
:NO_RELEVANT_OLD_TYPE_FILES
ECHO [INFO ] No robots_* file found. Continueing ...

:: For the new versions
dir "robots_*" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO NO_RELEVANT_NEW_TYPE_FILES
FOR /f %%G in ('dir /b /A:-D "robots_*"') DO (
    ECHO [INFO ] Moving %%G to history folder ...
    MOVE "%%G" ".\_history\"
) 
:NO_RELEVANT_NEW_TYPE_FILES
ECHO [INFO ] No robots_* file found. Continueing ...

:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

ECHO [INFO ] Download current version of robots.txt from website using %TRANSFER_COMMAND% ...
CD "%cmd_dir%" 
SET temporary_folder=%secrets_folder%
CALL deploy_%TRANSFER_COMMAND%_get.cmd
IF %ERRORLEVEL% NEQ 0 (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] script deploy_%TRANSFER_COMMAND%_get.cmd returned error ...
   GOTO ERROR_EXIT
)

ECHO [INFO ] Check if robots.txt was downloaded then rename it ...
CD "%extension_folder%"
IF EXIST robots.txt ( 
   ECHO [INFO ] Renaming robots.txt to robots_from_site_%dtStamp%.txt
   RENAME robots.txt robots_from_site_%dtStamp%.txt
)

:: Inspiration: https://ec.haxx.se/usingcurl-verbose.html (getting response info in variable)
::              https://stackoverflow.com/questions/313111/is-there-a-dev-null-on-windows 
::               (-o /dev/null in linux ; -o nul in windows)    
::
ECHO [INFO ] Check if robots.txt for %site_name% exists at staging area ...
FOR /f "tokens=*" %%G IN ('curl -LI http://download.pvln.nl/joomla/baselines/robots/%site_name%/robots.txt -o nul -w %%{http_code} -s') DO (
    SET CURL_RESPONSE=%%G
)
IF "%CURL_RESPONSE%" NEQ "200" (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] File robots.txt for %site_name% is not available at staging area ...
   GOTO ERROR_EXIT
)

ECHO [INFO ] Get the robots.txt file for %site_name% from staging area ...
curl http://download.pvln.nl/joomla/baselines/robots/%site_name%/robots.txt --output robots.txt
COPY robots.txt robots_to_site_%dtStamp%.txt
::
:: Put the files on the server
::
CD "%cmd_dir%" 
::
:: For some put actions temporary files are needed. Set a foldername for that.
::
SET temporary_folder=%secrets_folder%
ECHO [INFO ] Running deploy_%TRANSFER_COMMAND%_put.cmd ...
CALL deploy_%TRANSFER_COMMAND%_put.cmd
IF %ERRORLEVEL% NEQ 0 (
   SET ERROR_MESSAGE=[ERROR] [%~n0 ] script deploy_%TRANSFER_COMMAND%_put.cmd returned error ...
   GOTO ERROR_EXIT
)
ECHO [INFO ] File deployed ...
GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
:: remove any existing _deploy_files.txt file
IF EXIST "%temporary_folder%\_deploy_files.txt" (del "%temporary_folder%\_deploy_files.txt")
ECHO *******************
ECHO %ERROR_MESSAGE%
ECHO *******************
   
:CLEAN_EXIT
timeout /T 5
