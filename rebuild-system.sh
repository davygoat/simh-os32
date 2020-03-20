#!/bin/sh
for stage in stage-*.ini; do
   ./id32 $stage || exit
done
cat <<EOD


Next steps:

- Open up two more terminals.

  - Terminal 0:   leave this terminal visible
  - Terminal 1:   ./id32 os32.ini    or    ./OS32-FTPd
  - Terminal 2:   telnet localhost 1026

- Type these commands in terminal 2 (telnet session):

  SIGNON whatever,25,user1
      ... wait for 'wild' and 'search' programs to be compiled ...
  SIGNOFF

  Hit Ctrl+] and quit

- Type this command in terminal 1 (system console, SimH/id32 window):

  SHUTDOWN

- Done


EOD
exit
