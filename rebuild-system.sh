#!./id32
# vim:set syntax=sh:
# vim:set nowrap:

:safety-first

   if not exist dm0.dsk goto check-prerequisites
   echo
   echo
   echo
   set env -p "Warning: file 'dm0.dsk' already exists, overwrite (yes/no) ?  " YES=no
   if -i YES == "y" goto check-prerequisites
   if -i YES == "yes" goto check-prerequisites
   if -i YES == "n" echo ; echo ; exit 1
   if -i YES == "no" echo ; echo ; exit 1
   goto safety-first


:check-prerequisites

   echo
   echo
   echo
   echo ************* STAGE 0 - CHECK PREREQUISITES *************
   echo
   echo
   echo

   if not exist tapes/eou.tap echo ; echo ; echo Cannot find eou.tap. It should be in the kit! ; echo ; echo ; echo ; exit

   if not exist tapes/04-082M71R16S_OS32_starter.tap  set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/OS32_8.1/04-082M71R16S_OS32_starter.tap.gz
   if not exist tapes/04-082M71R16_OS32_8.1.tap       set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/OS32_8.1/04-082M71R16_OS32_8.1.tap.gz
   if not exist tapes/04-083M71R10_OS32MTM8.1.tap     set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/OS32_8.1/04-083M71R10_OS32MTM8.1.tap.gz
   if not exist tapes/04-101M31R09_FortranVII.tap     set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/04-101M31R09_FortranVII.tap.gz
   if not exist tapes/OS32_pascal.tap                 set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/OS32_pascal.tap.gz

   if "%MISSING%" == "" echo ALL TAPES PRESENT AND CORRECT ; goto install-os32

   echo gunzip *.tap.gz
   echo mv *.tap tapes/
   echo
   echo
   echo
   echo *** PLEASE DOWNLOAD THE URLS LISTED ABOVE, AND GUNZIP THEM INTO THE TAPES DIRECTORY ***
   echo
   echo
   echo
   exit 1


:install-os32

   echo
   echo
   echo
   echo ************* STAGE 1 - INSTALL OS/32 *************
   echo
   echo
   echo

   set cpu 832
   set dm0 msm80
   set environ DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set environ TIME=%TIME_HH%:%TIME_MM%
   send delay=10000

   attach -n dm0 dm0.dsk
   attach -e -r mt0 tapes/04-082M71R16S_OS32_starter.tap

   deposit 78 85a18540

   noexpect
   expect "ENTER DATE AND TIME\n" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "ffile mag1:\r";c
   expect "*" send "ffile mag1:\r";c
   expect "*" send "ffile mag1:\r";c
   expect "*" send "ffile mag1:\r";c
   expect "*" send "ffile mag1:\r";c
   expect "*" send "load f,mag1:,300\r";c
   expect "TSKID = F" send "start ,init=dsc4:,vol=sys,li=con:\r";c
   expect "F:END OF TASK     0" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "ffile mag1: ; load backup,mag1:\r";c
   expect "TSKID = BACKUP" attach -e -r mt0 tapes/04-082M71R16_OS32_8.1.tap ; send "start ,in=mag1:,out=dsc4:,list=con:,verify\r";c
   expect "BACKUP:END OF TASK     0" send "mark dsc4:,off ; display devices\r";c
   expect "DSC5  FC 0000   OFF" detach mt0 ; detach dm0 ; goto perform-sysgen

   boot mt0
   exit 1


