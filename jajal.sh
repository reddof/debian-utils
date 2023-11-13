#!/bin/bash

FN_DEBOOTSTRAP=$(pacman -Qsq debootstrap)

if [ "$FN_DEBOOTSTRAP" = "debootstrap" ] ;
    then
        echo "debootstrap terinstall"
    else
        echo "debootstrap tidak terinstall"
fi
