
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

   The following Interdata User Group (IUG) tapes have also been placed
   on SYS:.

   SYS:/104	IUG-104 object library utilities
   SYS:/200	IUG-200 HLAL2 high level assembler macros

   The following packages are also on the disk, but not 'installed'. You
   may be able to get them to work if you try hard enough. Documentation
   is  lacking... The  two editors  have textfiles  that should  get you
   started.

   SYS:/12	Fortran-VII universal compiler
   SYS:/14	Debugger
   SYS:/15	SORT/MERGE, may need COBOL for this
   SYS:/16	DMS/32 database management system, but lack documentation
   SYS:/17	MEDIT, a full screen editor
   SYS:/165	Micro EMACS, a full screen editor, needs termcap setup

   Sadly, the other two languages, COBOL and RPG, are nowhere to be found.
   Reliance ECM (transaction monitor) and  spooler are on the disk, but I
   don't know how to get them working. Again, available documentation is
   rather scarce.

   
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

   SimH Classic

      If you want  to use Bob Supnik's "Classic" SimH,  which comes with
      many Linux distributions,  I have added a  little file, supnik.ini
      without any of  the unsupported/unavailable SEND/EXPECT sequences.
      OS32-FTPd takes care of the OS/32  startup sequence for you if you
      are using Classic.  But if you are running without  the FTP server
      (e.g. in Microsoft Windows), then you  will have to type SET TIME,
      MARK DSC4:,ON and STARTUP yourself.


Remote logins (aka. MTM) :-

   Default passwords:

	ACT   PASSWORD  DESCRIPTION
	----  --------  ----------------------------------------------
	255   pass1     super user, use only for MTM administration !!
	25    user1     power user, has SET PRIVATE and SET GROUP
	165   emacs     example user, restricted to their own account

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

   If you want to use the EOU commands (COMPILE, LINK, EXECUTE, EDIT),
   you MUST signon as 'EOU', as follows:

   SIGNON eou,25,user1

   For anything else, including additional logins under the 25 account,
   use whatever name you like, for example:

   SIGNON fred,25,user1      -- good for everything, including non EOU
   SIGNON wilma,25,user1        C programming using the 'cc' command,
   SIGNON barney,25,user1       and for general OS/32 commands.

   SIGNON mtm,255,pass1      -- use account 255 for MTM user admin only


Basic file handling commands :-

   DISPLAY FILES	or abbreviate to D F
   DISPLAY FILES ,-.C   note comma, '-' is multiple chars, '*' single
   DELETE filename	cannot use wildcards
   RENAME from,to       again, no wildcards allowed

   Note: there is no COPY or TYPE command (but see CSS below).

   Note: wildcards are '-' (multiple characters) and '*' (single char).


