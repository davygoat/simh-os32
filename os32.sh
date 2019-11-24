#!./id32
# vim:set nowrap:
#
# This will boot OS/32 from disk and set date/time.
#
# It also assumes that you have two CSS files called STARTUP.CSS and
# SHUTDOWN.CSS. STARTUP brings up MTM and anything else you may want, such
# as the spooler. SHUTDOWN cancels those tasks and marks non system disks
# off, after which it tell us to mark the system disk off and power down
# (which cannot be done inside a CSS file).
#

:init

   if not exist dm0.dsk echo ; echo ; echo dm0.dsk not found, try running rebuild-system.sh ; echo ; echo ; echo ; exit 0

   set cpu 832
   set cpu idle

   set ttp enabled
   set pas devno=20
   attach pas 1026

   set pt enabled
   #TODO - attach pt?

   attach -e dm0 dm0.dsk
   #attach -e dm1 dsk3.dsk   ;# To mount disk, e.g. FOR, on DSK3:
   #attach mt0 mag1.tap      ;# To use backup tape on MAG1:

   attach lpt printer.out
   deposit 7c 00000002

   goto ok-here-we-go

:fastchek-needed

   echo
   echo *** UNCLEAN -- DOING FASTCHEK ***
   echo

   set env DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set env TIME=%TIME_HH%:%TIME_MM%

   noexpect
   expect "ENTER DATE AND TIME\r\n*" send "set time %DATE%,%TIME%\r";c
   expect "*" send "mark dsc4:,on,protect\r";c
   expect "*" send "load sys:fastchek\r";c
   expect "*" send "mark dsc4:,off\r";c
   expect "*" send "start ,ch=dsc4:,nor,ext,li=con:\r";c
   expect "FASTCHEK:END OF TASK     0\r\n*" echo ; echo *** DISK SHOULD BE CLEAN NOW *** ; echo ; goto ok-here-we-go

   boot dm0
   goto ok-here-we-go

:ok-here-we-go

   set env DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set env TIME=%TIME_HH%:%TIME_MM%

   noexpect
   expect "ENTER DATE AND TIME\r\n*" send "set time %DATE%,%TIME%\r";c
   expect "*" send AFTER=100000 "mark dsc4:,on\r";c
   expect "NOFF-ERR  POS=on\r\n*"; goto fastchek-needed
   expect "DSC4:  SYS\r\n*" noexpect "NOFF-ERR  POS=on\r\n*" ; send "volume sys/temp\r";c
   expect "*" send "startup\r";c
   expect "MARK DSC4 OFF BEFORE YOU GO\r\n*" send "mark dsc4:,off ; display devices\r";c
   expect "DSC0  C8 0000   OFF\r\nDSC1  C6 0000   OFF\r\nDSC2  C7 0000   OFF\r\nDSC3  FD 0000   OFF\r\nDSC4  FC 0000   OFF\r\nDSC5  FE 0000   OFF\r\n" detach pas ; exit

   boot dm0
