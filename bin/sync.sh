#!/bin/sh

prevdir=$PWD

cd ~

for arg in "$@"; do
    filepath="$PWD/$arg"
    if [ -d "$filepath" ]; then
	rclone --include "$1/**" sync ~ remote:
    elif [ -f "$filepath" ]; then
	rclone --include "$1" sync ~ remote:
    else
	echo "cannot sync file $filepath"
    fi
done

cd $prevdir
