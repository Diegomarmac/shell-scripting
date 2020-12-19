#!/usr/bin/env python
# Script para obtener informacion del sistema
import subprocess

# Comando 1
def uname_func():
    uname     = "uname"
    uname_arg = "-a"
    print ("Obteniendo informacion del sistema con el comando %s \n" %)
    subprocess.call([uname, uname_arg])

# Comando 2
def disk_func():
    diskspace = "df"
    diskspace_arg = "-h"
    print ("Obteniendo espacio en disco con el comando %s \n" % diskspace)
    subprocess.call([diskspace, diskspace_arg])

# Funcion Main que llama a las demas funciones
def main():
    uname_func()
    disk_func()

main()
