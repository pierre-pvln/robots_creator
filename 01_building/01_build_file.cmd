:: Name:     01_build_file.cmd
:: Purpose:  Create the robots.txt file from the building blocks
:: Author:   pierre@pvln.nl
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

:: COMMANDLINE INPUT
:: =================
:: 
:: read the input folder name
SET baseline=%1

:: STATIC VARIABLES
:: ================
CD ..\04_settings\

:: Determine the name of the baseline folder
:: Either from command line setting or from value in file
IF NOT "%baseline%" == "" GOTO BASELINE_FROM_COMMANDLINE
:: no baseline set on command line, get if from the file
IF EXIST 00_name.cmd (
   CALL 00_name.cmd
) ELSE (
   SET ERROR_MESSAGE=File with name settings doesn't exist
   GOTO ERROR_EXIT
)
:BASELINE_FROM_COMMANDLINE
:: Convert baseline to lowercase
:: http://www.robvanderwoude.com/battech_convertcase.php
::
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "baseline=%%baseline:%%~i%%"
 
IF EXIST 04_folders.cmd (
   CALL 04_folders.cmd
) ELSE (
   SET ERROR_MESSAGE=File with folder settings doesn't exist
   GOTO ERROR_EXIT
)

IF NOT EXIST "%output_dir%\%baseline%" (MD "%output_dir%\%baseline%")
)	

:: Retrieving build version parameters for default settings
::
SET buildparameter.majorversion=""
SET buildparameter.minorversion=""
SET buildparameter.patchversion=""

IF NOT EXIST "%building_blocks%\default\_version.txt" (
   SET ERROR_MESSAGE=File %building_blocks%\default\_version.txt with build version parameters doesn't exist
   GOTO ERROR_EXIT
)
:: Read parameters file
:: Inspiration: http://www.robvanderwoude.com/battech_inputvalidation_commandline.php#ParameterFiles
::              https://ss64.com/nt/for_f.html
::
:: Remove comment lines
TYPE "%building_blocks%\default\_version.txt" | FINDSTR /v # >"%output_dir%\default\robots_parameters_clean.txt"
:: Check parameter file for unwanted characters
FINDSTR /R "( ) & ' ` \"" "%output_dir%\default\robots_parameters_clean.txt" > NUL
IF NOT ERRORLEVEL 1 (
	SET ERROR_MESSAGE=The parameter file contains unwanted characters, and cannot be parsed.
	GOTO ERROR_EXIT
)
:: Only parse the file if no unwanted characters were found
FOR /F "tokens=1,2 delims==" %%A IN ('FINDSTR /R /X /C:"[^=][^=]*=.*" "%output_dir%\default\robots_parameters_clean.txt" ') DO (
	SET buildparameter.%%A=%%B
)

IF "%buildparameter.majorversion%" == "" (
	ECHO The buildparameter.majorversion is not defined. Setting it to 0.
	SET buildparameter.majorversion=0
)
IF "%buildparameter.minorversion%" == "" (
	ECHO The buildparameter.minorversion is not defined. Setting it to 0.
	SET buildparameter.minorversion=0
)
IF "%buildparameter.patchversion%" == "" (
	ECHO The buildparameter.patchversion is not defined. Setting it to 0.
	SET buildparameter.patchversion=0
)

SET buildversiondefault=d%buildparameter.majorversion%.%buildparameter.minorversion%.%buildparameter.patchversion%

:: Retrieving build version parameters for specific settings
::
SET buildparameter.majorversion=""
SET buildparameter.minorversion=""
SET buildparameter.patchversion=""

IF NOT EXIST "%building_blocks%\%baseline%\_version.txt" (
   SET ERROR_MESSAGE=File %building_blocks%\%baseline%\_version.txt with build version parameters doesn't exist
   GOTO ERROR_EXIT
)
:: Read parameters file
:: Inspiration: http://www.robvanderwoude.com/battech_inputvalidation_commandline.php#ParameterFiles
::              https://ss64.com/nt/for_f.html
::
:: Remove comment lines
TYPE "%building_blocks%\%baseline%\_version.txt" | FINDSTR /v # >"%output_dir%\%baseline%\robots_parameters_clean.txt"
:: Check parameter file for unwanted characters
FINDSTR /R "( ) & ' ` \"" "%output_dir%\%baseline%\robots_parameters_clean.txt" > NUL
IF NOT ERRORLEVEL 1 (
	SET ERROR_MESSAGE=The parameter file contains unwanted characters, and cannot be parsed.
	GOTO ERROR_EXIT
)
:: Only parse the file if no unwanted characters were found
FOR /F "tokens=1,2 delims==" %%A IN ('FINDSTR /R /X /C:"[^=][^=]*=.*" "%output_dir%\%baseline%\robots_parameters_clean.txt" ') DO (
	SET buildparameter.%%A=%%B
)

IF "%buildparameter.majorversion%" == "" (
	ECHO The buildparameter.majorversion is not defined. Setting it to 0.
	SET buildparameter.majorversion=0
)
IF "%buildparameter.minorversion%" == "" (
	ECHO The buildparameter.minorversion is not defined. Setting it to 0.
	SET buildparameter.minorversion=0
)
IF "%buildparameter.patchversion%" == "" (
	ECHO The buildparameter.patchversion is not defined. Setting it to 0.
	SET buildparameter.patchversion=0
)

