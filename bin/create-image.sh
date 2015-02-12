#!/bin/bash

DIST="trusty" # ubuntu 14.04

# TODO: remove comment for the release
# rm -rf $HOMEDIR/domains/$SERVERNAME

if [ ! -d $HOMEDIR/domains/$SERVERNAME ]; then
  mkdir $HOMEDIR/domains/$SERVERNAME

  sudo xen-create-image --force --verbose --password=$PASSWORD \
    --output=$HOMEDIR/domains/$SERVERNAME --dir=$HOMEDIR \
    --hostname=$SERVERNAME --dist=$DIST \
    --initrd=/boot/initrd.img-`uname -r` \
    --kernel=/boot/vmlinuz-`uname -r`
    
    #TODO: still requests password
fi

# replace vif in config file
IFC=$(sed \
  	  -e "s/@GENIP@/$GENIP/g" \
  	  -e "s/@GENBR@/$GENBR/g" \
  	  -e "s/@GENNAME@/$GENNAME/g" \
  	  -e "s/@XENBR@/$XENBR/g" \
  	  -e "s/@CONF@/$CONFIF/g" -- $DIR/../cfg/VIF)

sed -i "s/^vif.*$/$IFC/g" "$HOMEDIR/domains/$SERVERNAME/$SERVERNAME.cfg"

# TODO: make sure that server image is not running

# mount the image
MNT_LOC=$TMP/m
[ -d $MNT_LOC ] && [[ "$(umount $MNT_LOC)" -eq 0 ]]
[ ! -d $MNT_LOC ] && mkdir $MNT_LOC

# network and ssh config
mount -o loop $HOMEDIR/domains/$SERVERNAME/disk.img $MNT_LOC
cp $DIR/../cfg/interfaces $MNT_LOC/etc/network/interfaces
sed -i "s/^PermitRootLogin without-password/PermitRootLogin yes/g" "$MNT_LOC/etc/ssh/sshd_config"
echo "UseDNS no" >> $MNT_LOC/etc/ssh/sshd_config # makes DNS connection time very short

# download pktgen, build and copy
rm -f $TMP/3.11.0-netfilter.tar.gz*
wget -P $TMP -- https://github.com/danieltt/pktgen/archive/3.11.0-netfilter.tar.gz
tar -xf $TMP/3.11.0-netfilter.tar.gz --no-same-owner -C $TMP
pushd $TMP/pktgen-3.11.0-netfilter
make
popd
cp -r $TMP/pktgen-3.11.0-netfilter $MNT_LOC/root

# create pktgen configs
source $DIR/create-pktgen-conf.sh
cp -r $TMP/pktc $MNT_LOC/root

umount $MNT_LOC


