:: Name:     version.cmd
:: Purpose:  set the version as an environment variable
:: Author:   pierre.veelen@pvln.nl
:: Revision: 2018 11 24 - initial version

:: Using Semantic Versioning (2.0.0) 
:: Major.Minor[.patch]
::
:: In summary:
:: Major releases indicate a break in backward compatibility.
:: - change of folder structure
:: - change of file name for generic files
::
:: Minor releases indicate the addition of new features or a significant change to existing features.
:: - Building blocks added or removed
::
:: Patch releases indicate that bugs have been fixed.
:: - Changes within building blocks
::
:: Changes should be commented in CHANGELOG.md
::

:: -VERSION
SET majorversion=0
SET minorversion=0
SET patchversion=1

SET version=v%majorversion%.%minorversion%.%patchversion%
