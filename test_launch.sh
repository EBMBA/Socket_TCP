#!/bin/bash
(sleep 1 && timeout 3 ./output/client)&
timeout 4 ./output/server
if [ $? -eq 0 ]; then 
    exit
fi
