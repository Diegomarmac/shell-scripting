#!/usr/bin/env python

# Script para obtener informacion del sistema
import subprocess

# Comando 1
uname     = "uname"
uname_arg = "-a"

print ("Se uso el comando %s" % uname)
subprocess.call([uname, uname_arg])

# Comando 2
diskspace     = "df"
diskspace_arg = "-h"

print ("Se uso el comando %s" % diskspace)
subprocess.call([diskspace, diskspace_arg])
