#!/usr/bin/env bash
# SCript para obtener informacion del sistema

# Comando 1
function uname_func(){
    UNAME="uname -a"
    printf "Obteniendo informacion del sistema con el comando $UNAME \n \n"
    $UNAME
}

# Comando 2
function disk_func(){
    DISKSPACE="df -h"
    printf "Obteniendo espacio en disco con el comando $DISKSPACE \n \n"
    $DISKSPACE
}

# Funcion main
function main(){
    uname_func
    disk_func
}

main
