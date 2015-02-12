#!/bin/bash

# command
# sudo bash mir-perf.sh mirage-net-xen b06361d
# TODO: find a way to detect traffic generator's ip address (instead of setting it in config file)
# by settimng the mac address in VIF file. So given mac, we might be able to find ip address

set -ex # set -ex

DIR=$( cd "$( dirname '${BASH_SOURCE[0]}' )" && pwd )

# apt-get install bridge-utils expect-dev

source $DIR/init.sh
# source $DIR/create-unikernel.sh

function on_exit {
  set +e
  source $DIR/cleanup.sh
}

trap on_exit EXIT

[[ "$(brctl addbr $UBRG1)" -eq 0 ]]
[[ "$(brctl addbr $UBRG2)" -eq 0 ]]
ip link set dev $UBRG1 up
ip link set dev $UBRG2 up

source $DIR/create-image.sh

xl create $HOMEDIR/domains/$SERVERNAME/$SERVERNAME.cfg

ssh-keygen -f "/root/.ssh/known_hosts" -R $SERVERIP
SERVER="sshpass -p $PASSWORD ssh -oStrictHostKeyChecking=no -l root $SERVERIP"

echo -e "${INF} wating for the traffic generator to boot up"

retry=0
while true; do
    set +e
    
    $SERVER 'insmod /root/pktgen-3.11.0-netfilter/pktgen.ko'
    [[ "$?" -ne "255" ]] && break # does not suffice for all possible errors

    sleep 5    
    let retry++
    [[ $retry -ge "5" ]] && echo "${ERR} Unable to connect to the traffic generator" && exit
done

echo -e "${INF} pktgen module is loaded on the server"
echo -e "${INF} booting up unikernel..."

xl create $APPDIR/$UNIKERNEL.xl

sleep 5

pps=($(cat $DIR/../cfg/range-pps))
psz=($(cat $DIR/../cfg/range-psz))

[ -f stats ] && rm -f stats

for (( i=0; i<${#pps[@]}; i++ )) 
do
  for (( j=0; j<${#psz[@]}; j++ ))
  do

  ( $SERVER "timeout ${RUNTIME}s bash /root/pktc/pktgen-${pps[$i]}-${psz[$j]}.conf" & )
  sleep 1
  
  timeout $(( $RUNTIME - $GRDTIME ))s \
    unbuffer bmon -p $INTMON1,$INTMON2 -o \
    'format:fmt=$(element:name): Packets Rate: $(attr:rxrate:packets)/$(attr:txrate:packets)\n' \
    > $TMP/tmpfile
  sleep 5
  
  echo "Target packet rate: ${pps[$i]}    Packet size: ${psz[$j]}" >> stats
  grep -o "$INTMON1.*" $TMP/tmpfile | tail -1 >> stats
  grep -o "$INTMON2.*" $TMP/tmpfile | tail -1 >> stats
  echo "" >> stats
  
  done
done



