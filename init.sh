#!/usr/bin/env bash
for d in config data; do
    cd $d; ./init.sh
    cd ..
done
