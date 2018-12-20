:: Name:     01_deploy_to_pvln.cmd
:: Purpose:  set enviroment and run deploy script 
:: Author:   pierre.veelen@pvln.nl
:: Revision: 2018 12 10 - initial version
::

@ECHO off
SETLOCAL ENABLEEXTENSIONS

:: Required environment variables:
::
::
SET site_name=ver-bind
SET extension_name=robots
SET deploy_folder=./joomla_01/
SET secrets_folder=..\..\..\..\_settings
SET extension_folder=..\..\_5_extensions\_installed\_robots

CALL 05_deploy_files.cmd


PAUSE