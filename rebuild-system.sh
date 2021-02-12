#!/bin/sh
for stage in stage-*.ini; do
   ./id32 $stage || exit
done
echo
echo Waiting for TIME_WAIT socket to go away.
echo
echo This can take up to 90 seconds...
echo
for ((cc=90; cc>=0; cc--)); do
   printf "\r   $cc "
   sleep 1s
done
printf "\rBegone!       \n"
echo
echo
exit
