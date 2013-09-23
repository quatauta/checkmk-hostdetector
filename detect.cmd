@echo off

set PATH=%PATH%;%ProgramFiles%\nmap;
set PATH=%PATH%;%ProgramFiles(x86)%\nmap
set PATH=%PATH%;c:\tools\prg\cygwin\bin
set PATH=%PATH%;c:\tools\prg\net-snmp\bin
set PATH=%PATH%;c:\tools\prg\ruby\2.0.0-x64\bin
set RUBYOPT=

ruby detect.rb locations.txt
