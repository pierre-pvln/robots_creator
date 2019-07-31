# README file for the robots building blocks deployment scripts

Goto to the _06_scripts/_robots folder of the site and get the required file from github. 

```batchfile

set domainname=<your_domain>
:: get script for deploy files
curl https://raw.githubusercontent.com/pierre-pvln/robots_creator/master/03_deploying/_get_script_files_%domainname%.cmd --output _get_script_files_%domainname%.cmd --remote-time
:: and run it
_get_script_files_%domainname%.cmd
:: run deploy script files
01_deploy_to_%domainname%.cmd

```
