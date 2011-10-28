#!/bin/bash
#
# Builds a .dmg file for Cellular,
# suitable for distributing for OS X computers

if [ $# -ne "1" ]; then
	echo "Usage: `basename $0` version"
	echo "   ex: `basename $0` Cellular-0.0.3"
	exit 1
fi

mkdir $1
pushd ../..
pwd
bash copyforrelease.sh "Installers/MacOSX/$1/Cellular" --verbose --exclude-from Installers/MacOSX/omit-from-osx-release
popd

hdiutil create "$1.dmg" -srcfolder "$1/" -ov

