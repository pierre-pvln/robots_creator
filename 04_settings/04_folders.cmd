:: Name:     folders.cmd
:: Purpose:  set folders for updateserver and downloadserver as an environment variable
:: Author:   pierre.veelen@pvln.nl
:: Revision: 2018 11 231 - initial version
::
:: Required environment variables:
::
::

:: -BUILDING BLOCKS DIRECTORY FOR BUILD
:: do not start with \ , and do not end with \
SET building_blocks=..\00_dev_code

:: -OUTPUT DIRECTORY FOR BUILD
:: do not start with \ , and do not end with \
SET output_dir=..\06_output

:: -BACKUP DIRECTORY FOR OUTPUT BUILD
:: do not start with \ , and do not end with \
SET backup_dir=%output_dir%\backup

:: -FTP FOLDERS
SET ftp_download_folder=/download/joomla/baselines/robots/
