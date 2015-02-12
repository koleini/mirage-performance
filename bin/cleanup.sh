#!/bin/bash

  echo -e "${INF} cleaning up"

  xl destroy $SERVERNAME 
  xl destroy $UNIKERNEL

  ip link set dev $UBRG1 down
  ip link set dev $UBRG2 down
  brctl delbr $UBRG1
  brctl delbr $UBRG2

  rm -rf $TMP
  rm -rf $HOMEDIR/domains/$SERVERNAME
