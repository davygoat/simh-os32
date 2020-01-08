#!./id32
# vim:set syntax=sh:
# vim:set nowrap:

set cpu idle

:safety-first

   if not exist dsk4.dsk goto check-prerequisites
   echo
   echo
   echo
   set env -p "Warning: file 'dsk4.dsk' already exists, overwrite (yes/no) ?  " YES=no
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
   if not exist tapes/04-149M31R01_UnvFortSwPgk.tap   set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/04-149M31R01_UnvFortSwPgk.tap.gz
   if not exist tapes/04-081M71R02_sortMergeII.tap    set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/04-081M71R02_sortMergeII.tap
   if not exist tapes/04-108M31R05_DMS32.tap          set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/04-108M31R05_DMS32.tap
   if not exist tapes/04-199M71R01_OS32Medit.tap      set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/04-199M71R01_OS32Medit.tap.gz
   if not exist tapes/OS32_pascal.tap                 set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/OS32_pascal.tap.gz
   if not exist tapes/C_Deb_Bas_Pas.tap               set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/32bit/os32/C_Deb_Bas_Pas.tap.gz
   if not exist tapes/iug0165.tap                     set environ MISSING=true ; echo wget http://bitsavers.org/bits/Interdata/interchange/iug0165.tap.gz

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

   attach -n dm0 dsk4.dsk
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

   attach -e dm0 dsk4.dsk

   deposit 78 0
   deposit 7c 001

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
   expect "CMDP>" send "VERSION    OS32MTS1              *OS32MTS1 SYSTEM\r";c
   expect "CMDP>" send "CPU        8/32,8                *CPU = 7/32 OR 8/3\r";c
   expect "CMDP>" send "MEMORY     1024                  *MEMORY = 1024-KB\r";c
   expect "CMDP>" send "DSYS       100                   *SYSTEM SPACE = 1\r";c
   expect "CMDP>" send "MEMCHECK                         *MEMORY DIAGNOSTIC\r";c
   expect "CMDP>" send "DEVADS     3                     *MAX OF 1023 DEVIC\r";c
   expect "CMDP>" send "FLOAT      S,S                   *FLOATING POINT SO\r";c
   expect "CMDP>" send "CLOCK      60,6C,6D,D            *60-HZ, LFC=6C, PI\r";c
   expect "CMDP>" send "BACKGROUND 16,200                *BACKGROUND TASK'S\r";c
   expect "CMDP>" send "VOLUME     SYS                   *DEFAULT SYSTEM VOL\r";c
   expect "CMDP>" send "TEMP       SYS                   *DEFAULT TEMPORARY\r";c
   expect "CMDP>" send "DIRECTORY                        *CORE DIRECTORY IN\r";c
   expect "CMDP>" send "DISCBLOCK  32,IN=8/1             *DISKFILE BLOCKING\r";c
   expect "CMDP>" send "CSS        8                     *CSS NESTING DEPTH\r";c
   expect "CMDP>" send "CMDLEN     100                   *COMMAND BUFFER LE\r";c
   expect "CMDP>" send "LOGLEN     100                   *LOG BUFFER LENGTH\r";c
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
#  expect "CMDP>" send "SPOOL SYS                        *OLD SPOOLER\r";c
#  expect "CMDP>" send "SPOOL DSC4                       *OLD SPOOLER\r";c
#  expect "CMDP>" send "SPOOL PTPR                       *OLD SPOOLER\r";c
#  expect "CMDP>" send "SPL32                            *NEW SPOOLER\r";c
   expect "CMDP>" send "ENDC\r";c
   expect "CMDP>" send "ENDB\r";c
   expect "ENDB" send "OSGEN\r";c
   expect "OSGEN COMPLETED  ***" send "sysgen32 new02\r";c
   expect "*** SYSGEN32 ERROR ***" echo ; echo Oh, bugger! ; exit
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

   attach -e dm0 dsk4.dsk

   deposit 7c 002

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
   expect "EDIT32>" send "find /NUSERS   EQU/,1- ; sub/4/8/\r";c ;# Eight terminals rather than just four
   expect "EDIT32>" send "done\r";c
   expect "EDIT32:END OF TASK     0\r\n*" send "MTMSGN MAC\r";c
   expect "MTMMAC.TSK CREATED ***" send "load actuty\r";c
   expect "TSKID = ACTUTY" send "start ,com=con:,li=con:,cre=users.auf\r";c
   expect "ACTUTY>" send "add 255,255,pass1,MTM admin,*,*,FFFFFFF0\r";c
   expect "ACTUTY>" send "add 25,20,user1,Joe Bloggs with privs,*,*,FFFFFFF0\r";c
   expect "ACTUTY>" send "end\r";c
   expect "ACTUTY:END OF TASK" send "rename users.auf,users.auf/255 ; mark dsc4:,off ; display devices\r";c
   expect "DSC5  FE 0000   OFF" detach mt0 ; detach dm0 ; goto install-compilers

   boot dm0
   exit 1


