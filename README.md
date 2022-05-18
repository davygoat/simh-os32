# SimH Interdata OS/32 kit

This repository holds the source code and build files for a SimH software kit with a working OS/32 system with two assemblers, four high level languages, and a handy Tcl/Expect based FTP server front-end. The kit is built with bitsavers tapes using SimH 4.0, but the ready-made disk also works with SimH 3.X "Classic".

OS/32 base system and software development tools:

- Perkin-Elmer **OS/32** V8.1.
- **MTM** 8.1 with Ease of Use (**EOU**) program development utilities and **HELP** files.
- **Fortran VII** R0.5-01.00 (Development and Optimising compilers).
- Perkin-Elmer **Pascal** R01-00.
- OS/32 **C Compiler** 04-193R00-00 (aka. **Whitesmiths C**).
- **RATFOR** from the Software Tools tape (IUG-523).
- **Common Assembly Language CAL/32** 03-338R01-01.
- **MACRO/32** assembler 03-339 R00-01.
- HLAL2 **high level assembler macros** (IUG-200).
- SYSGEN'd with 8 terminal lines on port 1026 for **telnet** access.
- Optionally, an Expect/Tcl-based **FTP** front-end to upload or download ASCII files via the OS/32 console.

The following items exist on the disk, but have not been tested in any way, since the relevant documentation is not available:

- A debugger in SYS:/14.
- SORT/MERGE-II, in SYS:/15, if you know how to use it without COBOL.
- DMS/32, a CODASYL-type database management system, in SYS:/16. Again, this probably depends on having COBOL.
- IUG-523 Software Tools is on a separate disk labelled STUG.
- IUG-165 MicroEMACS in SYS:/165 if you want to try and get it working.
- MEDIT, another full screen editor, in SYS:/17.
- VCF (Virtual Console Facility)
- Reliance/ECM (Environment Control Manager, a transaction processor)

As already hinted at, COBOL and RPG are not installed because there are no available tapes or documentation. But I doubt many people would miss RPG anyway.

Some useful additions of my own:

- DIR for those of us with DEC previous.
- COPY to copy files using the COPY/32 program.
- TYPE to display a file using COPY/32.
- HEX to produce a hex dump from a binary file, again using COPY/32.
- WILD to run a command with a wildcard pattern.
- SEARCH, which uses WILD to search files for a substring.
- WHOAMI, to remind you of your SIGNON username.
- CD to move into another account, optionally on another disk, without having to use separate SET PRIVATE or VOLUME commands.
- LIB to create, list and work with object libraries.
- Compile-link-and-go scripts that do not lock up MTM the way EOU does.

## Starting OS/32

### SimH 4.0 "GitHub" users (Windows and UNIX)

- Unzip the kit into a suitable directory
- `git clone https://github.com/simh/simh`
- `cd simh` and `make id32`
- `cp BIN/id32 ..` and `cd ..`
- `./id32 os32.ini`
- The ini file will take care of the boot sequence.

### SimH 3.X "Classic" users (Windows and UNIX)

- Unzip the kit into a suitable directory
- `wget http://simh.trailing-edge.com/sources/simhv312-2.zip`
- `cd sim` and `make id32`
- `cp BIN/id32 ..` and `cd ..`
- `./id32 supnik.ini`
- Manually enter the following commands at the asterisk prompt to finish booting and bring up MTM. Take notice of the commas in command lines.
- `set time 05/16/22,19:00`
- `mark dsc4:,on`
- `startup`

### Both SimH versions (UNIX only)

- `./OS32-FTPd`
- This script takes care of the boot sequence even if you use SimH "Classic" !

## Logging in

Account 25 -- a developer account

- `telnet 1026` and wait for the asterisk prompt to appear.
- `signon fred,25,user1`. Note: the example username 'fred' can be anything you like, as long as it is unique. You actually sign on with the *numeric* account 25. The default password for account 25 is 'user1'.
- Type `display files` or `dir` to list files.
- Account 25 has SET PRIVATE and SET GROUP privileges and a few more.

Account 255 -- the MTM administrator

- `telnet 1026` and wait for the asterisk prompt to appear.
- `signon mtm,255,pass1`. Note: the example username 'mtm' can be anything you like, as long as it is unique. You actually sign on with the numeric id/account 255. The default password for account 255 is 'pass1'.
- Account 255 has every privilege in the OS/32 world, even if you revoke them all!
- Type `actuty` to launch the account utility, which is used to create and manage MTM users. My CSS script also provides handy summary (gleaned from hex dumps and MACRO sources). When you have finished, type `end` to return to the MTM prompt.
- Type `display files` or `dir` at the MTM/asterisk prompt to list the contents of the 255 account.
- Type `auflist` to list the password database. Encryption was not a thing in those days. The source code for auflist.c is in account 25.

Account 165 -- low-privilege user and MicroEMACS sources

- `signon gnoo,165,emacs`. The default password for this account is 'emacs'.
- Account 165 can create their own CSS files and compile stuff, but not much else.

Special case -- Ease of Use scripts