:perform-sysgen

   echo
   echo
   echo
   echo
   echo ************* STAGE 2 - PERFORM SYSGEN *************
   echo
   echo
   echo

   set cpu 832
   set dm0 msm80
   set environ DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set environ TIME=%TIME_HH%:%TIME_MM%
   send delay=10000

   attach -e dm0 dm0.dsk

   deposit 78 0
   deposit 7c 00000001

   noexpect
   expect "ENTER DATE AND TIME\n" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys ; volume sys/temp\r";c
   expect "*" send "build new02.sys\r";c
   expect "CMDP>" send "COPY\r";c
   expect "CMDP>" send "         MCALL DCBI,CCBI,CONVNUM,EVNGEN,DMT,SLABEL\r";c
   expect "CMDP>" send "         MCALL $DCB$,$CCB,$EVN,$TABL$\r";c
   expect "CMDP>" send "         MCALL MMDGEN,$MMDDCB,DCB53,DCB54\r";c
   expect "CMDP>" send "         MCALL MTPI,$MTP,DCB64,DCB65\r";c
   expect "CMDP>" send "         MCALL BIOCGEN,BIOCDCB,BIOCEQU,$VFDCB,DCB39\r";c
   expect "CMDP>" send "ENDCOPY\r";c
   expect "CMDP>" send "VERSION OS32MTS1                 *OS32MTS1 SYSTEM\r";c
   expect "CMDP>" send "CPU 8/32,8                       *CPU = 7/32 OR 8/3\r";c
   expect "CMDP>" send "MEMORY 1024                      *MEMORY = 1024-KB\r";c
   expect "CMDP>" send "DSYS         100                 *SYSTEM SPACE = 1\r";c
   expect "CMDP>" send "MEMCHECK                         *MEMORY DIAGNOSTIC\r";c
   expect "CMDP>" send "DEVADS          3                *MAX OF 1023 DEVIC\r";c
   expect "CMDP>" send "FLOAT      S,S                   *FLOATING POINT SO\r";c
   expect "CMDP>" send "CLOCK 60,6C,6D,D                 *60-HZ, LFC=6C, PI\r";c
   expect "CMDP>" send "BACKGROUND 16,200                *BACKGROUND TASK'S\r";c
   expect "CMDP>" send "VOLUME SYS                       *DEFAULT SYSTEM VOL\r";c
   expect "CMDP>" send "TEMP       SYS                   *DEFAULT TEMPORARY\r";c
   expect "CMDP>" send "DIRECTORY                        *CORE DIRECTORY IN\r";c
   expect "CMDP>" send "DISCBLOCK 32,IN=8/1              *DISKFILE BLOCKING\r";c
   expect "CMDP>" send "CSS 8                            *CSS NESTING DEPTH\r";c
   expect "CMDP>" send "CMDLEN 100                       *COMMAND BUFFER LE\r";c
   expect "CMDP>" send "LOGLEN 100                       *LOG BUFFER LENGTH\r";c
   expect "CMDP>" send "DEVICES\r";c
   expect "CMDP>" send "CON: ,10,39,XDCOD=X2A0D,RECL=120,CONS\r";c
   expect "CMDP>" send "T020:,20,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T022:,22,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T024:,24,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T026:,26,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T028:,28,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T02A:,2A,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T02C:,2C,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "T02E:,2E,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "CRT: ,12,39,XDCOD=X2A0D          *PE 550/PE 1100\r";c
   expect "CMDP>" send "PTPR:,13,80                      *PAPER TAPE\r";c
   expect "CMDP>" send "CR:  ,4,96                       *CARD READER\r";c
   expect "CMDP>" send "PR:  ,62,113                     *300-LPM LINE PRIN\r";c
   expect "CMDP>" send "CAS1:,45,66                      *CASSETTE NO 1\r";c
   expect "CMDP>" send "CAS2:,55,66                      *CASSETTE NO 2\r";c
   expect "CMDP>" send "FLP1:,C1,55,SPINDLE=0            *FLOPPY DISK-1\r";c
   expect "CMDP>" send "FLP2:,C1,55,SPINDLE=1            *FLOPPY DISK-2\r";c
   expect "CMDP>" send "MAG1:,85,64,SELCH=F0,CONTR=0     * 800-BPI TAPE\r";c
   expect "CMDP>" send "MAG2:,C5,65,SELCH=F0,CONTR=1     *1600-BPI TAPE\r";c
   expect "CMDP>" send "MAG3:,85,68,SELCH=F0,CONTR=2     *6250-BPI TAPE HPT\r";c
   expect "CMDP>" send "MAG4:,85,69,SELCH=F0,CONTR=3     *6250-BPI TAPE STC\r";c
   expect "CMDP>" send "MAG5:,85,70,SELCH=F0,CONTR=4     *6250-BPI TAPE TEL\r";c
   expect "CMDP>" send "DSC0:,C8,49,SELCH=F0,CONTR=B6    *2.5-MB DISK (REMO\r";c
   expect "CMDP>" send "DSC1:,C6,51,SELCH=F0,CONTR=B6    * 5-MB DISK (REMO\r";c
   expect "CMDP>" send "DSC2:,C7,50,SELCH=F0,CONTR=B6    * 5-MB DISK (FIXE\r";c
   expect "CMDP>" send "DSC3:,FD,53,SELCH=F0,CONTR=FB    * 67-MB DISK (REMO\r";c
   expect "CMDP>" send "DSC4:,FC,53,SELCH=F0,CONTR=FB    * 67-MB DISK (REMO\r";c
   expect "CMDP>" send "DSC5:,FE,53,SELCH=F0,CONTR=FB    *67-MB DISK (REMOV\r";c
   expect "CMDP>" send "ENDD\r";c
   expect "CMDP>" send "SPL32                            *NEW SPOOLER\r";c
   expect "CMDP>" send "ENDC\r";c
   expect "CMDP>" send "ENDB\r";c
   expect "ENDB" send "OSGEN\r";c
   expect "OSGEN COMPLETED  ***" send "sysgen32 new02\r";c
   expect "BG:END OF TASK     0" send "sysmacro new02\r";c
   expect "BG:END OF TASK     0"                        ;c
   expect "BG:END OF TASK     0" send "syslink new02\r" ;c
   expect "NEW02.OS\n" send "load copy32\r";c
   expect "TSKID = COPY32\n" send "start\r";c
   expect "COPY32>" send "copy new02.os,os32mts1.002\r";c
   expect "COPY32>" send "end\r";c
   expect "COPY32:END OF TASK     0" send "mark dsc4:,off ; display devices\r";c
   expect "DSC5  FC 0000   OFF" detach dm0 ; goto install-mtm

   boot dm0
   exit 1


