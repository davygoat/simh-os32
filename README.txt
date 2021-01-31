
Contents :-

   This 'SimH  kit' gives  you a  working OS/32  system with  three high
   level  languages. It  has  a  few problems,  but  overall it's  quite
   usable, and enjoyable.

   Interdata 8/32
   Perkin-Elmer OS/32 V8.1
   Fortran, Pascal and C
   Common Assembly Language (CAL) and Macro Assembler (MACRO)
   MTM 8.1 with Ease of Use (EOU) program development utilities
   Up to 8 MTM logins (telnet sessions) on port 1026
   Optionally (UNIX only), an FTP 'server' on port 2121

   The following compilers are 'installed' in the system account so they
   are available to everyone. If any  files are 'missing', you should be
   able  to find  them in  the following  'directories' (OS/32  accounts
   [slash-numeric] are broadly comparable to directories).

   SYS:/11	Fortran VII development and optimizing compilers
   SYS:/13	Pascal
   SYS:/14	Whitesmiths C

   The following packages are also on the disk, but not 'installed'. You
   may be able to get them to work if you try hard enough. Documentation
   is  lacking... The  two editors  have textfiles  that should  get you
   started.

   SYS:/12	Fortran-VII universal compiler
   SYS:/14	BAS32D, presumably a BASIC interpreter
   		Debugger
   SYS:/15	SORT/MERGE, may need COBOL for this
   SYS:/16	DMS/32 database management system, but we have no COBOL
   SYS:/17	MEDIT, a full screen editor
   SYS:/18	Micro EMACS, a full screen editor, needs termcap setup

   Unfortunately, there are  no COBOL or RPG tapes. (Not  sure if anyone
   will miss  RPG.) Reliance ECM  (transaction monitor) and  spooler are
   there, but I don't know how to get them working. Again, the available
   documentation is somewhat sparse.

   
Startup :-

   You will need id32 (id32.exe) from SIMH v4.0 Current.

   UNIX:

      git clone https://github.com/simh/simh.git
      cd simh
      make id32
      cp id32 <wherever>

      Without FTP server:

         ./id32 os32.ini

      With FTP server (see below for more details):

         ./OS32-FTPd

   Windows:

      Build your own id32.exe using the Visual Studio Solution.
      git clone https://github.com/simh/simh.git

      Or download the most recent zipped-up Windows binaries.
      https://github.com/simh/Win32-Development-Binaries

      id32 os32.ini

      Unfortunately you cannot use OS32-FTPd  under Windows, as there is
      no longer  a native version of  expect. Windows 10 users  might be
      able  to run  it in  the  "Windows Subsystem  for Linux".  Another
      option is to use Cygwin or MobaXterm. Anyway, YMMV.


Remote logins (aka. MTM) :-

   Telnet localhost 1026
   Wait for asterisk, hit return if necessary
   Type SIGNON whatever,25,user1
   Use account number 25
   Replace "whatever" with whatever you like (must be unique)
   Tip: Hit Ctrl/E before your password (user1) to disable echoing

   or

   Telnet localhost 1026
   Wait for asterisk
   Type SIGNON without parameters
   At USERID prompt, type whatever (must be unique)
   At ACCOUNT NUMBER, type 25 (does not echo)
   At PASSWORD, type user1 (does not echo)
   Leave ENVIRONMENT blank, or enter name of a CSS file


Basic file handling commands :-

   DISPLAY FILES	or abbreviate to D F
   DISPLAY FILES ,-.C   note comma, '-' is multiple chars, '*' single
   DELETE filename	cannot use wildcards
   RENAME from,to       again, no wildcards allowed

   Note: there is no COPY or TYPE command (but see CSS below).

   Note: wildcards are '-' (multiple characters) and '*' (single char).


