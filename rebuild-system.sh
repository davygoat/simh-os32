#!/bin/sh

./id32 stage-00-prelim.ini    || exit
./id32 stage-01-os32base.ini  || exit
./id32 stage-02-sysgen.ini    || exit
./id32 stage-03-mtm.ini       || exit
./id32 stage-04-compilers.ini || exit
./id32 stage-05-scripts.ini   || exit
./id32 stage-06-examples.ini  || exit
./id32 stage-99-done.ini      || exit

exit
