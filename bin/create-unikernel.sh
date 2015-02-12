#!/bin/bash

if [ $# -eq 0 ]; then
  echo -e "${ERR} provide library name for performance test"
  exit
fi

add-apt-repository -y ppa:avsm/ppa
apt-get update
apt-get -yf install build-essential m4 ocaml ocaml-native-compilers camlp4-extra opam

sudo -u $USER bash ./unikernel.sh $1 $2
