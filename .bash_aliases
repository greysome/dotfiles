#!/bin/bash
alias pi="sudo pacman -S"
alias pd="sudo pacman -Rs"
alias pq="pacman -Ss"
alias y="yaourt"

alias spi="sudo pip install"
alias spu="sudo pip uninstall"
alias sp3i="sudo pip3 install"
alias sp3u="sudo pip3 uninstall"

alias md="mkdir"
alias rd="rmdir"

alias src=". ~/.bashrc"
alias permall="sudo chmod 755"

alias org2docx="python3 ~/bin/org2docx.py" 

function r() {
    make
    $1
}

function v() {
    make clean
    make debug
    valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes $1
}

function mdc() {
    mkdir $1 && cd $1
}

function sync() {
    rclone sync ~ remote: --include "$1/**" -v
}
