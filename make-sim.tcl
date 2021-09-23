#!/bin/sh
## vim:set nowrap:\
## vim:set syntax=tcl:\
## FreeBSD, no symlink... ##############################################\
   SH=$(ls /{usr,usr/local,opt}/bin/tclsh* 2>/dev/null | head -1)      #\
   [ -n "$SH" ] || exec echo "Cannot find tclsh"                       #\
   exec $SH "$0" ${1+"$@"}                                             #\
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
   if { [string first $fnam .] == -1 } { append fnam . }
   if { $acct } {
       puts "   # [string toupper $fnam]/$acct"
   } else {
       puts "   # [string toupper $fnam]"
   }
   puts "   expect \"\\r\\n*\" send \"alloc $fnam,in,80 ; build $fnam,append\\r\";c"
   foreach line [split $schluck \n] {
      set line [string trimright $line]
      regsub -all {[\\"]} $line {\\&} line
      regsub -all {[%]} $line {&&} line
      if { $line == "" } { set line " " }
      puts "   expect \".CMDP>\" send \"$line\\r\";c"
   }
   puts "   expect \".CMDP>\" send \"endb\\r\";c"
   if { $acct } {
      if { $makeithappen } {
         puts "   expect \"\\r\\n*\" send \"xdelete $fnam/$acct ; rename $fnam,$fnam/$acct\\r\";c"
      } else {
         puts "   expect \"\\r\\n*\" send \"rename $fnam,$fnam/$acct\\r\";c"
      }
   }
}

if { $makeithappen } {
   puts "   # make it happen!"
   puts "   send \"\\r\""
   puts "   continue"
}