Program development (aka. EOU -- under MTM only) :-

   EDIT filename	line editor, but quite nice actually; has help

   FORT hellof		enter Fortran environment, filename hellof.ftn
   COMPILE		compile hellof.FTN to hellof.OBJ
   LINK			link hello.OBJ to hellof.TSK
   EXEC			load hellof.TSK, and run it

   PASCAL hellop	enter Pascal environment, filename hellop.PAS
   COMPILE
   LINK
   EXEC			btw, you can skip COMPILE and LINK step

   CC helloc		compile and link helloc.C, and produce helloc.CSS
   helloc		invokes helloc.CSS to run helloc.TSK

   HELP *		help

    ***************************** WARNING ******************************

    EOU has a nasty habit of locking up. For example, you cannot use the
    compile  commands in  more than  one  MTM terminal,  and you  cannot
    signon if  anyone is using the  EDIT command.  MTM will go into some
    kind of deadlock if you do that...
  
    If you find yourself in this sticky situation:
  
    - Go to the operator console (i.e. the SimH window)
    - Type MTMDOWN
    - Type MTMUP
    - Log back into your kicked-off MTM sessions
    - Do not try to COMPILE or LINK in more than one session

    ***************************** WARNING ******************************


Switching 'directories' :-

   SET PRIVATE n	set current account to n (like UNIX cd command)
   SET GROUP n		set current group to n (also like cd command)
   VOLUME fred/USR	set current user device to fred (also like cd)
   DIR /P               list PRIVATE files (cf. SET PRIVATE)
   DIR /G		list GROUP files (cf. SET GROUP)
   DIR /S               list SYSTEM files (files owned by /0 account)


Some handy CSS scripts :-

   CSS stands for Command Substitution System, like batch files or shell
   scripts.

   DIR			a lot of us have DEC previous, so why not
   COPY from,to		runs COPY32 to copy 'from' to 'to', no wildcards
   TYPE filename	runs COPY32 to copy filename to CON:
   SEARCH -.c,include	handy search utility
   WILD delete,-.tsk	run the DELETE command on all files -.tsk


To log out of your MTM session :-

   SIGNOFF


To shutdown the system :-

   Go back to the operator console (SimH window)
   Type SHUTDOWN (a CSS file)


Operator commands :-

   These only work at the operator console, i.e. the SimH window.

   DISPLAY TASKS	show running tasks
   DISPLAY VOLUME	show information about disks
   DISPLAY DEVICES	show devices, including disks
   MARK DSCn:,ON        mount a disk, e.g. a second disk on DSC3
   MARK DSCn:,OFF       dismount disk
   MTMDOWN		stop MTM (timesharing)
   MTMUP		start MTM
   SHUTDOWN		a CSS to stop tasks, mark disks off, exit SimH

   
Useful SimH scripts (operator console only) :-

   Ctrl/E		break to SimH prompt, then...

   DO fixdisk		fix disk after an unclean shutdown
   DO makedisk		create and mount a clean 67MB disk pack on DSC3
   DO mountdisk		mount a 67MB disk pack on DSC3
   DO iug		copy an Interdata User Group tape to IUG: disk

   !tclsh make-sim.tcl 25 *.ftn >wop   generate EXPECT/SEND sequences ...
   DO wop			      ... to upload *.ftn into account 25


Using the FTP server (UNIX/Linux only) :-

   Note: Windows 10 users may be able to do this in the Windows Subsystem
   for Linux. Other Windows users could try Cygwin or MobaXterm -- YMMV.
   A better option would be to run Linux or BSD inside a VM or Docker.

   Required packages: tcl, expect, tcllib
   Copy example.shadow.config to shadow.config
   Edit according to your needs, note md5sum command for named users
   Start SimH by running the OS32-FTPd script

   ftp localhost 2121
   Username: 25
   Password: user1

   (if shadow.config has a named user yourname with password yourpass)

   ftp localhost 2121
   Username: yourname
   Password: yourpass

   Note your ACL :

   ACL=(25,*)		initial account is 25, you can access all accounts
   ACL=(25,-vt)		account 25 only, and VT100 colours are disabled
   ACL=(25,RO)		account 25 only, and readonly

   FTP commands :

   dir			list files
   get wild.c		download file
   put wild.c		upload file
   prompt		toggle prompting
   mget *.c		download multiple files
   mput *.c		upload multiple files

   cd 11		switch to account 11 (assuming you have access)
   cd iug		switch to volume IUG (assuming it is mounted)
   cd iug/78		switch to account 78 on volume IUG