:install-mtm

   echo
   echo
   echo
   echo
   echo ************* STAGE 3 - INSTALL MTM *************
   echo
   echo
   echo

   set cpu 832
   set dm0 msm80
   set environ DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set environ TIME=%TIME_HH%:%TIME_MM%
   send delay=10000

   set ttp enabled
   set pas devno=20
   attach pas 1026

   attach -e dm0 dm0.dsk

   deposit 7c 00000002

   noexpect
   expect "ENTER DATE AND TIME" send "set time %DATE%,%TIME%\r";c
   expect "SET TIME";c
   expect "*";c
   expect "*" send AFTER=100000 "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys ; volume sys/temp\r";c
   expect "*" attach -e mt0 tapes/04-083M71R10_OS32MTM8.1.tap; send "\r";c
   expect "*" send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,li=con:,ac=0,verify,delete\r";c
   expect "BACKUP:END OF TASK"; send "load edit32 ; start\r";c
   expect "EDIT32>" send "get mtmparms.mac\r";c
   expect "EDIT32>" send "sub/4/8/17\r";c ;# Eight terminals rather than just four
   expect "EDIT32>" send "done\r";c
   expect "EDIT32:END OF TASK     0\r\n*" send "MTMSGN MAC\r";c
   expect "MTMMAC.TSK CREATED ***" send "load actuty\r";c
   expect "TSKID = ACTUTY" send "start ,com=con:,li=con:,cre=users.auf\r";c
   expect "ACTUTY>" send "add 255,255,pass1,master,*,*,FFFFFFF0\r";c
   expect "ACTUTY>" send "add 25,20,user1,user1,*,*,FFFFFFF0\r";c
   expect "ACTUTY>" send "end\r";c
   expect "ACTUTY:END OF TASK" send "rename users.auf,users.auf/255 ; mark dsc4:,off ; display devices\r";c
   expect "DSC5  FE 0000   OFF" detach mt0 ; detach dm0 ; goto install-fortran-pascal

   boot dm0
   exit 1