Program development (aka. EOU -- under MTM only) :-

   To use these commands, you MUST SIGNON AS EOU, see warning below.

   EDIT filename	line editor, but quite nice actually; has help

   FORT hellof		enter Fortran environment, filename hellof.ftn
   COMPILE		compile hellof.FTN to hellof.OBJ
   LINK			link hello.OBJ to hellof.TSK
   EXEC			load hellof.TSK, and run it

   PASCAL hellop	enter Pascal environment, filename hellop.PAS
   COMPILE
   LINK
   EXEC			btw, you can skip COMPILE and LINK step

   C helloc	        enter C environment, filename hellop.C
   COMPILE
   LINK
   EXEC

   CAL helloa           enter CAL/32 assembler environment, filename.CAL
   COMPILE
   LINK
   EXEC

   MACRO hellom         enter MACRO/32 assembler environment, filename.MAC
   COMPILE
   LINK
   EXEC

    ***************************** WARNING ******************************

    EOU has a nasty  habit of locking up if used in  more than one login
    session. For  example, you cannot  use the compile commands  in more
    than one MTM terminal, and you  cannot signon if anyone is using the
    EDIT  command. MTM  will go  into some  kind of  deadlock if  you do
    that...
  
    If you find yourself in this sticky situation:
  
    - Go to the operator console (i.e. the SimH window)
    - Type MTMDOWN
    - Type MTMUP
    - Log back into your kicked-off MTM sessions
    - Do not try to COMPILE or LINK in more than one session

    That said,  I have  'sabotaged' the EOUINIT  command to  prevent you
    inadvertently using  EOU in more than  one session.  To use EOU, you
    must signon as 'EOU'.

    - SIGNON EOU,99,xyzzy   assuming you have created an account 99 with
                            password xyzzy using the ACTUTY command in
                            the MTM administrator account 255.

    - SIGNON EOU,25,user1   account 25 can use SET PRIVATE and SET GROUP
    - SIGNON EOU,165,emacs  account 165 is restricted to their own account

    ***************************** WARNING ******************************

   With that out of the way, the HELP command is perfectly safe to use,
   even if you are not signed on as EOU. It's well worth reading these.

   HELP *		help
   HELP FORT		help about the Fortran language environment
   HELP PASCAL		help about the Pascal language environment
   HELP CAL		help about the CAL/32 language environment
   HELP MACRO		help about the MACRO/32 language environment
   HELP EDIT 		help about the starting the EDIT/32 line editor
   HELP COMPILE         help about compiling a file
   HELP LINK            help about linking, or task establishing
   HELP EXEC            help about executing your program


Whitesmiths C has a convenient alternative to EOU :-

   CC helloc		compile and link helloc.C, and produce helloc.CSS
   helloc		invokes helloc.CSS to run helloc.TSK


The other high level languages also have their High Level Operator
Commands (HLOC), which can be used if you change your 'PATH'.

   SET CSS 11		Fortran
   SET CSS 13		Pascal


Switching 'directories' :-

   SET PRIVATE n	set current account to n (like UNIX cd command)
   SET GROUP n		set current group to n (also like cd command)
   VOLUME fred    	set current user device to FRED (also like cd)
   VOLUME sys     	set current user device back to SYS
   DISPLAY FILES ,/P    list PRIVATE files (cf. SET PRIVATE)
   DISPLAY FILES ,/G	list GROUP files (cf. SET GROUP)
   DISPLAY FILES ,/S    list SYSTEM files (files owned by /0 account)


Some handy CSS scripts :-

   CSS stands for Command Substitution System, like batch files or shell
   scripts.

   DIR			a lot of us have DEC previous, so why not
   COPY from,to		runs COPY32 to copy 'from' to 'to', no wildcards
   TYPE filename	runs COPY32 to copy filename to CON:
   SEARCH -.c,include	handy search utility
   WILD delete,-.tsk	run the DELETE command on all files -.tsk
   HEX mtmmac.tsk/s     produce a hex dump of the MTM daemon
   WHOAMI               what name are you logged in as, e.g. 'EOU'.
   CD [vol:]/acct       switch 'directory', possibly on another volume


To log out of your MTM session :-

   SIGNOFF


To shutdown the system :-

   Go back to the operator console (SimH window)
   Type SHUTDOWN (a CSS file)

   SimH Classic users: don't forget to MARK DSC4:,OFF before you hit
   Ctrl/E to quit SimH.


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

   Note: These only work with the new SimH 4.0, not SimH Classic.


Using the FTP server (UNIX/Linux only) :-

   Note: Windows 10 users may be able to do this in the Windows Subsystem
   for Linux. Other Windows users could try Cygwin or MobaXterm -- YMMV.
   A better option would be to run Linux or BSD inside a VM or Docker.

   Required packages: tcl, expect, tcllib
   Copy example.shadow.config to shadow.config
   Edit according to your needs.
   Start SimH by running the OS32-FTPd script
   Type FTP for help.
   Use FTP ADDUSER to add a user, and follow the prompts.

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


Account 255 -- adding user accounts :-

   SIGNON mtm,255,pass1
   ACTUTY		I've provided a handy summary of commands
   LISTAUF USERS.AUF	in case you've forgotten your password

