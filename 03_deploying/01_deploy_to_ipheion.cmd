:: Name:     01_deploy_to_ipheion.cmd
:: Purpose:  set environment and run deploy script 
:: Author:   pierre@pvln.nl
:: Revision: 2018 12 10 - initial version
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Setting required environment variables:
::
SET site_name=ipheion
SET extension_name=robots
:: where to put the files on the remote server
SET deploy_folder=./joomla_01/
:: where to put the files on the local machine
SET extension_folder=..\..\_5_extensions\_installed\_robots
:: Where to find the secrets on the local machine
SET secrets_folder=..\..\..\..\_settings

::
:: Assume psftp should be used first. Then pscp. If not available choose ftp
::

:: !! Do not use " or ' at beginning or end of the list
::    Do not use sftp as the password can't be entered from batch files   
SET CHECK_TRANSFER_LIST=psftp pscp ftp

CALL 05_deploy_files.cmd
