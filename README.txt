
Contents :-

   This 'kit'  provides you with  a ready-to-use OS/32 system  and three
   high level languages: Fortran, Pascal and C.

   Interdata 8/32
   Perkin-Elmer OS/32 V8.1
   Fortran, Pascal and C
   Common Assembly Language (CAL) and Macro Assembler (MACRO)
   MTM 8.1 with Ease of Use (EOU) program development utilities

   SYS:/11	Fortran VII development and optimizing compilers
   SYS:/13	Pascal
   SYS:/14	Whitesmiths C

   The following packages  are also on the disk, but  not installed. You
   may be able to get them to work if you try hard enough. Documentation
   is lacking... But the two editors  have textfiles that should get you
   started.

   SYS:/12	Fortran-VII universal compiler
   SYS:/14	BAS32D, presumably a BASIC interpreter
   		Debugger
   SYS:/15	SORT/MERGE, may need COBOL for this
   SYS:/16	DMS/32, database system, but we have no COBOL...
   SYS:/17	MEDIT, a full screen editor
   SYS:/18	Micro EMACS, a full screen editor, needs termcap setup

   Unfortunately, there are  no COBOL or RPG tapes. (Not  sure if anyone
   will miss  RPG.) Reliance ECM  (transaction monitor) and  spooler are
   present,  but I  have not  managed to  get them  working. Again,  the
   available documentation is somewhat sparse.

   
Startup :-

   Windows:

      id32 os32.ini

   UNIX:

      Without FTP server:

         ./id32 os32.ini

      With FTP server (see below for more details):

         ./OS32-FTPd


Remote logins (aka. MTM) :-

   Telnet localhost 2323
   Wait for asterisk, hit return if necessary
   Type SIGNON whatever,25,user1
   Use account number 25
   Replace "whatever" with whatever you like (must be unique)
   Tip: Hit Ctrl/E before your password (user1) to disable echoing

   or

   Telnet localhost 2323
   Wait for asterisk
   Type SIGNON without parameters
   At USERID prompt, type whatever (must be unique)
   At ACCOUNT NUMBER, type 25 (does not echo)
   At PASSWORD, type user1 (does not echo)
   Leave ENVIRONMENT blank, or enter name of a CSS file


Useful built-in commands (under MTM and operator console) :-

   DISPLAY FILES	or abbreviate to D F
   DISPLAY FILES ,-.C   note comma, '-' is asterisk, '*' is question mark
   DELETE filename	cannot use wildcard
   RENAME from,to       again, cannot use wildcards


Program development (aka. EOU -- under MTM only) :-

   EDIT filename	line editor, but quite nice actually; has help

   FORT hellof		enter Fortran environment, filename hellof.ftn
   COMPILE		compile hellof.ftn to hellof.obj
   LINK			link hello.obj to hellof.tsk
   EXEC			

   PASCAL hellop	enter Pascal environment, filename hellop.pas
   COMPILE
   LINK
   EXEC			btw, you can skip COMPILE and LINK step

   CC helloc		compile and link helloc.c, and produce helloc.css
   helloc		invokes helloc.css to run helloc.tsk

   HELP *		help

    **************************** WARNING ******************************

    EOU has  a nasty habit of  locking up. For example,  you cannot use
    the compile  commands in  more than  one MTM  terminal, and  do not
    attempt to signon if anyone is  using the EDIT command. MTM will go
    into some kind of deadlock if you do that...
  
    If you find yourself in this sticky situation:
  
    - Go to the operator console (i.e. the SimH window)
    - Type MTMDOWN
    - Type MTMUP
    - Log back into your kicked-off MTM sessions
    - Do not try to COMPILE in more than one session

    **************************** WARNING ******************************


Some handy CSS scripts :-

   DIR			a lot of us have DEC previous
   COPY from,to		runs COPY32 to copy 'from' to 'to', no wildcards
   TYPE filename	runs COPY32 to copy filename to CON:
   SEARCH -.c,include	handy search utility
   WILD delete,-.tsk	run the DELETE command on all files -.tsk


To log out of your MTM session :-

   SIGNOFF


To shutdown :-

   Go back to the operator console (SimH window)
   Type SHUTDOWN


Operator commands :-

   These only work at the operator console, i.e. the SimH window.

   DISPLAY TASKS	show running tasks
   DISPLAY VOLUME	show information about disks
   DISPLAY DEVICES	show devices, including disks
   MTMDOWN		stop MTM
   MTMUP		start MTM
   SHUTDOWN		stop tasks, mark disks off, exit SimH

   
Useful SimH scripts (operator console only) :-

   Ctrl/E		break to SimH prompt
   DO fixdisk		fix disk after an unclean shutdown
   DO makedisk		create a 67MB disk pack
   DO iug		copy an Interdata User Group tape to IUG: disk

   !tclsh make-sim 25 *.ftn >wop	generate EXPECT/SEND sequences ...
   DO wop				... to upload *.ftn into account 25


Using the FTP server (UNIX/Linux only) :-

   Required packages: tcl, expect, tcllib
   Copy example.shadow.config to shadow.config
   Edit according to your needs, note md5sum command for named users
   Start SimH by running the OS32-FTPd script

   ftp localhost 2121
   Username: 25
   Password: user1

   or (if your shadow.config has named users)

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

