#!/bin/sh
## vim:set nowrap:\
## vim:set syntax=tcl:\
## FreeBSD, no symlink... ##############################################\
   TCL=$(ls $(echo $PATH:|sed 's,:,/expect* ,g') 2>/dev/null|head -1)  #\
   [ -n "$TCL" ] || exec echo "Cannot find expect"                     #\
   exec $TCL "$0" ${1+"$@"}                                            #\
########################################################################

set numfiles 0
set acct 0
foreach arg $argv {
   if { ![string is integer $arg] } {
      incr numfiles
   }
}

if { $numfiles < 1 } {
   puts stderr ""
   puts stderr "Usage:     $ make-sim \[OPTIONS\] \[ACCOUNT\] FILENAME..."
   puts stderr ""
   puts stderr "Options:   -n  do not add 'make it happen' code"
   puts stderr ""
   puts stderr "   UNIX:     ./make-sim.tcl *.css >wop"
   puts stderr "   WINDOWS:  tclsh.exe make-sim.tcl  25 wild.c search.c >wop"
   puts stderr "   simh:     <Ctrl/E> do wop"
   puts stderr ""
   exit
}

set makeithappen 1
foreach arg $argv {
   if { $arg == "-n" } {
      set makeithappen 0
      continue
   }
}

foreach arg $argv {
   if { [string is integer $arg] } {
      set acct $arg
      continue
   }
   if { $arg == "-n" } {
      continue
   }
   set fnam $arg
   set fd [open $fnam r]
   set schluck [string trimright [read $fd]]
   set fnam [file tail $fnam]
   if { [string first . $fnam] == -1 } { append fnam . }
   puts "   # [string toupper $fnam]/$acct"
   puts "   expect \"\\r\\n*\" send \"***** UPLOADING ***** [string toupper $fnam]/$acct *****\\r\";c"
   puts "   expect \"\\r\\n*\" send \"xdelete z.z ; alloc z.z,in,80 ; build z.z,append\\r\";c"
   foreach line [split $schluck \n] {
      set line [string trimright $line]
      regsub -all {[\\"]} $line {\\&} line
      regsub -all {[%]} $line {&&} line
      if { $line == "" } { set line " " }
      puts "   expect \".CMDP>\" send \"$line\\r\";c"
   }
   puts "   expect \".CMDP>\" send \"endb\\r\";c"
   puts "   expect \"\\r\\n*\" send \"xdelete $fnam/$acct ; rename z.z,$fnam/$acct\\r\";c"
}

if { $makeithappen } {
   puts "   # make it happen!"
   puts "   send \"\\r\""
   puts "   continue"
}