- EOU has an unfortunate propensity to lock up MTM if you try to COMPILE, LINK or RUN in more than one MTM session. If your USERINIT.CSS calls EOUINIT, and someone else (including yourself) happens to be running EDIT at the same time, you will even lock up when you try try to log in.
- If you want to use the FORT, PASCAL, COMPILE, LINK, RUN and other EOU commands, or use the EDIT command to launch EDIT/32, then you should SIGNON as 'EOU', e.g. `signon eou,25,user1`. User names must be unique, so only one user can ever be signed on as 'EOU' at any given time. That at least mitigates the risk of MTM locking up on you.
- Or, if you want to live dangerously, go ahead and type `eouinit!` (EOU dammit) to bypass my safety hack. If MTM locks up, go over to the OS/32 console and type `mtmdown` followed by `mtmup`.

## Shutting down cleanly

- Log off all your MTM sessions.
- At the OS/32 console (i.e. the SimH session), type `shutdown`.
- If you are using SimH "Classic" *and* you are not using the OS32-FTPd script, then don't forget to type `mark dsc4:,off` before you hit Ctrl/E to exit the simulator.


#
# A quick OS/32 intro

## Commonly-used commands

- `SIGNON user,act,pass[,ENV=css]` or `SIGNON` and follow the prompts
- `D(ISPLAY) F(ILES) [,fd]` or `DIR [fd]`
- `TYPE fd`
- `COPY from,to`
- `REN(AME) from,to`
- `DEL(ETE) fd`
- `SET PRIVATE actno`
- `CANCEL`, `CLOSE` and `$CLEAR`
- `HELP`, `HELP *` and `HELP command [subcommand]`
- `SIGNOFF`

`fd` stands for 'file descriptor', which is OS/32's terminology for a filename.

Here are some examples of valid fds:

- `hellof.ftn` (8.3 chars max).
- `iug:emacs.c/165` (emacs.c in account 165 on the IUG: disk. This only works at the OS/32 console, because MTM restricts you to the /P, /G and /S classes).
- `dir.css/s` (dir.css in the SYSTEM account 0).
- `fred.css/g` (fred.css in your GROUP account).
- `fred.css/p` (fred.css in your PRIVATE account).

If you find yourself bewildered by one cryptic error message after another, try typing `CAN[CEL]`, `CL[OSE]` and `$CL[EAR]` to get back into a known state.

For any real work, you will also have to familiarize yourself with the `BUILD`, `ASSIGN`, `LOAD` and `START` commands. Read the manuals and have a look a the `HELP` files.

## EDIT/32 line editor

Despite its obvious quirks, the default editor is surprisingly pleasant to use.

Starting the editor:

- `L[OAD] EDIT32 ; ST[ART] [,args]...` (abbreviate to `l edit32;st`).

Inside the editor:

- `G[ET] fred.ftn` to open a file.
- `H[ELP] *` to list commands.
- `H[ELP] cmd` for help on a specific command.
- `SC[REEN]` to display a screenful at a time.
- `n`, `TO[P]`, `B[OTTOM]`, `-` (minus), `+` (plus or enter) to move around.
- `FI[ND] /str/ [,range]` to search for a string.
- `CH[ANGE] /str1/,/str2/ [,range]` to replace str1 with str2 (note commas)
- `BE[FORE] /str1/str2/ [range]` to insert str1 before str2 (note lack of commas)
- `AF[TER] /str1/str2/ [range]` to insert str1 after str2 (note lack of commas)
- `INS[ERT] [n]` to insert lines after the current line or after line n, end with an empty newline. For a blank line, enter a space.
- `A[PPEND]` to add lines to the end of the file finish with empty newline.
- `S[AVE] *` to save the file if it already has a name.
- `S[AVE] fd` to save to give the file a name.
- `DO[NE]` to save and quit.
- `END` to quit without saving (type `END` again to confirm).

Ranges:

- `10-20` means lines `10` to `20`.
- `1-` means the whole document.

#
# Programming

There are various ways of compiling and linking tasks:

1. Directly run the compiler and link editor using the `LOAD`, `ASSIGN` and `START`. This is the most efficient method with the least overhead, but it's not as easy on the fingers and the mind.

2. Use the so-called High Level Operator Commands (HLOCs) provided with the compilers. These are a bit quirky, and default to listing on the (non-working) PR: device, which requires ACCT privilege.
   - Pascal: `SET CSS 13`, `PASCAL hellop,null:`.
   - Fortran: `SET CSS 11`, `F7CE D,hellof,,null:`.
   - There is also the `CC` command, but it can only handle one file, and has a few bugs. But it is incredibly convenient!

3. Use the Ease Of Use (EOU) commands `FORT`, `PASCAL`, `CAL`, `MACRO`, `COMPILE`, `LINK` and `EXEC`. These are quite nice, and can handle multi-file projects with the `ENV` command. But they _will_ lock up MTM if you are not careful. If you want to give these a go, log in to with the username 'EOU', e.g. `SIGNON EOU,25,pass1`, or type `EOUINIT!` and expect to deadlock at some point.

4. Use my compile-link-and-go scripts. These are a little friendlier to newcomers like myself.
   - Pascal: `PASC`, `PASL`, `PASCL`, `PASCLG`, `PASGO`.
   - Fortran: `FORC`, `FORL`, `FORCL`, `FORCLG`, `FORGO`.
   - RATFOR: `RATC`, `RATL`, `RATCL`, `RATCLG`, `RATGO`.
   - C: `CCC`, `CCL`, `CCCL`, `CCCLG`, `CCGO`.
   - CAL: `CALC`, `CALL`, `CALCL`, `CALCLG`, `CALGO`.
   - MACRO: `MACC`, `MACL`, `MACCL`, `MACCLG`, `MACGO`.
