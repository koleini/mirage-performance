#!/bin/bash

ERR='\033[0;31m[ERROR]\033[0m'
WRN='\033[1;33m[WARNING]\033[0m'
INF='\033[1;34m[INFO]\033[0m'

SERVERIP=$(cat $DIR/../cfg/SERVERIP)
SERVERNAME="traff-gen"
UNIKERNEL="network"

HOMEDIR=$(eval echo ~${SUDO_USER})

TMP=/tmp/perf

APPDIR=$TMP/app
NETDIR=$TMP/mirage-net-xen

PASSWORD=$(cat $DIR/../cfg/PASSWORD)

# TODO: check:
# first and second interface defined in mirage config assign  to second and first xen vifs

UBRG1="if1"
UBRG2="if2"

GENBR=$UBRG1
GENIP="10.0.0.2"
GENNAME="tgen"

XENBR="xenbr0"
CONFIF="pgen-conf"

UINT1="tap1"
UINT2="tap2"

# interfaces to listen to
INTMON1=tgen
INTMON2=$UINT1

RUNTIME=15 # runtime for each pktgen script
GRDTIME=2  # time that traff monitor tool samples output before pktgen stops
