#!/bin/bash
xset +fp ~/.fonts
xset fp rehash
xrdb merge ~/.Xresources
exec emacs