:install-fortran-pascal

   echo
   echo
   echo
   echo
   echo ************* STAGE 4 - INSTALL FORTRAN AND PASCAL *************
   echo
   echo
   echo

   set cpu 832
   set ttp enabled
   set pas devno=20
   set dm0 msm80
   set environ DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set environ TIME=%TIME_HH%:%TIME_MM%
   send delay=10000

   attach -e dm0 dm0.dsk
   attach -n dm1 dm1.dsk
   attach -e -r mt0 tapes/04-101M31R09_FortranVII.tap

   deposit 7c 00000002

   noexpect
   expect "ENTER DATE AND TIME" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys\r";c
   expect "*";c
   expect "*" send "volume sys/temp\r";c
   expect "*" send "load sys:fastchek\r";c
   expect "TSKID = FASTCHEK" send "start ,init=dsc3:,vol=for,li=con:\r";c
   expect "FASTCHEK:END OF TASK" send "mark dsc3:,on\r";c
   expect "DSC3:  FOR" send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc3:,list=con:,verify\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "copy for:f7d51.tsk,f7d51.tsk\r";c
   expect "COPY32>" send "copy for:f7d51.err,f7d51.err\r";c
   expect "COPY32>" send "copy for:f7lib51.obj,f7lib51.obj\r";c
   expect "COPY32>" send "copy for:f7rtl51.err,f7rtl51.err\r";c
   expect "COPY32>" send "copy for:pem51.obj,pem51.obj\r";c
   expect "COPY32>" send "copy for:f7o51.tsk,f7o51.tsk\r";c
   expect "COPY32>" send "copy for:f7zo51.err,f7zo51.err\r";c
   expect "COPY32>" send "copy for:f7lib51a.obj,f7lib51a.obj\r";c
   expect "COPY32>" send "copy for:pem51a.obj,pem51a.obj\r";c
   expect "COPY32>" send "end\r";c
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/OS32_pascal.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc3:,list=con:,ac=0,verify,delete\r";c
   expect "BACKUP:TASK PAUSED" send "cancel backup\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "copy for:pascal.tsk,pascal.tsk\r";c
   expect "COPY32>" send "copy for:pasrtl.obj,pasrtl.obj\r";c
   expect "COPY32>" send "copy for:primes.pas,primes.pas\r";c
   expect "COPY32>" send "copy for:pem51.obj,pemath.obj\r";c   ;# Needed for EOU
   expect "COPY32>" send "copy for:f7rtl.obj,f7rtl51.obj\r";c  ;# Needed for EOU
   expect "COPY32>" send "end\r";c
   expect "COPY32:END OF TASK" send "mark dsc3:,off ; mark dsc4:,off ; display devices\r";c
   expect "DSC5  FE 0000   OFF" detach mt0 ; detach dm1 ; detach dm0 ; goto startup-shutdown-scripts

   boot dm0
   exit 1


