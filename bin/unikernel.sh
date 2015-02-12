#!/bin/bash

# TODO: assuming maximum of 1 input parameter. no comparison in this revision
set -e

DIR=$( cd "$( dirname '${BASH_SOURCE[0]}' )" && pwd )
source $DIR/init.sh

PACKAGES="mirage tcpip"

opam init -y
eval `opam config env`
opam install $PACKAGES -y

case $1 in
  "mirage-net-xen" )
    rm -rf $NETDIR $APPDIR
    
    # clone mirage-net-xen and pin
    git clone $(cat $DIR/../cfg/NET-XEN.repo) $NETDIR
  
    pushd $NETDIR
    
    if [ $# -ne 0 ]; then
      echo -e "${WRN} No revision number supplied. Latest revision will be considered."
    else
      git reset --hard $2
    fi
    
    opam pin add mirage-net-xen . -y
    popd
      
    # clone application and build
    git clone https://github.com/mirage/mirage-skeleton $APPDIR/tmp
    
    sed \
  	  -e "s/@INT1@/$UINT1/g" \
  	  -e "s/@INT2@/$UINT2/g" \
  	  -e "s/@BRG1@/$UBRG1/g" \
  	  -e "s/@BRG2@/$UBRG2/g" -- $DIR/../cfg/UVIF > $APPDIR/UVIF
    
    mv $APPDIR/tmp/netif-forward/* $APPDIR
    pushd $APPDIR

    env NET=direct mirage config --xen
    sed -i \
      -e "s/^# disk.*$/disk = [ '\/dev\/loop0,,xvda' ]/g" \
      -e "s/^# vif.*$/$(cat $APPDIR/UVIF)/g" \
     -- $UNIKERNEL.xl

    echo -e "\non_poweroff = 'destroy'\non_reboot   = 'restart'\non_crash    = 'restart'" >> $UNIKERNEL.xl
    
    make
    popd
    ;;

  *)
    echo -e "${ERR} library '$1' is not supported"
esac
