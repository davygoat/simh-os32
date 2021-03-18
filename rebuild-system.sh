#!/bin/sh
for stage in stage-*.ini; do
   ./id32 $stage || exit
done
