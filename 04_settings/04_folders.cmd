:: Name:     folders.cmd
:: Purpose:  set folders for downloadserver as an environment variable
:: Author:   pierre@pvln.nl
:: Revision: 2018 11 23 - initial version
::
:: Required environment variables:
::
::

:: -BUILDING BLOCKS DIRECTORY FOR BUILD
:: do not start with \ , and do not end with \
SET building_blocks=..\00_dev_code

:: -OUTPUT DIRECTORY FOR BUILD
:: do not start with \ , and do not end with \
SET output_dir=..\06_output\staging

:: -BACKUP DIRECTORY FOR OUTPUT BUILD
:: do not start with \ , and do not end with \
SET backup_dir=..\06_output\backup

:: -FTP FOLDERS
SET staging_folder=/download/joomla/baselines/robots/
::SET ftp_download_folder=/download/joomla/baselines/robots/