:install-compilers

   echo
   echo
   echo
   echo
   echo ************* STAGE 4 - INSTALL COMPILERS *************
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

   attach -e dm0 dsk4.dsk

   deposit 7c 002

   noexpect
   expect "ENTER DATE AND TIME" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys\r";c
   expect "*";c
   expect "*" send "volume sys/temp\r";c
   # Copy CAL to /10 because we may need to juggle with it later on
   expect "*" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "copy cal32.tsk,cal32.tsk/10\r";c
   expect "COPY32>" send "end\r";c
   # Fortran tape (Development and Global/Optimizing) goes into /11
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/04-101M31R09_FortranVII.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=11,verify,list=con:\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "copy f7d51.tsk/11,f7d51.tsk/0\r";c
   expect "COPY32>" send "copy f7d51.err/11,f7d51.err/0\r";c
   expect "COPY32>" send "copy f7lib51.obj/11,f7lib51.obj/0\r";c
   expect "COPY32>" send "copy f7rtl51.err/11,f7rtl51.err/0\r";c
   expect "COPY32>" send "copy pem51.obj/11,pem51.obj/0\r";c
   expect "COPY32>" send "copy f7o51.tsk/11,f7o51.tsk/0\r";c
   expect "COPY32>" send "copy f7zo51.err/11,f7zo51.err/0\r";c
   expect "COPY32>" send "copy f7lib51a.obj/11,f7lib51a.obj/0\r";c
   expect "COPY32>" send "copy pem51a.obj/11,pem51a.obj/0\r";c
   expect "COPY32>" send "end\r";c
   # Universal Fortran tape goes into /12
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/04-149M31R01_UnvFortSwPgk.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=12,verify,list=con:\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "end\r";c
   # Pascal tape goes to /13
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/OS32_pascal.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=13,verify,list=con:\r";c
   expect "BACKUP:TASK PAUSED" send "cancel backup\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "copy pascal.tsk/13,pascal.tsk/0\r";c
   expect "COPY32>" send "copy pasrtl.obj/13,pasrtl.obj/0\r";c
   expect "COPY32>" send "copy prefix.pas/13,prefix.pas/0\r";c
   expect "COPY32>" send "copy prefix.pas/13,prefix.pas/0\r";c
   expect "COPY32>" send "copy primes.pas/13,primes.pas/0\r";c
   expect "COPY32>" send "copy smplsvcs.pas/13,smplsvcs.pas/0\r";c
   expect "COPY32>" send "copy pemath.obj/13,pemath.obj/0\r";c  ;# Needed for EOU
   expect "COPY32>" send "copy f7rtl.obj/13,f7rtl51.obj/0\r";c  ;# Needed for EOU
   expect "COPY32>" send "end\r";c
   # C, Pascal, Debugger (and BASIC?) goes to /14
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/C_Deb_Bas_Pas.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=14,verify,list=con:\r";c
   expect "BACKUP:TASK PAUSED" send "cancel backup\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "copy pp.tsk/14,pp.tsk/0\r";c
   expect "COPY32>" send "copy p1.tsk/14,p1.tsk/0\r";c
   expect "COPY32>" send "copy p2.tsk/14,p2.tsk/0\r";c
   expect "COPY32>" send "copy lister.tsk/14,lister.tsk/0\r";c
   expect "COPY32>" send "copy libe.obj/14,libe.obj/0\r";c
   expect "COPY32>" send "copy libu.obj/14,libu.obj/0\r";c
   expect "COPY32>" send "copy libw.obj/14,libw.obj/0\r";c
   expect "COPY32>" send "copy cinit.obj/14,cinit.obj/0\r";c
   expect "COPY32>" send "copy cfinit.obj/14,cfinit.obj/0\r";c
   expect "COPY32>" send "copy eouc.css/14,eouc.css/0\r";c
   expect "COPY32>" send "copy chloc.css/14,chloc.css/0\r";c
   expect "COPY32>" send "option noterm,nopsfm\r";c
   expect "COPY32>" send "copy chfiles.css/14,chfiles.css/0\r";c
   expect "COPY32>" send "end\r";c
   # SORT/MERGE-II goes to /15 (probably needs COBOL)
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/04-081M71R02_sortMergeII.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=15,verify,list=con:\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "end\r";c
   # DMS/32 goes to /16 (probably needs COBOL, but might work with Fortran)
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/04-108M31R05_DMS32.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=16,verify,list=con:\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "end\r";c
   # MEDIT goes to /17 (someone might prefer this to the EDIT/32 line editor, needs terminal config)
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/04-199M71R01_OS32Medit.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=17,delete,verify,list=con:\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "end\r";c
   # IUG-165 (MicroEMACS) goes to /18 (lots of people might like this, needs termcap setup)
   expect "COPY32:END OF TASK" attach -e -r mt0 tapes/iug0165.tap ; send "load backup\r";c
   expect "TSKID = BACKUP" send "start ,in=mag1:,out=dsc4:,ac=18,verify,delete,list=con:\r";c
   expect "BACKUP:END OF TASK" send "load copy32\r";c
   expect "TSKID = COPY32" send "start\r";c
   expect "COPY32>" send "end\r";c
   expect "COPY32:END OF TASK" send "chloc ; chfiles ; mark dsc4:,off ; display devices\r";c
   expect "DSC5  FE 0000   OFF" detach mt0 ; detach dm0 ; goto startup-shutdown-scripts

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

   attach -e dm0 dsk4.dsk

   deposit 7c 002

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
   # MTMONLY.CSS
   expect "\r\n*" send "build mtmonly.css\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   display users ,null:\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   $write THIS COMMAND ONLY WORKS IN MTM\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # STARTUP.CSS
   expect "\r\n*" send "build startup.css\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "*   mark dsc3:,on\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   $write *** DSC3 IS BROKEN, USE SIMH 'DO FIXDISK' TO RECOVER ***\r";c
   expect ".CMDP>" send "$endc\r";c
