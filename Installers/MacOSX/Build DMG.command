#!/bin/bash

cd "`dirname \"$0\"`"

echo "Enter the name for the build: (ex. 'Enchanting-0.0.5')"
read NAME

./builddmg.sh $NAME
