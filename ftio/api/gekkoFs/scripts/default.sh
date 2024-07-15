#!/bin/bash

BLACK="\033[0m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
FINISH=false #set using export in
JIT_ID=""
FTIO_NODE=""
ALL_NODES=""
EXCLUDE_APP_NODES=""
EXCLUDE_FTIO_NODES=""

echo -e "${BLUE}---- Started Script JIT ----${BLACK}"

# by default FTIO is included in the setup
EXCLUDE_FTIO=false

# Set default values. Check if enviromental variables are set
# cluster or local mode?
CLUSTER=false
if [ -n "$(hostname | grep 'cpu\|mogon')" ]; then
	CLUSTER=true
fi
echo -e "${GREEN}> Cluster Mode: ${CLUSTER}${BLACK}"

ip=$(ip addr | grep ib0 | awk '{print $4}' | tail -1)

###################
# Common variables
###################
ADDRESS=${ADDRESS:-"127.0.0.1"} # usually obtained automatically before executing FTIO
PORT=${PORT:-"5555"}
NODES=${NODES:-"2"}
PROCS=${PROCS:-"128"}
MAX_TIME=${MAX_TIME:-"30"}

# import flags
source ${SCRIPT_DIR}/flags.sh

# TODO: Bind sockets to CPU numactl --cpunodebind=0,1 --membind=0,1 (particular sockets are faster)
# TODO: remove FTIO from node list and exlude it from others (see functions.sh)
# TODO: Gekko Proxy