#  expect ".CMDP>" send "splup ; $wait 1\r";c
   expect ".CMDP>" send "mtmup ; $wait 1\r";c
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
#  # SPLUP.CSS
#  expect "\r\n*" send "build splup.css\r";c
#  expect ".CMDP>" send "sysonly\r";c
#  expect ".CMDP>" send "$job\r";c
#  expect ".CMDP>" send "   $write STARTING SPL/32\r";c
#  expect ".CMDP>" send "   load spl32\r";c
#  expect ".CMDP>" send "   task spl32\r";c
#  expect ".CMDP>" send "   start\r";c
#  expect ".CMDP>" send "   $wait 1\r";c
#  expect ".CMDP>" send "$termjob\r";c
#  expect ".CMDP>" send "$ifne 0\r";c
#  expect ".CMDP>" send "   $write NO PROBLEM, SPL/32 ALREADY RUNNING\r";c
#  expect ".CMDP>" send "$endc\r";c
#  expect ".CMDP>" send "$exit\r";c
#  expect ".CMDP>" send "endb\r";c
#  # SPLDOWN.CSS
#  expect "\r\n*" send "build spldown.css\r";c
#  expect ".CMDP>" send "sysonly\r";c
#  expect ".CMDP>" send "$job\r";c
#  expect ".CMDP>" send "   $write STOPPING SPL/32\r";c
#  expect ".CMDP>" send "   cancel spl32\r";c
#  expect ".CMDP>" send "$termjob\r";c
#  expect ".CMDP>" send "$ifne 0\r";c
#  expect ".CMDP>" send "   $write NO PROBLEM, SPL/32 PROBABLY NOT RUNNING\r";c
#  expect ".CMDP>" send "$endc\r";c
#  expect ".CMDP>" send "$exit\r";c
#  expect ".CMDP>" send "endb\r";c
   # SHUTDOWN.CSS
   expect "\r\n*" send "build shutdown.css\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "$write MARKING NON SYSTEM DISKS OFF\r";c
   expect ".CMDP>" send "mark dsc0:,off\r";c
   expect ".CMDP>" send "mark dsc1:,off\r";c
   expect ".CMDP>" send "mark dsc2:,off\r";c
   expect ".CMDP>" send "mark dsc3:,off\r";c
   expect ".CMDP>" send "mark dsc5:,off\r";c
   expect ".CMDP>" send "mtmdown ; $wait 1\r";c