:startup-shutdown-scripts

   echo
   echo
   echo
   echo
   echo ************* STAGE 5 - STARTUP/SHUTDOWN AND CSS SCRIPTS *************
   echo
   echo
   echo

   set cpu 832
   set ttp enabled
   set pas devno=20
   set dm0 msm80
   set environ DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set environ TIME=%TIME_HH%:%TIME_MM%
   send delay=10000

   attach -e dm0 dm0.dsk

   deposit 7c 00000002

   noexpect
   expect "ENTER DATE AND TIME" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys\r";c
   expect "*";c
   expect "*" send "volume sys/temp\r";c
   # SYSONLY.CSS
   expect "\r\n*" send "build sysonly.css\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   display tasks ,null:\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   $write THIS COMMAND ONLY WORKS AT THE SYSTEM CONSOLE\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # STARTUP.CSS
   expect "\r\n*" send "build startup.css\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "mtmup\r";c
   expect ".CMDP>" send "$wait 1\r";c
   expect ".CMDP>" send "display tasks\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # MTMUP.CSS
   expect "\r\n*" send "build mtmup.css\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   $write STARTING MTM\r";c
   expect ".CMDP>" send "   load .mtm,mtmmac\r";c
   expect ".CMDP>" send "   task .mtm\r";c
   expect ".CMDP>" send "   start ,auf=users.auf,atf=null:\r";c
   expect ".CMDP>" send "   $wait 1\r";c
   expect ".CMDP>" send "   .mtm add t020:\r";c
   expect ".CMDP>" send "   .mtm add t022:\r";c
   expect ".CMDP>" send "   .mtm add t024:\r";c
   expect ".CMDP>" send "   .mtm add t026:\r";c
   expect ".CMDP>" send "   .mtm add t028:\r";c
   expect ".CMDP>" send "   .mtm add t02a:\r";c
   expect ".CMDP>" send "   .mtm add t02c:\r";c
   expect ".CMDP>" send "   .mtm add t02e:\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   $write NO PROBLEM, MTM ALREADY RUNNING\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # MTMDOWN.CSS
   expect "\r\n*" send "build mtmdown.css\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   $write STOPPING MTM\r";c
   expect ".CMDP>" send "   cancel .mtm\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   $write NO PROBLEM, MTM PROBABLY NOT RUNNING\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # SHUTDOWN.CSS
   expect "\r\n*" send "build shutdown.css\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "$write MARKING NON SYSTEM DISKS OFF\r";c
   expect ".CMDP>" send "mark dsc0:,off\r";c
   expect ".CMDP>" send "mark dsc1:,off\r";c
   expect ".CMDP>" send "mark dsc2:,off\r";c
   expect ".CMDP>" send "mark dsc3:,off\r";c
   expect ".CMDP>" send "mark dsc5:,off\r";c
   expect ".CMDP>" send "mtmdown\r";c
   expect ".CMDP>" send "$write MARK DSC4 OFF BEFORE YOU GO\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # TYPE.CSS
   expect "\r\n*" send "build type.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   $write USAGE: TYPE FD\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnx @1\r";c
   expect ".CMDP>" send "   $write FILE NOT FOUND\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   $build type.tmp\r";c
   expect ".CMDP>" send "      copy @1,con:\r";c
   expect ".CMDP>" send "      end\r";c
   expect ".CMDP>" send "   $endb\r";c
   expect ".CMDP>" send "   load .bg,copy32; task .bg; start ,command=type.tmp\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "xdelete type.tmp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "endb\r";c
   # COPY.CSS
   expect "\r\n*" send "build copy.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   $write USAGE: COPY FROM,TO\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnx @1\r";c
   expect ".CMDP>" send "   $write FILE NOT FOUND\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifx @2\r";c
   expect ".CMDP>" send "   $write OUTPUT FILE ALREADY EXISTS\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   $build copy.tmp\r";c
   expect ".CMDP>" send "      copy @1,@2\r";c
   expect ".CMDP>" send "      end\r";c
   expect ".CMDP>" send "   $endb\r";c
   expect ".CMDP>" send "   load .bg,copy32; task .bg; start ,command=copy.tmp\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "xdelete copy.tmp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "endb\r";c
   # DIR.CSS
   expect "\r\n*" send "build dir.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   display files\r";c
   expect ".CMDP>" send "$else\r";c
   expect ".CMDP>" send "   display files ,@1\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "endb\r";c
   # USERINIT.CSS/255
   expect "\r\n*"  send "build userinit.css\r";c
   expect ".CMDP>" send "prevent prompt\r";c
   expect ".CMDP>" send "prevent etm\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write Type ACTUTY to load-start the MTM account utility.\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename userinit.css,userinit.css/255\r";c
   # ACTUTY.CSS/255
   expect "\r\n*" send "build actuty.css\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write Useful, i.e. known, commands are:\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write list  [ACT]\r";c
   expect ".CMDP>" send "$write add    ACT,GRP,PASS,NAME,*,*,PRIV\r";c
   expect ".CMDP>" send "$write change ACT,GRP,PASS,NAME,*,*,PRIV\r";c
   expect ".CMDP>" send "$write end\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "load actuty\r";c
   expect ".CMDP>" send "start ,com=con:,li=con:,upd=users.auf\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename actuty.css,actuty.css/255\r";c
   # Over to stage 6
   expect "\r\n*" send "mark dsc4:,off ; display devices\r";c
   expect "DSC5  FE 0000   OFF" detach dm0 ; goto example-code

   boot dm0
   exit 1


