#!/usr/bin/tclsh

if { $argc < 1 } {
   puts stderr "Usage: $ makedo FILENAME"
   exit
}
set fnam [lindex $argv 0]
set fd [open $fnam r]
set schluck [string trimright [read $fd]]
set fnam [file tail $fnam]
puts "   expect \"\\r\\n*\" send \"build $fnam\\r\";c"
foreach line [split $schluck \n] {
   set line [string trimright $line]
   if { $line == "" } { set line " " }
   puts "   expect \".CMDP>\" send \"$line\\r\";c"
}
puts "   expect \".CMDP>\" send \"endb\\r\";c"
