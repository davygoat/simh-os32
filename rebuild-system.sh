#!/bin/sh
mkdir -p logs
rm -f logs/*
for stage in stage-*.ini; do
   ./id32 $stage || exit
done
