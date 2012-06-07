#!/bin/bash
#
# Builds a .dmg for Cellular

if [ $# -ne "1" ]; then
	echo "Usage: `basename $0` version"
	exit 1
fi

TEMPIMG="template.dmg"
TEMPSRC="$TEMPIMG.bz2"
APPSRC="Cellular/"
APPNAME="Cellular"
APPIMG="$APPNAME-$1.dmg"
MOUNTDIR="mount"

bzip2 -dkv $TEMPSRC
mkdir $MOUNTDIR; hdiutil mount -mountpoint $MOUNTDIR $TEMPIMG
rsync -r --delete --exclude='.DS_Store' $APPSRC $MOUNTDIR/$APPNAME
cp ${APPSRC}Icon* $MOUNTDIR/$APPNAME
hdiutil detach $MOUNTDIR
hdiutil convert $TEMPIMG -format UDBZ -o $APPIMG
rm $TEMPIMG; rmdir $MOUNTDIR