:example-code

   echo
   echo
   echo
   echo
   echo ************* STAGE 6 - EOU AND EXAMPLE CODE *************
   echo
   echo
   echo

   set cpu 832
   set ttp enabled
   set pas devno=20
   set dm0 msm80
   set environ DATE=%DATE_MM%/%DATE_DD%/%DATE_YY%
   set environ TIME=%TIME_HH%:%TIME_MM%
   send delay=10000

   attach -e dm0 dm0.dsk

   deposit 7c 00000002

   noexpect
   expect "ENTER DATE AND TIME" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys\r";c
   expect "*";c
   expect "*" send "volume sys/temp\r";c
   # HELLOA.CAL
   expect "\r\n*" send "build helloa.cal\r";c
   expect ".CMDP>" send "         svc   1,say\r";c
   expect ".CMDP>" send "         svc   3,0\r";c
   expect ".CMDP>" send "         align adc\r";c
   expect ".CMDP>" send "say      db    x'28'\r";c
   expect ".CMDP>" send "         db    x'00'\r";c
   expect ".CMDP>" send "         ds    2\r";c
   expect ".CMDP>" send "         dc    a(say1)\r";c
   expect ".CMDP>" send "         dc    a(say2)\r";c
   expect ".CMDP>" send "         das   2\r";c
   expect ".CMDP>" send "say1     dc    c'Hello Assembly'\r";c
   expect ".CMDP>" send "say2     equ   *-1\r";c
   expect ".CMDP>" send "         end\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename helloa.cal,helloa.cal/25\r";c
   # HELLOF.FTN
   expect "\r\n*" send "build hellof.ftn\r";c
   expect ".CMDP>" send "       program hello;\r";c
   expect ".CMDP>" send "       write(0,1000)\r";c
   expect ".CMDP>" send "1000   format(' Hello Fortran')\r";c
   expect ".CMDP>" send "       end\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename hellof.ftn,hellof.ftn/25\r";c
   # HELLOP.PAS
   expect "\r\n*" send "build hellop.pas\r";c
   expect ".CMDP>" send "program hello(output);\r";c
   expect ".CMDP>" send "begin\r";c
   expect ".CMDP>" send "   writeln('Hello Pascal');\r";c
   expect ".CMDP>" send "end.\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename hellop.pas,hellop.pas/25\r";c
   # USERINIT.CSS/25
   expect "\r\n*" send "alloc userinit.css,in,100 ; build userinit.css\r";c
   expect ".CMDP>" send "prevent prompt\r";c
   expect ".CMDP>" send "eouinit\r";c
   expect ".CMDP>" send "ssysprt null:\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename userinit.css,userinit.css/25\r";c
   # Get canned EOU from my tape
   expect "\r\n*" attach -e mt0 tapes/eou.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,li=con:,ac=0,verify,delete\r";c
   expect "BACKUP:END OF TASK     0" send "mark dsc4:,off ; display devices\r";c
   # It's the final shutdown!
   expect "DSC5  FE 0000   OFF" detach dm0 ; goto thats-all-folks

   boot dm0
   exit 1


:thats-all-folks

   echo
   echo
   echo
   echo ************* ALL DONE *************
   echo
   echo
   echo
   exit 0
