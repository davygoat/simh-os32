#!/bin/sh
echo
echo
if [ -n "`echo exit | ./id32 | tee /dev/tty | grep 'Interdata 32b simulator V3'`" ]; then
   echo
   echo
   echo
   echo "    *** THE BUILD SCRIPTS ONLY WORK WITH SIMH V4 (GITHUB) ***"
   echo
   echo
   echo
   exit 1
fi
mkdir -p logs
rm -f logs/*
for stage in stage-*.ini; do
   ./id32 $stage || exit
done
