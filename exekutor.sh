#!/bin/bash
set -o nounset
set -e
USERNAME=ubuntu
HOSTS="master-0001.pinetes node-0001.pinetes node-0002.pinetes node-0003-pinetes"
SCRIPT="sudo apt update"
for HOSTNAME in ${HOSTS} ; do
    ssh -l ${USERNAME} ${HOSTNAME} "${SCRIPT}" $
done
