#!/bin/bash

# This script copies the needed files to create a release of the software

if [ $# -lt "1" ]; then
	echo "Usage: `basename $0` destination_folder [additional rsync parameters]"
	echo "   ex: `basename $0` ../Enchanting-0.0.3"
	echo "   or: `basename $0` 'Installers/Mac OS X/Cellular-0.0.5' --progress --exclude-from=foo"
	exit 1
fi

DIR=$1
shift

echo rsync -a ./Application/ "$DIR" --exclude-from=.bzrignore --exclude-from=omit-from-release "$@"
rsync -a ./Application/ "$DIR" --exclude-from=.bzrignore --exclude-from=omit-from-release $@
cp Application/Cellular.image "$DIR/Cellular.image"