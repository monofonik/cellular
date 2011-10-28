#!/bin/bash
#
# Builds a .tar.bz2 file for Enchanting,
# suitable for distributing for Linux computers

if [ $# -ne "1" ]; then
	echo "Usage: `basename $0` version"
	echo "   ex: `basename $0` Enchanting-0.0.3"
	exit 1
fi

mkdir $1
pushd ../..
pwd
bash copyforrelease.sh "Installers/Linux/$1/Enchanting" --verbose --exclude-from Installers/Linux/omit-from-linux-release
popd

tar cjf $1.tar.bz2 $1/Enchanting/