SET buildversionspecific=s%buildparameter.majorversion%.%buildparameter.minorversion%.%buildparameter.patchversion%

:: Determine the build version
SET buildversion=%buildversiondefault%-%buildversionspecific%
ECHO Building version:      %buildversion%
ECHO For environment:       %baseline%
ECHO From default settings: %buildversiondefault%
ECHO And specific settings: %buildversionspecific%

CD "%cmd_dir%"

:: Check if the inputfolder exists
:: inspiration: https://stackoverflow.com/questions/138981/how-to-test-if-a-file-is-a-directory-in-a-batch-script
:: 
IF NOT EXIST "%building_blocks%\%baseline%\*" (
   SET ERROR_MESSAGE=The folder %building_blocks%\%baseline% doesn't exist
   GOTO ERROR_EXIT
)

:: Sets the proper date and time stamp with 24Hr Time for log file naming convention
:: inspiration: http://stackoverflow.com/questions/1192476/format-date-and-time-in-a-windows-batch-script
::
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~9,4%%date:~6,2%%date:~3,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
SET dtStamp24=%date:~9,4%%date:~6,2%%date:~3,2%_%time:~0,2%%time:~3,2%%time:~6,2%
IF "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) ELSE (SET dtStamp=%dtStamp24%)

:: If robots.txt file exists copy that file to the backup folder en rename that backed-up file.
::
:: check if back_up directory exists
SET backup_dir=%output_dir%\%baseline%\backup
IF NOT EXIST "%backup_dir%" (MD "%backup_dir%")

::
IF EXIST "%output_dir%\%baseline%\robots_%buildversion%.txt" (
	COPY "%output_dir%\%baseline%\robots_%buildversion%.txt" "%backup_dir%\robots_%buildversion%_%dtStamp%.txt"
	DEL  "%output_dir%\%baseline%\robots_%buildversion%.txt"
)
IF EXIST "%output_dir%\%baseline%\robots_%buildversion%_comments.txt" (
	COPY "%output_dir%\%baseline%\robots_%buildversion%_comments.txt" "%backup_dir%\robots_%buildversion%_%dtStamp%_comments.txt"
	DEL  "%output_dir%\%baseline%\robots_%buildversion%_comments.txt"
)

SET input_filenames=
SET plus_sign=
SETLOCAL ENABLEDELAYEDEXPANSION
FOR /f %%G in ('dir /b /A:-D "%building_blocks%\default\*.robots.txt"') DO (
	IF EXIST "%building_blocks%\%baseline%\%%G" (
	   SET input_filenames=!input_filenames!!plus_sign!%building_blocks%\%baseline%\%%G
	) ELSE (
	   SET input_filenames=!input_filenames!!plus_sign!%building_blocks%\default\%%G
	)  
	SET plus_sign=+
)	

::
:: Inspiration: https://stackoverflow.com/questions/2477271/concatenate-text-files-with-windows-command-line-dropping-leading-lines
:: 
:: Combine the building blocks
:: /b - treats the input files as binary (i.e., a raw stream of meaningless bytes), and copies them byte for byte.
::
COPY /b %input_filenames% %output_dir%\%baseline%\robots_constructed.txt

::
:: Inspiration: https://stackoverflow.com/questions/418916/delete-certain-lines-in-a-txt-file-via-a-batch-file
:: 
:: Remove the comment lines
TYPE "%output_dir%\%baseline%\robots_constructed.txt" | FINDSTR /v # >"%output_dir%\%baseline%\robots_clean.txt"

:: Create new header
ECHO #======================================================= >"%output_dir%\tmp_header.txt"
ECHO # robots.txt file created for: %baseline% >>"%output_dir%\tmp_header.txt"
ECHO # build version: %buildversion% >>"%output_dir%\tmp_header.txt"
ECHO # by script on : %dtStamp% >>"%output_dir%\tmp_header.txt"
ECHO # More information is available in ...\%baseline%\robots_%buildversion%_comments.txt >>"%output_dir%\tmp_header.txt"
ECHO #======================================================= >>"%output_dir%\tmp_header.txt"
ECHO # >>"%output_dir%\tmp_header.txt"

:: Create the robots.txt file
COPY /b %output_dir%\tmp_header.txt+%output_dir%\%baseline%\robots_clean.txt %output_dir%\%baseline%\robots_%buildversion%.txt

:: Add header to robots.txt file with comments
COPY /b %output_dir%\tmp_header.txt+%output_dir%\%baseline%\robots_constructed.txt %output_dir%\%baseline%\robots_%buildversion%_comments.txt

:: cleanup
DEL %output_dir%\tmp_header.txt
DEL %output_dir%\%baseline%\robots_clean.txt
DEL %output_dir%\%baseline%\robots_constructed.txt
DEL %output_dir%\%baseline%\robots_parameters_clean.txt

:: Create the robots.txt file 
COPY %output_dir%\%baseline%\robots_%buildversion%.txt %output_dir%\%baseline%\robots.txt

GOTO CLEAN_EXIT

:ERROR_EXIT
cd "%cmd_dir%" 
ECHO *******************
ECHO Error: %ERROR_MESSAGE%
ECHO *******************

:CLEAN_EXIT   
timeout /T 10
