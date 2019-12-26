#!/bin/sh
## vim:set nowrap:\
## vim:set syntax=tcl:\
## FreeBSD, no symlink... ###############################################\
   TCL=$(ls /usr/bin/tclsh* /usr/local/bin/tclsh* 2>/dev/null |head -1) #\
   [ -n "$TCL" ] || exec echo "Cannot find tclsh"                       #\
   exec $TCL "$0" ${1+"$@"}                                             #\
#########################################################################

if { $argc < 1 } {
   puts stderr ""
   puts stderr "Usage: $ make-sim FILENAME..."
   puts stderr ""
   puts stderr "   UNIX:     ./make-sim *.css >wop"
   puts stderr "   WINDOWS:  tclsh.exe make-sim  wild.c search.c >wop"
   puts stderr "   simh:     <Ctrl/E> do wop"
   puts stderr ""
   exit
}
foreach fnam $argv {
   set fd [open $fnam r]
   set schluck [string trimright [read $fd]]
   set fnam [file tail $fnam]
   puts "   # $fnam"
   puts "   expect \"\\r\\n*\" send \"build $fnam\\r\";c"
   foreach line [split $schluck \n] {
      set line [string trimright $line]
      regsub -all {[\\"]} $line {\\&} line
      regsub -all {[%]} $line {&&} line
      if { $line == "" } { set line " " }
      puts "   expect \".CMDP>\" send \"$line\\r\";c"
   }
   puts "   expect \".CMDP>\" send \"endb\\r\";c"
}
puts "   # make it happen!"
puts "   send \"\\r\""
puts "   continue"
