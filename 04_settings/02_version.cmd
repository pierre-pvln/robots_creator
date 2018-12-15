:: Name:     version.cmd
:: Purpose:  set the version as an environment variable
:: Author:   pierre.veelen@pvln.nl
:: Revision: 2018 11 24 - initial version

:: Using Semantic Versioning (2.0.0) 
:: Major.Minor[.patch]
::
:: In summary:
:: Major releases indicate a break in backward compatibility.
:: Minor releases indicate the addition of new features or a significant change to existing features.
:: Patch releases indicate that bugs have been fixed.

:: -VERSION
SET majorversion=0
SET minorversion=0
SET patchversion=1

SET version=v%majorversion%.%minorversion%.%patchversion%
