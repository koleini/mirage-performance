#!/bin/bash

INT=eth0
DST_IP="pgset \"dst 10.0.0.5\""
DST_MAC="pgset \"dst_mac 00:11:22:33:44:55\""

pps=($(cat $DIR/../cfg/range-pps))
psz=($(cat $DIR/../cfg/range-psz))

[ ! -d $TMP/pktc ] && mkdir $TMP/pktc
rm -rf $TMP/pktc/*

for (( i=0; i<${#pps[@]}; i++ )) 
do
  for (( j=0; j<${#psz[@]}; j++ ))
  do
 
  cp $DIR/../cfg/pktgen.conf $TMP/pktc/pktgen-${pps[$i]}-${psz[$j]}.conf
  sed -i \
  	-e "s/@INT@/$INT/g" \
  	-e "s/@PSZ@/${psz[$j]}/g" \
  	-e "s/@PPS@/${pps[$i]}/g" \
  	-e "s/@DST_IP@/$DST_IP/g" \
  	-e "s/@DST_MAC@/$DST_MAC/g" \
  	 -- $TMP/pktc/pktgen-${pps[$i]}-${psz[$j]}.conf
  done
done

