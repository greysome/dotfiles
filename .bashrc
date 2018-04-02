#!/bin/bash
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

shopt -u histappend
shopt -s checkwinsize

export PS1='\w - '

. ~/.bash_aliases
. ~/.bash_secret
