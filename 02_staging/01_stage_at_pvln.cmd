:: Name:     01_stage_at_pvln.cmd
:: Purpose:  set enviroment and run deploy script 
:: Author:   pierre@pvln.nl
:: Revision: 2019 02 11 - initial version
::

@ECHO off

:: Setting required environment variables:
::
SET extension_name=robots
:: Where to put the files on the staging/download server
SET staging_folder=/download/joomla/baselines/robots/
:: Where to find the secrets
SET secrets_folder=..\..\..\_secrets

:: -OUTPUT DIRECTORY FOR BUILD = INPUT DIRECTORY FOR STAGING
:: do not start with \ , and do not end with \
SET output_dir=..\06_output\staging

::
:: Assume psftp should be used first. Then pscp. If not available choose ftp
::

:: !! Do not use " or ' at beginning or end of the list
::    Do not use sftp as the password can't be entered from batch files   
SET CHECK_TRANSFER_LIST=psftp pscp ftp

CALL 05_stage_files.cmd
