::
@ECHO off
CALL 01_build_file.cmd default
CALL 01_build_file.cmd pvln
CALL 01_build_file.cmd ver-bind
CALL 01_build_file.cmd 2connect4u