#  expect ".CMDP>" send "spldown ; $wait 1\r";c
   expect ".CMDP>" send "$write MARK DSC4 OFF BEFORE YOU GO\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # DIR.CSS
   expect "\r\n*" send "build dir.css\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "$ifnnull @1\r";c
   expect ".CMDP>" send "   display files ,@1\r";c
   expect ".CMDP>" send "$else\r";c
   expect ".CMDP>" send "   display files\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$exit\r";c
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
   expect ".CMDP>" send "      option noterm,nopsfm\r";c
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
   # TYPE.CSS
   expect "\r\n*" send "build type.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   $write USAGE: TYPE FD\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnx @1\r";c
   expect ".CMDP>" send "   $write FILE NOT FOUND\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   $build type.tmp\r";c
   expect ".CMDP>" send "      option noterm,nopsfm\r";c
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
   # WILD.CSS/25
   expect "\r\n*" send "build wild.css\r";c
   expect ".CMDP>" send "sys:wild/s \"@1\",@2\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*" send "repro wild.css,ff00 ; rename wild.css,wild.css/25\r";c
   # SEARCH.CSS/25
   expect "\r\n*" send "build search.css\r";c
   expect ".CMDP>" send "sys:search/s @1,\"@2\",,@4\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*" send "repro search.css,ff00 ; rename search.css,search.css/25\r";c
   # WILD.CSS
   expect "\r\n*" send "build wild.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "mtmonly\r";c
   expect ".CMDP>" send "$ifnx wild.tsk/s\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write CANNOT FIND WILD.TSK\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write CC WILD\r";c
   expect ".CMDP>" send "   $write RENAME WILD.TSK,WILD.TSK/S\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "* Check parameters present\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   load sys:wild,10\r";c
   expect ".CMDP>" send "   task wild\r";c
   expect ".CMDP>" send "   start\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "$ifnull @2\r";c
   expect ".CMDP>" send "   load sys:wild,10\r";c
   expect ".CMDP>" send "   task wild\r";c
   expect ".CMDP>" send "   start\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$end\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "* Use DISPLAY FILES to write WILD.TSK input\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   xalloc wildin.tmp,index,80\r";c
   expect ".CMDP>" send "   xalloc wildtmp.css,index,128\r";c
   expect ".CMDP>" send "   display files ,@2,wildin.tmp\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   xdelete wildin.tmp\r";c
   expect ".CMDP>" send "   xdelete wildtmp.css\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "* Convert to CSS using WILD.TSK\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   load sys:wild,10\r";c
   expect ".CMDP>" send "   task wild\r";c
   expect ".CMDP>" send "   assign 0,wildin.tmp,ero\r";c
   expect ".CMDP>" send "   assign 1,wildtmp.css,ewo\r";c
   expect ".CMDP>" send "   start ,\"@1\",@2\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   xdelete wildin.css\r";c
   expect ".CMDP>" send "   xdelete wildtmp.css\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "* Run CSS\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$job\r";c
   expect ".CMDP>" send "   wildtmp\r";c
   expect ".CMDP>" send "$termjob\r";c
   expect ".CMDP>" send "$ifne 0\r";c
   expect ".CMDP>" send "   $write THERE WERE A FEW PROBLEMS\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "* Cleanup\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "xdelete wildin.tmp\r";c
   expect ".CMDP>" send "xdelete wildtmp.css\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # SEARCH.CSS
   expect "\r\n*" send "build search.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnx sys:search.tsk/s\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write CANNOT FIND SEARCH.TSK\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write CC SEARCH\r";c
   expect ".CMDP>" send "   $write RENAME SEARCH.TSK,SEARCH.TSK/S\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $clear\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnnull @4\r";c
   expect ".CMDP>" send "   $goto dofile\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** WILDCARD *************************************\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "mtmonly\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write USAGE: SEARCH WILDCARD,\"STRING\"\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write NOTE:  TO SEARCH FOR $, USE $$\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$ifnull @2\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write USAGE: SEARCH WILDCARD,\"STRING\"\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write NOTE:  TO SEARCH FOR $, USE $$\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "wild \"search $V:$F,@2,,go\",@1\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** SINGLE FILE **********************************\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$label dofile\r";c
   expect ".CMDP>" send "prevent etm\r";c
   expect ".CMDP>" send "load .bg,sys:search,10\r";c
   expect ".CMDP>" send "task .bg\r";c
   expect ".CMDP>" send "assign 0,@1\r";c
   expect ".CMDP>" send "assign 1,con:\r";c
   expect ".CMDP>" send "assign 2,con:\r";c
   expect ".CMDP>" send "start ,@1,\"@2\"\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "endb\r";c
   # WILD.C/25
   expect "\r\n*" send "build wild.c\r";c
   expect ".CMDP>" send "/*\r";c
   expect ".CMDP>" send " * This program converts fixed-format DISPLAY FILES output into\r";c
   expect ".CMDP>" send " * whatever you ask. Its primary use will be in generating CSS scripts\r";c
   expect ".CMDP>" send " * that can delete or rename object files and other such clutter en\r";c
   expect ".CMDP>" send " * masse. OS/32 does not make that sort of thing terribly easy.\r";c
   expect ".CMDP>" send " */\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "#include <stdio.h>\r";c
   expect ".CMDP>" send "#include <ctype.h>\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "#define strchr(s,c) index((s),(c))\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int usage()\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   printf (\"\\n\\n\");\r";c
   expect ".CMDP>" send "   printf (\"Usage: WILD \\\"command\\\",wildcard\\n\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   'command' is an OS/32 command or CSS \");\r";c
   expect ".CMDP>" send "   printf (\"to run on each file.\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   'wildcard' is an OS/32 wildcard pattern.\\n\\n\");\r";c
   expect ".CMDP>" send "   printf (\"Placeholders:\\n\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $V  volume\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $N  file NAME\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $X  extension\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $A  account (/P, /G, or /S)\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $F  file name, extension and account\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $T  type\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $D  dbs\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $I  ibs\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $L  record LENGTH\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $R  records\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $C  created date (ctime)\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $W  written date (mtime)\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $K  keys (protection)\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $:  semicolon\\n\");\r";c
   expect ".CMDP>" send "   printf (\"   $$  dollar sign\\n\");\r";c
   expect ".CMDP>" send "   printf (\"\\n\");\r";c
   expect ".CMDP>" send "   return (1);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int memcmp(p1,p2,len)\r";c
   expect ".CMDP>" send "   char *p1, *p2;\r";c
   expect ".CMDP>" send "   int len;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   while (--len > 0 && *p1 == *p2)\r";c
   expect ".CMDP>" send "   {\r";c
   expect ".CMDP>" send "      p1++;\r";c
   expect ".CMDP>" send "      p2++;\r";c
   expect ".CMDP>" send "   }\r";c
   expect ".CMDP>" send "   return (*p1-*p2);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "char *rtrim (str)\r";c
   expect ".CMDP>" send "   char *str;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   char *p = str;\r";c
   expect ".CMDP>" send "   while (*p) p++;\r";c
   expect ".CMDP>" send "   while (p >= str && *p <= ' ') *p-- = 0;\r";c
   expect ".CMDP>" send "   return (str);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int toupper(ch)\r";c
   expect ".CMDP>" send "   int ch;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   if (islower(ch)) ch -= 'a' - 'A';\r";c
   expect ".CMDP>" send "   return (ch);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int main (argc, argv)\r";c
   expect ".CMDP>" send "   int argc;\r";c
   expect ".CMDP>" send "   char **argv;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   char line[90], *p;\r";c
   expect ".CMDP>" send "   char volbuf[80], *vol;\r";c
   expect ".CMDP>" send "   char *cmd, *wild, *act;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   if (argc < 3) return usage();\r";c
   expect ".CMDP>" send "   cmd = argv[1];\r";c
   expect ".CMDP>" send "   wild = argv[2];\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   act = strchr (wild, '/');\r";c
   expect ".CMDP>" send "   if (act) act++;\r";c
   expect ".CMDP>" send "   else act = \"P\";\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   while ( fgets(line,sizeof(line),stdin) && !feof(stdin) )\r";c
   expect ".CMDP>" send "   {\r";c
   expect ".CMDP>" send "      int dolcnt = 0;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "      char *nam = line+1;\r";c
   expect ".CMDP>" send "      char *ext = line+10;\r";c
   expect ".CMDP>" send "      char *typ = line+20;\r";c
   expect ".CMDP>" send "      char *dbs = line+23;\r";c
   expect ".CMDP>" send "      char *ibs = line+27;\r";c
   expect ".CMDP>" send "      char *len = line+31;\r";c
   expect ".CMDP>" send "      char *rex = line+37;\r";c
   expect ".CMDP>" send "      char *cre = line+45;\r";c
   expect ".CMDP>" send "      char *wri = line+60;\r";c
   expect ".CMDP>" send "      char *key = line+75;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "      if (!memcmp(line,\"VOLUME=\",7))\r";c
   expect ".CMDP>" send "      {\r";c
   expect ".CMDP>" send "         strcpy (vol=volbuf, rtrim(line+7));\r";c
   expect ".CMDP>" send "         while (*vol > 0 && *vol <= ' ') vol++;\r";c
   expect ".CMDP>" send "         continue;\r";c
   expect ".CMDP>" send "      }\r";c
   expect ".CMDP>" send "      if (!memcmp(line,\" FILENAME...\",12)) continue;\r";c
   expect ".CMDP>" send "      if (*line != ' ')\r";c
   expect ".CMDP>" send "      {\r";c
   expect ".CMDP>" send "         fprintf (stderr, \"%%s\", line);\r";c
   expect ".CMDP>" send "         exit (1);\r";c
   expect ".CMDP>" send "      }\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "      nam[8] = ext[3] = typ[2] = dbs[3] = ibs[3] = 0;\r";c
   expect ".CMDP>" send "      len[5] = rex[7] = cre[14] = wri[14] = key[4] = 0;\r";c
   expect ".CMDP>" send "      rtrim (ext);\r";c
   expect ".CMDP>" send "      rtrim (nam);\r";c
   expect ".CMDP>" send "      while (*dbs != 0 && *dbs <= ' ') dbs++;\r";c
   expect ".CMDP>" send "      while (*ibs != 0 && *ibs <= ' ') ibs++;\r";c
   expect ".CMDP>" send "      while (*rex != 0 && *rex <= ' ') rex++;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "      for (p=cmd; *p; p++)\r";c
   expect ".CMDP>" send "      {\r";c
   expect ".CMDP>" send "         if (*p == '$')\r";c
   expect ".CMDP>" send "         {\r";c
   expect ".CMDP>" send "            switch (toupper(p[1]))\r";c
   expect ".CMDP>" send "            {\r";c
   expect ".CMDP>" send "               case 'V':  printf(\"%%s\",vol); p++; break;;\r";c
   expect ".CMDP>" send "               case 'N':  printf(\"%%s\",nam); p++; break;;\r";c
   expect ".CMDP>" send "               case 'X':  printf(\"%%s\",ext); p++; break;;\r";c
   expect ".CMDP>" send "               case 'A':  printf(\"%%s\",act); p++; break;;\r";c
   expect ".CMDP>" send "               case 'T':  printf(\"%%s\",typ); p++; break;;\r";c
   expect ".CMDP>" send "               case 'D':  printf(\"%%s\",dbs); p++; break;;\r";c
   expect ".CMDP>" send "               case 'I':  printf(\"%%s\",ibs); p++; break;;\r";c
   expect ".CMDP>" send "               case 'L':  printf(\"%%s\",len); p++; break;;\r";c
   expect ".CMDP>" send "               case 'R':  printf(\"%%s\",rex); p++; break;;\r";c
   expect ".CMDP>" send "               case 'C':  printf(\"%%s\",cre); p++; break;;\r";c
   expect ".CMDP>" send "               case 'W':  printf(\"%%s\",wri); p++; break;;\r";c
   expect ".CMDP>" send "               case 'K':  printf(\"%%s\",key); p++; break;;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "               case 'F':\r";c
   expect ".CMDP>" send "                  printf (\"%%s.%%s/%%s\", nam, ext, act);\r";c
   expect ".CMDP>" send "                  p++;\r";c
   expect ".CMDP>" send "                  break;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "               case ':':\r";c
   expect ".CMDP>" send "                  putchar (';');\r";c
   expect ".CMDP>" send "                  p++;\r";c
   expect ".CMDP>" send "                  break;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "               case '$':\r";c
   expect ".CMDP>" send "                  putchar ('$');\r";c
   expect ".CMDP>" send "                  p++;\r";c
   expect ".CMDP>" send "                  break;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "               default:\r";c
   expect ".CMDP>" send "                  fprintf (stderr, \"Invalid placeholder '%%c'\\n\", *p);\r";c
   expect ".CMDP>" send "                  exit (1);\r";c
   expect ".CMDP>" send "            }\r";c
   expect ".CMDP>" send "            dolcnt++;\r";c
   expect ".CMDP>" send "         }\r";c
   expect ".CMDP>" send "         else\r";c
   expect ".CMDP>" send "            putchar (*p);\r";c
   expect ".CMDP>" send "      }\r";c
   expect ".CMDP>" send "      if (dolcnt == 0) printf (\" %%s.%%s/%%s\", nam, ext, act);\r";c
   expect ".CMDP>" send "      putchar ('\\n');\r";c
   expect ".CMDP>" send "   }\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   printf (\"$exit\\n\");\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   return (0);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*" send "rename wild.c,wild.c/25\r";c
   # SEARCH.C/25
   expect "\r\n*" send "build search.c\r";c
   expect ".CMDP>" send "#include <stdio.h>\r";c
   expect ".CMDP>" send "#include <ctype.h>\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int toupper(ch)\r";c
   expect ".CMDP>" send "   int ch;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   if (islower(ch)) ch -= 'a' - 'A';\r";c
   expect ".CMDP>" send "   return (ch);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "char *stristr (haystack,needle)\r";c
   expect ".CMDP>" send "   char *haystack;\r";c
   expect ".CMDP>" send "   char *needle;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   char *hs, *p, *q;\r";c
   expect ".CMDP>" send "   for (hs=haystack; *hs; hs++)\r";c
   expect ".CMDP>" send "   {\r";c
   expect ".CMDP>" send "      if (toupper(*hs) == toupper(*needle))\r";c
   expect ".CMDP>" send "      {\r";c
   expect ".CMDP>" send "         p = needle;\r";c
   expect ".CMDP>" send "         q = hs;\r";c
   expect ".CMDP>" send "         while ( *p > 0 &&\r";c
   expect ".CMDP>" send "                 *q > 0 &&\r";c
   expect ".CMDP>" send "                 toupper(*p) == toupper(*q) )\r";c
   expect ".CMDP>" send "         {\r";c
   expect ".CMDP>" send "            p++;\r";c
   expect ".CMDP>" send "            q++;\r";c
   expect ".CMDP>" send "         }\r";c
   expect ".CMDP>" send "         if (*p == 0) return (hs);\r";c
   expect ".CMDP>" send "      }\r";c
   expect ".CMDP>" send "   }\r";c
   expect ".CMDP>" send "   return (NULL);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int main (argc,argv)\r";c
   expect ".CMDP>" send "   int argc;\r";c
   expect ".CMDP>" send "   char **argv;\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   char *fnam, *str, line[256];\r";c
   expect ".CMDP>" send "   int lc, mc, i;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   if (argc < 3)\r";c
   expect ".CMDP>" send "   {\r";c
   expect ".CMDP>" send "      fprintf (stderr, \"Usage: $ search FILENAME,STRING\\n\");\r";c
   expect ".CMDP>" send "      exit (0);\r";c
   expect ".CMDP>" send "   }\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   fnam = argv[1];\r";c
   expect ".CMDP>" send "   str = argv[2];\r";c
   expect ".CMDP>" send "   lc = mc = 0;\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   while ( fgets(line,sizeof(line),stdin) && !feof(stdin) )\r";c
   expect ".CMDP>" send "   {\r";c
   expect ".CMDP>" send "      lc++;\r";c
   expect ".CMDP>" send "      if (stristr(line,str))\r";c
   expect ".CMDP>" send "      {\r";c
   expect ".CMDP>" send "         if (!mc++)\r";c
   expect ".CMDP>" send "         {\r";c
   expect ".CMDP>" send "            printf (\"\\n\\n====== \");\r";c
   expect ".CMDP>" send "            printf (\"%%s \", fnam);\r";c
   expect ".CMDP>" send "            for (i=71-strlen(fnam); i>0; i--) putc ('=', stdout);\r";c
   expect ".CMDP>" send "            printf (\"\\n\\n\");\r";c
   expect ".CMDP>" send "         }\r";c
   expect ".CMDP>" send "         printf (\"%%6d %%s\", lc, line);\r";c
   expect ".CMDP>" send "      }\r";c
   expect ".CMDP>" send "   }\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   if (mc > 0)\r";c
   expect ".CMDP>" send "      printf (\"\\nFound %%d matches for \\\"%%s\\\".\", mc, str);\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "   return (0);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*" send "rename search.c,search.c/25\r";c
   # FTP.CSS
   expect "\r\n*" send "build ftp.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "sysonly\r";c
   expect ".CMDP>" send "$ifnull @1\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write OPERATOR COMMANDS ARE:\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write FTP ON\r";c
   expect ".CMDP>" send "   $write FTP OFF\r";c
   expect ".CMDP>" send "   $write FTP RESET\r";c
   expect ".CMDP>" send "   $write FTP USERS\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $write ALL OTHER COMMANDS ARE RESERVED FOR THE FTP SERVER.\r";c
   expect ".CMDP>" send "   $write\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "xdelete users.ftp,reset.ftp\r";c
   expect ".CMDP>" send "xdelete off.ftp,down.ftp,stop.ftp\r";c
   expect ".CMDP>" send "xdelete on.ftp,up.ftp,start.ftp\r";c
   expect ".CMDP>" send "xdelete copyout.ftp,copyin.ftp\r";c
   expect ".CMDP>" send "xdelete delete.ftp,rename.ftp\r";c
   expect ".CMDP>" send "xdelete dir.ftp,checkvol.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** FTP USERS ************************************************\r";c
   expect ".CMDP>" send "xallocate users.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   $write SHOW FTP USERS\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete users.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** FTP OFF **************************************************\r";c
   expect ".CMDP>" send "xallocate off.ftp,index,80\r";c
   expect ".CMDP>" send "xallocate down.ftp,index,80\r";c
   expect ".CMDP>" send "xallocate stop.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   $write STOP FTP SERVER\r";c
   expect ".CMDP>" send "   delete off.ftp,down.ftp,stop.ftp\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete off.ftp,down.ftp,stop.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** FTP ON ***************************************************\r";c
   expect ".CMDP>" send "xallocate on.ftp,index,80\r";c
   expect ".CMDP>" send "xallocate up.ftp,index,80\r";c
   expect ".CMDP>" send "xallocate start.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   $write START FTP SERVER\r";c
   expect ".CMDP>" send "   delete on.ftp,up.ftp,start.ftp\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete on.ftp,up.ftp,start.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** FTP RESET ************************************************\r";c
   expect ".CMDP>" send "xallocate reset.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   $write SHOW FTP USERS\r";c
   expect ".CMDP>" send "   $write STOP FTP SERVER\r";c
   expect ".CMDP>" send "   $write START FTP SERVER\r";c
   expect ".CMDP>" send "   delete reset.ftp\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete reset.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** DIR ******************************************************\r";c
   expect ".CMDP>" send "xallocate dir.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $write === BEGIN DIR @2 ===\r";c
   expect ".CMDP>" send "   dir @2\r";c
   expect ".CMDP>" send "   $write === END DIR @2 ===\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete dir.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** COPYOUT **************************************************\r";c
   expect ".CMDP>" send "xallocate copyout.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $write === BEGIN COPYOUT @2 ===\r";c
   expect ".CMDP>" send "   type @2\r";c
   expect ".CMDP>" send "   $write === END COPYOUT @2 ===\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete copyout.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** COPYIN ***************************************************\r";c
   expect ".CMDP>" send "xallocate copyin.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $write === BEGIN COPYIN @2 ===\r";c
   expect ".CMDP>" send "   $job\r";c
   expect ".CMDP>" send "      xallocate copyin.tmp,index,@3\r";c
   expect ".CMDP>" send "      xdelete @2\r";c
   expect ".CMDP>" send "   $termjob\r";c
   expect ".CMDP>" send "   $ife 0\r";c
   expect ".CMDP>" send "      $build edit.tmp\r";c
   expect ".CMDP>" send "         option command=con: ; get copyin.tmp ; append\r";c
   expect ".CMDP>" send "      $endb\r";c
   expect ".CMDP>" send "      $job\r";c
   expect ".CMDP>" send "         load .bg,edit32\r";c
   expect ".CMDP>" send "         task .bg\r";c
   expect ".CMDP>" send "         start ,command=edit.tmp,list=con:\r";c
   expect ".CMDP>" send "      $termjob\r";c
   expect ".CMDP>" send "      $ife 0\r";c
   expect ".CMDP>" send "         copy copyin.tmp,@2\r";c
   expect ".CMDP>" send "      $endc\r";c
   expect ".CMDP>" send "      xdelete edit.tmp\r";c
   expect ".CMDP>" send "   $endc\r";c
   expect ".CMDP>" send "   xdelete copyin.tmp\r";c
   expect ".CMDP>" send "   $write === END COPYIN @2 ===\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete copyin.ftp\r";c
   expect ".CMDP>" send "*** STOR (COPYIN) ********************************************\r";c
   expect ".CMDP>" send "xallocate stor.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $ifx @2\r";c
   expect ".CMDP>" send "      $write STOR EXISTS\r";c
   expect ".CMDP>" send "   $else\r";c
   expect ".CMDP>" send "      $write STOR NEWFILE\r";c
   expect ".CMDP>" send "   $endc\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete stor.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** CHECKVOL *************************************************\r";c
   expect ".CMDP>" send "xallocate checkvol.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $write === BEGIN CHECKVOL @2 ===\r";c
   expect ".CMDP>" send "   $job\r";c
   expect ".CMDP>" send "      display volume ,@2\r";c
   expect ".CMDP>" send "      $write VOLUME @2 OK\r";c
   expect ".CMDP>" send "   $termjob\r";c
   expect ".CMDP>" send "   $ifne 0\r";c
   expect ".CMDP>" send "      $write VOLUME @2 NOT FOUND\r";c
   expect ".CMDP>" send "   $endc\r";c
   expect ".CMDP>" send "   $write === END CHECKVOL @2 ===\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete checkvol.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** DELETE ***************************************************\r";c
   expect ".CMDP>" send "xallocate delete.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $write === BEGIN DELETE @2 ===\r";c
   expect ".CMDP>" send "   $job\r";c
   expect ".CMDP>" send "      delete @2\r";c
   expect ".CMDP>" send "   $termjob\r";c
   expect ".CMDP>" send "   $ife 0\r";c
   expect ".CMDP>" send "      $write FILE DELETED\r";c
   expect ".CMDP>" send "   $endc\r";c
   expect ".CMDP>" send "   $write === END DELETE @2 ===\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete delete.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "*** RENAME ***************************************************\r";c
   expect ".CMDP>" send "xallocate rename.ftp,index,80\r";c
   expect ".CMDP>" send "$ifx @1.ftp\r";c
   expect ".CMDP>" send "   delete @1.ftp\r";c
   expect ".CMDP>" send "   $write === BEGIN RENAME @2 @3 ===\r";c
   expect ".CMDP>" send "   $job\r";c
   expect ".CMDP>" send "      rename @2,@3\r";c
   expect ".CMDP>" send "   $termjob\r";c
   expect ".CMDP>" send "   $ife 0\r";c
   expect ".CMDP>" send "      $write FILE RENAMED\r";c
   expect ".CMDP>" send "   $endc\r";c
   expect ".CMDP>" send "   $write === END RENAME @2 @3 ===\r";c
   expect ".CMDP>" send "   $exit\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "delete rename.ftp\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$write FTP UNRECOGNISED COMMAND @1\r";c
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

   attach -e dm0 dsk4.dsk

   deposit 7c 002

   noexpect
   expect "ENTER DATE AND TIME" send "set time %DATE%,%TIME%\r";c
   expect "*";c
   expect "*" send "mark dsc4:,on\r";c
   expect "DSC4:  SYS" send "volume sys\r";c
   expect "*";c
   expect "*" send "volume sys/temp\r";c
   # MAKE.CSS/25
   expect "\r\n*" send "build make.css\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$if ch \"@1\" eq \"clean\"\r";c
   expect ".CMDP>" send "   $goto clean\r";c
   expect ".CMDP>" send "$endc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write *********** CAL ******************\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "cal\r";c
   expect ".CMDP>" send "compile helloa\r";c
   expect ".CMDP>" send "link\r";c
   expect ".CMDP>" send "exec\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write *********** FORTRAN **************\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "fort hellof\r";c
   expect ".CMDP>" send "exec\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write *********** PASCAL ***************\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "pascal\r";c
   expect ".CMDP>" send "exec hellop.pas\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "$write *********** C ********************\r";c
   expect ".CMDP>" send "$write\r";c
   expect ".CMDP>" send "cc helloc\r";c
   expect ".CMDP>" send "helloc\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "$label clean\r";c
   expect ".CMDP>" send "$write *********** MAKE CLEAN ***********\r";c
   expect ".CMDP>" send "xdelete helloa.obj,helloa.tsk\r";c
   expect ".CMDP>" send "xdelete helloc.obj,helloc.tsk,helloc.map,helloc.css\r";c
   expect ".CMDP>" send "xdelete hellof.obj,hellof.tsk\r";c
   expect ".CMDP>" send "xdelete hellop.obj,hellop.tsk\r";c
   expect ".CMDP>" send "$exit\r";c
   expect ".CMDP>" send "*\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename make.css,make.css/25\r";c
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
   expect ".CMDP>" send "say1     dc    c'CAL the assembler says, \"Hello world\".'\r";c
   expect ".CMDP>" send "say2     equ   *-1\r";c
   expect ".CMDP>" send "         end\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename helloa.cal,helloa.cal/25\r";c
   # HELLOC.C
   expect "\r\n*" send "build helloc.c\r";c
   expect ".CMDP>" send "#include <stdio.h>\r";c
   expect ".CMDP>" send " \r";c
   expect ".CMDP>" send "int main (void)\r";c
   expect ".CMDP>" send "{\r";c
   expect ".CMDP>" send "   printf (\"Whitesmiths C says, 'Hello world'.\");\r";c
   expect ".CMDP>" send "   return (0);\r";c
   expect ".CMDP>" send "}\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename helloc.c,helloc.c/25\r";c
   # HELLOF.FTN
   expect "\r\n*" send "build hellof.ftn\r";c
   expect ".CMDP>" send "       program hello;\r";c
   expect ".CMDP>" send "       write(0,*) 'Interdata Fortran VII says, \"Hello world\".'\r";c
   expect ".CMDP>" send "       end\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename hellof.ftn,hellof.ftn/25\r";c
   # HELLOP.PAS
   expect "\r\n*" send "build hellop.pas\r";c
   expect ".CMDP>" send "program hello(output);\r";c
   expect ".CMDP>" send "begin\r";c
   expect ".CMDP>" send "   writeln('Perkin-Elmer Pascal says, \"Hello world\".');\r";c
   expect ".CMDP>" send "end.\r";c
   expect ".CMDP>" send "endb\r";c
   expect "\r\n*"  send "rename hellop.pas,hellop.pas/25\r";c
   # USERINIT.CSS/25
   expect "\r\n*" send "alloc userinit.css,in,100 ; build userinit.css\r";c
   expect ".CMDP>" send "prevent prompt\r";c
   expect ".CMDP>" send "eouinit\r";c
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
