## vim:set nowrap:
## vim:set syntax=tcl:

if { $argc < 3 } {
   puts stderr "Usage: $ mtmcheckpass.tcl PORT ACCOUNT PASS"
   exit 99
}

#
# port: must be numeric
#
set port [lindex $argv 0]
if { ![string is integer $port] || $port < 1 } {
   puts stderr "*** FAIL 99 (BAD INPUT) ***"
   exit 99
}

#
# account: must be numeric
#
set acct [lindex $argv 1]
if { ![string is integer $acct] || $acct < 0 || $acct >= 255 } {
   puts stderr "*** FAIL 99 (BAD INPUT) ***"
   exit 99
}

#
# password: anything goes, but weed out high and low values
#
set pass [lindex $argv 2]
if { [regexp "\[\x00-\x19\x7f-\xff\]" $pass] } {
   puts stderr "*** FAIL 99 (BAD INPUT) ***"
   exit 99
}

#
# Over to  MTM. Try  to sign on  with the account  number. Use  a random
# USERID to  avoid duplicate names.  Use a random ENVIRONMENT  to bypass
# userinit.css.
#

spawn telnet localhost $port

expr { srand([clock clicks]) }
set userid [format ftp%05d [expr {int(rand()*100000)%100000}]]
set envid  [format nop%05d [expr {int(rand()*100000)%100000}]]

interact {
   -o
   #
   # MTM or line prompt. They both look the same.
   #
   -re "\\*" {
      puts -nonewline stdout "*"
      if { ![info exists signingOn] } {
         send "signon\r"
         set signingOn 1
      } elseif { ![info exists signedOn] } {
         send "signoff\r"
         set signedOn 1
      } elseif { [info exists signedOff] } {
         puts "*** SUCCESS ***"
         exit 0
      }
   }
   #
   # SIGNON prompts.
   #
   -re "USERID: " {
      send -- "$userid\r"
   }
   -re "ACCOUNT NUMBER: " {
      send -- "$acct\r"
   }
   -re "PASSWORD: " {
      send -- "$pass\r"
   }
   -re "ENVIRONMENT= " {
      send -- "$envid\r"
   }
   #
   # SIGNOFF message.
   #
   -re "OS/32 TERMINAL MONITOR" {
      set signedOff 1
   }
   #
   # Failure modes
   #
   -re "INVALID PARAMETER - - SIGNON REQUIRED" {
      # Normal: wrong account or password
      puts stderr "\n*** FAIL 1 (USERNAME/PASSWORD ERROR) ***"
      exit 1
   }
   -re "NOPR-ERR" {
      # Normal: empty password
      puts stderr "\n*** FAIL 1 (USERNAME/PASSWORD ERROR) ***"
      exit 1
   }
   eof {
      # Config: PALSA not attached, or wrong port
      puts stderr "*** FAIL 2 (NO CONNECT) ***"
      exit 2
   }
   timeout 5 {
      # Operator: MTM is down, out of lines, or it took too long
      puts stderr "*** FAIL 3 (NO RESPONSE) ***"
      exit 3
   }
   -re "DUPLICATE USERNAME" {
      # Bug: already/still logged in as FTP
      puts stderr "\n*** FAIL 4 (DISPLAY NAME CONFLICT) ***"
      exit 4
   }
}
